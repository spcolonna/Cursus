// ─────────────────────────────────────────────────────────────────────────────
// ARCHIVO DE CONTENIDO — Editá acá sin tocar lógica
//
// Estructura de progresión:
//   Phase 0: Tutorial encubierto (pruebas del líder)
//   Phase 1: Primera misión real
//   Phase 2+: Misiones desbloqueadas por rank
// ─────────────────────────────────────────────────────────────────────────────

import '../domain/entities/entities.dart';
import '../domain/entities/world.dart';
import '../domain/entities/content.dart';

export '../domain/entities/content.dart';

// ═══════════════════════════════════════════════════════════════
// PHASE 0 — Tutorial encubierto
// El jugador no sabe que es un tutorial. Es su líder Varus
// poniéndolo a prueba antes de confiarle mensajes reales.
// Duración total: ~27 minutos (1 + 3 + 8 + 15). Cada prueba enseña una
// cosa; Varus la nombra al cierre (ver resultVarusLesson* en los ARB).
// ═══════════════════════════════════════════════════════════════

const List<TutorialMission> tutorialMissions = [

  TutorialMission(
    id: 'tut_01',
    phase: 0,
    durationMinutes: 1,
    origin: 'Cuartel de Varus',
    destination: 'Puerta Sur',
    packageDescription: 'Nota sellada para el guardia de la Puerta Sur',
    lore: '"Lleva esto a la Puerta Sur. Es una prueba simple — quiero ver cómo te mueves."',
    narrativeIntro: 'Varus, tu superior en la red de mensajeros, te tiende un pequeño rollo sellado. Sus ojos te evalúan sin disimulo.',
    eventIds: ['tut_evt_01a'],
    rewardXp: 20,
    unlockNextOnComplete: true,
  ),

  TutorialMission(
    id: 'tut_02',
    phase: 0,
    durationMinutes: 3,
    origin: 'Cuartel de Varus',
    destination: 'Taberna del Buey',
    packageDescription: 'Mensaje cifrado para el tabernero Lucius',
    lore: '"Bien. Ahora algo más difícil. El tabernero Lucius no confía en desconocidos — tendrás que convencerlo."',
    narrativeIntro: 'Varus asiente levemente. Parece satisfecho. Pero su próxima orden viene antes de que puedas respirar.',
    eventIds: ['tut_evt_02a', 'tut_evt_02b'],
    rewardXp: 40,
    unlockNextOnComplete: true,
  ),

  TutorialMission(
    id: 'tut_03',
    phase: 0,
    durationMinutes: 8,
    origin: 'Roma — Foro',
    destination: 'Villa del Senador Claudius',
    packageDescription: 'Correspondencia urgente y confidencial',
    lore: '"Esta es la última prueba. El Senador Claudius espera esto antes del mediodía. Nadie puede saber que vienes de mi parte."',
    narrativeIntro: 'Esta vez Varus no sonríe. La correspondencia lleva tres sellos de cera. Uno de ellos es del Senado.',
    eventIds: ['tut_evt_03a', 'tut_evt_03b', 'tut_evt_03c'],
    rewardXp: 80,
    unlockNextOnComplete: true,
  ),

  TutorialMission(
    id: 'tut_04',
    phase: 0,
    durationMinutes: 15,
    origin: 'Roma',
    destination: 'Campamento Legionario',
    packageDescription: 'Órdenes militares selladas — máxima prioridad',
    lore: '"Superaste las pruebas. Esto ya no es un ejercicio. Las legiones necesitan estas órdenes antes del amanecer."',
    narrativeIntro: 'Varus te mira diferente ahora. Ya no como a un candidato — como a alguien que podría ser valioso.',
    eventIds: ['tut_evt_04a', 'tut_evt_04b', 'tut_evt_04c'],
    rewardXp: 120,
    unlockNextOnComplete: false, // Completes tutorial → unlocks real missions
  ),
];

// ═══════════════════════════════════════════════════════════════
// EVENTS — Tutorial
// ═══════════════════════════════════════════════════════════════

