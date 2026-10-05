// lib/domain/usecases/forecast.dart
//
// Pronóstico de una opción de evento: qué tan bien le puede ir al jugador
// ANTES de decidir, y por qué.
//
// Regla de diseño (GDD): nada de porcentajes. El jugador recibe una banda
// cualitativa y una línea en su idioma. Pero la banda sale de la MISMA
// aritmética que usa ResolveEventUseCase._calculateOutcome — si alguien toca
// la fórmula y no toca esto, el test `forecast coincide con la fórmula` falla.

import '../entities/entities.dart';
import '../entities/skill_tree.dart';

/// Qué tan probable es que salga bien. Cinco bandas, de mejor a peor.
enum ForecastBand { assured, favourable, uncertain, risky, reckless }

extension ForecastBandX on ForecastBand {
  String get label => switch (this) {
        ForecastBand.assured => 'Lo tenés dominado',
        ForecastBand.favourable => 'Buenas chances',
        ForecastBand.uncertain => 'Incierto',
        ForecastBand.risky => 'Arriesgado',
        ForecastBand.reckless => 'Temerario',
      };
}

class OptionForecast {
  final ForecastBand band;

  /// La razón principal, contada como la contaría un mensajero.
  final String reason;

  /// Parte determinística del score (todo menos el azar del camino).
  final int baseScore;

  /// Riesgo ya descontado por perks de Sigilo.
  final int effectiveRisk;

  const OptionForecast({
    required this.band,
    required this.reason,
    required this.baseScore,
    required this.effectiveRisk,
  });
}

// El azar del camino: _rng.nextInt(30) - 10 → uniforme en [-10, 19].
const int _luckMin = -10;
const int _luckMax = 19;
const int _successThreshold = 55;

// ── Tiradas críticas ─────────────────────────────────────────────────────────
// Se tira un d100 aparte del azar del camino. Garantizan las dos puntas del
// diseño: el maxeado puede fallar en riesgo 4-5 (CLAUDE.md, invariante 7) y
// una opción sin oficio puede salir bien. Usan el riesgo NOMINAL: los perks
// de Sigilo no anulan el imprevisto.

/// % de "Imprevisto" (fallo seguro) según el riesgo nominal de la opción.
int mishapPercent(int nominalRisk) => switch (nominalRisk) {
      >= 5 => 10,
      4 => 5,
      _ => 0,
    };

/// % de "Golpe de suerte" (éxito seguro), igual para toda opción.
const int kLuckyBreakPercent = 5;

/// Probabilidad de éxito (0..1) dado el score sin azar.
double _successChance(int baseScore) {
  // Éxito si base + luck >= 55 → luck >= 55 - base.
  final needed = _successThreshold - baseScore;
  if (needed <= _luckMin) return 1.0;
  if (needed > _luckMax) return 0.0;
  const total = _luckMax - _luckMin + 1;
  return (_luckMax - needed + 1) / total;
}

