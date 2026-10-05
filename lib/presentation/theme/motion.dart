// lib/presentation/theme/motion.dart
//
// Tokens de movimiento: todas las duraciones y curvas del juego salen de acá.
// Regla: el movimiento explica (de dónde viene algo, qué cambió), nunca
// decora. Si el jugador pide menos movimiento — en el sistema o en Ajustes —
// las animaciones se acortan a casi nada y las celebraciones se vuelven fades.

import 'package:flutter/widgets.dart';

class AppMotion {
  AppMotion._();

  // ─── Duraciones ────────────────────────────────────────────────────────────
  /// Respuesta táctil: presionar un botón, toggles.
  static const fast = Duration(milliseconds: 120);

  /// Cambios de estado dentro de una pantalla (AnimatedSwitcher, chips).
  static const base = Duration(milliseconds: 220);

  /// Transiciones de pantalla y entradas de cards.
  static const slow = Duration(milliseconds: 360);

  /// Momentos de recompensa: sello, subida de nivel, rank.
  static const celebrate = Duration(milliseconds: 900);

  /// Escalonado entre elementos de una lista que entra.
  static const stagger = Duration(milliseconds: 60);

  // ─── Curvas ────────────────────────────────────────────────────────────────
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOutCubic;

  /// Rebote corto: sellos, badges, ítems que "aterrizan".
  static const Curve pop = Curves.easeOutBack;

  // ─── Movimiento reducido ───────────────────────────────────────────────────
  /// Preferencia del jugador (Ajustes). La carga `main.dart` al arrancar.
  static final ValueNotifier<bool> userPrefersReduced = ValueNotifier(false);

  /// True si hay que evitar movimiento: preferencia del sistema o del juego.
  static bool reduced(BuildContext context) =>
      userPrefersReduced.value ||
      (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  /// [d], o casi nada si el movimiento está reducido. No devuelve cero para
  /// no romper animaciones encadenadas que esperan un `onEnd`.
  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? const Duration(milliseconds: 1) : d;
}
