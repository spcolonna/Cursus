// ═══════════════════════════════════════════════════════════════
// FACCIONES — lo que abre cada escalón de reputación, las rutas que
// solo te dan si te conocen y los encargos semanales con nombre propio.
// Español rioplatense, sin emojis, sin anacronismos (ver skill historia).
// ═══════════════════════════════════════════════════════════════

import '../domain/entities/content.dart';
import '../domain/entities/weekly.dart';
import '../domain/entities/world.dart';

// ─── Rutas de facción ─────────────────────────────────────────────────────────
// Piden reputación con quien las encarga. Las dos últimas son las primeras
// rutas de rango 4 y 5.
const List<RealMissionConfig> factionMissions = [
  RealMissionConfig(
    id: 'real_16',
    origin: 'Roma',
    destination: 'Neapolis — correo exprés',
    distanceKm: 210,
    durationMinutes: 360,
    danger: 0.30,
    requiredRank: 2,
    patron: Faction.guild,
    minReputation: 30,
    openedByFlag: 'ending_varus',
    lore: 'La valija de los pedidos urgentes. Caballo de relevo en cada posta '
        'y nadie pregunta por qué tanta prisa.',
    packageOptions: [
      'Un aviso de quiebra que tiene que llegar antes que el rumor',
      'La firma que falta para cerrar una venta de trigo',
    ],
    eventPoolIds: ['evt_patrol', 'evt_cart_jam', 'evt_merchant_offer', 'evt_rival_messenger', 'evt_heatwave'],
    minEvents: 1,
    maxEvents: 2,
  ),
  RealMissionConfig(
    id: 'real_17',
    origin: 'Roma',
    destination: 'Brundisium por la Via Appia',
    distanceKm: 540,
    durationMinutes: 2160,
    danger: 0.65,
    requiredRank: 4,
    patron: Faction.legions,
    minReputation: 30,
    lore: 'Despachos sellados para la flota. La Appia entera, de posta militar '
        'en posta militar, con el salvoconducto de un legado en el cinto.',
    packageOptions: [
      'Órdenes de embarque para dos cohortes',
      'La lista de pagas de una legión que espera en el puerto',
    ],
    eventPoolIds: ['evt_patrol', 'evt_deserter', 'evt_old_soldier', 'evt_spy_drop', 'evt_bandits', 'evt_heatwave', 'evt_wolf', 'evt_landslide', 'evt_tax_collector'],
    minEvents: 5,
    maxEvents: 6,
  ),
  RealMissionConfig(
    id: 'real_18',
    origin: 'Ostia',
    destination: 'Neapolis por mar, de noche',
    distanceKm: 230,
    durationMinutes: 600,
    danger: 0.70,
    requiredRank: 3,
    patron: Faction.underworld,
    minReputation: 30,
    lore: 'Un pesquero sin farol, una carga que no figura en ningún registro '
        'y un capitán que cobra por no hacer preguntas.',
    packageOptions: [
      'Un cofre chico que pesa más de lo que debería',
      'Cartas de un liberto a un socio que nadie conoce',
    ],
    eventPoolIds: ['evt_storm', 'evt_spy_drop', 'evt_letter_bribe', 'evt_merchant_offer', 'evt_pickpocket'],
    minEvents: 2,
    maxEvents: 3,
  ),
  RealMissionConfig(
    id: 'real_19',
    origin: 'Ostia',
    destination: 'Massilia por mar',
    distanceKm: 850,
    durationMinutes: 2520,
    danger: 0.55,
    requiredRank: 5,
    patron: Faction.patricians,
    minReputation: 30,
    lore: 'Correspondencia de un senador para sus socios de Massilia. Nave '
        'rápida, camarote propio y orden de entregar en mano, aunque el mar no quiera.',
    packageOptions: [
      'Un contrato de aceite con el sello de tres familias',
      'Una carta que no se lee en voz alta',
    ],
    eventPoolIds: ['evt_storm', 'evt_omen', 'evt_oracle', 'evt_merchant_offer', 'evt_spy_drop', 'evt_letter_bribe', 'evt_rival_messenger', 'evt_tax_collector'],
    minEvents: 6,
    maxEvents: 7,
  ),
];

