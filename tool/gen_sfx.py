#!/usr/bin/env python3
"""Genera los efectos de sonido de Cursus (solo stdlib).

Uso:  python3 tool/gen_sfx.py            → escribe assets/audio/sfx_*.wav

Paleta sonora: lira (Karplus-Strong), bucina (metal con vibrato), golpes de
ruido filtrado (madera, cera, pergamino) y monedas (parciales inarmónicos).
Todo sale en mono, 44,1 kHz, 16 bits, normalizado a −3 dBFS. El azar usa una
semilla fija: correr el script dos veces da archivos idénticos.
"""
import math
import os
import random
import struct
import wave

SR = 44100
PEAK = 10 ** (-3 / 20)  # −3 dBFS
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')

rng = random.Random(1950)

# ─── Notas ───
A4 = 440.0


def note(name):
    """'C4', 'G#3', 'Bb2' → Hz."""
    names = {'C': -9, 'D': -7, 'E': -5, 'F': -4, 'G': -2, 'A': 0, 'B': 2}
    semis = names[name[0]]
    rest = name[1:]
    if rest[0] == '#':
        semis += 1
        rest = rest[1:]
    elif rest[0] == 'b':
        semis -= 1
        rest = rest[1:]
    octave = int(rest)
    return A4 * 2 ** ((semis + (octave - 4) * 12) / 12)


# ─── Utilidades ───
def silence(sec):
    return [0.0] * int(sec * SR)


def mix(dst, src, at=0.0, gain=1.0):
    """Suma src dentro de dst a partir del segundo `at` (agranda si hace falta)."""
    start = int(at * SR)
    need = start + len(src)
    if need > len(dst):
        dst.extend([0.0] * (need - len(dst)))
    for i, s in enumerate(src):
        dst[start + i] += s * gain
    return dst


def lowpass(buf, cutoff):
    a = 1 - math.exp(-2 * math.pi * cutoff / SR)
    y = 0.0
    out = []
    for x in buf:
        y += a * (x - y)
        out.append(y)
    return out


def highpass(buf, cutoff):
    low = lowpass(buf, cutoff)
    return [x - l for x, l in zip(buf, low)]


def env_ar(n, attack, release_curve=4.0):
    """Ataque lineal y caída exponencial a lo largo de n muestras."""
    a = max(1, int(attack * SR))
    out = []
    for i in range(n):
        if i < a:
            out.append(i / a)
        else:
            t = (i - a) / max(1, n - a)
            out.append(math.exp(-release_curve * t))
    return out


def apply(buf, env):
    return [x * e for x, e in zip(buf, env)]


def fade_tail(buf, sec=0.01):
    n = min(len(buf), int(sec * SR))
    for i in range(n):
        buf[len(buf) - n + i] *= 1 - i / n
    return buf


# ─── Instrumentos ───
def lyre(freq, dur, bright=0.5, decay=0.996):
    """Cuerda pulsada (Karplus-Strong) con un poco de cuerpo de madera."""
    period = max(2, int(SR / freq))
    burst = [rng.uniform(-1, 1) for _ in range(period)]
    burst = lowpass(burst, 2000 + 6000 * bright)
    line = burst[:]
    out = []
    n = int(dur * SR)
    idx = 0
    for _ in range(n):
        cur = line[idx]
        nxt = line[(idx + 1) % period]
        line[idx] = decay * 0.5 * (cur + nxt)
        out.append(cur)
        idx = (idx + 1) % period
    # Cuerpo: resonancia suave en graves.
    body = lowpass(out, 900)
    out = [0.75 * o + 0.35 * b for o, b in zip(out, body)]
    return fade_tail(out)


def bucina(freq, dur, vibrato=5.5, depth=0.006):
    """Metal romano: diente de sierra filtrado, vibrato y ataque lento."""
    n = int(dur * SR)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = freq * (1 + depth * math.sin(2 * math.pi * vibrato * t) * min(1, t * 4))
        phase += f / SR
        frac = phase % 1.0
        saw = 2 * frac - 1
        # un poco de cuadrada para el "bronce"
        sq = 1.0 if frac < 0.5 else -1.0
        out.append(0.7 * saw + 0.3 * sq)
    out = lowpass(out, 1800)
    out = lowpass(out, 2600)
    a = int(0.06 * SR)
    r = int(0.12 * SR)
    for i in range(n):
        g = 1.0
        if i < a:
            g = i / a
        elif i > n - r:
            g = (n - i) / r
        out[i] *= g
    return out


