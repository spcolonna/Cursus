// lib/presentation/feedback/feedback.dart
//
// Un solo punto para sonido + vibración. Los componentes del design system
// (GameButton, GameIconButton…) lo llaman solos; las pantallas solo lo usan
// para momentos propios (resultado de evento, entrega, cobros).
//
// Se configura una vez en `main.dart` con el servicio de audio y las
// preferencias guardadas. Sin configurar (tests), no hace nada.

import 'package:flutter/services.dart';

import '../../infrastructure/audio/sfx_service.dart';

class AppFeedback {
  AppFeedback._();

  static SfxService? _sfx;
  static bool hapticsEnabled = true;

  static void configure({required SfxService sfx, required bool haptics}) {
    _sfx = sfx;
    hapticsEnabled = haptics;
  }

  static void _haptic(Future<void> Function() fn) {
    if (hapticsEnabled) fn();
  }

  /// Toque de cualquier control.
  static void tap() {
    _haptic(HapticFeedback.selectionClick);
    _sfx?.playTap();
  }

  /// Volver / cerrar.
  static void back() => _haptic(HapticFeedback.selectionClick);

  /// Acción que no se pudo hacer (botón deshabilitado, saldo insuficiente).
  static void denied() => _haptic(HapticFeedback.lightImpact);

  /// Cobrar algo: contratos, paga diaria, recompensas.
  static void reward() {
    _haptic(HapticFeedback.mediumImpact);
    _sfx?.playSuccess();
  }

  static void success() {
    _haptic(HapticFeedback.mediumImpact);
    _sfx?.playSuccess();
  }

  static void partial() {
    _haptic(HapticFeedback.lightImpact);
    _sfx?.playPartial();
  }

  static void fail() {
    _haptic(HapticFeedback.heavyImpact);
    _sfx?.playFail();
  }

  static void delivery() {
    _haptic(HapticFeedback.heavyImpact);
    _sfx?.playDelivery();
  }

  /// Golpe seco sin sonido: sellos que caen, subidas de nivel.
  static void impact() => _haptic(HapticFeedback.heavyImpact);
}