const List<TutorialEvent> tutorialEvents = [

  // ── Misión 1 ─────────────────────────────────────────────────
  TutorialEvent(
    id: 'tut_evt_01a',
    category: EventCategory.patrol,
    title: 'El guardia te detiene',
    description: 'El guardia de la Puerta Sur te mira de arriba abajo. "¿Quién te manda, chico?"',
    decisionWindowMinutes: 2,
    options: [
      TutorialOption(
        id: 'opt_truth',
        text: 'Dices la verdad: "El comandante Varus"',
        riskLevel: 1,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'El guardia reconoce el nombre y te deja pasar sin más preguntas.',
        outcomePartial: 'El guardia duda, pero finalmente te deja pasar tras verificar el sello.',
        outcomeFail: 'El guardia llama a su superior. Pierdes varios minutos justificándote.',
      ),
      TutorialOption(
        id: 'opt_confident',
        text: 'Pasas con confianza sin responder',
        riskLevel: 2,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'Tu actitud decidida hace que el guardia asuma que tienes autorización.',
        outcomePartial: 'Casi funciona. El guardia te para pero te deja pasar al ver el sello oficial.',
        outcomeFail: 'El guardia te detiene por no responder. Situación incómoda.',
      ),
    ],
  ),

  // ── Misión 2 ─────────────────────────────────────────────────
  TutorialEvent(
    id: 'tut_evt_02a',
    category: EventCategory.forum,
    title: 'Callejón concurrido',
    description: 'El camino directo está bloqueado por un mercado improvisado. Hay dos rutas.',
    decisionWindowMinutes: 3,
    options: [
      TutorialOption(
        id: 'opt_push',
        text: 'Te abres paso entre la multitud',
        riskLevel: 2,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'Con habilidad navegas entre los vendedores sin perder tiempo.',
        outcomePartial: 'Llegas al otro lado con la ropa sucia y algo tarde.',
        outcomeFail: 'Un vendedor te hace tropezar. El paquete cae, todo te mira.',
      ),
      TutorialOption(
        id: 'opt_detour',
        text: 'Rodeas por la calle paralela',
        riskLevel: 1,
        timeCostMinutes: 1,
        requiredSkills: {},
        outcomeSuccess: 'El desvío es más largo pero llegas sin contratiempos.',
        outcomePartial: 'El desvío funciona bien.',
        outcomeFail: 'El desvío funciona bien.',
      ),
    ],
  ),

  TutorialEvent(
    id: 'tut_evt_02b',
    category: EventCategory.inn,
    npcId: 'lucius',
    title: 'Lucius desconfía',
    description: 'El tabernero Lucius te mira fijo. "No conozco tu cara. ¿Por qué debería confiar en ti?"',
    decisionWindowMinutes: 3,
    options: [
      TutorialOption(
        id: 'opt_seal',
        text: 'Muestras el sello de Varus en el mensaje',
        riskLevel: 1,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'Lucius reconoce el sello al instante. Lo acepta sin más.',
        outcomePartial: 'Lucius examina el sello largo rato, pero finalmente acepta.',
        outcomeFail: 'Lucius dice que el sello podría ser falso. Hay que convencerlo de otra forma.',
      ),
      TutorialOption(
        id: 'opt_charm',
        text: 'Le dices que el mensaje es urgente y confidencial',
        riskLevel: 2,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'La urgencia en tu voz convence a Lucius. Acepta el mensaje.',
        outcomePartial: 'Lucius acepta pero con reservas. Te pide que vuelvas con más credenciales la próxima vez.',
        outcomeFail: 'Lucius no cede. Terminas mostrando el sello de todas formas.',
      ),
    ],
  ),

  // ── Misión 3 ─────────────────────────────────────────────────
  TutorialEvent(
    id: 'tut_evt_03a',
    category: EventCategory.forum,
    title: 'Alguien te sigue',
    description: 'Notas a un hombre con capucha que apareció en dos esquinas distintas. Puede ser coincidencia.',
    decisionWindowMinutes: 5,
    options: [
      TutorialOption(
        id: 'opt_evade',
        text: 'Doblas en una esquina y esperas oculto',
        riskLevel: 2,
        timeCostMinutes: 0,
        requiredSkills: {SkillType.stealth: 1},
        outcomeSuccess: 'El hombre pasa de largo. No era nada, o lo perdiste bien.',
        outcomePartial: 'El hombre te ve esperar pero sigue de largo de todas formas.',
        outcomeFail: 'Al detenerte, el hombre se acerca. Resulta ser un vendedor buscando clientes.',
      ),
      TutorialOption(
        id: 'opt_ignore',
        text: 'Ignoras la situación y sigues a paso normal',
        riskLevel: 1,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'Era una coincidencia. Llegas sin problemas.',
        outcomePartial: 'Nada pasa. Llegas al destino.',
        outcomeFail: 'El hombre efectivamente te seguía, pero era un espía de Claudius verificando el mensajero. Positivo inesperado.',
      ),
    ],
  ),

  TutorialEvent(
    id: 'tut_evt_03b',
    category: EventCategory.forum,
    title: 'El portero del Senador',
    description: 'La villa de Claudius tiene un portero enorme que no te deja pasar. "El Senador no recibe mensajeros sin cita."',
    decisionWindowMinutes: 5,
    options: [
      TutorialOption(
        id: 'opt_seals',
        text: 'Muestras los tres sellos — incluyendo el del Senado',
        riskLevel: 1,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'El sello del Senado cambia todo. El portero se hace a un lado inmediatamente.',
        outcomePartial: 'El portero va a verificar. Esperas cinco minutos en la entrada.',
        outcomeFail: 'El portero dice que necesita confirmación verbal. Hay que esperar.',
      ),
      TutorialOption(
        id: 'opt_authority',
        text: '"Esto viene directamente de la red del Senado. ¿Quieres explicarle al Senador el retraso?"',
        riskLevel: 3,
        timeCostMinutes: 0,
        requiredSkills: {SkillType.contacts: 1},
        outcomeSuccess: 'El portero no quiere problemas. Te deja pasar al instante.',
        outcomePartial: 'El portero duda pero cede. Tu tono fue convincente.',
        outcomeFail: 'El portero llama al administrador. Pierdes tiempo explicando.',
      ),
    ],
  ),

  TutorialEvent(
    id: 'tut_evt_03c',
    category: EventCategory.forum,
    npcId: 'claudius',
    title: 'El Senador hace preguntas',
    description: 'Claudius acepta el mensaje pero antes de dejarte ir pregunta: "¿Quién más sabe de esto?"',
    decisionWindowMinutes: 5,
    options: [
      TutorialOption(
        id: 'opt_silence',
        text: '"Nadie, Senador. Es entre tú y quien envía el mensaje."',
        riskLevel: 1,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'Claudius asiente satisfecho. "Bien entrenado. Varus elige bien."',
        outcomePartial: 'Claudius te mira un momento largo. Finalmente asiente.',
        outcomeFail: 'Claudius sospecha de tu hesitación, pero acepta la respuesta.',
      ),
      TutorialOption(
        id: 'opt_honest',
        text: '"Solo mi superior directo, que me envió."',
        riskLevel: 2,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'Claudius aprecia la honestidad. "Un mensajero que no miente — raro y valioso."',
        outcomePartial: 'Claudius frunce el ceño pero acepta la respuesta.',
        outcomeFail: 'Claudius no queda satisfecho. Mencionas a Varus y eso complica las cosas.',
      ),
    ],
  ),

  // ── Misión 4 ─────────────────────────────────────────────────
  TutorialEvent(
    id: 'tut_evt_04a',
    category: EventCategory.patrol,
    title: 'Patrulla nocturna',
    description: 'Una patrulla de cuatro legionarios bloquea el camino. El toque de queda rige después del ocaso.',
    decisionWindowMinutes: 5,
    options: [
      TutorialOption(
        id: 'opt_orders',
        text: 'Muestras las órdenes militares selladas',
        riskLevel: 1,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'El centurión lee el sello. "Paso libre. Que los dioses te acompañen, mensajero."',
        outcomePartial: 'El centurión verifica con su segundo. Te dejan pasar tras una espera.',
        outcomeFail: 'El centurión quiere confirmación superior. Esperas media hora.',
      ),
      TutorialOption(
        id: 'opt_speed',
        text: 'Aceleras el paso antes de que te vean',
        riskLevel: 4,
        timeCostMinutes: 0,
        requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Pasas entre las sombras antes de que te detecten.',
        outcomePartial: 'Te ven pero ya estás lejos. Nadie te persigue.',
        outcomeFail: 'Un legionario grita "¡Alto!" — terminas explicando todo de todas formas.',
      ),
    ],
  ),

  TutorialEvent(
    id: 'tut_evt_04b',
    category: EventCategory.patrol,
    title: 'Perro del campamento',
    description: 'Un perro enorme encadenado en la entrada ladra descontrolado. El guardia dentro tarda en aparecer.',
    decisionWindowMinutes: 3,
    options: [
      TutorialOption(
        id: 'opt_wait_dog',
        text: 'Esperas paciente a que aparezca el guardia',
        riskLevel: 1,
        timeCostMinutes: 2,
        requiredSkills: {},
        outcomeSuccess: 'El guardia aparece, regaña al perro, te deja pasar.',
        outcomePartial: 'El guardia tarda pero finalmente aparece.',
        outcomeFail: 'El guardia tarda mucho. Pierdes tiempo pero llegas.',
      ),
      TutorialOption(
        id: 'opt_calm_dog',
        text: 'Te acercas lentamente y calmas al perro',
        riskLevel: 3,
        timeCostMinutes: 0,
        requiredSkills: {SkillType.survival: 1},
        outcomeSuccess: 'El perro te olfatea y se calma. El guardia aparece sorprendido.',
        outcomePartial: 'El perro se calma a medias. Llega el guardia justo a tiempo.',
        outcomeFail: 'El perro ladra más fuerte. Terminas esperando igual.',
      ),
    ],
  ),

  TutorialEvent(
    id: 'tut_evt_04c',
    category: EventCategory.patrol,
    npcId: 'sexto',
    title: 'El Centurión pide confirmar identidad',
    description: '"Las órdenes son auténticas, pero necesito confirmar que tú eres quien dice ser. ¿Quién es tu superior?"',
    decisionWindowMinutes: 5,
    options: [
      TutorialOption(
        id: 'opt_name_varus',
        text: 'Nombras a Varus directamente',
        riskLevel: 1,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'El Centurión conoce a Varus. Acepta la entrega sin más preguntas.',
        outcomePartial: 'El Centurión envía a alguien a verificar. Esperas diez minutos.',
        outcomeFail: 'El Centurión no conoce a Varus. Verificación larga.',
      ),
      TutorialOption(
        id: 'opt_rank_only',
        text: '"Mis órdenes son no revelar la cadena de mando. Las órdenes hablan por sí solas."',
        riskLevel: 3,
        timeCostMinutes: 0,
        requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: 'El Centurión aprecia el protocolo correcto. "Como debe ser." Te deja pasar.',
        outcomePartial: 'El Centurión frunce el ceño pero acepta. Las órdenes son válidas.',
        outcomeFail: 'El Centurión insiste. Terminas nombrando a Varus de todas formas.',
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════
// REAL MISSIONS — Phase 1 (desbloqueadas al terminar tutorial)
// Primera misión real: máximo 12 horas
// ═══════════════════════════════════════════════════════════════

const List<RealMissionConfig> phase1Missions = [
  RealMissionConfig(
    id: 'real_01',
    origin: 'Roma',
    destination: 'Ostia',
    distanceKm: 28,
    durationMinutes: 120, // 2 horas — primera misión real corta
    danger: 0.2,
    requiredRank: 1,
    patron: Faction.guild,
    lore: 'Tu primera misión oficial. El puerto de Ostia espera documentos mercantiles antes del cierre del día.',
    packageOptions: [
      'Documentos de aduana para el puerto',
      'Contrato mercantil urgente',
      'Correspondencia oficial del Erario',
    ],
    eventPoolIds: ['evt_patrol', 'evt_bridge', 'evt_injured', 'evt_pickpocket', 'evt_omen', 'evt_letter_bribe', 'evt_salt_road', 'evt_counterfeit'],
    minEvents: 1,
    maxEvents: 2,
  ),
  RealMissionConfig(
    id: 'real_02',
    origin: 'Roma',
    destination: 'Capua',
    distanceKm: 212,
    durationMinutes: 480, // 8 horas
    danger: 0.4,
    requiredRank: 1,
    patron: Faction.patricians,
    lore: 'La Via Appia te lleva al corazón de Campania. Cuídate de los bandidos en los tramos boscosos.',
    packageOptions: [
      'Órdenes del gobernador para Capua',
      'Correspondencia urgente del Senado',
    ],
    eventPoolIds: ['evt_patrol', 'evt_storm', 'evt_bandits', 'evt_bridge', 'evt_injured', 'evt_wounded_traveler', 'evt_rival_messenger', 'evt_old_soldier', 'evt_merchant_offer', 'evt_gladiator_troupe', 'evt_veteran_land', 'evt_pontine_barge'],
    minEvents: 2,
    maxEvents: 3,
  ),
  RealMissionConfig(
    id: 'real_03',
    origin: 'Roma',
    destination: 'Lugdunum',
    distanceKm: 1050,
    durationMinutes: 4320, // 72 horas — misión de largo aliento
    danger: 0.6,
    requiredRank: 2,
    patron: Faction.legions,
    lore: 'Cruzas los Alpes para llegar a la Galia. Una ruta reservada para mensajeros con experiencia.',
    packageOptions: [
      'Tratado diplomático sellado',
      'Correspondencia militar confidencial',
    ],
    eventPoolIds: ['evt_patrol', 'evt_storm', 'evt_bandits', 'evt_bridge', 'evt_injured', 'evt_wounded_traveler', 'evt_rival_messenger', 'evt_old_soldier', 'evt_merchant_offer', 'evt_letter_bribe', 'evt_omen', 'evt_hostage_escort', 'evt_fallen_milestone', 'evt_horse_sick'],
    minEvents: 4,
    maxEvents: 6,
  ),
  // Ruta exclusiva del final "El que sabe demasiado" (Arco 1, final C).
  RealMissionConfig(
    id: 'real_nocturna',
    origin: 'Roma — Subura',
    destination: 'Ostia — Muelle Viejo',
    distanceKm: 30,
    durationMinutes: 300, // 5 horas — siempre de noche
    danger: 0.5,
    requiredRank: 2,
    patron: Faction.underworld,
    requiredFlag: 'route_nocturna_unlocked',
    lore: 'El correo que no figura en ningún registro. Los Bajos Fondos pagan bien a quien sabe callar y caminar de noche.',
    packageOptions: [
      'Un paquete envuelto en cuero que nadie te explicó',
      'Una caja sellada que huele a incienso extranjero',
    ],
    eventPoolIds: ['evt_patrol', 'evt_bandits', 'evt_merchant_offer', 'evt_letter_bribe', 'evt_pickpocket', 'evt_dice_game', 'evt_counterfeit', 'evt_fugitive'],
    minEvents: 2,
    maxEvents: 3,
  ),
];

// ═══════════════════════════════════════════════════════════════
// REAL EVENTS POOL — usados en misiones reales
// ═══════════════════════════════════════════════════════════════

const List<RealEventConfig> realEventPool = [

  // ══ Los cinco clásicos — ahora con prosa propia y memoria ══════════════════

  RealEventConfig(
    id: 'evt_patrol',
    category: EventCategory.patrol,
    title: 'Patrulla romana',
    description: 'Un grupo de legionarios bloquea el paso. Inspeccionan a todos los viajeros. Tu carga podría levantar sospechas.',
    options: [
      RealOptionConfig(
        id: 'opt_wait', text: 'Esperas a que termine la inspección',
        riskLevel: 1, timeCostMinutes: 120, requiredSkills: {},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'Esperas en la fila con la paciencia de un buey. El centurión revisa tu carga, asiente, y hasta te señala el camino más corto. "Los que esperan no esconden nada", murmura.',
        outcomePartial: 'La inspección es lenta y minuciosa. Un legionario aburrido te hace preguntas de más. Pierdes buena parte de la tarde, pero sales limpio.',
        outcomeFail: 'Justo cuando llega tu turno, cambia la guardia. Todo vuelve a empezar. El sol se mueve en el cielo y tú sigues en la misma fila.',
      ),
      RealOptionConfig(
        id: 'opt_stealth', text: 'Rodeas el puesto por un camino lateral',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 2},
        outcomeSuccess: 'Te deslizas entre los matorrales como una sombra más del atardecer. Cuando vuelves al camino, el puesto quedó atrás y nadie vio nada.',
        outcomePartial: 'El desvío existe, pero está lleno de espinas y piedra suelta. Llegas al otro lado arañado y con el orgullo intacto a medias.',
        outcomeFail: 'Una rama seca cruje bajo tu pie. "¡Ahí! ¡Entre los árboles!" Terminas explicando ante el centurión por qué un mensajero honesto evita los controles.',
      ),
      RealOptionConfig(
        id: 'opt_contacts', text: 'Muestras un sello del Senado que conoces',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'El centurión mira el sello, después te mira a ti, y algo cambia en su postura. "Paso libre para el correo del Senado." Nadie toca tu bolsa.',
        outcomePartial: 'El sello impresiona al legionario raso, pero el centurión quiere verlo dos veces. Al final funciona, aunque te ganaste una mirada que no olvida caras.',
        outcomeFail: '"Cualquiera puede mostrar un sello viejo", dice el centurión. La revisión que sigue es el doble de larga por haberlo intentado.',
      ),
      // Callback secreto: los centuriones oyeron cómo frenaste a los bandidos.
      RealOptionConfig(
        id: 'opt_known_by_legion', text: 'El centurión entrecierra los ojos: «¿Tú no eres el del camino de Capua?»',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'fought_bandits',
        repDelta: {Faction.legions: 2},
        outcomeSuccess: 'Asientes. El centurión se dirige a sus hombres sin dejar de mirarte: «Este le partió la cara a los de Capua y no soltó la bolsa.» Te devuelven el paso y algo parecido al respeto. Nadie revisa nada.',
        outcomePartial: 'La historia le llegó torcida —en su versión eran ocho bandidos y un oso— y te hace repetirla dos veces. Pasas igual, pero perdiste un rato haciendo de aedo.',
        outcomeFail: 'Te confunde con otro. Cuando aclaras el malentendido, el centurión ya decidió que eres sospechoso de algo. La revisión es completa.',
        journalNote: 'Un centurión me reconoció por lo de los bandidos. La fama viaja más rápido que yo.',
      ),
      // Callback secreto: el chico de los bolsillos rápidos devuelve el favor.
      RealOptionConfig(
        id: 'opt_thief_friend', text: 'Una figura pequeña te hace señas desde un callejón…',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'spared_thief',
        outcomeSuccess: 'Es el chico al que no perseguiste. Sin decir palabra, vuelca un cajón de gallinas en medio del control. En el caos, te cruza por un pasillo que solo los pibes de la calle conocen. Ya estás del otro lado.',
        outcomePartial: 'El chico te guía por los techos bajos del mercado. Casi te caes dos veces, pero funcionó. Antes de irse te dice: "Ahora estamos a mano."',
        outcomeFail: 'La distracción funciona a medias: pasas, pero un legionario te vio salir del callejón. Mejor no volver por acá en unos días.',
        journalNote: 'El chico de la bolsa me devolvió el favor frente a la patrulla. En Roma, nadie olvida.',
      ),
      RealOptionConfig(
        id: 'opt_legion_writ', text: 'Muestras el salvoconducto de la legión',
        riskLevel: 1, timeCostMinutes: 10, requiredSkills: {},
        minReputation: {Faction.legions: 30},
        lockedHint: 'Hace falta que las Legiones te respeten para tener ese papel.',
        outcomeSuccess: 'El centurión reconoce el sello de la Décima antes de terminar de desenrollarlo. Se cuadra a medias, que en un centurión es una reverencia, y te abre la barrera él mismo. Los que esperan en la fila te miran como a un tribuno.',
        outcomePartial: 'El salvoconducto vale, pero el optio nuevo lo lee entero, letra por letra, moviendo los labios. Diez minutos de gramática militar. Después te deja pasar con un saludo que le sale torcido.',
        outcomeFail: 'El papel es bueno; el centurión, desconfiado de oficio. Manda a un jinete a confirmar con el campamento y te sienta a esperar a la sombra. Vuelve con la confirmación y una disculpa que no suena a disculpa.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_storm',
    category: EventCategory.storm,
    title: 'Tormenta en el paso',
    description: 'Un frente de tormenta brutal cubre el camino. El viento derriba árboles y la lluvia convierte el sendero en barro.',
    options: [
      RealOptionConfig(
        id: 'opt_wait_storm', text: 'Buscas refugio y esperas que pase',
        riskLevel: 1, timeCostMinutes: 240, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        journalNote: 'Esperé la tormenta en una ermita. Varus dice que el paquete seco vale más que el correo rápido.',
        outcomeSuccess: 'Encuentras una ermita abandonada con el techo entero. Mientras el mundo se cae afuera, secas tus cosas junto a un fuego chico. La tormenta pasa; tú sigues.',
        outcomePartial: 'El refugio es apenas una cornisa de roca. Sales entumecido y con medio cuerpo mojado, pero el paquete quedó seco contra tu pecho.',
        outcomeFail: 'El "refugio" resulta ser el hogar de una familia de jabalíes con mal carácter. Entre la corrida y la lluvia, pierdes más tiempo del que pensabas.',
      ),
      RealOptionConfig(
        id: 'opt_push_storm', text: 'Fuerzas el paso bajo la lluvia',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        setFlags: ['walked_the_storm'],
        journalNote: 'Crucé el paso con la tormenta encima. No lo recomiendo. Lo volvería a hacer.',
        outcomeSuccess: 'Caminas inclinado contra el viento, leyendo el terreno como te enseñó el camino. Cada paso es una apuesta y las ganas todas. La tormenta queda atrás, tú no.',
        outcomePartial: 'Avanzas, pero la montaña cobra peaje: resbalas en el barro y un golpe en las costillas te acompaña el resto del viaje.',
        outcomeFail: 'Un árbol cae a metros tuyo y el estruendo te tira al barro. Sigues adelante, pero golpeado, empapado y maldiciendo en tres dialectos.',
      ),
      RealOptionConfig(
        id: 'opt_shortcut', text: 'Conoces un desvío por la ladera',
        riskLevel: 2, timeCostMinutes: 60, requiredSkills: {SkillType.survival: 1},
        outcomeSuccess: 'La ladera este corta el viento como una pared. El desvío es más largo en pasos pero más corto en problemas. Bien jugado.',
        outcomePartial: 'El desvío funciona, aunque la niebla te hace dudar en dos cruces. Llegas al otro lado con la ropa húmeda y la moral seca.',
        outcomeFail: 'La memoria te falla: el sendero de la ladera terminaba en un derrumbe viejo. Vuelves sobre tus pasos con la tormenta riéndose encima.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_bridge',
    category: EventCategory.river,
    title: 'Puente cortado',
    description: 'El puente principal sobre el río está destruido. Las crecidas de los últimos días se llevaron la mitad.',
    options: [
      RealOptionConfig(
        id: 'opt_swim', text: 'Cruzas el río a nado con el paquete en alto',
        riskLevel: 4, timeCostMinutes: 60, requiredSkills: {SkillType.survival: 3},
        outcomeSuccess: 'El agua está helada y la corriente empuja, pero tus brazos saben lo que hacen. Sales del otro lado chorreando, con el paquete seco sobre la cabeza como un trofeo.',
        outcomePartial: 'La corriente te arrastra río abajo más de lo planeado. Cruzaste, sí, pero ahora hay que desandar la orilla y el frío te caló los huesos.',
        outcomeFail: 'Un tronco sumergido te golpea las piernas y por un instante todo es agua y pánico. Sales del río sin saber cómo. El paquete... mejor revisarlo.',
      ),
      RealOptionConfig(
        id: 'opt_detour_b', text: 'Rodeas hasta el siguiente puente',
        riskLevel: 1, timeCostMinutes: 360, requiredSkills: {},
        outcomeSuccess: 'Seis horas de camino extra, cero sorpresas. A veces el mensajero más rápido es el que no se moja.',
        outcomePartial: 'El puente siguiente existe, pero está lleno de carros de mercado. Cruzas a paso de hombre entre bueyes y gritos.',
        outcomeFail: 'A mitad del rodeo descubres que el "siguiente puente" es apenas dos tablones con pretensiones. Cruzas igual, un tablón por vez, rezando en latín.',
      ),
      RealOptionConfig(
        id: 'opt_ferry', text: 'Negocias con un barquero local',
        riskLevel: 2, timeCostMinutes: 120, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'El barquero no pregunta qué llevas y tú no preguntas por qué su barca tiene doble fondo. Cruce limpio, trato justo, y un contacto nuevo en la orilla.',
        outcomePartial: 'El barquero acepta, pero primero termina "un asunto" en la otra orilla. Esperas viendo el agua pasar, que es lo único que acá se apura.',
        outcomeFail: 'El barquero quiere el triple al ver tu apuro. Regateas, pierdes, pagas con tiempo: te lleva último, después de tres viajes de cabras.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_bandits',
    category: EventCategory.bandits,
    title: 'Emboscada en el camino',
    description: 'Un grupo de bandidos sale de entre los árboles. Saben que llevas algo valioso. Te rodean con calma.',
    options: [
      RealOptionConfig(
        id: 'opt_fight', text: 'Defiendes tu carga con todo lo que tienes',
        riskLevel: 5, timeCostMinutes: 0, requiredSkills: {SkillType.combat: 3},
        repDelta: {Faction.underworld: -3, Faction.legions: 1},
        setFlags: ['fought_bandits'],
        outcomeSuccess: 'El primero que se acerca se lleva un codazo que le reacomoda las ideas. Los demás lo piensan mejor. "Este no", dice el jefe, y el camino se abre. La historia va a correr.',
        outcomePartial: 'Peleas como gato entre perros. Te llevas golpes, ellos también, y al final el paquete sigue siendo tuyo. Caro, pero tuyo.',
        outcomeFail: 'Eran demasiados. Te dejan en el suelo con el orgullo roto y el cuerpo peor, aunque el paquete —escondido a tiempo entre las piedras— sobrevive.',
        journalNote: 'Les planté cara a los bandidos del camino. Que se sepa: este mensajero no paga peajes.',
      ),
      RealOptionConfig(
        id: 'opt_run', text: 'Sales corriendo por el monte',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        setFlags: ['fled_bandits'],
        followUpEventId: 'evt_bandits_revenge',
        outcomeSuccess: 'Corres como si el mismísimo Mercurio te empujara. Cuando los gritos quedan atrás, sabes dos cosas: estás vivo, y ellos tienen memoria.',
        outcomePartial: 'Escapas por el monte perdiendo el aliento y un pedazo de capa en una zarza. Libre, pero esta gente no perdona una corrida.',
        outcomeFail: 'Corres, tropiezas, ruedas por una pendiente y aterrizas en un arroyo. Te escapaste de milagro, y ahora te conocen la cara.',
      ),
      RealOptionConfig(
        id: 'opt_negotiate', text: 'Negocias: les das algo a cambio del paso',
        riskLevel: 2, timeCostMinutes: 60, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.underworld: 3},
        setFlags: ['paid_bandits'],
        outcomeSuccess: 'Hablas su idioma: respeto, sin miedo. Unas monedas cambian de mano y el jefe te estudia. "Tú entiendes cómo funciona el camino. Ve." Acabas de comprar algo más que el paso.',
        outcomePartial: 'La negociación es tensa y el precio, injusto. Pero pagas y pasas, y en el mundo de los caminos eso ya es amistad.',
        outcomeFail: 'Aceptan tu pago... y te retienen una hora más "por las dudas". Humillante, pero saliste entero y en sus libros ya figuras como cliente.',
        journalNote: 'Pagué el peaje de los bandidos. Varus no lo aprobaría. Los bandidos, sí.',
      ),
      // Callback secreto: ya pagaste el peaje una vez.
      RealOptionConfig(
        id: 'opt_toll_paid', text: '"Pregúntenle a su jefe por el que pagó el peaje."',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'paid_bandits',
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'El más viejo del grupo entorna los ojos y te reconoce. "Es el que pagó el peaje. Déjalo pasar." Nadie más te toca. En este mundo, la palabra vale más que la espada.',
        outcomePartial: 'Tardan en reconocerte y hay un momento feo, manos en las empuñaduras. Después alguien se acuerda y todo se relaja. Pasas con el corazón a los saltos.',
        outcomeFail: 'El grupo es nuevo y tu nombre no les dice nada... hasta que un jinete llega con la contraseña. Perdiste un rato, pero la red funcionó.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_injured',
    category: EventCategory.road,
    title: 'Tropiezas en el camino',
    description: 'Una piedra suelta en el sendero te hace tropezar. Caes con fuerza. El tobillo duele, pero el paquete parece estar bien.',
    options: [
      RealOptionConfig(
        id: 'opt_rest', text: 'Descansas unas horas antes de seguir',
        riskLevel: 1, timeCostMinutes: 180, requiredSkills: {},
        outcomeSuccess: 'Vendas el tobillo con una tira de tu túnica y duermes a la sombra de un olivo. Al despertar, el dolor es un recuerdo y el camino sigue donde lo dejaste.',
        outcomePartial: 'El descanso ayuda a medias: el tobillo baja la hinchazón pero cada pendiente te lo recuerda. Sigues, más lento y más sabio.',
        outcomeFail: 'Te duermes más de la cuenta bajo el sol que se mueve. Despiertas sobresaltado, con el tobillo mejor y la agenda peor.',
      ),
      RealOptionConfig(
        id: 'opt_push_on', text: 'Ignoras el dolor y sigues a toda marcha',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        repDelta: {Faction.guild: 1},
        journalNote: 'Seguí con el tobillo hinchado. El paquete llegó a tiempo; yo, a medias.',
        outcomeSuccess: 'Aprietas los dientes y encuentras el paso que duele menos. El cuerpo protesta, la voluntad manda. No perdiste ni un minuto.',
        outcomePartial: 'Sigues, pero el tobillo te cobra intereses en cada bajada. Llegas al siguiente tramo cojeando y de mal humor.',
        outcomeFail: 'A la legua siguiente el tobillo dice basta y te sientas donde el cuerpo decide. Terminas descansando igual, pero en el peor lugar posible.',
      ),
      // Callback secreto: el viajero al que auxiliaste devuelve el gesto.
      RealOptionConfig(
        id: 'opt_traveler_cart', text: 'Un carro frena a tu lado y el que lo maneja te conoce…',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'helped_traveler',
        repDelta: {Faction.guild: 1},
        journalNote: 'El viajero que auxilié en el camino me levantó con su carro cuando el tobillo me falló. Roma es más chica de lo que parece.',
        outcomeSuccess: 'Es el hombre al que vendaste hace unas semanas. No pregunta nada: baja, te sube al carro y arrea las mulas. "Tú me diste una tarde. Yo te doy dos leguas." El tobillo descansa y el plazo también.',
        outcomePartial: 'El carro va cargado hasta el techo y solo hay lugar entre las ánforas. Viajas incómodo, entero y agradecido: es más de lo que tenías hace un minuto.',
        outcomeFail: 'El carro pierde una rueda a media legua. Terminas empujando con el tobillo hinchado y los dos riéndose de lo absurdo del asunto. Igual, no caminaste solo.',
      ),
    ],
  ),

  // ══ Evento encadenado — la memoria de los bandidos ═════════════════════════

  RealEventConfig(
    id: 'evt_bandits_revenge',
    category: EventCategory.bandits,
    title: 'Te estaban esperando',
    description: 'Más adelante, el camino se angosta entre dos lomas. Ahí están otra vez: los mismos bandidos, el doble de hombres, y el jefe al frente con una sonrisa sin apuro. "El que corre, vuelve a pasar."',
    options: [
      RealOptionConfig(
        id: 'opt_revenge_fight', text: 'Esta vez no corres: plantas pelea',
        riskLevel: 5, timeCostMinutes: 0, requiredSkills: {SkillType.combat: 3},
        repDelta: {Faction.underworld: -2},
        outcomeSuccess: 'No esperaban que el que corrió diera el primer golpe. La sorpresa vale por dos hombres. Cuando el polvo baja, el paso es tuyo y la historia también.',
        outcomePartial: 'La pelea es fea y pareja. Terminas pasando, pero dejas sangre propia en el peaje que no quisiste pagar.',
        outcomeFail: 'Esta vez el número pudo más. Te sacuden el cuerpo y el bolso, aunque lo importante estaba bien escondido. La lección duele.',
      ),
      RealOptionConfig(
        id: 'opt_revenge_pay', text: 'Pagas el peaje... con recargo',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {},
        repDelta: {Faction.underworld: 2},
        setFlags: ['paid_bandits'],
        outcomeSuccess: 'El jefe cuenta las monedas dos veces y asiente. "Aprendes rápido." Te abren paso con algo parecido al respeto. El camino tiene sus reglas.',
        outcomePartial: 'Pagas el doble de lo que hubiera costado la primera vez. El jefe te lo hace saber con una sonrisa. Lección cara pero completa.',
        outcomeFail: 'Pagas, y encima te hacen esperar mientras "verifican" que no lleves más. Sales más liviano de bolsa y de paciencia.',
      ),
      RealOptionConfig(
        id: 'opt_revenge_ghost', text: 'Los viste primero: te fundes con el terreno',
        riskLevel: 4, timeCostMinutes: 60, requiredSkills: {SkillType.stealth: 3},
        outcomeSuccess: 'Cuerpo a tierra, paciencia de piedra. Los ves pasar a metros, escuchas sus chistes malos, y cuando el camino queda libre ya eres parte de la tarde. Nunca supieron.',
        outcomePartial: 'Los esquivas arrastrándote por una acequia seca. Funciona, pero sales oliendo a barro viejo y con horas perdidas.',
        outcomeFail: 'Un perro flaco del campamento te olfatea y ladra. Corres de nuevo, y de nuevo te salvas por poco. Esto se está volviendo costumbre.',
      ),
    ],
  ),

  // ══ Dilemas — acá no hay respuesta correcta ════════════════════════════════

  RealEventConfig(
    id: 'evt_wounded_traveler',
    category: EventCategory.road,
    title: 'El viajero caído',
    description: 'Al costado del camino, un hombre mayor yace junto a su mula muerta. Respira con dificultad y levanta una mano al verte. Llevas una entrega con plazo. Él no tiene a nadie más.',
    options: [
      RealOptionConfig(
        id: 'opt_help_full', text: 'Lo ayudas como se debe: agua, vendas y hasta el pueblo',
        riskLevel: 1, timeCostMinutes: 120, requiredSkills: {},
        repDelta: {Faction.guild: 2},
        setFlags: ['helped_traveler'],
        journalNote: 'Perdí dos horas ayudando a un viejo en el camino. Hay entregas que no llevan sello.',
        outcomeSuccess: 'Lo cargas hasta el caserío más cercano. Resulta ser un mercader conocido en tres provincias. "Un mensajero que se detiene", dice. "Voy a acordarme de tu cara, y de tu gremio." ',
        outcomePartial: 'Lo dejas a salvo con una familia de pastores. Perdiste dos horas y ganaste algo que no cotiza en denarios.',
        outcomeFail: 'El viejo es más terco que su mula: insiste en volver por sus mercancías. Tardas más de lo planeado en convencerlo de que la vida vale más que los odres.',
      ),
      RealOptionConfig(
        id: 'opt_help_quick', text: 'Le dejas agua y lo acomodas a la sombra — el plazo manda',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.survival: 2},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Manos rápidas: lo hidratas, le entablillas el brazo y lo dejas visible para la próxima caravana. Lo mejor de ambos mundos, y el plazo respira.',
        outcomePartial: 'Haces lo que puedes en poco tiempo. Al alejarte, su "gracias" te sigue durante una legua entera.',
        outcomeFail: 'Con el apuro, el vendaje queda flojo y tienes que rehacerlo. La medida a medias siempre cuesta el doble.',
      ),
      RealOptionConfig(
        id: 'opt_pass_by', text: 'Apartas la mirada y sigues — el mensaje no puede esperar',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        setFlags: ['left_traveler'],
        journalNote: 'Dejé a un hombre tirado en el camino porque el plazo mandaba. El plazo. Eso me digo.',
        outcomeSuccess: 'Sigues de largo con el paso firme y la conciencia menos. El oficio es el oficio, te repites. Casi te lo crees.',
        outcomePartial: 'Pasas sin mirar. Cien pasos después, miras atrás igual. Todavía levanta la mano.',
        outcomeFail: 'Sigues de largo, pero su voz te acompaña más lejos que cualquier tormenta. Esta entrega va a llegar a tiempo y a pesar mucho.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_letter_bribe',
    category: EventCategory.inn,
    title: 'El precio de la curiosidad',
    description: 'En la posada, un hombre de manos limpias y acento del norte se sienta a tu mesa sin invitación. "Sé lo que llevas. Solo quiero leerlo. Nadie va a enterarse, y esto..." — desliza una bolsita que suena a monedas — "...es tuyo."',
    options: [
      RealOptionConfig(
        id: 'opt_refuse_seal', text: '"El sello no se toca." Te levantas de la mesa',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: 2, Faction.underworld: -1},
        setFlags: ['refused_spy'],
        journalNote: 'Alguien quiso comprar mi correo en una posada. El sello no se toca. Nunca.',
        outcomeSuccess: 'Te levantas sin drama y él no insiste: los profesionales se reconocen. Al salir, notas que el posadero te sirve mejor vino. Las paredes escuchan, y a veces aprueban.',
        outcomePartial: 'Rechazas la oferta y él sonríe como quien anota algo en una lista. Sales de la posada con la nuca tensa, pero con el sello intacto.',
        outcomeFail: 'Tu negativa suena más fuerte de lo que querías y media posada se entera de que llevas algo valioso. Duermes con un ojo abierto.',
      ),
      RealOptionConfig(
        id: 'opt_take_bribe', text: 'Aceptas la bolsa y miras para otro lado un minuto',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.underworld: 2, Faction.patricians: -2},
        setFlags: ['sold_a_look'],
        journalNote: 'Dejé que un desconocido leyera un correo ajeno por una bolsa de plata. El sello estaba intacto al final. Yo, no tanto.',
        outcomeSuccess: 'El hombre lee rápido, memoriza y vuelve a plegar la carta con dedos de cirujano. El sello ni se dañó. La bolsita pesa bien. Lo que pese tu conciencia es asunto tuyo.',
        outcomePartial: 'Lee la carta, pero el sello queda... convincente, no perfecto. Con suerte, nadie mira dos veces. Con suerte.',
        outcomeFail: 'Cuando el hombre termina, notas que el sello no volvió a cerrar bien. Te pagaron, sí, pero ahora entregas una carta que grita que fue abierta.',
      ),
      RealOptionConfig(
        id: 'opt_double_game', text: 'Finges aceptar... y le muestras una carta falsa',
        riskLevel: 4, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 3},
        repDelta: {Faction.underworld: 1, Faction.patricians: 1},
        outcomeSuccess: 'Le vendes humo con cara de mármol: una lista de precios de aceitunas con sello de utilería. Paga, lee, asiente como un entendido y se va. Obra de arte.',
        outcomePartial: 'El truco funciona a medias: sospecha, paga la mitad y se va sin despedirse. El correo real nunca salió de tu túnica.',
        outcomeFail: 'Reconoce la carta falsa al segundo vistazo. Se levanta sin decir palabra, y esa mirada te dice que quedaste en la lista equivocada.',
      ),
      RealOptionConfig(
        id: 'opt_guild_warning', text: '"El Gremio ya sabe quién eres. Vete."',
        riskLevel: 2, timeCostMinutes: 10, requiredSkills: {},
        minReputation: {Faction.guild: 30},
        lockedHint: 'Para hablar en nombre del Gremio, el Gremio te tiene que respetar.',
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Lo dices sin levantar la voz. El hombre del norte recoge la bolsa despacio, como si se le hubiera caído, y se va sin terminar el vino. En las postas de la red, una amenaza del Gremio vale más que una espada.',
        outcomePartial: 'Duda, calcula y al final se levanta, pero antes te deja dicho que el Gremio no está en todas las posadas. Tiene razón. Esta noche duermes con el bolso de almohada.',
        outcomeFail: 'Se ríe. "El Gremio está lejos y yo estoy acá." No se va hasta que el posadero, que sí conoce a Varus, le pide que pague y se retire. Te salvó el posadero, no tu nombre. Todavía.',
      ),
      RealOptionConfig(
        id: 'opt_known_cipher', text: 'Reconoces la cifra: es la del rollo que leíste',
        riskLevel: 2, timeCostMinutes: 20, requiredSkills: {},
        requiredFlag: 'saw_the_message',
        repDelta: {Faction.legions: 1},
        journalNote: 'El hombre del norte usaba la misma cifra que el rollo de la plaza. Ahora sé para quién trabaja, y él sabe que lo sé.',
        outcomeSuccess: 'En la tablilla que asoma de su manga está la misma cifra del rollo que abriste en la plaza. Se lo dices en voz baja. Se pone pálido, deja la bolsa sobre la mesa y se va. La bolsa también es un mensaje: cállate.',
        outcomePartial: 'Le nombras la cifra y él no se va: se queda a negociar qué sabes y qué no. Media hora de esgrima con palabras. Al final se levanta, pero te deja claro que ahora te tiene anotado.',
        outcomeFail: 'Le nombras la cifra y te equivocas en un signo. Él sonríe: sabes algo, pero no tanto. Se va sin la carta y con tu cara bien estudiada. La próxima vez va a venir mejor preparado.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_pickpocket',
    category: EventCategory.forum,
    title: 'Manos rápidas',
    description: 'Un tirón seco en el cinturón: un chico de no más de diez años sale corriendo con tu bolsa de monedas entre codos y canastos. El correo lo tienes encima. Las monedas, ya no.',
    options: [
      RealOptionConfig(
        id: 'opt_chase', text: 'Lo persigues por los callejones',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Lo alcanzas en tres cuadras: el oficio corre más que el hambre. Recuperas la bolsa. El chico espera el golpe que no llega. "Corre para otro lado la próxima", le dices.',
        outcomePartial: 'Lo pierdes en el laberinto, pero la bolsa aparece tirada en una esquina: se llevó unas monedas y dejó el resto. Un ladrón con apuro, no con odio.',
        outcomeFail: 'El chico conoce cada rendija del barrio y tú ninguna. Terminas en un callejón sin salida, sin bolsa y con dos vecinas riéndose.',
      ),
      RealOptionConfig(
        id: 'opt_let_go', text: 'Lo dejas ir — conoces esa flacura',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.underworld: 1},
        setFlags: ['spared_thief'],
        journalNote: 'Un chico me robó la bolsa y lo dejé correr. Tenía el hambre que yo tuve. Que la gaste bien.',
        outcomeSuccess: 'Bajas el brazo y lo miras perderse entre la gente. Un verdulero que vio todo te alcanza una manzana: "Bien hecho. Ese chico mantiene tres bocas." Roma tiene ojos.',
        outcomePartial: 'Lo dejas ir con rabia y algo más viejo que la rabia. El dinero se repone. Otras cosas no.',
        outcomeFail: 'Lo dejas ir... y a la cuadra descubres que también te llevó el pañuelo bueno. El gesto noble tiene sus impuestos.',
      ),
      RealOptionConfig(
        id: 'opt_call_guards', text: '"¡Al ladrón!" — que lo agarren los guardias',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {},
        repDelta: {Faction.legions: 1, Faction.underworld: -2},
        outcomeSuccess: 'Dos guardias lo atrapan en la esquina. Te devuelven la bolsa completa. El chico te mira mientras se lo llevan. La ley es la ley, te dices. La mirada no se va.',
        outcomePartial: 'Los guardias llegan tarde para el chico pero a tiempo para el sermón: media hora de preguntas para devolverte una bolsa que apareció vacía.',
        outcomeFail: 'El grito solo consigue que todo el mercado te mire a ti. El chico ya es un recuerdo y los guardias, un interrogatorio.',
      ),
      RealOptionConfig(
        id: 'opt_subura_whistle', text: 'Silbas la seña de la Subura',
        riskLevel: 1, timeCostMinutes: 10, requiredSkills: {},
        minReputation: {Faction.underworld: 30},
        lockedHint: 'Esa seña solo la conocen los que la Subura respeta.',
        outcomeSuccess: 'Dos notas cortas y una larga. El chico frena en seco a mitad del callejón, se da vuelta, te mira bien y vuelve caminando con la bolsa estirada. "No sabía que eras de los nuestros." Ahora lo sabe media cuadra.',
        outcomePartial: 'El silbido llega, pero el chico duda: la seña la conoce, tu cara no. Vuelve a medias, tira la bolsa a tus pies y desaparece. Falta una moneda. Es el precio de que no te conozcan todavía de vista.',
        outcomeFail: 'Silbas bien, pero el chico es nuevo y nadie le enseñó la seña. Sigue corriendo. Una vieja desde un balcón te señala para dónde fue y diez minutos después lo encuentras contando tu dinero. Te la devuelve con cara de ofendido.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_rival_messenger',
    category: EventCategory.road,
    npcId: 'marco',
    title: 'El colega caído',
    description: 'Sentado contra un mojón, un mensajero de otra red se agarra el tobillo hinchado. Te reconoce el morral al instante. "Colega... mi entrega vence hoy en el mismo pueblo al que vas. Llévala tú. Te debo una que no te imaginas."',
    options: [
      RealOptionConfig(
        id: 'opt_take_letter', text: 'Aceptas su carta — hoy por él, mañana por ti',
        riskLevel: 2, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.guild: 3},
        setFlags: ['helped_rival'],
        journalNote: 'Llevé la entrega de un colega caído además de la mía. El gremio es esto, aunque él sea de otra red.',
        outcomeSuccess: 'Entregas las dos cartas y vuelves a buscarlo con un carretero amigo. Para el ocaso, todos los mensajeros del camino saben tu nombre. Esa moneda no se gasta nunca.',
        outcomePartial: 'Llevas ambas entregas, aunque el desvío te cuesta caro en tiempo. El colega promete devolverla. Los tobillos sanan; las deudas de honor, no.',
        outcomeFail: 'Su destinatario resultó vivir en la otra punta del pueblo, tras dos puertas equivocadas y un perro con opiniones. Cumpliste, pero el favor salió carísimo.',
      ),
      RealOptionConfig(
        id: 'opt_refuse_letter', text: '"Lo siento, colega. Mi plazo no perdona."',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: -1},
        outcomeSuccess: 'Le dejas tu cantimplora y la mitad de tu pan, pero la carta no. Él asiente: entiende el oficio mejor que nadie. No hay rencor. Tampoco hay favor.',
        outcomePartial: 'Te alejas con su silencio a la espalda. En el oficio se cuenta todo: lo que haces y lo que no.',
        outcomeFail: 'Dos días después te enteras: su entrega era la paga de un pueblo entero. Llegó tarde. Nadie te culpa en voz alta.',
      ),
      RealOptionConfig(
        id: 'opt_carry_him', text: 'Ni la carta ni excusas: lo cargas a él hasta el pueblo',
        riskLevel: 3, timeCostMinutes: 120, requiredSkills: {SkillType.survival: 2},
        repDelta: {Faction.guild: 2},
        setFlags: ['helped_rival'],
        outcomeSuccess: 'Una legua y media con un mensajero al hombro que no para de disculparse. Llegan los dos, entregan los dos. En la taberna esa noche, la historia ya tiene música.',
        outcomePartial: 'Lo cargas a tramos, descansando cada mil pasos. Llegan tarde pero llegan, y su gratitud pesa menos que él, por suerte.',
        outcomeFail: 'A mitad de camino aparece el carro de su propia red: te agradecen secamente y se lo llevan. Dos horas de esfuerzo para una lección de humildad.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_merchant_offer',
    category: EventCategory.forum,
    title: 'El carro del mercader',
    description: 'Un mercader con demasiados anillos te ofrece viajar en su carro: "Llegas en la mitad del tiempo. Solo te pido que si alguien pregunta, tú no viste lo que hay bajo la lona." Bajo la lona hay ánforas sin sello de aduana.',
    options: [
      RealOptionConfig(
        id: 'opt_ride_contraband', text: 'Subes al carro y miras el paisaje',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.underworld: 2, Faction.legions: -1},
        setFlags: ['rode_contraband'],
        journalNote: 'Viajé rápido en un carro que las aduanas no vieron. Yo tampoco vi nada. Así funciona.',
        outcomeSuccess: 'El carro vuela por la vía y el mercader resulta buena compañía: conoce cada posada y cada guardia comprable del camino. Llegas fresco, rápido y con nuevos conocidos.',
        outcomePartial: 'El viaje es rápido pero tenso: dos controles pasados con sonrisas de piedra. Bajas del carro con las piernas dormidas y el pulso despierto.',
        outcomeFail: 'A mitad del viaje, un eje cede por el sobrepeso de la lona misteriosa. Ayudas a repararlo — qué remedio — y llegas con las manos sucias en más de un sentido.',
      ),
      RealOptionConfig(
        id: 'opt_decline_ride', text: 'Declinas con una sonrisa y sigues a pie',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        outcomeSuccess: '"Mis piernas son mi oficio", le dices, y el mercader se ríe y te tira una manzana. Cada cual con su camino y sus riesgos.',
        outcomePartial: 'Sigues a pie viendo el polvo del carro alejarse. Más lento, más limpio. El oficio también es saber decir que no.',
        outcomeFail: 'Una legua después, el carro te pasa de vuelta... detenido por una patrulla que revisa la lona. Apuras el paso mirando fijo el horizonte. Buena decisión, mejor timing.',
      ),
      RealOptionConfig(
        id: 'opt_report_merchant', text: 'Anotas el carro y avisas en el próximo puesto de control',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {},
        repDelta: {Faction.legions: 2, Faction.underworld: -3},
        setFlags: ['reported_smuggler'],
        journalNote: 'Denuncié a un contrabandista en el puesto de control. Las Legiones lo agradecen. Los caminos tienen memoria, y no toda es amable.',
        outcomeSuccess: 'El decurión anota tu descripción con precisión militar. "Roma agradece a sus ojos en el camino." Te sella un salvoconducto para la zona. Del otro lado del favor, alguien maldice tu nombre.',
        outcomePartial: 'El aviso llega tarde: el carro cambió de ruta. Igual, el decurión registra tu buena voluntad. Y los mercaderes del camino, tu cara.',
        outcomeFail: 'El puesto está a cargo de un guardia que bosteza y anota tu denuncia en la memoria, que es donde se pierden las cosas. Perdiste tiempo y ganaste enemigos.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_old_soldier',
    category: EventCategory.inn,
    title: 'El veterano del puente',
    description: 'Un veterano de las legiones, más vino que hombre a esta hora, bloquea el paso angosto del puente. "¡Nadie cruza sin escuchar cómo perdí este ojo en la Galia!" No parece que la historia sea corta. Tampoco parece mentira.',
    options: [
      RealOptionConfig(
        id: 'opt_listen_story', text: 'Te sientas en la baranda y lo escuchas',
        riskLevel: 1, timeCostMinutes: 45, requiredSkills: {},
        repDelta: {Faction.guild: 1, Faction.legions: 1},
        journalNote: 'Perdí una hora escuchando a un veterano tuerto en un puente. La historia era buena. Nadie más se la escucha.',
        outcomeSuccess: 'La historia es larga, exagerada y magnífica. Al final, el viejo te aprieta el hombro: "Eres el primero en un año que no me esquiva." Te cruza el puente él mismo, como escolta de honor.',
        outcomePartial: 'Escuchas la versión completa, con desvíos por tres campañas y dos esposas. Pierdes casi una hora. El viejo gana un buen día.',
        outcomeFail: 'A mitad del relato, el veterano se queda dormido de pie, apoyado en tu hombro. Lo acomodas contra la baranda y cruzas en puntas de pie.',
      ),
      RealOptionConfig(
        id: 'opt_push_past', text: 'Lo esquivas con un quiebre de cintura',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Un amague al este, un paso al oeste, y ya estás del otro lado. "¡Reflejos de explorador!", grita el viejo, entre ofendido y admirado.',
        outcomePartial: 'Lo esquivas, pero el veterano alcanza a agarrarte la capa y tienes que dejársela para librarte. La recuperas del otro lado, con disculpas mutuas.',
        outcomeFail: 'El viejo tuerto resulta tener los reflejos intactos del lado bueno. Te atrapa del brazo y ahora la historia empieza desde el principio. Con más detalles.',
      ),
      RealOptionConfig(
        id: 'opt_soldier_salute', text: 'Te cuadras y lo saludas por su rango',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'Reconoces la cicatriz de la XII Fulminata y lo saludas como corresponde. El veterano se endereza tres pulgadas, devuelve el saludo y se aparta marcial. "Paso libre al correo."',
        outcomePartial: 'Fallas con la legión pero aciertas con el respeto. El viejo te corrige con paciencia y te deja pasar igual.',
        outcomeFail: '"¿La XII? ¡La XII eran unos inútiles!" Elegiste la legión rival. La historia ahora incluye por qué su legión era mejor. Con demostraciones.',
      ),
    ],
  ),

  RealEventConfig(
    id: 'evt_omen',
    category: EventCategory.temple,
    title: 'El augur del cruce',
    description: 'En el cruce de caminos, un augur flaco lee el vuelo de los pájaros. Te clava los ojos: "Mensajero. Los cuervos volaron contra el sol. Hay sombra en tu camino... a menos que los dioses reciban lo suyo."',
    options: [
      RealOptionConfig(
        id: 'opt_pay_respect', text: 'Dejas una moneda en el altar del cruce',
        riskLevel: 1, timeCostMinutes: 15, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        setFlags: ['paid_the_augur'],
        outcomeSuccess: 'La moneda tintinea en el altar y el augur asiente lento. "Los dioses miran a los que miran." Sigues camino con una calma rara, como si el aire pesara menos.',
        outcomePartial: 'Dejas la moneda, el augur murmura algo en etrusco y te salpica con agua de un cuenco dudoso. Protegido o mojado: uno de los dos, seguro.',
        outcomeFail: 'Buscas la moneda y descubres que solo te queda una grande. El augur la mira. Tú lo miras. Los dioses ganan el pulso. Carísima, la sombra.',
      ),
      RealOptionConfig(
        id: 'opt_dismiss_omen', text: '"Mis plazos no entienden de cuervos." Sigues de largo',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: -1},
        journalNote: 'Le dije que no a un augur en el cruce. En Roma eso se cuenta.',
        outcomeSuccess: 'Pasas de largo. Ningún rayo cae, ningún cuervo ataca. La superstición es el único peaje opcional del Imperio.',
        outcomePartial: 'Sigues sin pagar, pero durante la siguiente legua cada sombra de pájaro te hace levantar la vista. El augur cobra igual, a su manera.',
        outcomeFail: 'Cien pasos después del cruce, tropiezas con la raíz más visible de todo el camino. Desde atrás, la voz del augur: "¡Los cuervos, mensajero!" No te dignas a mirar.',
      ),
      RealOptionConfig(
        id: 'opt_read_birds', text: 'Miras el cielo y lees los pájaros tú mismo',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 3},
        repDelta: {Faction.underworld: 1},
        setFlags: ['read_the_birds'],
        journalNote: 'Le leí los pájaros al augur del cruce. Se quedó sin presagio y yo sin sombra.',
        outcomeSuccess: 'Conoces el cielo mejor que cualquier augur de cruce: esos cuervos van al bebedero del molino, como todas las tardes. "Volaron contra el sol porque el molino queda al oeste", dices. El augur, por primera vez en años, se queda sin presagio.',
        outcomePartial: 'Lees los pájaros a tu manera y sigues. El augur grita algo sobre la arrogancia de los jóvenes. Empate técnico.',
        outcomeFail: 'Señalas el cielo con confianza justo cuando una bandada entera cambia de rumbo sin avisar. El augur sonríe con todos los dientes que le quedan. Pagas la moneda. Por las dudas.',
      ),
    ],
  ),
];
