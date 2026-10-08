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

  static void _play(Sfx sfx) => _sfx?.play(sfx);

  /// Toque de cualquier control.
  static void tap() {
    _haptic(HapticFeedback.selectionClick);
    _play(Sfx.tap);
  }

  /// Volver / cerrar.
  static void back() {
    _haptic(HapticFeedback.selectionClick);
    _play(Sfx.back);
  }

  /// Interruptores y selectores.
  static void toggle() {
    _haptic(HapticFeedback.selectionClick);
    _play(Sfx.toggle);
  }

  /// Acción que no se pudo hacer (botón deshabilitado, saldo insuficiente).
  static void denied() {
    _haptic(HapticFeedback.lightImpact);
    _play(Sfx.errorSoft);
  }

  /// Cobrar algo chico: un contrato, la paga diaria.
  static void reward() {
    _haptic(HapticFeedback.mediumImpact);
    _play(Sfx.coin);
  }

  /// Cobrar mucho de una vez: monedas que vuelan, compras grandes.
  static void rewardBig() {
    _haptic(HapticFeedback.mediumImpact);
    _play(Sfx.coinsMany);
  }

  static void success() {
    _haptic(HapticFeedback.mediumImpact);
    _play(Sfx.success);
  }

  static void partial() {
    _haptic(HapticFeedback.lightImpact);
    _play(Sfx.partial);
  }

  static void fail() {
    _haptic(HapticFeedback.heavyImpact);
    _play(Sfx.fail);
  }

  static void delivery() {
    _haptic(HapticFeedback.heavyImpact);
    _play(Sfx.delivery);
  }

  /// Sello de cera que cae: nota, nodos 6-10 del árbol.
  static void seal() {
    _haptic(HapticFeedback.heavyImpact);
    _play(Sfx.sealStamp);
  }

  static void levelUp() {
    _haptic(HapticFeedback.mediumImpact);
    _play(Sfx.levelUp);
  }

  static void rankUp() {
    _haptic(HapticFeedback.heavyImpact);
    _play(Sfx.rankUp);
  }

  static void achievement() {
    _haptic(HapticFeedback.mediumImpact);
    _play(Sfx.achievement);
  }

  static void weeklyComplete() {
    _haptic(HapticFeedback.mediumImpact);
    _play(Sfx.weeklyComplete);
  }

  /// Llega un evento mientras el jugador mira la misión.
  static void eventArrive() {
    _haptic(HapticFeedback.mediumImpact);
    _play(Sfx.eventArrive);
  }

  /// La firma sonora de Cursus (tres notas de lira): el splash, la nota S.
  /// Es también el sonido de los avisos.
  static void motif() {
    _haptic(HapticFeedback.lightImpact);
    _play(Sfx.motif);
  }

  /// Se abre un pergamino: carta de evento, diario.
  static void unroll() => _play(Sfx.pageUnroll);

  /// Golpe seco sin sonido.
  static void impact() => _haptic(HapticFeedback.heavyImpact);
}
