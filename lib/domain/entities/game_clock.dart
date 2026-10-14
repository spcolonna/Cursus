// ═════════════════════════════════════════════════════════════════════════════
// GameClock: la hora del juego. Toda regla que depende del tiempo (misiones,
// eventos, diarios, semanales, racha, avisos) la lee de acá y nunca de
// DateTime.now(): así, adelantar el reloj del teléfono no termina misiones
// ni resetea los diarios.
//
// La infraestructura (TrustedTimeService) la ancla a la hora del servidor y,
// sin red, la hace avanzar con el reloj monotónico del sistema. Sin anclar
// (tests, primer arranque) es la hora del dispositivo.
// ═════════════════════════════════════════════════════════════════════════════

class GameClock {
  GameClock._();

  static DateTime? _base;
  static final Stopwatch _sinceBase = Stopwatch();
  static DateTime Function()? _override;

  /// Ahora, en hora local.
  static DateTime now() {
    final override = _override;
    if (override != null) return override();
    final base = _base;
    if (base == null) return DateTime.now();
    return base.add(_sinceBase.elapsed);
  }

  /// Cuánto se adelanta la hora del juego a la del dispositivo (negativo si
  /// el teléfono está adelantado).
  static Duration get skew => now().difference(DateTime.now());

  /// Una hora del juego en la hora del dispositivo (para programar avisos,
  /// que el sistema dispara con su propio reloj).
  static DateTime toDevice(DateTime gameTime) => gameTime.subtract(skew);

  /// Fija la hora del juego; desde acá avanza con un cronómetro monotónico.
  static void setBase(DateTime gameNow) {
    _base = gameNow.toLocal();
    _sinceBase
      ..reset()
      ..start();
  }

  static bool get isAnchored => _base != null;

  /// Solo tests: una hora fija o programable. null vuelve al normal.
  static void debugOverride(DateTime Function()? now) => _override = now;

  /// Solo tests: olvida el ancla.
  static void debugReset() {
    _base = null;
    _override = null;
    _sinceBase
      ..stop()
      ..reset();
  }
}
