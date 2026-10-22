// ─── Economía ajustable ───────────────────────────────────────────────────────
// Los números que deciden cuánto cuesta avanzar sin pagar: la curva de XP,
// el precio de adelantar un viaje y el de los manuales. Arrancan en estos
// defaults y Remote Config los puede corregir sin publicar (ver RemoteFlags);
// el valor de la sesión se fija al arrancar, nunca en medio de una partida.
//
// Meta (GDD §6): jugar gratis siempre alcanza; pagar ahorra semanas, no
// reemplaza jugar.

/// XP para pasar del nivel [level] al siguiente, con la curva base. Sube
/// con el nivel: los primeros niveles llegan rápido, el 5 se trabaja.
const Map<int, int> kXpCurve = {1: 100, 2: 125, 3: 175, 4: 250};

/// Manuales de la tienda: Denarios por nivel actual (GDD §5).
const Map<int, int> kManualDenarios = {1: 200, 2: 500, 3: 1200, 4: 2500};

/// El mismo manual pagado con Aureos, para quien no quiere esperar a juntar
/// los Denarios.
const Map<int, int> kManualAureos = {1: 10, 2: 15, 3: 25, 4: 40};

class EconomyTuning {
  /// Escala de la curva de XP, en %. 100 = [kXpCurve].
  final int xpCurvePercent;

  /// Denarios por minuto de viaje adelantado.
  final int skipDenariosPerMinute;

  /// Escala del precio de los manuales en Aureos, en %.
  final int manualAureosPercent;

  const EconomyTuning({
    this.xpCurvePercent = 100,
    this.skipDenariosPerMinute = 2,
    this.manualAureosPercent = 100,
  });

  static const defaults = EconomyTuning();

  /// La de esta sesión. Se fija una vez al arrancar, con Remote Config.
  static EconomyTuning current = defaults;

  int xpForLevel(int level) =>
      ((kXpCurve[level] ?? kXpCurve[4]!) * xpCurvePercent / 100).round();

  int? manualAureosFor(int level) => switch (kManualAureos[level]) {
        final p? => (p * manualAureosPercent / 100).round(),
        null => null,
      };
}