def coin(freq=2400, dur=0.35):
    """Ping metálico: parciales inarmónicos de una moneda de bronce."""
    ratios = [(1.0, 1.0), (2.76, 0.5), (5.4, 0.25), (8.93, 0.12)]
    n = int(dur * SR)
    out = []
    for i in range(n):
        t = i / SR
        s = 0.0
        for r, g in ratios:
            s += g * math.sin(2 * math.pi * freq * r * t) * math.exp(-t * (6 + 5 * r))
        out.append(s)
    click = noise_hit(0.006, 6000, 0.3)
    return mix(out, click)


def noise_hit(dur, cutoff, gain=1.0, curve=6.0):
    n = int(dur * SR)
    buf = [rng.uniform(-1, 1) for _ in range(n)]
    buf = lowpass(buf, cutoff)
    return [x * gain for x in apply(buf, env_ar(n, 0.001, curve))]


def thump(freq_from, freq_to, dur, gain=1.0):
    """Golpe grave con caída de tono (tambor, sello sobre la mesa)."""
    n = int(dur * SR)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / n
        f = freq_from * (freq_to / freq_from) ** t
        phase += f / SR
        out.append(math.sin(2 * math.pi * phase) * math.exp(-5 * t) * gain)
    return out


def sweep_noise(dur, f_from, f_to, gain=1.0):
    """Ruido con filtro que se mueve: pergamino que se desenrolla."""
    n = int(dur * SR)
    out = []
    y = 0.0
    for i in range(n):
        t = i / n
        cutoff = f_from + (f_to - f_from) * t
        a = 1 - math.exp(-2 * math.pi * cutoff / SR)
        x = rng.uniform(-1, 1)
        # crujidos sueltos
        if rng.random() < 0.0015:
            x *= 6
        y += a * (x - y)
        env = math.sin(math.pi * t) ** 0.6
        out.append(y * env * gain)
    return highpass(out, 300)


def arpeggio(notes, step, dur, bright=0.5, gain=1.0):
    buf = []
    for k, nm in enumerate(notes):
        mix(buf, lyre(note(nm), dur, bright), at=k * step, gain=gain)
    return buf


# ─── Sonidos ───
def sfx_tap():
    buf = noise_hit(0.025, 3500, 0.6, 9)
    mix(buf, apply([math.sin(2 * math.pi * 1100 * i / SR) for i in range(int(0.04 * SR))],
                   env_ar(int(0.04 * SR), 0.001, 10)), gain=0.5)
    return buf


def sfx_back():
    buf = noise_hit(0.03, 2200, 0.5, 9)
    mix(buf, apply([math.sin(2 * math.pi * 700 * i / SR) for i in range(int(0.05 * SR))],
                   env_ar(int(0.05 * SR), 0.001, 9)), gain=0.5)
    mix(buf, apply([math.sin(2 * math.pi * 520 * i / SR) for i in range(int(0.06 * SR))],
                   env_ar(int(0.06 * SR), 0.001, 9)), at=0.045, gain=0.4)
    return buf


def sfx_toggle():
    buf = noise_hit(0.015, 5000, 0.5, 10)
    mix(buf, noise_hit(0.02, 2500, 0.4, 10), at=0.035)
    return buf


def sfx_error_soft():
    return arpeggio(['E3', 'C3'], 0.11, 0.45, bright=0.2)


def sfx_coin():
    buf = coin(2350, 0.3)
    mix(buf, coin(3150, 0.35), at=0.06, gain=0.7)
    return buf


def sfx_coins_many():
    buf = []
    t = 0.0
    for _ in range(9):
        mix(buf, coin(rng.uniform(2000, 3400), 0.3), at=t, gain=rng.uniform(0.5, 0.9))
        t += rng.uniform(0.035, 0.08)
    return buf