// ─── Desbloqueos por escalón ──────────────────────────────────────────────────
const List<FactionUnlock> factionUnlocks = [
  // El Gremio: arranca en Conocido, así que todo pide más.
  FactionUnlock(
    faction: Faction.guild,
    tier: FactionTier.respected,
    kind: FactionUnlockKind.perk,
    perk: FactionPerk.contractReroll,
    orFlag: 'ending_varus',
    name: 'Cambiar un contrato',
    description: 'Una vez por día podés cambiar un contrato del tablón por otro.',
  ),
  FactionUnlock(
    faction: Faction.guild,
    tier: FactionTier.respected,
    kind: FactionUnlockKind.route,
    ref: 'real_16',
    orFlag: 'ending_varus',
    name: 'Correo exprés a Neapolis',
    description: 'La valija urgente del Gremio. Corta y bien paga.',
  ),
  FactionUnlock(
    faction: Faction.guild,
    tier: FactionTier.legend,
    kind: FactionUnlockKind.perk,
    perk: FactionPerk.patronPay,
    name: 'Tarifa de la casa',
    description: '+10% de paga en las rutas del Gremio.',
  ),
  FactionUnlock(
    faction: Faction.guild,
    tier: FactionTier.legend,
    kind: FactionUnlockKind.title,
    ref: 'Voz del Gremio',
    name: 'Título: Voz del Gremio',
    description: 'Los novatos te piden que les cuentes cómo se hace.',
  ),

  // Las Legiones.
  FactionUnlock(
    faction: Faction.legions,
    tier: FactionTier.known,
    kind: FactionUnlockKind.perk,
    perk: FactionPerk.patronPay,
    name: 'Tarifa militar',
    description: '+10% de paga en las rutas de las Legiones.',
  ),
  FactionUnlock(
    faction: Faction.legions,
    tier: FactionTier.respected,
    kind: FactionUnlockKind.route,
    ref: 'real_17',
    name: 'Brundisium por la Via Appia',
    description: 'Despachos para la flota. Pide rango Maestro.',
  ),
  FactionUnlock(
    faction: Faction.legions,
    tier: FactionTier.legend,
    kind: FactionUnlockKind.title,
    ref: 'Amigo de la Legión',
    name: 'Título: Amigo de la Legión',
    description: 'Las patrullas te saludan antes de pedirte el pase.',
  ),

  // Los Bajos Fondos.
  FactionUnlock(
    faction: Faction.underworld,
    tier: FactionTier.known,
    kind: FactionUnlockKind.perk,
    perk: FactionPerk.patronPay,
    name: 'Tarifa sin recibo',
    description: '+10% de paga en las rutas de los Bajos Fondos.',
  ),
  FactionUnlock(
    faction: Faction.underworld,
    tier: FactionTier.respected,
    kind: FactionUnlockKind.route,
    ref: 'real_18',
    name: 'Neapolis por mar, de noche',
    description: 'Un pesquero sin farol y una carga sin registro.',
  ),
  FactionUnlock(
    faction: Faction.underworld,
    tier: FactionTier.legend,
    kind: FactionUnlockKind.title,
    ref: 'Sombra de la Subura',
    name: 'Título: Sombra de la Subura',
    description: 'En ciertas tabernas, tu cuenta ya está paga.',
  ),

  // Los Patricios.
  FactionUnlock(
    faction: Faction.patricians,
    tier: FactionTier.known,
    kind: FactionUnlockKind.perk,
    perk: FactionPerk.patronPay,
    name: 'Tarifa de villa',
    description: '+10% de paga en las rutas de los Patricios.',
  ),
  FactionUnlock(
    faction: Faction.patricians,
    tier: FactionTier.respected,
    kind: FactionUnlockKind.route,
    ref: 'real_19',
    name: 'Massilia por mar',
    description: 'Cartas de un senador, en mano. Pide rango Leyenda.',
  ),
  FactionUnlock(
    faction: Faction.patricians,
    tier: FactionTier.legend,
    kind: FactionUnlockKind.title,
    ref: 'Cliente del Senado',
    name: 'Título: Cliente del Senado',
    description: 'Tu nombre aparece en las listas de las cenas.',
  ),
];

