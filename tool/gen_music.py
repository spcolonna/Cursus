#!/usr/bin/env python3
"""Genera la música PROVISORIA de Cursus (síntesis con stdlib).

Uso:  python3 tool/gen_music.py [tema ...]   → assets/audio/music_<tema>.m4a

TEMPORAL: son placeholders hasta tener música real. docs/AUDIO.md tiene la
hoja de cues para reemplazarlos archivo por archivo sin tocar código.

Instrumentos: lira (Karplus-Strong, la misma de los SFX), aulos (doble flauta
de caña: un tubo hace el bordón y el otro la melodía) y tambor de marco. Cada
tema abre con el motivo de Cursus (D-A-E por quintas, transportado al tono).

Sale en mono, 32 kHz, codificado a AAC 64 kbps con `afconvert` (viene con
macOS). El nivel apunta a ~−16 LUFS (RMS −18 dBFS, picos limitados a −1 dBFS);
es una aproximación: medilo con una herramienta real al reemplazar. Cada tema
cierra con un respiro (fundido) para que la vuelta del loop no haga clic.
"""
import array
import math
import os
import random
import shutil
import subprocess
import sys
import tempfile
import wave

sys.path.insert(0, os.path.dirname(__file__))
import gen_sfx as fx  # noqa: E402  (lira, tambor y utilidades compartidas)

SR = fx.SR = 32000  # la música no necesita 44,1 kHz y así pesa la mitad
OUT = fx.OUT

MODES = {
    'dorian': [0, 2, 3, 5, 7, 9, 10],
    'phrygian': [0, 1, 3, 5, 7, 8, 10],
    'mixolydian': [0, 2, 4, 5, 7, 9, 10],
    'aeolian': [0, 2, 3, 5, 7, 8, 10],
}

# El motivo en grados de la escala: tónica, quinta y la quinta de la quinta.
MOTIF = [7, 11, 15]

# ─── Los temas ───
# drum: patrón por compás, lista de (tiempo, golpe). prog: acorde (grado) cada
# 2 compases. rhythm: posiciones de la melodía en un compás, se eligen al azar.
TRACKS = {
    # Home, uno por cielo (SkyPhase)
    'home_dawn': dict(root='D3', mode='dorian', bpm=66, bars=20, seed=11,
                      prog=[0, 3, 0, 4, 2, 3, 0, 0],
                      rhythm=[[0, 2], [0, 1.5, 3], [0, 3], [0, 2, 3]],
                      drum=None, lead='lyre', drone=0.5, gain_lead=0.8),
    'home_day': dict(root='E3', mode='dorian', bpm=88, bars=28, seed=12,
                     prog=[0, 3, 4, 0, 5, 3, 4, 0],
                     rhythm=[[0, 1, 2, 3], [0, 1.5, 2, 3], [0, 0.5, 1, 2], [0, 2, 2.5, 3]],
                     drum=[(0, 'dum'), (2, 'tak'), (3, 'tak')], lead='lyre',
                     drone=0.35, gain_lead=0.85),
    'home_dusk': dict(root='A2', mode='aeolian', bpm=72, bars=22, seed=13,
                      prog=[0, 5, 3, 4, 0, 5, 6, 4],
                      rhythm=[[0, 2], [0, 1.5, 3], [0, 1, 2], [0, 3]],
                      drum=[(0, 'dum')], lead='both', drone=0.5, gain_lead=0.8),
    'home_night': dict(root='D3', mode='dorian', bpm=54, bars=16, seed=14,
                       prog=[0, 0, 3, 0, 4, 3, 0, 0],
                       rhythm=[[0], [0, 2], [2], [0, 3]],
                       drum=None, lead='lyre', drone=0.6, gain_lead=0.6,
                       stars=True),
    # En misión: el camino
    'travel': dict(root='D3', mode='dorian', bpm=96, bars=30, seed=15,
                   prog=[0, 4, 3, 0, 0, 6, 3, 4],
                   rhythm=[[0, 1, 2, 3], [0, 0.5, 1, 2, 3], [0, 1.5, 2, 3], [0, 1, 2, 2.5, 3]],
                   drum=[(0, 'dum'), (1, 'tak'), (2, 'dum'), (2.5, 'tak'), (3, 'tak')],
                   lead='lyre', drone=0.4, gain_lead=0.85),
    # Capítulos de historia, uno por arco
    'arc_claudius': dict(root='E3', mode='phrygian', bpm=60, bars=18, seed=16,
                         prog=[0, 1, 0, 6, 0, 1, 3, 0],
                         rhythm=[[0, 2], [0, 1, 2], [0], [0, 3]],
                         drum=[(0, 'dum')], drum_every=2, lead='aulos',
                         drone=0.55, gain_lead=0.7, ostinato=True),
    'arc_lucius': dict(root='G3', mode='mixolydian', bpm=104, bars=32, seed=17,
                       prog=[0, 3, 4, 0, 6, 3, 4, 4],
                       rhythm=[[0, 1, 1.5, 2, 3], [0, 0.5, 1, 2, 3], [0, 1, 2, 2.5, 3.5]],
                       drum=[(0, 'dum'), (1, 'tak'), (1.5, 'jingle'), (2, 'dum'),
                             (3, 'tak'), (3.5, 'jingle')],
                       lead='lyre', drone=0.3, gain_lead=0.9),
}