/// Calcula el pronóstico de [option] para [messenger].
/// Debe reflejar exactamente los sumandos de `_calculateOutcome`.
OptionForecast forecastFor(EventOption option, Messenger? messenger) {
  var score = 40;

  // Habilidades exigidas por la opción.
  var lowestSkillLevel = 99;
  SkillType? weakestSkill;
  SkillType? strongestSkill;
  var highestSkillLevel = 0;
  for (final entry in option.requiredSkills.entries) {
    final level = messenger?.skillLevel(entry.key) ?? 1;
    score += level * 15;
    if (level < lowestSkillLevel) {
      lowestSkillLevel = level;
      weakestSkill = entry.key;
    }
    if (level > highestSkillLevel) {
      highestSkillLevel = level;
      strongestSkill = entry.key;
    }
  }

  final usedSkill = option.requiredSkills.keys.firstOrNull;
  var perkBonus = 0;
  if (messenger != null) {
    perkBonus = SkillPerks.scoreBonus(usedSkill, messenger);
    score += perkBonus;
  }

  final effectiveRisk = messenger == null
      ? option.riskLevel
      : (option.riskLevel - SkillPerks.riskReduction(usedSkill, messenger))
          .clamp(0, 5);
  score -= effectiveRisk * 8;

  final fatigue = messenger?.fatigue ?? 0;
  final fatigueFactor =
      messenger == null ? 1.0 : SkillPerks.fatiguePenaltyFactor(messenger);
  var fatiguePenalty = 0;
  if (fatigue >= 70) {
    fatiguePenalty = (15 * fatigueFactor).round();
  } else if (fatigue >= 40) {
    fatiguePenalty = (7 * fatigueFactor).round();
  }
  score -= fatiguePenalty;

  final mishap = mishapPercent(option.riskLevel) / 100;
  const lucky = kLuckyBreakPercent / 100;
  final chance = lucky + (1 - mishap - lucky) * _successChance(score);
  final band = switch (chance) {
    >= 0.85 => ForecastBand.assured,
    >= 0.60 => ForecastBand.favourable,
    >= 0.35 => ForecastBand.uncertain,
    >= 0.10 => ForecastBand.risky,
    _ => ForecastBand.reckless,
  };

  return OptionForecast(
    band: band,
    baseScore: score,
    effectiveRisk: effectiveRisk,
    reason: _reason(
      band: band,
      option: option,
      effectiveRisk: effectiveRisk,
      fatigue: fatigue,
      fatiguePenalty: fatiguePenalty,
      perkBonus: perkBonus,
      weakestSkill: weakestSkill,
      lowestSkillLevel: lowestSkillLevel == 99 ? 0 : lowestSkillLevel,
      strongestSkill: strongestSkill,
      highestSkillLevel: highestSkillLevel,
    ),
  );
}

/// La línea que lee el jugador. Se elige el factor que más pesa, para que
/// aprenda qué mirar: primero lo que puede cambiar (fatiga, habilidad),
/// después el riesgo propio de la opción.
String _reason({
  required ForecastBand band,
  required EventOption option,
  required int effectiveRisk,
  required int fatigue,
  required int fatiguePenalty,
  required int perkBonus,
  required SkillType? weakestSkill,
  required int lowestSkillLevel,
  required SkillType? strongestSkill,
  required int highestSkillLevel,
}) {
  // La fatiga es lo primero que hay que decir: es lo que el jugador puede
  // arreglar hoy mismo (descanso, poción).
  if (fatiguePenalty > 0 && band.index >= ForecastBand.uncertain.index) {
    return fatigue >= 70
        ? 'Vas agotado: cualquier cosa te puede salir mal.'
        : 'El cansancio te está pesando en las manos.';
  }

  // Sin habilidad de por medio: solo pesa el riesgo del camino.
  if (option.requiredSkills.isEmpty) {
    return switch (band) {
      ForecastBand.assured => 'Es la opción prudente. Lenta, pero segura.',
      ForecastBand.favourable => 'No necesitás nada especial para intentarlo.',
      ForecastBand.uncertain => 'Sin un oficio que te ayude, depende del día.',
      ForecastBand.risky => 'Puro pulso y suerte. Puede salir feo.',
      ForecastBand.reckless => 'Esto es tirarse al vacío y esperar lo mejor.',
    };
  }

  if (perkBonus > 0 && band.index <= ForecastBand.favourable.index) {
    return 'Tu camino de ${strongestSkill?.label ?? 'oficio'} '
        'te da una ventaja acá.';
  }

  final skillLabel = weakestSkill?.label ?? 'tu oficio';
  return switch (band) {
    ForecastBand.assured =>
      '$skillLabel Nv.$lowestSkillLevel te sobra para esto.',
    ForecastBand.favourable =>
      '$skillLabel Nv.$lowestSkillLevel debería alcanzar.',
    ForecastBand.uncertain => effectiveRisk >= 4
        ? 'Tu $skillLabel ayuda, pero el peligro es alto.'
        : 'Podés lograrlo, aunque no está garantizado.',
    ForecastBand.risky =>
      'Con $skillLabel Nv.$lowestSkillLevel, esto es una apuesta.',
    ForecastBand.reckless =>
      'Te falta $skillLabel para algo así. Sería un milagro.',
  };
}
