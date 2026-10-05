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
  final int level;
  final String name;
  final String perk; // qué otorga este nivel (texto para el jugador)
  const SkillNodeDef(this.level, this.name, this.perk);
}

/// Definición completa de los 5 caminos, 10 nodos cada uno.
const Map<SkillType, List<SkillNodeDef>> skillTree = {
  SkillType.speed: [
    SkillNodeDef(1, 'Paso firme', 'Desbloquea opciones de Velocidad Nv.1'),
    SkillNodeDef(2, 'Trote sostenido', '+30 a tus tiradas · opciones de Velocidad Nv.2'),
    SkillNodeDef(3, 'Zancada larga', '+45 a tus tiradas · opciones de Velocidad Nv.3'),
    SkillNodeDef(4, 'Pies de viento', '+60 a tus tiradas · opciones de Velocidad Nv.4'),
    SkillNodeDef(5, 'Corredor de postas', '+75 a tus tiradas · todas las opciones de Velocidad'),
    SkillNodeDef(6, 'Atajos del Imperio', 'Misiones -3% de duración'),
    SkillNodeDef(7, 'Ritmo de campaña', 'Misiones -5% de duración'),
    SkillNodeDef(8, 'Viento del norte', 'Misiones -7% de duración'),
    SkillNodeDef(9, 'Sombra en el camino', 'Misiones -9% de duración'),
    SkillNodeDef(10, 'Correo del César', 'Misiones -12% y las notas S pagan +25 denarios'),
  ],
  SkillType.stealth: [
    SkillNodeDef(1, 'Pisada suave', 'Desbloquea opciones de Sigilo Nv.1'),
    SkillNodeDef(2, 'Entre las sombras', '+30 a tus tiradas · opciones de Sigilo Nv.2'),
    SkillNodeDef(3, 'Rostro anónimo', '+45 a tus tiradas · opciones de Sigilo Nv.3'),
    SkillNodeDef(4, 'Manto gris', '+60 a tus tiradas · opciones de Sigilo Nv.4'),
    SkillNodeDef(5, 'Fantasma del foro', '+75 a tus tiradas · todas las opciones de Sigilo'),
    SkillNodeDef(6, 'Callejones conocidos', 'Las opciones de Sigilo exigen 1 nivel menos'),
    SkillNodeDef(7, 'Paso de gato', '+5 a tus tiradas de Sigilo'),
    SkillNodeDef(8, 'Niebla romana', 'Las opciones de Sigilo tienen 1 punto menos de riesgo'),
    SkillNodeDef(9, 'Nadie te vio', '+10 extra a tus tiradas de Sigilo'),
    SkillNodeDef(10, 'Invisible', 'Riesgo -2 y +10 extra en opciones de Sigilo'),
  ],
  SkillType.combat: [
    SkillNodeDef(1, 'Guardia alzada', 'Desbloquea opciones de Combate Nv.1'),
    SkillNodeDef(2, 'Puño del camino', '+30 a tus tiradas · opciones de Combate Nv.2'),
    SkillNodeDef(3, 'Reflejos de legión', '+45 a tus tiradas · opciones de Combate Nv.3'),
    SkillNodeDef(4, 'Acero prestado', '+60 a tus tiradas · opciones de Combate Nv.4'),
    SkillNodeDef(5, 'Veterano de riñas', '+75 a tus tiradas · todas las opciones de Combate'),
    SkillNodeDef(6, 'Postura firme', '+5 a tus tiradas de Combate'),
    SkillNodeDef(7, 'Contragolpe', '+10 a tus tiradas de Combate'),
    SkillNodeDef(8, 'Escudo del correo', 'Los fallos en Combate no dañan el paquete'),
    SkillNodeDef(9, 'Furia controlada', '+10 extra a tus tiradas de Combate'),
    SkillNodeDef(10, 'Gladiador', 'Los fallos en Combate te cuestan la mitad de salud'),
  ],
  SkillType.survival: [
    SkillNodeDef(1, 'Ojo del terreno', 'Desbloquea opciones de Supervivencia Nv.1'),
    SkillNodeDef(2, 'Piel curtida', '+30 a tus tiradas · opciones de Supervivencia Nv.2'),
    SkillNodeDef(3, 'Aguas y raíces', '+45 a tus tiradas · opciones de Supervivencia Nv.3'),
    SkillNodeDef(4, 'Refugio rápido', '+60 a tus tiradas · opciones de Supervivencia Nv.4'),
    SkillNodeDef(5, 'Hijo del camino', '+75 a tus tiradas · todas las opciones de Supervivencia'),
    SkillNodeDef(6, 'Segundo aliento', 'Los eventos te fatigan menos (8 → 6)'),
    SkillNodeDef(7, 'Sangre dura', 'Los resultados parciales te cuestan menos salud'),
    SkillNodeDef(8, 'Temple de hierro', 'Los eventos te fatigan mucho menos (6 → 4)'),
    SkillNodeDef(9, 'Marcha forzada', 'La fatiga alta te penaliza la mitad'),
    SkillNodeDef(10, 'Incansable', 'La fatiga nunca penaliza tus tiradas'),
  ],
  SkillType.contacts: [
    SkillNodeDef(1, 'Cara conocida', 'Desbloquea opciones de Contactos Nv.1'),
    SkillNodeDef(2, 'Amigo del tabernero', '+30 a tus tiradas · opciones de Contactos Nv.2'),
    SkillNodeDef(3, 'Deudas y favores', '+45 a tus tiradas · opciones de Contactos Nv.3'),
    SkillNodeDef(4, 'Oído en el foro', '+60 a tus tiradas · opciones de Contactos Nv.4'),
    SkillNodeDef(5, 'Red de porteros', '+75 a tus tiradas · todas las opciones de Contactos'),
    SkillNodeDef(6, 'Comisión del gremio', 'Las entregas pagan +5% de denarios'),
    SkillNodeDef(7, 'Cliente frecuente', 'Las entregas pagan +8% de denarios'),
    SkillNodeDef(8, 'Palabra del Senado', 'Las entregas pagan +12% de denarios'),
    SkillNodeDef(9, 'Mano derecha de Varus', 'Las entregas pagan +16% de denarios'),
    SkillNodeDef(10, 'Red imperial', 'Las entregas pagan +20% de denarios'),
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
    SkillEffect('Suma a tus tiradas', '+${level * 15}'),
    SkillEffect('Opciones que podés elegir', 'hasta Nv.$level'),
  ];

  switch (skill) {
    case SkillType.speed:
      final factor = SkillPerks.missionDurationFactor(m);
      effects.add(SkillEffect('Duración de las misiones',
          factor == 1.0 ? 'sin cambios' : '−${((1 - factor) * 100).round()}%'));
      if (SkillPerks.gradeSBonus(m) > 0) {
        effects.add(SkillEffect(
            'Bonus por nota S', '+${SkillPerks.gradeSBonus(m)} denarios'));
      }
    case SkillType.stealth:
      final bonus = SkillPerks.scoreBonus(skill, m);
      if (bonus > 0) {
        effects.add(SkillEffect('Bonus de sigilo', '+$bonus a la tirada'));
      }
      final risk = SkillPerks.riskReduction(skill, m);
      if (risk > 0) effects.add(SkillEffect('Riesgo efectivo', '−$risk'));
      if (SkillPerks.gatingDiscount(skill, m) > 0) {
        effects.add(const SkillEffect('Requisitos de sigilo', '1 nivel menos'));
      }
    case SkillType.combat:
      final bonus = SkillPerks.scoreBonus(skill, m);
      if (bonus > 0) {
        effects.add(SkillEffect('Bonus de combate', '+$bonus a la tirada'));
      }
      if (SkillPerks.combatProtectsPackage(skill, m)) {
        effects.add(const SkillEffect('Al fallar', 'el paquete no se daña'));
      }
      final fail = SkillPerks.failHealthDelta(skill, m, false);
      if (fail > -20) {
        effects.add(SkillEffect('Salud al fallar', '$fail en vez de −20'));
      }
    case SkillType.survival:
      effects.add(SkillEffect(
          'Fatiga por evento', '+${SkillPerks.fatiguePerEvent(m)}'));
      final factor = SkillPerks.fatiguePenaltyFactor(m);
      if (factor < 1.0) {
        effects.add(SkillEffect(
            'Castigo por fatiga alta',
            factor == 0.0
                ? 'ninguno'
                : '−${((1 - factor) * 100).round()}%'));
      }
      final partial = SkillPerks.partialHealthDelta(m);
      if (partial > -5) {
        effects.add(SkillEffect('Salud en parciales', '$partial en vez de −5'));
      }
    case SkillType.contacts:
      final mult = SkillPerks.payMultiplier(m);
      effects.add(SkillEffect('Paga de las entregas',
          mult == 1.0 ? 'normal' : '+${((mult - 1) * 100).round()}%'));
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