def degree(root_hz, mode, d):
    octave, i = divmod(d, 7)
    return root_hz * 2 ** ((MODES[mode][i] + 12 * octave) / 12)


# ─── Instrumentos ───
_AULOS_TABLE = None


def _aulos_table():
    """Un ciclo de caña doble: mucho impar, algo de par."""
    global _AULOS_TABLE
    if _AULOS_TABLE is None:
        harm = [(1, 1.0), (2, 0.3), (3, 0.55), (4, 0.12), (5, 0.3), (7, 0.14), (9, 0.06)]
        n = 2048
        _AULOS_TABLE = [sum(g * math.sin(2 * math.pi * h * i / n) for h, g in harm)
                        for i in range(n)]
    return _AULOS_TABLE


def aulos(freq, dur, attack=0.4, release=0.7, vibrato=4.8, depth=0.004, breath=0.05):
    table = _aulos_table()
    size = len(table)
    n = int(dur * SR)
    a, r = max(1, int(attack * SR)), max(1, int(release * SR))
    out = [0.0] * n
    phase = 0.0
    breath_y = 0.0
    k = 1 - math.exp(-2 * math.pi * 1500 / SR)
    for i in range(n):
        t = i / SR
        f = freq * (1 + depth * math.sin(2 * math.pi * vibrato * t) * min(1.0, t))
        phase = (phase + f * size / SR) % size
        breath_y += k * (fx.rng.uniform(-1, 1) - breath_y)
        if i < a:
            g = 0.5 - 0.5 * math.cos(math.pi * i / a)
        elif i > n - r:
            g = 0.5 - 0.5 * math.cos(math.pi * (n - i) / r)
        else:
            g = 1.0
        out[i] = g * (table[int(phase)] * 0.45 + breath_y * breath)
    return fx.lowpass(out, 2600)


def drum(kind):
    if kind == 'dum':  # el parche al centro
        buf = fx.thump(95, 58, 0.4, 1.0)
        return fx.mix(buf, fx.noise_hit(0.03, 900, 0.4, 7))
    if kind == 'tak':  # el borde, con los dedos
        buf = fx.noise_hit(0.03, 3800, 0.5, 9)
        return fx.mix(buf, fx.thump(330, 250, 0.07, 0.35))
    # 'jingle': las sonajas del tambor
    buf = []
    for j in range(3):
        fx.mix(buf, fx.coin(fx.rng.uniform(5200, 6800), 0.12), at=j * 0.012, gain=0.25)
    return buf


