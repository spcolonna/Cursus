import '../domain/entities/progression.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Logros y títulos. Reglas de balance (las verifica test/progression_test):
//   · Nunca dan Aureos.
//   · Como mucho 1 Sello por logro y 8 en toda la partida.
//   · Los Denarios son de una sola vez: no entran en el presupuesto diario.
// ═══════════════════════════════════════════════════════════════════════════

const allAchievements = <AchievementDef>[
  // ─── El camino ───
  AchievementDef(
    id: 'ach_first_delivery', name: 'Primer sello roto',
    goal: 'Entrega tu primer mensaje.',
    kind: AchievementKind.road, metric: StatMetric.missions, target: 1,
    reward: AchievementReward(denarios: 30),
  ),
  AchievementDef(
    id: 'ach_missions_10', name: 'Suela gastada',
    goal: 'Entrega 10 mensajes.',
    kind: AchievementKind.road, metric: StatMetric.missions, target: 10,
    reward: AchievementReward(denarios: 80, title: 'Suela gastada'),
  ),
  AchievementDef(
    id: 'ach_missions_50', name: 'Cursus publicus',
    goal: 'Entrega 50 mensajes.',
    kind: AchievementKind.road, metric: StatMetric.missions, target: 50,
    reward: AchievementReward(denarios: 200, title: 'Hombre del cursus'),
  ),
  AchievementDef(
    id: 'ach_missions_150', name: 'Todas las vías',
    goal: 'Entrega 150 mensajes.',
    kind: AchievementKind.road, metric: StatMetric.missions, target: 150,
    reward: AchievementReward(seals: 1, title: 'Correo del Imperio'),
  ),
  AchievementDef(
    id: 'ach_routes_all', name: 'Conocés el mapa',
    goal: 'Completa 4 rutas distintas.',
    kind: AchievementKind.road, metric: StatMetric.distinctRoutes, target: 4,
    reward: AchievementReward(denarios: 120, title: 'Cartógrafo'),
  ),
  AchievementDef(
    id: 'ach_long_haul', name: 'Tres días de polvo',
    goal: 'Entrega un mensaje de una ruta de 24 h o más.',
    kind: AchievementKind.road, metric: StatMetric.longMissions, target: 1,
    reward: AchievementReward(denarios: 150, title: 'El de la Vía Larga'),
  ),
  AchievementDef(
    id: 'ach_events_25', name: 'Sangre fría',
    goal: 'Resuelve 25 imprevistos en el camino.',
    kind: AchievementKind.road, metric: StatMetric.eventsResolved, target: 25,
    reward: AchievementReward(denarios: 80),
  ),
  AchievementDef(
    id: 'ach_events_100', name: 'Nada te sorprende',
    goal: 'Resuelve 100 imprevistos en el camino.',
    kind: AchievementKind.road, metric: StatMetric.eventsResolved, target: 100,
    reward: AchievementReward(denarios: 200, title: 'Sangre fría'),
  ),

  // ─── Notas ───
  AchievementDef(
    id: 'ach_grade_s_1', name: 'Impecable',
    goal: 'Consigue una nota S.',
    kind: AchievementKind.grade, metric: StatMetric.gradeS, target: 1,
    reward: AchievementReward(denarios: 60),
  ),
  AchievementDef(
    id: 'ach_grade_s_10', name: 'Sello de oro',
    goal: 'Consigue 10 notas S.',
    kind: AchievementKind.grade, metric: StatMetric.gradeS, target: 10,
    reward: AchievementReward(seals: 1, title: 'Sello de oro'),
  ),
  AchievementDef(
    id: 'ach_grade_s_30', name: 'Nunca un rasguño',
    goal: 'Consigue 30 notas S.',
    kind: AchievementKind.grade, metric: StatMetric.gradeS, target: 30,
    reward: AchievementReward(seals: 1, title: 'El Impecable'),
  ),

  // ─── Gremio ───
  AchievementDef(
    id: 'ach_contracts_10', name: 'Hombre del tablón',
    goal: 'Cobra 10 contratos del gremio.',
    kind: AchievementKind.guild, metric: StatMetric.contractsClaimed, target: 10,
    reward: AchievementReward(denarios: 100),
  ),
  AchievementDef(
    id: 'ach_contracts_50', name: 'Favorito de Varus',
    goal: 'Cobra 50 contratos del gremio.',
    kind: AchievementKind.guild, metric: StatMetric.contractsClaimed, target: 50,
    reward: AchievementReward(denarios: 250, title: 'Favorito de Varus'),
  ),
  AchievementDef(
    id: 'ach_streak_7', name: 'Una semana sin faltar',
    goal: 'Cobra la paga del gremio 7 días seguidos.',
    kind: AchievementKind.guild, metric: StatMetric.bestPayStreak, target: 7,
    reward: AchievementReward(denarios: 100, title: 'El Puntual'),
  ),
  AchievementDef(
    id: 'ach_streak_28', name: 'Un mes de servicio',
    goal: 'Cobra la paga del gremio 28 días seguidos.',
    kind: AchievementKind.guild, metric: StatMetric.bestPayStreak, target: 28,
    reward: AchievementReward(seals: 1, title: 'Veterano del gremio'),
  ),
  AchievementDef(
    id: 'ach_messengers_2', name: 'Ya no estás solo',
    goal: 'Contrata un segundo mensajero.',
    kind: AchievementKind.guild, metric: StatMetric.messengers, target: 2,
    reward: AchievementReward(denarios: 80),
  ),
  AchievementDef(
    id: 'ach_messengers_4', name: 'Casa de postas',
    goal: 'Ten cuatro mensajeros a la vez.',
    kind: AchievementKind.guild, metric: StatMetric.messengers, target: 4,
    reward: AchievementReward(denarios: 200, title: 'Jefe de posta'),
  ),

  // ─── Oficio ───
  AchievementDef(
    id: 'ach_rank_2', name: 'Mensajero',
    goal: 'Llega al rango Mensajero.',
    kind: AchievementKind.skill, metric: StatMetric.rank, target: 2,
    reward: AchievementReward(denarios: 80),
  ),
  AchievementDef(
    id: 'ach_rank_3', name: 'Courier',
    goal: 'Llega al rango Courier.',
    kind: AchievementKind.skill, metric: StatMetric.rank, target: 3,
    reward: AchievementReward(denarios: 150),
  ),
  AchievementDef(
    id: 'ach_rank_4', name: 'Maestro de postas',
    goal: 'Llega al rango Maestro.',
    kind: AchievementKind.skill, metric: StatMetric.rank, target: 4,
    reward: AchievementReward(seals: 1, title: 'Maestro de postas'),
  ),
  AchievementDef(
    id: 'ach_rank_5', name: 'Leyenda de la Vía',
    goal: 'Llega al rango Leyenda.',
    kind: AchievementKind.skill, metric: StatMetric.rank, target: 5,
    reward: AchievementReward(seals: 1, title: 'Leyenda de la Vía'),
  ),
  AchievementDef(
    id: 'ach_first_elite', name: 'Lacrado',
    goal: 'Sube un camino a nivel 6 con Sellos del Gremio.',
    kind: AchievementKind.skill, metric: StatMetric.eliteLevels, target: 1,
    reward: AchievementReward(denarios: 150, title: 'Lacrado'),
  ),
  AchievementDef(
    id: 'ach_skill_10', name: 'Sin igual',
    goal: 'Lleva un camino a nivel 10.',
    kind: AchievementKind.skill, metric: StatMetric.maxSkillLevel, target: 10,
    reward: AchievementReward(seals: 1, title: 'Sin igual'),
  ),
  AchievementDef(
    id: 'ach_denarios_5000', name: 'Bolsa pesada',
    goal: 'Gana 5.000 Denarios trabajando.',
    kind: AchievementKind.empire, metric: StatMetric.denariosEarned, target: 5000,
    reward: AchievementReward(title: 'Bolsa pesada'),
  ),

  // ─── Historia ───
  AchievementDef(
    id: 'ach_arc_first', name: 'El sello de Claudius',
    goal: 'Termina el arco de Claudius.',
    kind: AchievementKind.story, metric: StatMetric.arcEndings, target: 1,
    reward: AchievementReward(denarios: 200), secret: true,
  ),
  AchievementDef(
    id: 'ach_arc_two', name: 'Dos historias, un camino',
    goal: 'Termina dos arcos de historia.',
    kind: AchievementKind.story, metric: StatMetric.arcEndings, target: 2,
    reward: AchievementReward(seals: 1, title: 'El que lo vio todo'),
    secret: true,
  ),
  AchievementDef(
    id: 'ach_arc_three', name: 'Tres historias',
    goal: 'Termina los tres arcos de historia.',
    kind: AchievementKind.story, metric: StatMetric.arcEndings, target: 3,
    reward: AchievementReward(denarios: 400), secret: true,
  ),

  // ─── Finales (se buscan volviendo a recorrer los arcos) ───
  AchievementDef(
    id: 'ach_endings_4', name: 'Otro camino',
    goal: 'Encuentra 4 finales distintos.',
    kind: AchievementKind.story, metric: StatMetric.endingsFound, target: 4,
    reward: AchievementReward(denarios: 300),
  ),
  AchievementDef(
    id: 'ach_endings_6', name: 'Lo que pudo ser',
    goal: 'Encuentra 6 finales distintos.',
    kind: AchievementKind.story, metric: StatMetric.endingsFound, target: 6,
    reward: AchievementReward(denarios: 500, title: 'El que volvió'),
  ),
  AchievementDef(
    id: 'ach_endings_9', name: 'Todos los caminos',
    goal: 'Encuentra los 9 finales.',
    kind: AchievementKind.story, metric: StatMetric.endingsFound, target: 9,
    reward: AchievementReward(
        denarios: 1000, title: 'El que conoce todos los caminos'),
  ),
];
