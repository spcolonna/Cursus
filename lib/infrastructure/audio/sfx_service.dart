import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// SFX mínimos del loop: outcomes + entrega + tap.
/// Fallar en silencio si el asset no carga — nunca tumba la UX.
class SfxService {
  SfxService();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  bool _ready = false;

  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(0.7);
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
  Future<void> playTap() => _play('audio/sfx_tap.wav');

  Future<void> _play(String asset) async {
    if (!_enabled || !_ready) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Sfx play failed ($asset): $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
