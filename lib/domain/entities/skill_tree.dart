import 'domain_strings.dart';
import 'entities.dart';
import 'world.dart';

// ─── Caminos del Mensajero ───────────────────────────────────────────────────
// Cada skill es un "camino" de 10 niveles con nombre propio.
// Niveles 1-5 se ganan con XP (o manuales). Niveles 6-10 ("élite") se
// ascienden con Sellos del Gremio y otorgan perks pasivos reales.
// Regla de balance: el poder total de un camino al máximo ≤ +25%.

/// Nivel máximo alcanzable ascendiendo con Sellos.
const int kMaxSkillLevelElite = 10;

/// Costo en Sellos del Gremio para ascender a cada nivel élite.
const Map<int, int> sealCostForLevel = {
  6: 2, 7: 4, 8: 8, 9: 14, 10: 22,
};

class SkillNodeDef {
  final SkillType skill;
  final int level;
  const SkillNodeDef(this.skill, this.level);

  /// Nombre propio del nodo (textos en kDomainStrings: ui.skill_node.*).
  String get name => ds('ui.skill_node.${skill.name}.$level.name');

  /// Qué otorga este nivel (texto para el jugador).
  String get perk => ds('ui.skill_node.${skill.name}.$level.perk');
}

/// Definición completa de los 5 caminos, 10 nodos cada uno.
final Map<SkillType, List<SkillNodeDef>> skillTree = {
  for (final skill in SkillType.values)
    skill: [
      for (var level = 1; level <= kMaxSkillLevelElite; level++)
        SkillNodeDef(skill, level),
    ],
};

SkillNodeDef skillNode(SkillType skill, int level) =>
    skillTree[skill]![(level - 1).clamp(0, kMaxSkillLevelElite - 1)];

// ─── Fórmula de resolución compartida ────────────────────────────────────────
// La usan ResolveEventUseCase._calculateOutcome y forecast.dart: un solo lugar
// para que el pronóstico nunca se despegue de la tirada real.

/// Azar del camino: uniforme en [kLuckMin, kLuckMax] (50 valores).
const int kLuckMin = -25;
const int kLuckMax = 24;

/// Nivel más alto que exige hoy una opción: referencia del árbol.
const int kMaxOptionRequirement = 3;

/// Aporte de una habilidad al score. Hasta un nivel por encima de lo que pide
/// la opción suma 15 por nivel; de ahí en más, 2 por nivel. Sin este codo la
/// habilidad tapaba toda la banda de azar desde el nivel 4-5.
int skillScore(int level, int required) {
  final cap = (required < 1 ? 1 : required) + 1;
  return level <= cap ? level * 15 : cap * 15 + (level - cap) * 2;
}

/// Las opciones sin habilidad cuentan como oficio básico (nivel 1): con la
/// banda de azar de 50 puntos, sin esto la vía prudente fallaba más que la
/// arriesgada y convenía ignorar el evento.
const int kNoSkillBonus = 15;

/// XP por evento resuelto con una opción que usa habilidad.
const int kXpPerEvent = 25;

/// XP de una opción sin habilidad: va a la habilidad más baja. Sin esto,
/// quien elegía siempre lo más seguro no subía nunca de nivel (en nivel 1 la
/// habilidad suma lo mismo que "Sentido común" y arriesga más).
const int kFreeOptionXp = 10;

/// A qué habilidad va la XP de una opción sin habilidad: la de menor nivel
/// que todavía sube por XP (empate: la primera). Null si ya están todas en 5.
SkillType? freeOptionXpSkill(Messenger m) {
  SkillType? best;
  for (final s in SkillType.values) {
    final lvl = m.skillLevel(s);
    if (lvl >= kMaxSkillLevel) continue;
    if (best == null || lvl < m.skillLevel(best)) best = s;
  }
  return best;
}

/// Penalización por riesgo efectivo: los riesgos 4 y 5 pesan más que lineal,
/// para que el fallo exista también en el endgame.
int riskPenalty(int risk) => const [0, 8, 16, 24, 40, 56][risk.clamp(0, 5)];

// ─── Perks pasivos — efectos reales en el juego ──────────────────────────────
// Todos los efectos escalan lo que ya existe; ninguno elimina la decisión
// ni rompe el gating por habilidad.
class SkillPerks {
  SkillPerks._();

  /// Velocidad 6-10: reduce la duración real de las misiones.
  static double missionDurationFactor(Messenger m) =>
      switch (m.skillLevel(SkillType.speed)) {
        >= 10 => 0.92,
        9 => 0.94,
        8 => 0.95,
        7 => 0.97,
        6 => 0.98,
        _ => 1.0,
      };

  /// Velocidad 10: bonus de denarios al entregar con nota S.
  static int gradeSBonus(Messenger m) =>
      m.skillLevel(SkillType.speed) >= 10 ? 25 : 0;

