import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// SFX mínimos del loop: outcomes + entrega + tap.
/// Fallar en silencio si el asset no carga — nunca tumba la UX.
class SfxService {
  SfxService();

  final AudioPlayer _player = AudioPlayer();
  /// Los taps van por otro canal: si no, cada toque cortaba el sonido de un
  /// resultado o una entrega que todavía estaba sonando.
  final AudioPlayer _uiPlayer = AudioPlayer();
  bool _enabled = true;
  bool _ready = false;

  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(0.7);
      await _uiPlayer.setReleaseMode(ReleaseMode.stop);
      await _uiPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _uiPlayer.setVolume(0.45);
      _ready = true;
    } catch (e) {
      debugPrint('SfxService init failed: $e');
      _ready = false;
    }
  }

  void setEnabled(bool enabled) => _enabled = enabled;

  Future<void> playSuccess() => _play('audio/sfx_success.wav');
  Future<void> playPartial() => _play('audio/sfx_partial.wav');
  Future<void> playFail() => _play('audio/sfx_fail.wav');
  Future<void> playDelivery() => _play('audio/sfx_delivery.wav');
  Future<void> playTap() => _play('audio/sfx_tap.wav', ui: true);

  Future<void> _play(String asset, {bool ui = false}) async {
    if (!_enabled || !_ready) return;
    final player = ui ? _uiPlayer : _player;
    try {
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Sfx play failed ($asset): $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _uiPlayer.dispose();
  }
}
