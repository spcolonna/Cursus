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

// ─── Perks pasivos — efectos reales en el juego ──────────────────────────────
// Todos los efectos escalan lo que ya existe; ninguno elimina la decisión
// ni rompe el gating por habilidad.
class SkillPerks {
  SkillPerks._();

  /// Velocidad 6-10: reduce la duración real de las misiones.
  static double missionDurationFactor(Messenger m) =>
      switch (m.skillLevel(SkillType.speed)) {
        >= 10 => 0.88,
        9 => 0.91,
        8 => 0.93,
        7 => 0.95,
        6 => 0.97,
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
        (level >= 7 ? 5 : 0) + (level >= 9 ? 10 : 0) + (level >= 10 ? 10 : 0),
      SkillType.combat =>
        (level >= 6 ? 5 : 0) + (level >= 7 ? 5 : 0) + (level >= 9 ? 10 : 0),
      _ => 0,
    };
  }

  /// Sigilo 8/10: reduce el riesgo efectivo de las opciones de Sigilo.
  static int riskReduction(SkillType? usedSkill, Messenger m) {
    if (usedSkill != SkillType.stealth) return 0;
    final level = m.skillLevel(SkillType.stealth);
    if (level >= 10) return 2;
    if (level >= 8) return 1;
    return 0;
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
        >= 10 => 0.0,
        >= 9 => 0.5,
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
    // Base común a los cinco caminos: cada nivel suma 15 a la tirada.
    SkillEffect(ds('ui.effect.roll_bonus'), '+${level * 15}'),
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
