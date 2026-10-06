import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Catálogo de efectos. Los archivos salen de `tool/gen_sfx.py`
/// (`assets/audio/sfx_<nombre>.wav`): para cambiar un sonido se edita el
/// script y se regenera, nunca se reemplaza el WAV a mano.
enum Sfx {
  tap(0.40, ui: true),
  back(0.40, ui: true),
  toggle(0.40, ui: true),
  errorSoft(0.50, ui: true, file: 'error_soft'),
  coin(0.60),
  coinsMany(0.60, file: 'coins_many'),
  sealStamp(0.75, file: 'seal_stamp'),
  levelUp(0.70, file: 'level_up'),
  rankUp(0.75, file: 'rank_up'),
  achievement(0.65),
  weeklyComplete(0.70, file: 'weekly_complete'),
  eventArrive(0.65, file: 'event_arrive'),
  pageUnroll(0.50, file: 'page_unroll'),
  success(0.70),
  partial(0.70),
  fail(0.70),
  delivery(0.75);

  const Sfx(this.volume, {this.ui = false, String? file}) : _file = file;

  final double volume;

  /// Los sonidos de interfaz van por su propio canal: un toque nunca corta
  /// el sonido de un resultado o una entrega que todavía está sonando.
  final bool ui;
  final String? _file;

  String get asset => 'audio/sfx_${_file ?? name}.wav';
}

/// Reproduce los efectos con un pool chico de players precargados.
/// Falla en silencio si el asset no carga: el audio nunca tumba la UX.
class SfxService {
  SfxService();

  static const _poolSize = 4;

  final List<AudioPlayer> _pool =
      List.generate(_poolSize, (_) => AudioPlayer());
  final AudioPlayer _uiPlayer = AudioPlayer();
  int _next = 0;
  bool _enabled = true;
  bool _ready = false;

  Future<void> init() async {
    try {
      // Ambient en iOS: respeta el switch de silencio y no corta la música
      // que el jugador tenga sonando.
      await AudioPlayer.global
          .setAudioContext(AudioContextConfig(respectSilence: true).build());
      for (final p in [..._pool, _uiPlayer]) {
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setPlayerMode(PlayerMode.lowLatency);
      }
      await AudioCache.instance
          .loadAll([for (final s in Sfx.values) s.asset]);
      _ready = true;
    } catch (e) {
      debugPrint('SfxService init failed: $e');
      _ready = false;
    }
  }

  void setEnabled(bool enabled) => _enabled = enabled;

  Future<void> play(Sfx sfx) async {
    if (!_enabled || !_ready) return;
    final player = sfx.ui ? _uiPlayer : _pool[_next++ % _poolSize];
    try {
      await player.stop();
      await player.play(AssetSource(sfx.asset), volume: sfx.volume);
    } catch (e) {
      debugPrint('Sfx play failed (${sfx.asset}): $e');
    }
  }

  Future<void> dispose() async {
    for (final p in [..._pool, _uiPlayer]) {
      await p.dispose();
    }
  }
}
