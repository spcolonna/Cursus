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
    goal: 'Entregá tu primer mensaje.',
    kind: AchievementKind.road, metric: StatMetric.missions, target: 1,
    reward: AchievementReward(denarios: 30),
  ),
  AchievementDef(
    id: 'ach_missions_10', name: 'Suela gastada',
    goal: 'Entregá 10 mensajes.',
    kind: AchievementKind.road, metric: StatMetric.missions, target: 10,
    reward: AchievementReward(denarios: 80, title: 'Suela gastada'),
  ),
  AchievementDef(
    id: 'ach_missions_50', name: 'Cursus publicus',
    goal: 'Entregá 50 mensajes.',
    kind: AchievementKind.road, metric: StatMetric.missions, target: 50,
    reward: AchievementReward(denarios: 200, title: 'Hombre del cursus'),
  ),
  AchievementDef(
    id: 'ach_missions_150', name: 'Todas las vías',
    goal: 'Entregá 150 mensajes.',
    kind: AchievementKind.road, metric: StatMetric.missions, target: 150,
    reward: AchievementReward(seals: 1, title: 'Correo del Imperio'),
  ),
  AchievementDef(
    id: 'ach_routes_all', name: 'Conocés el mapa',
    goal: 'Completá 4 rutas distintas.',
    kind: AchievementKind.road, metric: StatMetric.distinctRoutes, target: 4,
    reward: AchievementReward(denarios: 120, title: 'Cartógrafo'),
  ),
  AchievementDef(
    id: 'ach_long_haul', name: 'Tres días de polvo',
    goal: 'Entregá un mensaje de una ruta de 24 h o más.',
    kind: AchievementKind.road, metric: StatMetric.longMissions, target: 1,
    reward: AchievementReward(denarios: 150, title: 'El de la Vía Larga'),
  ),
  AchievementDef(
    id: 'ach_events_25', name: 'Sangre fría',
    goal: 'Resolvé 25 imprevistos en el camino.',
    kind: AchievementKind.road, metric: StatMetric.eventsResolved, target: 25,
    reward: AchievementReward(denarios: 80),
  ),
  AchievementDef(
    id: 'ach_events_100', name: 'Nada te sorprende',
    goal: 'Resolvé 100 imprevistos en el camino.',
    kind: AchievementKind.road, metric: StatMetric.eventsResolved, target: 100,
    reward: AchievementReward(denarios: 200, title: 'Sangre fría'),
  ),

  // ─── Notas ───
  AchievementDef(
    id: 'ach_grade_s_1', name: 'Impecable',
    goal: 'Conseguí una nota S.',
    kind: AchievementKind.grade, metric: StatMetric.gradeS, target: 1,
    reward: AchievementReward(denarios: 60),
  ),
  AchievementDef(
    id: 'ach_grade_s_10', name: 'Sello de oro',
    goal: 'Conseguí 10 notas S.',
    kind: AchievementKind.grade, metric: StatMetric.gradeS, target: 10,
    reward: AchievementReward(seals: 1, title: 'Sello de oro'),
  ),
  AchievementDef(
    id: 'ach_grade_s_30', name: 'Nunca un rasguño',
    goal: 'Conseguí 30 notas S.',
    kind: AchievementKind.grade, metric: StatMetric.gradeS, target: 30,
    reward: AchievementReward(seals: 1, title: 'El Impecable'),
  ),

  // ─── Gremio ───
  AchievementDef(
    id: 'ach_contracts_10', name: 'Hombre del tablón',
    goal: 'Cobrá 10 contratos del gremio.',
    kind: AchievementKind.guild, metric: StatMetric.contractsClaimed, target: 10,
    reward: AchievementReward(denarios: 100),
  ),
  AchievementDef(
    id: 'ach_contracts_50', name: 'Favorito de Varus',
    goal: 'Cobrá 50 contratos del gremio.',
    kind: AchievementKind.guild, metric: StatMetric.contractsClaimed, target: 50,
    reward: AchievementReward(denarios: 250, title: 'Favorito de Varus'),
  ),
  AchievementDef(
    id: 'ach_streak_7', name: 'Una semana sin faltar',
    goal: 'Cobrá la paga del gremio 7 días seguidos.',
    kind: AchievementKind.guild, metric: StatMetric.bestPayStreak, target: 7,
    reward: AchievementReward(denarios: 100, title: 'El Puntual'),
  ),
  AchievementDef(
    id: 'ach_streak_28', name: 'Un mes de servicio',
    goal: 'Cobrá la paga del gremio 28 días seguidos.',
    kind: AchievementKind.guild, metric: StatMetric.bestPayStreak, target: 28,
    reward: AchievementReward(seals: 1, title: 'Veterano del gremio'),
  ),
  AchievementDef(
    id: 'ach_messengers_2', name: 'Ya no estás solo',
    goal: 'Contratá un segundo mensajero.',
    kind: AchievementKind.guild, metric: StatMetric.messengers, target: 2,
    reward: AchievementReward(denarios: 80),
  ),
  AchievementDef(
    id: 'ach_messengers_4', name: 'Casa de postas',
    goal: 'Tené cuatro mensajeros a la vez.',
    kind: AchievementKind.guild, metric: StatMetric.messengers, target: 4,
    reward: AchievementReward(denarios: 200, title: 'Jefe de posta'),
  ),

  // ─── Oficio ───
  AchievementDef(
    id: 'ach_rank_2', name: 'Mensajero',
    goal: 'Llegá al rango Mensajero.',
    kind: AchievementKind.skill, metric: StatMetric.rank, target: 2,
    reward: AchievementReward(denarios: 80),
  ),
  AchievementDef(
    id: 'ach_rank_3', name: 'Courier',
    goal: 'Llegá al rango Courier.',
    kind: AchievementKind.skill, metric: StatMetric.rank, target: 3,
    reward: AchievementReward(denarios: 150),
  ),
  AchievementDef(
    id: 'ach_rank_4', name: 'Maestro de postas',
    goal: 'Llegá al rango Maestro.',
    kind: AchievementKind.skill, metric: StatMetric.rank, target: 4,
    reward: AchievementReward(seals: 1, title: 'Maestro de postas'),
  ),
  AchievementDef(
    id: 'ach_rank_5', name: 'Leyenda de la Vía',
    goal: 'Llegá al rango Leyenda.',
    kind: AchievementKind.skill, metric: StatMetric.rank, target: 5,
    reward: AchievementReward(seals: 1, title: 'Leyenda de la Vía'),
  ),
  AchievementDef(
    id: 'ach_first_elite', name: 'Lacrado',
    goal: 'Subí un camino a nivel 6 con Sellos del Gremio.',
    kind: AchievementKind.skill, metric: StatMetric.eliteLevels, target: 1,
    reward: AchievementReward(denarios: 150, title: 'Lacrado'),
  ),
  AchievementDef(
    id: 'ach_skill_10', name: 'Sin igual',
    goal: 'Llevá un camino a nivel 10.',
    kind: AchievementKind.skill, metric: StatMetric.maxSkillLevel, target: 10,
    reward: AchievementReward(seals: 1, title: 'Sin igual'),
  ),
  AchievementDef(
    id: 'ach_denarios_5000', name: 'Bolsa pesada',
    goal: 'Ganá 5.000 Denarios trabajando.',
    kind: AchievementKind.empire, metric: StatMetric.denariosEarned, target: 5000,
    reward: AchievementReward(title: 'Bolsa pesada'),
  ),

  // ─── Historia ───
  AchievementDef(
    id: 'ach_arc_first', name: 'El sello de Claudius',
    goal: 'Terminá el arco de Claudius.',
    kind: AchievementKind.story, metric: StatMetric.arcEndings, target: 1,
    reward: AchievementReward(denarios: 200), secret: true,
  ),
  AchievementDef(
    id: 'ach_arc_two', name: 'Dos historias, un camino',
    goal: 'Terminá dos arcos de historia.',
    kind: AchievementKind.story, metric: StatMetric.arcEndings, target: 2,
    reward: AchievementReward(seals: 1, title: 'El que lo vio todo'),
    secret: true,
  ),
];