# ─── Composición ───
def compose(spec):
    rnd = random.Random(spec['seed'])
    fx.rng.seed(spec['seed'] * 101)
    root = fx.note(spec['root'])
    mode = spec['mode']
    beat = 60 / spec['bpm']
    bar = 4 * beat
    length = spec['bars'] * bar
    buf = [0.0] * int((length + 0.5) * SR)

    def put(src, at, gain):
        fx.mix(buf, src, at=at, gain=gain)

    # Bordón: el tubo grave del aulos, de a 4 compases que se pisan.
    if spec['drone']:
        for b in range(0, spec['bars'], 4):
            span = min(4, spec['bars'] - b) * bar + 1.2
            put(aulos(root / 2, span, attack=1.2, release=1.4, breath=0.03),
                b * bar, spec['drone'] * 0.55)
            put(aulos(degree(root / 2, mode, 4), span, attack=1.5, release=1.4,
                      breath=0.02), b * bar, spec['drone'] * 0.25)

    # Acordes: la lira rasgueada cada 2 compases.
    prog = spec['prog']
    for b in range(0, spec['bars'], 2):
        c = prog[(b // 2) % len(prog)]
        for k, d in enumerate([c, c + 2, c + 4]):
            put(fx.lyre(degree(root, mode, d), 2.4, bright=0.3, decay=0.995),
                b * bar + k * 0.035, 0.28)
        if spec.get('ostinato'):  # un pulso grave que insiste
            for q in range(8):
                put(fx.lyre(degree(root / 2, mode, c), 0.8, bright=0.25),
                    b * bar + q * beat, 0.22)

    # Melodía: frases de 4 compases. A abre con el motivo; B contesta.
    def phrase(start_bar, motif):
        notes = []
        cur = 9
        for b in range(4):
            chord = prog[((start_bar + b) // 2) % len(prog)]
            tones = [chord + 7, chord + 9, chord + 11]
            for pos in rnd.choice(spec['rhythm']):
                if motif and b == 0 and pos <= 1.5 and len(notes) < 3:
                    d = MOTIF[len(notes)]
                elif pos in (0, 2):
                    d = min(tones, key=lambda t: abs(t - cur))
                else:
                    d = cur + rnd.choice([-2, -1, -1, 1, 1, 2])
                d = max(5, min(15, d))
                notes.append((b, pos, d))
                cur = d
        return notes

    phrase_a = phrase(0, True)
    phrase_b = phrase(4, False)
    lead = spec['lead']
    for p, start in enumerate(range(0, spec['bars'], 4)):
        notes = phrase_a if p % 2 == 0 else phrase_b
        for b, pos, d in notes:
            if start + b >= spec['bars']:
                continue
            at = (start + b) * bar + pos * beat
            f = degree(root, mode, d)
            if lead in ('lyre', 'both'):
                put(fx.lyre(f, 1.8, bright=0.55, decay=0.995), at, spec['gain_lead'] * 0.5)
            if lead == 'aulos' or (lead == 'both' and pos == 0):
                put(aulos(f, beat * 1.8, attack=0.08, release=0.3), at, spec['gain_lead'] * 0.4)

    # Estrellas: armónicos altos sueltos, de noche.
    if spec.get('stars'):
        for _ in range(spec['bars']):
            at = rnd.uniform(0, length - 2)
            put(fx.lyre(degree(root * 4, mode, rnd.choice([0, 2, 4])), 2.0, bright=0.8),
                at, 0.12)

    # Tambor de marco.
    if spec['drum']:
        every = spec.get('drum_every', 1)
        for b in range(0, spec['bars'], every):
            for pos, kind in spec['drum']:
                put(drum(kind), b * bar + pos * beat,
                    0.5 * (1.0 if kind == 'dum' else 0.7) * rnd.uniform(0.85, 1.0))

    buf = buf[:int(length * SR)]
    # Respiro al final y entrada suave: la vuelta del loop no hace clic.
    fade_in, fade_out = int(0.25 * SR), int(1.5 * SR)
    for i in range(fade_in):
        buf[i] *= i / fade_in
    for i in range(fade_out):
        buf[-1 - i] *= i / fade_out
    return buf


def master(buf):
    rms = math.sqrt(sum(x * x for x in buf) / len(buf)) or 1.0
    gain = 10 ** (-18 / 20) / rms
    ceiling = 10 ** (-1 / 20)
    return [math.tanh(x * gain / ceiling) * ceiling for x in buf]


def encode(name, buf):
    path = os.path.join(OUT, f'music_{name}.m4a')
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, f'{name}.wav')
        with wave.open(wav, 'wb') as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(array.array(
                'h', (int(max(-1.0, min(1.0, x)) * 32767) for x in buf)).tobytes())
        subprocess.run(['afconvert', '-f', 'm4af', '-d', 'aac', '-b', '64000', wav, path],
                       check=True)
    return path


def main():
    if not shutil.which('afconvert'):
        sys.exit('Hace falta afconvert (macOS) para codificar a AAC.')
    names = sys.argv[1:] or list(TRACKS)
    for name in names:
        buf = master(compose(TRACKS[name]))
        path = encode(name, buf)
        kb = os.path.getsize(path) // 1024
        print(f'{os.path.relpath(path)}  {len(buf) / SR:.1f}s  {kb} KB')


if __name__ == '__main__':
    main()