  /// Sigilo/Combate 6-10: bonus plano al score del evento cuando la opción
  /// elegida usa esa habilidad.
  static int scoreBonus(SkillType? usedSkill, Messenger m) {
    if (usedSkill == null) return 0;
    final level = m.skillLevel(usedSkill);
    return switch (usedSkill) {
      SkillType.stealth =>
        (level >= 7 ? 4 : 0) + (level >= 8 ? 3 : 0) + (level >= 9 ? 3 : 0),
      SkillType.combat =>
        (level >= 6 ? 3 : 0) + (level >= 7 ? 3 : 0) + (level >= 9 ? 4 : 0),
      _ => 0,
    };
  }

  /// Sigilo 10: reduce en 1 el riesgo efectivo de las opciones de Sigilo.
  static int riskReduction(SkillType? usedSkill, Messenger m) {
    if (usedSkill != SkillType.stealth) return 0;
    return m.skillLevel(SkillType.stealth) >= 10 ? 1 : 0;
  }

  /// Sigilo 6: las opciones de Sigilo exigen 1 nivel menos.
  static int gatingDiscount(SkillType requiredSkill, Messenger m) =>
      requiredSkill == SkillType.stealth &&
              m.skillLevel(SkillType.stealth) >= 6
          ? 1
          : 0;

  /// Supervivencia 6/8: fatiga que suma cada evento resuelto.
  static int fatiguePerEvent(Messenger m) =>
      switch (m.skillLevel(SkillType.survival)) {
        >= 8 => 4,
        >= 6 => 6,
        _ => 8,
      };

  /// Supervivencia 9/10: atenúa la penalización por fatiga alta.
  static double fatiguePenaltyFactor(Messenger m) =>
      switch (m.skillLevel(SkillType.survival)) {
        >= 10 => 0.5,
        >= 9 => 0.75,
        _ => 1.0,
      };

  /// Supervivencia 7: los resultados parciales cuestan menos salud.
  static int partialHealthDelta(Messenger m) =>
      m.skillLevel(SkillType.survival) >= 7 ? -3 : -5;

  /// Combate 8: un fallo usando Combate no daña el paquete.
  static bool combatProtectsPackage(SkillType? usedSkill, Messenger m) =>
      usedSkill == SkillType.combat && m.skillLevel(SkillType.combat) >= 8;

  /// Combate 10: los fallos usando Combate cuestan la mitad de salud.
  static int failHealthDelta(SkillType? usedSkill, Messenger m, bool isTutorial) {
    if (isTutorial) return -10;
    if (usedSkill == SkillType.combat &&
        m.skillLevel(SkillType.combat) >= 10) {
      return -10;
    }
    return -20;
  }

  /// Contactos 6-10: multiplica la paga en denarios de cada entrega.
  static double payMultiplier(Messenger m) =>
      switch (m.skillLevel(SkillType.contacts)) {
        >= 10 => 1.20,
        9 => 1.16,
        8 => 1.12,
        7 => 1.08,
        6 => 1.05,
        _ => 1.0,
      };
}

// ─── Cuánto mejora cada nivel ─────────────────────────────────────────────────
// La pantalla del árbol tiene que poder responder "¿qué gano si subo?" con
// números, no con "mejora tus tiradas". Estas funciones leen SkillPerks con un
// mensajero de prueba, así lo que se muestra nunca se despega de lo que aplica.

Messenger _probe(SkillType skill, int level) => Messenger(
      id: '_probe',
      name: '',
      gender: MessengerGender.male,
      health: 100,
      fatigue: 0,
      status: MessengerStatus.idle,
      skills: {skill: level},
      skillXp: const {},
      completedMissionIds: const [],
      tutorialPhase: 0,
      tutorialMissionIndex: 0,
      tutorialComplete: true,
    );

/// Un efecto medible del camino [skill] en el nivel [level].
class SkillEffect {
  final String label;
  final String value;
  const SkillEffect(this.label, this.value);
}