def sfx_seal_stamp():
    buf = thump(140, 55, 0.28, 1.0)
    mix(buf, noise_hit(0.05, 1800, 0.7, 7))
    # la cera que se aplasta
    mix(buf, lowpass(noise_hit(0.12, 900, 0.35, 3), 600), at=0.02)
    return buf


def sfx_level_up():
    buf = arpeggio(['C4', 'E4', 'G4', 'C5'], 0.075, 0.9, bright=0.6)
    mix(buf, coin(4200, 0.5), at=0.3, gain=0.3)
    return buf


def sfx_rank_up():
    buf = []
    mix(buf, bucina(note('G3'), 0.22), at=0.0)
    mix(buf, bucina(note('C4'), 0.22), at=0.24)
    mix(buf, bucina(note('E4'), 0.22), at=0.48)
    mix(buf, bucina(note('G4'), 0.9), at=0.72)
    mix(buf, bucina(note('C4'), 0.9), at=0.72, gain=0.6)
    mix(buf, thump(110, 50, 0.35), at=0.72, gain=0.8)
    mix(buf, arpeggio(['C5', 'E5', 'G5', 'C6'], 0.05, 0.8, bright=0.7), at=0.75, gain=0.35)
    return buf


def sfx_achievement():
    buf = arpeggio(['G4', 'C5', 'E5', 'G5'], 0.06, 1.0, bright=0.7)
    for k in range(4):
        mix(buf, coin(3600 + k * 300, 0.4), at=0.25 + k * 0.05, gain=0.25)
    return buf


def sfx_weekly_complete():
    buf = thump(120, 55, 0.4, 0.9)
    # rasguido de acorde
    for k, nm in enumerate(['C3', 'G3', 'C4', 'E4', 'G4']):
        mix(buf, lyre(note(nm), 1.1, 0.5), at=0.02 + k * 0.025, gain=0.55)
    mix(buf, bucina(note('C4'), 0.5), at=0.12, gain=0.35)
    return buf


def sfx_event_arrive():
    buf = arpeggio(['A4', 'E5'], 0.12, 0.6, bright=0.6)
    mix(buf, thump(160, 80, 0.2, 0.6))
    mix(buf, thump(160, 80, 0.2, 0.5), at=0.12)
    return buf


def sfx_page_unroll():
    return sweep_noise(0.45, 900, 4500, 0.9)


def sfx_success():
    return arpeggio(['C4', 'E4', 'G4'], 0.09, 0.8, bright=0.6)


def sfx_partial():
    return arpeggio(['D4', 'G4'], 0.12, 0.7, bright=0.4)


def sfx_fail():
    buf = arpeggio(['E3', 'C3', 'A2'], 0.13, 0.7, bright=0.25)
    mix(buf, thump(90, 40, 0.35, 0.8), at=0.26)
    return buf


def sfx_delivery():
    buf = []
    mix(buf, bucina(note('C4'), 0.18))
    mix(buf, bucina(note('G4'), 0.55), at=0.2)
    mix(buf, sfx_coin(), at=0.55, gain=0.6)
    return buf


SOUNDS = {
    'tap': sfx_tap,
    'back': sfx_back,
    'toggle': sfx_toggle,
    'error_soft': sfx_error_soft,
    'coin': sfx_coin,
    'coins_many': sfx_coins_many,
    'seal_stamp': sfx_seal_stamp,
    'level_up': sfx_level_up,
    'rank_up': sfx_rank_up,
    'achievement': sfx_achievement,
    'weekly_complete': sfx_weekly_complete,
    'event_arrive': sfx_event_arrive,
    'page_unroll': sfx_page_unroll,
    'success': sfx_success,
    'partial': sfx_partial,
    'fail': sfx_fail,
    'delivery': sfx_delivery,
}


def write(name, buf):
    buf = fade_tail(buf, 0.02)
    peak = max(abs(x) for x in buf) or 1.0
    scale = PEAK / peak
    path = os.path.join(OUT, f'sfx_{name}.wav')
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1.0, min(1.0, x * scale)) * 32767)) for x in buf))
    return path, len(buf) / SR


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, fn in SOUNDS.items():
        path, secs = write(name, fn())
        print(f'{os.path.relpath(path)}  {secs:.2f}s')


if __name__ == '__main__':
    main()