// ─── Encargos semanales ───────────────────────────────────────────────────────
// Presupuesto: el del Sello es el "1.ª S semanal" del GDD §6.1. Los demás
// promedian ~88 Denarios; con dos por semana son ~25 por día (lo que reserva
// el test de presupuesto diario).
const List<WeeklyCommissionDef> weeklyCommissionPool = [
  WeeklyCommissionDef(
    id: kWeeklySealId,
    npcName: 'Varus',
    npcRole: 'jefe de la casa de postas',
    npcFaction: Faction.guild,
    intro: 'Una entrega perfecta por semana. Es lo único que te pido, y lo '
        'único que voy a recordar.',
    goalText: 'Conseguí una nota S',
    goal: WeeklyGoal.gradeS,
    target: 1,
    seals: 1,
    rep: {Faction.guild: 1},
    journal: 'Varus me dio un Sello sin decir nada. Con él, eso es mucho.',
  ),
  WeeklyCommissionDef(
    id: 'w_deliver5',
    npcName: 'Décimo',
    npcRole: 'escriba del Gremio',
    npcFaction: Faction.guild,
    intro: 'Se me amontonan las tablillas. Si salen cinco esta semana, '
        'te debo una.',
    goalText: 'Entregá 5 mensajes',
    goal: WeeklyGoal.deliver,
    target: 5,
    denarios: 80,
    rep: {Faction.guild: 2},
    journal: 'Décimo tachó cinco tablillas de su pila y me pagó contento.',
  ),
  WeeklyCommissionDef(
    id: 'w_deliver8',
    npcName: 'Décimo',
    npcRole: 'escriba del Gremio',
    npcFaction: Faction.guild,
    intro: 'Semana de mercado: todo el mundo escribe. Necesito alguien que '
        'no pare.',
    goalText: 'Entregá 8 mensajes',
    goal: WeeklyGoal.deliver,
    target: 8,
    denarios: 100,
    rep: {Faction.guild: 2},
    journal: 'Ocho entregas en una semana. Décimo dice que nunca vio la pila tan baja.',
  ),
  WeeklyCommissionDef(
    id: 'w_guild_routes',
    npcName: 'Marco',
    npcRole: 'mensajero de la casa',
    npcFaction: Faction.guild,
    intro: 'Tengo la pierna a la miseria. ¿Me cubrís las rutas de la casa '
        'unos días?',
    goalText: 'Entregá 3 mensajes en rutas del Gremio',
    goal: WeeklyGoal.patronDelivery,
    faction: Faction.guild,
    target: 3,
    denarios: 80,
    rep: {Faction.guild: 2},
    journal: 'Le cubrí las rutas a Marco. Me lo agradeció a su manera: '
        'diciendo que él las hacía más rápido.',
  ),
  WeeklyCommissionDef(
    id: 'w_grade_a3',
    npcName: 'Marco',
    npcRole: 'mensajero de la casa',
    npcFaction: Faction.guild,
    intro: 'Apuesto a que no hacés tres entregas limpias seguidas. '
        'Si las hacés, pago yo.',
    goalText: 'Conseguí 3 notas A o mejores',
    goal: WeeklyGoal.gradeAOrS,
    target: 3,
    denarios: 95,
    rep: {Faction.guild: 2},
    journal: 'Marco perdió la apuesta. Pagó entero y sin protestar, que es raro.',
  ),
  WeeklyCommissionDef(
    id: 'w_legion_routes',
    npcName: 'Sexto',
    npcRole: 'centurión de la Puerta Capena',
    npcFaction: Faction.legions,
    intro: 'La posta militar anda corta de gente. Si llevás lo nuestro, '
        'en la Puerta se acuerdan.',
    goalText: 'Entregá 2 mensajes en rutas de las Legiones',
    goal: WeeklyGoal.patronDelivery,
    faction: Faction.legions,
    target: 2,
    denarios: 90,
    rep: {Faction.legions: 3},
    journal: 'Sexto anotó mi nombre en la tablilla de la Puerta Capena. '
        'Dice que es para no pedirme el pase.',
  ),
  WeeklyCommissionDef(
    id: 'w_long_legion',
    npcName: 'Sexto',
    npcRole: 'centurión de la Puerta Capena',
    npcFaction: Faction.legions,
    intro: 'Cualquiera corre una hora. Quiero ver quién aguanta un día entero '
        'en el camino.',
    goalText: 'Entregá una ruta de 8 h o más',
    goal: WeeklyGoal.longRoute,
    target: 1,
    denarios: 85,
    rep: {Faction.legions: 2},
    journal: 'Sexto me vio llegar embarrado hasta las rodillas y se rió. '
        'Después me sirvió vino.',
  ),
  WeeklyCommissionDef(
    id: 'w_patrician_routes',
    npcName: 'Fulvia',
    npcRole: 'matrona de una villa del Palatino',
    npcFaction: Faction.patricians,
    intro: 'Mi marido confía en cualquiera. Yo no. Llevá lo de las villas '
        'y veremos.',
    goalText: 'Entregá 2 mensajes en rutas de los Patricios',
    goal: WeeklyGoal.patronDelivery,
    faction: Faction.patricians,
    target: 2,
    denarios: 90,
    rep: {Faction.patricians: 3},
    journal: 'Fulvia me recibió en el atrio y no en la puerta de servicio. '
        'Es un comienzo.',
  ),
  WeeklyCommissionDef(
    id: 'w_long_patrician',
    npcName: 'Fulvia',
    npcRole: 'matrona de una villa del Palatino',
    npcFaction: Faction.patricians,
    intro: 'Tengo parientes lejos y cartas que no esperan. Necesito piernas '
        'que no se cansen.',
    goalText: 'Entregá 2 rutas de 8 h o más',
    goal: WeeklyGoal.longRoute,
    target: 2,
    denarios: 100,
    rep: {Faction.patricians: 2},
    journal: 'Las cartas de Fulvia llegaron lejos. Ella pagó sin mirar la cuenta.',
  ),
  WeeklyCommissionDef(
    id: 'w_underworld_routes',
    npcName: 'Rufo',
    npcRole: 'barquero del Muelle Viejo',
    npcFaction: Faction.underworld,
    intro: 'No te pregunto qué llevás si vos no me preguntás de quién es. '
        'Dos viajes, y quedamos amigos.',
    goalText: 'Entregá 2 mensajes en rutas de los Bajos Fondos',
    goal: WeeklyGoal.patronDelivery,
    faction: Faction.underworld,
    target: 2,
    denarios: 90,
    rep: {Faction.underworld: 3},
    journal: 'Rufo me pagó en monedas de tres cecas distintas. '
        'No pregunté de dónde.',
  ),
  WeeklyCommissionDef(
    id: 'w_events_success4',
    npcName: 'Atia',
    npcRole: 'sacerdotisa del templo de Mercurio',
    npcFaction: Faction.patricians,
    intro: 'Mercurio protege a los que saben elegir. Mostrame que sos '
        'uno de ellos.',
    goalText: 'Salí bien parado de 4 eventos',
    goal: WeeklyGoal.eventSuccesses,
    target: 4,
    denarios: 85,
    rep: {Faction.patricians: 1, Faction.guild: 1},
    journal: 'Atia quemó incienso a mi nombre. Dice que Mercurio ya me conoce.',
  ),
  WeeklyCommissionDef(
    id: 'w_resolve6',
    npcName: 'Cornelia',
    npcRole: 'viuda de un mensajero',
    npcFaction: Faction.underworld,
    intro: 'Mi marido decía que el camino te prueba seis veces por semana. '
        'Contame si tenía razón.',
    goalText: 'Resolvé 6 eventos en el camino',
    goal: WeeklyGoal.resolveEvents,
    target: 6,
    denarios: 75,
    rep: {Faction.underworld: 1, Faction.guild: 1},
    journal: 'Le conté a Cornelia lo que pasó en el camino. Lloró un poco, '
        'y después se rió de lo del puente.',
  ),
];