/// Estado numérico completo de un camino en un nivel dado.
/// Sirve para el "ahora → con el próximo nivel" del árbol.
List<SkillEffect> skillEffectsAt(SkillType skill, int level) {
  final m = _probe(skill, level);
  final effects = <SkillEffect>[
    // Base común a los cinco caminos, contra la opción más exigente.
    SkillEffect(ds('ui.effect.roll_bonus'),
        '+${skillScore(level, kMaxOptionRequirement)}'),
    SkillEffect(ds('ui.effect.options'),
        ds('ui.effect.options_value', {'level': level})),
  ];

  switch (skill) {
    case SkillType.speed:
      final factor = SkillPerks.missionDurationFactor(m);
      effects.add(SkillEffect(ds('ui.effect.duration'),
          factor == 1.0 ? ds('ui.effect.unchanged') : '−${((1 - factor) * 100).round()}%'));
      if (SkillPerks.gradeSBonus(m) > 0) {
        effects.add(SkillEffect(ds('ui.effect.grade_s'),
            ds('ui.effect.denarios_value', {'n': SkillPerks.gradeSBonus(m)})));
      }
    case SkillType.stealth:
      final bonus = SkillPerks.scoreBonus(skill, m);
      if (bonus > 0) {
        effects.add(SkillEffect(ds('ui.effect.stealth_bonus'),
            ds('ui.effect.roll_value', {'n': bonus})));
      }
      final risk = SkillPerks.riskReduction(skill, m);
      if (risk > 0) effects.add(SkillEffect(ds('ui.effect.risk'), '−$risk'));
      if (SkillPerks.gatingDiscount(skill, m) > 0) {
        effects.add(SkillEffect(
            ds('ui.effect.stealth_req'), ds('ui.effect.one_level_less')));
      }
    case SkillType.combat:
      final bonus = SkillPerks.scoreBonus(skill, m);
      if (bonus > 0) {
        effects.add(SkillEffect(ds('ui.effect.combat_bonus'),
            ds('ui.effect.roll_value', {'n': bonus})));
      }
      if (SkillPerks.combatProtectsPackage(skill, m)) {
        effects.add(SkillEffect(
            ds('ui.effect.on_fail'), ds('ui.effect.package_safe')));
      }
      final fail = SkillPerks.failHealthDelta(skill, m, false);
      if (fail > -20) {
        effects.add(SkillEffect(ds('ui.effect.fail_health'),
            ds('ui.effect.instead_of', {'value': fail, 'base': '−20'})));
      }
    case SkillType.survival:
      effects.add(SkillEffect(ds('ui.effect.fatigue_per_event'),
          '+${SkillPerks.fatiguePerEvent(m)}'));
      final factor = SkillPerks.fatiguePenaltyFactor(m);
      if (factor < 1.0) {
        effects.add(SkillEffect(
            ds('ui.effect.fatigue_penalty'),
            factor == 0.0
                ? ds('ui.effect.none')
                : '−${((1 - factor) * 100).round()}%'));
      }
      final partial = SkillPerks.partialHealthDelta(m);
      if (partial > -5) {
        effects.add(SkillEffect(ds('ui.effect.partial_health'),
            ds('ui.effect.instead_of', {'value': partial, 'base': '−5'})));
      }
    case SkillType.contacts:
      final mult = SkillPerks.payMultiplier(m);
      effects.add(SkillEffect(ds('ui.effect.pay'),
          mult == 1.0 ? ds('ui.effect.normal') : '+${((mult - 1) * 100).round()}%'));
  }
  return effects;
}

/// Qué cambia exactamente al pasar de [level] a [level] + 1.
/// Devuelve pares (etiqueta, "antes → después") solo de lo que se mueve.
List<({String label, String before, String after})> skillLevelDelta(
    SkillType skill, int level) {
  if (level >= kMaxSkillLevelElite) return const [];
  final before = {for (final e in skillEffectsAt(skill, level)) e.label: e.value};
  final after = {
    for (final e in skillEffectsAt(skill, level + 1)) e.label: e.value
  };
  final out = <({String label, String before, String after})>[];
  for (final entry in after.entries) {
    final prev = before[entry.key];
    if (prev != entry.value) {
      out.add((label: entry.key, before: prev ?? '—', after: entry.value));
    }
  }
  return out;
}

/// ¿La opción es visible para este jugador? Las opciones con `requiredFlag`
/// son callbacks secretos: no existen hasta que la historia las habilita.
bool optionVisible(EventOption option, WorldState? world) {
  if (option.requiredFlag != null &&
      !(world?.hasFlag(option.requiredFlag!) ?? false)) {
    return false;
  }
  if (option.forbiddenFlag != null &&
      (world?.hasFlag(option.forbiddenFlag!) ?? false)) {
    return false;
  }
  return true;
}

/// Requisitos de una opción de evento: skills (con el perk de Sigilo 6)
/// y reputación mínima. Única fuente de verdad: la UI y el dominio deben
/// usar esta función.
bool meetsOptionRequirements(EventOption option, Messenger? messenger,
    {WorldState? world}) {
  // Reputación mínima por facción.
  if (option.minReputation != null) {
    for (final e in option.minReputation!.entries) {
      if ((world?.repOf(e.key) ?? 0) < e.value) return false;
    }
  }
  if (option.requiredSkills.isEmpty) return true;
  if (messenger == null) return false;
  return option.requiredSkills.entries.every((e) {
    final required =
        e.value - SkillPerks.gatingDiscount(e.key, messenger);
    return messenger.skillLevel(e.key) >= required;
  });
}
