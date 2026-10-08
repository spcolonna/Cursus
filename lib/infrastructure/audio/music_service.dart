import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Temas de música. Los archivos (provisorios) salen de `tool/gen_music.py`
/// (`assets/audio/music_<nombre>.m4a`); la hoja de cues para reemplazarlos
/// por música real está en docs/AUDIO.md.
enum MusicTrack {
  homeDawn('home_dawn'),
  homeDay('home_day'),
  homeDusk('home_dusk'),
  homeNight('home_night'),
  travel('travel'),
  arcClaudius('arc_claudius'),
  arcLucius('arc_lucius');

  const MusicTrack(this.file);
  final String file;
  String get asset => 'audio/music_$file.m4a';

  /// Tema propio de un arco de historia; null si el arco no tiene.
  static MusicTrack? forArc(String? arcId) => switch (arcId) {
        'arc_claudius' => arcClaudius,
        'arc_lucius' => arcLucius,
        _ => null,
      };
}

/// Una voz en loop. Abstracta para poder probar el servicio sin audio real.
abstract class MusicChannel {
  Future<void> play(String asset, double volume);
  Future<void> setVolume(double volume);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
}

class AudioPlayerChannel implements MusicChannel {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> play(String asset, double volume) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(asset), volume: volume);
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> resume() => _player.resume();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> dispose() => _player.dispose();
}

class _Voice {
  final MusicChannel channel;
  MusicTrack? track;
  double gain = 0, target = 0;

  /// Ya se le dio play (si el tema entró en segundo plano, todavía no).
  bool started = false;
  _Voice(this.channel);
}

/// La música de fondo: un tema en loop por vez, con fundido cruzado al
/// cambiar, ducking (−8 dB) mientras el jugador decide o festeja, y pausa
/// en segundo plano. Como los SFX, falla en silencio: nunca tumba la UX.
///
/// Quién pide qué tema lo decide `MusicDirector` (presentación); acá solo se
/// obedece respetando el ajuste del jugador.
class MusicService {
  MusicService({
    MusicChannel Function()? channelFactory,
    this.crossfade = const Duration(milliseconds: 1500),
    this.duckFade = const Duration(milliseconds: 400),
  }) : _voices = List.generate(
            2, (_) => _Voice((channelFactory ?? AudioPlayerChannel.new)()));

  /// −8 dB.
  static const duckGain = 0.398;
  static const defaultVolume = 0.6;
  static const _tick = Duration(milliseconds: 50);

  final Duration crossfade, duckFade;
  final List<_Voice> _voices;
  int _front = 0;
  Timer? _timer;

  bool _enabled = true;
  double _volume = defaultVolume;
  bool _background = false;
  MusicTrack? _wanted;
  final Set<String> _ducks = {};

  bool get enabled => _enabled;
  double get volume => _volume;
  MusicTrack? get wanted => _wanted;
  bool get ducked => _ducks.isNotEmpty;

  /// El tema que suena (o está entrando); null si hay silencio.
  MusicTrack? get playing {
    final v = _voices[_front];
    return v.target > 0 ? v.track : null;
  }

  double get _level => _volume * (ducked ? duckGain : 1);

  void setEnabled(bool enabled) {
    if (_enabled == enabled) return;
    _enabled = enabled;
    _apply();
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _apply(fade: Duration.zero);
  }

  /// Pide un tema (null = silencio). Repetir el mismo no lo reinicia.
  void play(MusicTrack? track) {
    if (_wanted == track) return;
    _wanted = track;
    if (kDebugMode) debugPrint('Música: ${track?.file ?? 'silencio'}');
    _apply();
  }

  /// Baja la música mientras haya al menos un motivo activo.
  void duck(String reason, bool on) {
    final changed = on ? _ducks.add(reason) : _ducks.remove(reason);
    if (changed) _apply(fade: duckFade);
  }

  void pauseForBackground() {
    if (_background) return;
    _background = true;
    _timer?.cancel();
    _timer = null;
    for (final v in _voices) {
      if (v.track != null) _guard(v.channel.pause);
    }
  }

  void resumeFromBackground() {
    if (!_background) return;
    _background = false;
    for (final v in _voices) {
      if (v.track == null) continue;
      if (v.started) {
        _guard(v.channel.resume);
      } else {
        _start(v);
      }
    }
    _apply();
  }

  /// Ajusta voces y objetivos según lo pedido, y arranca el fundido.
  void _apply({Duration? fade}) {
    final want = _enabled ? _wanted : null;
    final front = _voices[_front];
    if (want != front.track) {
      // Tema nuevo: entra por la otra voz y la actual se apaga.
      front.target = 0;
      if (want != null) {
        _front = 1 - _front;
        final next = _voices[_front];
        next
          ..track = want
          ..gain = 0
          ..target = _level
          ..started = false;
        if (!_background) _start(next);
      }
    } else if (want != null) {
      front.target = _level;
    }
    if (_background) return;
    _fade(fade ?? crossfade);
  }

  void _start(_Voice v) {
    v.started = true;
    final asset = v.track!.asset;
    _guard(() => v.channel.play(asset, v.gain));
  }

  void _fade(Duration fade) {
    _timer?.cancel();
    _timer = null;
    if (fade <= Duration.zero) {
      for (final v in _voices) {
        _step(v, 1.0);
      }
      return;
    }
    final perTick = _tick.inMicroseconds / fade.inMicroseconds;
    _timer = Timer.periodic(_tick, (t) {
      var busy = false;
      for (final v in _voices) {
        busy |= _step(v, perTick);
      }
      if (!busy) {
        t.cancel();
        if (identical(_timer, t)) _timer = null;
      }
    });
  }

  /// Acerca una voz a su objetivo; true si todavía le falta.
  bool _step(_Voice v, double maxDelta) {
    if (v.track == null) return false;
    final diff = v.target - v.gain;
    final reached = diff.abs() <= maxDelta;
    v.gain = reached ? v.target : v.gain + maxDelta * diff.sign;
    _guard(() => v.channel.setVolume(v.gain));
    if (reached && v.target == 0) {
      v
        ..track = null
        ..started = false;
      _guard(v.channel.stop);
    }
    return !reached;
  }

  void _guard(Future<void> Function() action) {
    action().catchError((Object e) => debugPrint('Music: $e'));
  }

  Future<void> dispose() async {
    _timer?.cancel();
    for (final v in _voices) {
      await v.channel.dispose();
    }
  }
}
