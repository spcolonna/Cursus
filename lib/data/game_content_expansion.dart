// ═══════════════════════════════════════════════════════════════
// GAME CONTENT — EXPANSION PACK
// 12 rutas nuevas (real_04..real_15) y 15 eventos nuevos del camino.
// No modifica game_content.dart: se importa y se agrega por separado.
// Español neutro, sin emojis, sin anacronismos (ver .claude/skills/historia).
// ═══════════════════════════════════════════════════════════════

import 'consequence_content.dart';
import 'faction_content.dart';
import 'game_content.dart';
import 'road_events_v2.dart';
import 'story_rewards.dart';
import '../domain/entities/entities.dart';
import '../domain/entities/world.dart';

// ═══════════════════════════════════════════════════════════════
// EXPANSION MISSIONS — real_04 .. real_15
// ═══════════════════════════════════════════════════════════════

/// Todas las rutas jugables: base + expansión + facción + premios de arcos.
List<RealMissionConfig> get allRealMissions => [
      ...phase1Missions,
      ...expansionMissions,
      ...factionMissions,
      ...storyRewardMissions,
    ];

/// Todo el pool de eventos del camino: base + expansión + consecuencias + v2.
List<RealEventConfig> get allRealEvents =>
    [...realEventPool, ...expansionEvents, ...consequenceEvents, ...roadEventsV2];

const List<RealMissionConfig> expansionMissions = [
  RealMissionConfig(
    id: 'real_04',
    origin: 'Roma',
    destination: 'Tibur',
    distanceKm: 25,
    durationMinutes: 30,
    danger: 0.10,
    requiredRank: 1,
    patron: Faction.guild,
    lore: 'Un recado breve a Tibur, entre villas de veraneo y el rumor fresco de las cascadas.',
    packageOptions: [
      'Una invitación para una cena de verano',
      'Un recado personal para la villa de un magistrado',
    ],
    eventPoolIds: ['evt_patrol', 'evt_pickpocket', 'evt_tax_collector', 'evt_lost_child', 'evt_aqueduct_works', 'evt_compitalia'],
    minEvents: 1,
    maxEvents: 1,
  ),
  RealMissionConfig(
    id: 'real_05',
    origin: 'Roma',
    destination: 'Praeneste',
    distanceKm: 38,
    durationMinutes: 45,
    danger: 0.15,
    requiredRank: 1,
    patron: Faction.patricians,
    lore: 'El Templo de la Fortuna en Praeneste espera un mensaje que no puede demorarse ni un día.',
    packageOptions: [
      'Una ofrenda sellada para el templo',
      'Correspondencia de un sacerdote a su familia en Roma',
    ],
    eventPoolIds: ['evt_patrol', 'evt_omen', 'evt_temple_theft', 'evt_wedding_road', 'evt_pilgrims', 'evt_compitalia', 'evt_aqueduct_works'],
    minEvents: 1,
    maxEvents: 1,
  ),
  RealMissionConfig(
    id: 'real_06',
    origin: 'Roma',
    destination: 'Antium',
    distanceKm: 57,
    durationMinutes: 60,
    danger: 0.15,
    requiredRank: 1,
    patron: Faction.guild,
    lore: 'La costa de Antium, villa de patricios, aguarda correspondencia que prefiere no viajar sola.',
    packageOptions: [
      'Cartas entre dos villas de la costa',
      'Un pedido urgente de un patricio retirado',
    ],
    eventPoolIds: ['evt_patrol', 'evt_merchant_offer', 'evt_cart_jam', 'evt_tax_collector', 'evt_ferry', 'evt_census', 'evt_poet', 'evt_wreck_salvage'],
    minEvents: 1,
    maxEvents: 2,
  ),
  RealMissionConfig(
    id: 'real_07',
    origin: 'Neapolis',
    destination: 'Pompeii',
    distanceKm: 25,
    durationMinutes: 90,
    danger: 0.30,
    requiredRank: 1,
    patron: Faction.underworld,
    lore: 'Un salto corto entre Neapolis y Pompeii, por caminos que huelen a mar y a azufre.',
    packageOptions: [
      'Un cargamento de pergaminos comerciales',
      'Una carta entre comerciantes de vino',
    ],
    eventPoolIds: ['evt_bandits', 'evt_heatwave', 'evt_wolf', 'evt_pickpocket', 'evt_oracle', 'evt_bees', 'evt_gladiator_troupe'],
    minEvents: 1,
    maxEvents: 2,
  ),
  RealMissionConfig(
    id: 'real_08',
    origin: 'Roma',
    destination: 'Cumae',
    distanceKm: 225,
    durationMinutes: 180,
    danger: 0.35,
    requiredRank: 2,
    patron: Faction.patricians,
    lore: 'La cueva de la Sibila espera en Cumae. Dicen que ahí los caminos también hablan.',
    packageOptions: [
      'Una consulta escrita para la Sibila',
      'Correspondencia de un senador supersticioso',
    ],
    eventPoolIds: ['evt_storm', 'evt_oracle', 'evt_omen', 'evt_ghost_road', 'evt_bandits', 'evt_merchant_offer', 'evt_pilgrims', 'evt_poet'],
    minEvents: 2,
    maxEvents: 3,
  ),
  RealMissionConfig(
    id: 'real_09',
    origin: 'Roma',
    destination: 'Beneventum',
    distanceKm: 240,
    durationMinutes: 240,
    danger: 0.40,
    requiredRank: 2,
    patron: Faction.legions,
    lore: 'Beneventum, cruce de caminos del sur, necesita noticias que no esperen la próxima caravana.',
    packageOptions: [
      'Órdenes administrativas para el cruce de caminos',
      'Correspondencia militar de rutina',
    ],
    eventPoolIds: ['evt_bandits', 'evt_injured', 'evt_wolf', 'evt_deserter', 'evt_old_soldier', 'evt_heatwave', 'evt_shepherd_dispute', 'evt_apennine_fog', 'evt_fugitive'],
    minEvents: 2,
    maxEvents: 3,
  ),
  RealMissionConfig(
    id: 'real_10',
    origin: 'Ravenna',
    destination: 'Aquileia',
    distanceKm: 130,
    durationMinutes: 360,
    danger: 0.30,
    requiredRank: 2,
    patron: Faction.legions,
    lore: 'Entre pantanos del norte, Ravenna y Aquileia se hablan por mensajeros, no por mapas confiables.',
    packageOptions: [
      'Registros de aduana entre puertos del norte',
      'Correspondencia de mercaderes de ámbar',
    ],
    eventPoolIds: ['evt_flood', 'evt_ferry', 'evt_landslide', 'evt_patrol', 'evt_storm', 'evt_spy_drop', 'evt_plague_village', 'evt_salt_road'],
    minEvents: 2,
    maxEvents: 3,
  ),
  RealMissionConfig(
    id: 'real_11',
    origin: 'Pisae',
    destination: 'Genua',
    distanceKm: 140,
    durationMinutes: 480,
    danger: 0.40,
    requiredRank: 2,
    patron: Faction.underworld,
    lore: 'La costa entre Pisae y Genua es hermosa y traicionera a partes iguales. Lleva abrigo.',
    packageOptions: [
      'Cartas entre astilleros de la costa',
      'Un contrato de compra de madera naval',
    ],
    eventPoolIds: ['evt_landslide', 'evt_storm', 'evt_wolf', 'evt_bridge', 'evt_forge_fire', 'evt_injured', 'evt_mute_boy', 'evt_charcoal_burners', 'evt_fallen_milestone'],
    minEvents: 2,
    maxEvents: 4,
  ),
  RealMissionConfig(
    id: 'real_12',
    origin: 'Roma',
    destination: 'Tarentum',
    distanceKm: 480,
    durationMinutes: 480,
    danger: 0.50,
    requiredRank: 2,
    patron: Faction.underworld,
    lore: 'Tarentum, puerto del sur, paga bien a quien llega antes que el rumor.',
    packageOptions: [
      'Correspondencia de un armador del sur',
      'Documentos de embarque hacia Oriente',
    ],
    eventPoolIds: ['evt_tax_collector', 'evt_deserter', 'evt_spy_drop', 'evt_heatwave', 'evt_merchant_offer', 'evt_rival_messenger', 'evt_fugitive', 'evt_bees', 'evt_shepherd_dispute'],
    minEvents: 2,
    maxEvents: 4,
  ),
  RealMissionConfig(
    id: 'real_13',
    origin: 'Roma',
    destination: 'Brundisium',
    distanceKm: 540,
    durationMinutes: 720,
    danger: 0.55,
    requiredRank: 3,
    patron: Faction.legions,
    lore: 'Brundisium embarca hacia Oriente. Lo que llega tarde, se queda en el muelle.',
    packageOptions: [
      'Órdenes de embarque para las legiones de Oriente',
      'Correspondencia diplomática sellada',
    ],
    eventPoolIds: ['evt_deserter', 'evt_spy_drop', 'evt_tax_collector', 'evt_letter_bribe', 'evt_heatwave', 'evt_old_soldier', 'evt_wedding_road', 'evt_pontine_barge', 'evt_dice_game', 'evt_horse_sick'],
    minEvents: 3,
    maxEvents: 4,
  ),
  RealMissionConfig(
    id: 'real_14',
    origin: 'Roma',
    destination: 'Aquileia',
    distanceKm: 600,
    durationMinutes: 1440,
    danger: 0.50,
    requiredRank: 3,
    patron: Faction.guild,
    lore: 'Un día entero de camino hasta la frontera de Aquileia, donde Roma empieza a dudar de sus propios mapas.',
    packageOptions: [
      'Tratados fronterizos para el gobernador de la región',
      'Correspondencia militar confidencial',
    ],
    eventPoolIds: ['evt_flood', 'evt_landslide', 'evt_ghost_road', 'evt_wolf', 'evt_storm', 'evt_patrol', 'evt_omen', 'evt_deserter', 'evt_plague_village', 'evt_apennine_fog', 'evt_charcoal_burners'],
    minEvents: 4,
    maxEvents: 6,
  ),
  RealMissionConfig(
    id: 'real_15',
    origin: 'Roma',
    destination: 'Massilia',
    distanceKm: 900,
    durationMinutes: 2880,
    danger: 0.55,
    requiredRank: 3,
    patron: Faction.patricians,
    lore: 'Dos días de camino hasta Massilia, en la Galia. La ruta más larga que un mensajero puede aceptar sin preguntar por qué.',
    packageOptions: [
      'Un tratado comercial con la Galia',
      'Correspondencia diplomática de largo alcance',
    ],
    eventPoolIds: ['evt_storm', 'evt_bandits', 'evt_ghost_road', 'evt_wolf', 'evt_landslide', 'evt_oracle', 'evt_merchant_offer', 'evt_old_soldier', 'evt_letter_bribe', 'evt_deserter', 'evt_hostage_escort', 'evt_fallen_milestone', 'evt_charcoal_burners'],
    minEvents: 5,
    maxEvents: 7,
  ),
];

// ═══════════════════════════════════════════════════════════════
// EXPANSION EVENTS POOL — 15 eventos nuevos
// ═══════════════════════════════════════════════════════════════

const List<RealEventConfig> expansionEvents = [
  RealEventConfig(
    id: 'evt_flood',
    category: EventCategory.river,
    title: 'Crecida en el vado',
    description: 'La lluvia de la noche crece un río que ayer se cruzaba caminando. El vado desapareció bajo agua marrón y rápida. Del otro lado, el camino sigue esperando.',
    options: [
      RealOptionConfig(
        id: 'opt_flood_wait', text: 'Esperas en la orilla a que baje la corriente',
        riskLevel: 1, timeCostMinutes: 180, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Te sientas bajo un sauce y ves bajar la corriente hora tras hora. Al atardecer el vado reaparece, manso como si nunca hubiera crecido. Cruzas con los pies secos.',
        outcomePartial: 'La espera se estira más de lo pensado: la lluvia vuelve, chica pero terca. Cruzas igual, ya de noche, con el barro hasta las rodillas.',
        outcomeFail: 'Te quedas dormido contra el tronco y quien te despierta es el frío del atardecer. El vado bajó hace rato; tú, no tanto.',
      ),
      RealOptionConfig(
        id: 'opt_flood_cross', text: 'Cruzas a pie con el agua a la cintura',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Lees la corriente como un vadeador viejo: paso firme, cuerpo de costado, el paquete en alto. Sales del otro lado empapado hasta el pecho y nada más.',
        outcomePartial: 'La corriente te corre más de lo calculado y sales veinte metros más abajo, entre juncos. Mojado hasta el cuello, pero con todo lo que llevabas.',
        outcomeFail: 'Un remolino te hace perder pie a mitad de camino. Nadas más de lo que caminas y llegas a la otra orilla tosiendo agua marrón y maldiciendo al cielo.',
      ),
      RealOptionConfig(
        id: 'opt_flood_plank', text: 'Pagas a un pastor por su puente de tablas',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'El pastor guarda tres tablones justo para estos días. Cobra caro y sonríe más caro todavía, pero cruzas seco y rápido sobre su puente de fortuna.',
        outcomePartial: 'Las tablas ceden un poco a mitad de camino y terminas con un pie mojado y el corazón acelerado. El pastor cobra igual, sin descuento por el susto.',
        outcomeFail: 'El pastor cambió de idea a último momento: "hoy no, muchacho". Pierdes el tiempo de la negociación y cruzas igual, por donde ibas a cruzar de entrada.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_tax_collector',
    category: EventCategory.patrol,
    title: 'El recaudador del portazgo',
    description: 'En el puesto de portazgo, un recaudador con tablilla de cera revisa cada carga dos veces. Tu paquete no tiene el sello que él quiere ver, y él no tiene apuro.',
    options: [
      RealOptionConfig(
        id: 'opt_tax_pay', text: 'Pagas el portazgo completo, sin discutir',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'Pagas sin poner cara y el recaudador, sorprendido de no discutir con nadie por una vez, hasta te marca el camino más corto en la tablilla. Rareza total.',
        outcomePartial: 'Pagas, pero el recaudador tarda una eternidad en anotar cada moneda, como si desconfiara de los números. Sales libre y aburrido.',
        outcomeFail: 'El recaudador encuentra un impuesto nuevo que inventó esta misma mañana. Pagas dos veces por el mismo cruce y aprendes que la cera se puede reescribir.',
      ),
      RealOptionConfig(
        id: 'opt_tax_dodge', text: 'Rodeas el puesto por el campo arado',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 2},
        outcomeSuccess: 'El campo recién arado esconde tus pasos mejor que cualquier excusa. Sales al camino trescientos metros más allá, con las sandalias sucias y el portazgo intacto en el bolsillo.',
        outcomePartial: 'El barro del campo te frena más de lo esperado y pierdes una sandalia en el intento. Llegas al otro lado descalzo de un pie y con la dignidad embarrada.',
        outcomeFail: 'Un perro de guardia del campo te delata a mitad de camino. Vuelves al puesto escoltado por sus ladridos y terminas pagando el doble por la vergüenza.',
      ),
      RealOptionConfig(
        id: 'opt_tax_permit', text: 'Muestras un salvoconducto del gremio',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'El recaudador reconoce el sello del gremio de mensajeros y no necesita más. Te hace un gesto casi respetuoso, y el paso queda libre.',
        outcomePartial: 'El recaudador mira el salvoconducto largo rato, comparándolo con uno viejo que guarda. Al final te deja pasar, no sin dejar constancia de la demora.',
        outcomeFail: 'El salvoconducto es de un gremio que ya no existe hace dos años. El recaudador se ríe, no de mala manera, y te cobra el portazgo completo por la ocurrencia.',
      ),
      RealOptionConfig(
        id: 'opt_tax_patron', text: 'Nombras a la casa patricia que te encarga',
        riskLevel: 1, timeCostMinutes: 15, requiredSkills: {},
        minReputation: {Faction.patricians: 30},
        lockedHint: 'Ningún patricio te presta su nombre todavía.',
        outcomeSuccess: 'Dices el nombre de la casa como quien dice la hora. El recaudador borra algo de su tablilla con el pulgar, sella tu carga sin mirarla y hasta te desea buen viaje. Hay apellidos que pesan más que cualquier portazgo.',
        outcomePartial: 'El nombre funciona, pero el recaudador quiere verlo escrito. Le muestras la carta de encargo, la lee dos veces, la huele, y al final te deja pasar. Un cuarto de hora para comprobar que no mentías.',
        outcomeFail: 'El recaudador conoce la casa... y le debe dinero. Te demora por puro rencor hasta que llega su superior, que sí sabe con quién conviene estar bien. Pasas con disculpas y tarde.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_lost_child',
    category: EventCategory.road,
    title: 'La niña del cruce',
    description: 'En el cruce de caminos, una niña de no más de seis años llora sola, sin nadie a la vista. Repite un nombre entre lágrimas: el de un pueblo, o quizás el de su madre.',
    options: [
      RealOptionConfig(
        id: 'opt_child_walk', text: 'La llevas de la mano hasta el pueblo más cercano',
        riskLevel: 1, timeCostMinutes: 120, requiredSkills: {},
        repDelta: {Faction.guild: 2},
        setFlags: ['helped_lost_child'],
        journalNote: 'Llevé a una niña perdida hasta el pueblo. Llegué tarde a destino. Fue lo correcto igual.',
        outcomeSuccess: 'Caminan juntos hasta el pueblo, ella contándote cada flor del camino. En la plaza, una mujer grita su nombre y corre. "Gracias, mensajero" no alcanza, pero lo dice igual.',
        outcomePartial: 'El pueblo queda más lejos de lo que pensabas y la niña se cansa a mitad de camino. Termina las últimas cuadras en tus hombros, más liviana que el paquete.',
        outcomeFail: 'Se hace tarde y el pueblo resulta ser el equivocado: nadie la conoce ahí. Vuelves sobre tus pasos con la niña dormida en brazos y el sol ya bajo.',
      ),
      RealOptionConfig(
        id: 'opt_child_leave', text: 'Le señalas el camino y sigues apurado',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: -1},
        journalNote: 'Le señalé un camino a una niña perdida y seguí de largo. El plazo ganó. No sé si hice bien.',
        outcomeSuccess: 'Le indicas el camino recto al pueblo y la ves alejarse, insegura pero decidida. Sigues tu ruta con la conciencia apenas incómoda.',
        outcomePartial: 'Le señalas el camino y a los cien pasos escuchas que sigue llorando en el mismo lugar, sin animarse a caminar sola. Dudas, pero sigues.',
        outcomeFail: 'El camino que le indicaste tiene una bifurcación que olvidaste mencionar. No te enteras hasta el próximo pueblo, cuando alguien pregunta por una niña perdida.',
      ),
      RealOptionConfig(
        id: 'opt_child_ask', text: 'Preguntas en la posada más cercana por su familia',
        riskLevel: 2, timeCostMinutes: 45, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El posadero conoce a media comarca: reconoce el nombre que repite la niña y manda a un mozo a buscar a su tío. Antes de que se enfríe tu vino, ya se la llevan.',
        outcomePartial: 'Nadie en la posada la reconoce, pero el posadero se ofrece a cuidarla hasta que alguien la busque. Te vas confiando en la palabra de un desconocido amable.',
        outcomeFail: 'Preguntas de mesa en mesa sin suerte y la posada entera termina mirándote como sospechoso de algo. Te vas sin respuestas y con el tiempo perdido.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_wolf',
    category: EventCategory.road,
    title: 'Aullidos cerca del camino',
    description: 'El sol cae y los aullidos suenan más cerca de lo cómodo, en un tramo de bosque sin pueblos a la vista. Algo grande se mueve entre los árboles, al ritmo de tus pasos.',
    options: [
      RealOptionConfig(
        id: 'opt_wolf_fire', text: 'Armas una fogata y esperas la luz del día',
        riskLevel: 1, timeCostMinutes: 360, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El fuego alto mantiene a la manada a distancia toda la noche. Al amanecer solo quedan huellas alrededor del campamento, círculo perfecto de curiosidad y respeto.',
        outcomePartial: 'El fuego se apaga dos veces por el viento y pasas la noche alimentándolo con manos temblorosas. Amaneces agotado pero entero, y con leña de sobra.',
        outcomeFail: 'Te quedas dormido pasada la medianoche y el fuego muere solo. Despiertas al alba con el corazón latiendo fuerte y unas huellas frescas a un metro de tu manta.',
      ),
      RealOptionConfig(
        id: 'opt_wolf_run', text: 'Apuras el paso sin mirar atrás',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Corres el tramo boscoso al ritmo de tu propio miedo, que resulta ser bastante rápido. Sales al claro sin mirar atrás ni una vez. Los aullidos se quedan atrás también.',
        outcomePartial: 'Corres y tropiezas con una raíz que casi te cuesta el paquete. Llegas al claro con las rodillas raspadas, pero los aullidos ya suenan lejos.',
        outcomeFail: 'En la corrida pierdes el sendero y das tres vueltas sobre el mismo grupo de árboles antes de encontrar la salida. La manada, al parecer, solo miraba.',
      ),
      RealOptionConfig(
        id: 'opt_wolf_read', text: 'Lees el terreno y encuentras dónde no están',
        riskLevel: 3, timeCostMinutes: 30, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Reconoces las señales: pisadas frescas, marcaciones en la corteza. La manada caza río abajo, no acá. Cruzas el tramo tranquilo, casi curioso de tu propio oficio.',
        outcomePartial: 'Tu lectura del terreno es correcta a medias: evitas a la manada pero no a un zorro nervioso que te sigue gruñendo un buen trecho.',
        outcomeFail: 'Confundes marcas viejas con frescas y el atajo que eliges te acerca más de la cuenta. Retrocedes despacio, sin apuro, con el corazón en la garganta.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_ferry',
    category: EventCategory.port,
    title: 'El transbordador del estuario',
    description: 'El único cruce del estuario es una barcaza vieja que un barquero maneja según su humor del día. Hoy, por lo visto, el humor no es bueno.',
    options: [
      RealOptionConfig(
        id: 'opt_ferry_wait', text: 'Esperas el próximo turno, sin apurar al barquero',
        riskLevel: 1, timeCostMinutes: 150, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Esperas tu turno en la orilla, mirando pasar gaviotas y carros. El barquero, al ver que no protestas, te acomoda antes de lo que decía la fila.',
        outcomePartial: 'El turno tarda el doble de lo prometido: el barquero prioriza a quien paga de más. Cruzas igual, ya con el sol bajando.',
        outcomeFail: 'Cuando por fin te toca, la marea baja demasiado y la barcaza no puede zarpar. Esperas una vuelta completa de la marea, mirando el estuario vacío.',
      ),
      RealOptionConfig(
        id: 'opt_ferry_bribe', text: 'Le ofreces el doble por saltar la fila',
        riskLevel: 3, timeCostMinutes: 20, requiredSkills: {},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'El barquero cuenta las monedas con una sonrisa torcida y te hace subir antes que a nadie. Cruzas el estuario mientras los que esperaban todavía protestan en la orilla.',
        outcomePartial: 'Acepta el doble, pero te hace esperar "un ratito" que se estira. Cruzas igual, aunque con la sensación de haber pagado de más por poco.',
        outcomeFail: 'El barquero acepta tu dinero y la de otros tres al mismo tiempo, sin aclarar el orden. Terminas discutiendo tu lugar en la fila que creías haber comprado.',
      ),
      RealOptionConfig(
        id: 'opt_ferry_swim', text: 'Cruzas el estuario a nado, lejos de la barcaza',
        riskLevel: 5, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 3},
        outcomeSuccess: 'Conoces las corrientes del estuario mejor que el barquero mismo: entras por donde el agua empuja a favor y sales del otro lado antes de que la barcaza zarpe.',
        outcomePartial: 'La corriente del estuario es más fuerte que cualquier río y te empuja bien lejos del punto que buscabas. Llegas río arriba, agotado pero con todo intacto.',
        outcomeFail: 'A mitad de estuario un banco de arena te frena en el peor momento: el agua te llega al pecho y tienes que caminar media legua hundido hasta encontrar salida.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_forge_fire',
    category: EventCategory.forum,
    title: 'Fuego en la herrería',
    description: 'Al pasar por un pueblo de posta, ves llamas saliendo del techo de paja de la herrería. Adentro alguien grita y afuera nadie parece decidirse a actuar.',
    options: [
      RealOptionConfig(
        id: 'opt_forge_help', text: 'Te sumas a la cadena de baldes',
        riskLevel: 2, timeCostMinutes: 90, requiredSkills: {},
        repDelta: {Faction.guild: 2},
        journalNote: 'Ayudé a apagar un incendio en una herrería de paso. Llegué tarde a destino, pero el pueblo tiene techo.',
        outcomeSuccess: 'La cadena de baldes gana terreno al fuego de a poco, y con tus brazos de más se apaga antes de llegar al establo vecino. El herrero, tiznado y agradecido, jura recordar tu cara.',
        outcomePartial: 'El fuego cede pero no sin llevarse la mitad del techo. Sales oliendo a humo y con las manos ampolladas, pero el pueblo entero te palmea la espalda.',
        outcomeFail: 'El humo te gana antes que las llamas y terminas tosiendo a un costado mientras otros terminan el trabajo. Igual, nadie te reprocha el intento.',
      ),
      RealOptionConfig(
        id: 'opt_forge_pass', text: 'Rodeas la conmoción y sigues tu camino',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: -1},
        outcomeSuccess: 'Rodeas el gentío y sigues de largo. El fuego, según te enteras después, se apagó solo antes de mayores daños. Tu plazo, intacto.',
        outcomePartial: 'Sigues de largo, pero el griterío te sigue dos cuadras completas antes de perderse detrás. Llegas al próximo tramo con la cabeza en otro lado.',
        outcomeFail: 'El humo cambia de dirección justo cuando pasas y terminas corriendo un tramo con los ojos llorando y la garganta áspera, sin haber ayudado ni evitado nada.',
      ),
      RealOptionConfig(
        id: 'opt_forge_smart', text: 'Organizas el rescate: agua por un lado, tierra por el otro',
        riskLevel: 3, timeCostMinutes: 45, requiredSkills: {SkillType.survival: 2},
        repDelta: {Faction.guild: 2, Faction.patricians: 1},
        outcomeSuccess: 'Repartes tareas como si lo hubieras hecho toda la vida: unos con agua, otros cortando el paso al viento con tierra húmeda. El fuego muere rápido y el pueblo entero pregunta tu nombre.',
        outcomePartial: 'Tu método funciona a medias: el fuego principal cede, pero una chispa prende el corral de al lado. Terminas ayudando ahí también, más cansado de lo planeado.',
        outcomeFail: 'Das órdenes con confianza, pero nadie te conoce y nadie obedece del todo. El caos gana la primera media hora, hasta que el fuego decide apagarse por cuenta propia.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_oracle',
    category: EventCategory.temple,
    title: 'La sibila de Cumas',
    description: 'En la boca de una cueva, una anciana de ojos blancos susurra versos que nadie pidió. Te señala directo a ti: "El mensaje que llevas no es el que crees que es." Después, extiende la mano.',
    options: [
      RealOptionConfig(
        id: 'opt_oracle_listen', text: 'Te quedas a escuchar el resto del vaticinio',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        setFlags: ['heard_the_sibyl'],
        outcomeSuccess: 'El vaticinio completo es largo, extraño y en varios idiomas. Al final, algo en sus palabras encaja con algo que vas a ver más adelante en el camino. Sales pensativo, no asustado.',
        outcomePartial: 'Escuchas gran parte del vaticinio antes de que otro viajero interrumpa con su propia consulta. Te vas con la mitad de un mensaje que quizás nunca necesites.',
        outcomeFail: 'El vaticinio se pierde entre el eco de la cueva y el viento. Sales sin entender nada, salvo que perdiste una hora entera escuchando ecos.',
      ),
      RealOptionConfig(
        id: 'opt_oracle_ignore', text: 'Le dejas una moneda chica y sigues de largo',
        riskLevel: 2, timeCostMinutes: 10, requiredSkills: {},
        repDelta: {Faction.patricians: -1},
        outcomeSuccess: 'La moneda tintinea en su cuenco y la sibila no dice nada más. Sigues camino liviano de bolsillo y de superstición.',
        outcomePartial: 'Dejas la moneda y la anciana la rechaza con un gesto: quiere algo más, algo que no tienes para dar. Te vas con la moneda todavía en la mano.',
        outcomeFail: 'La moneda rueda y se pierde entre las piedras de la cueva. La sibila se ríe, un sonido que te acompaña varios pasos más de los que quisieras.',
      ),
      RealOptionConfig(
        id: 'opt_oracle_bargain', text: 'Le ofreces una historia a cambio de un vaticinio claro',
        riskLevel: 3, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: 'Le cuentas algo real del camino y ella, complacida, te devuelve un vaticinio sin acertijos: una advertencia concreta sobre lo que viene más adelante. Rarísimo trato, bien cerrado.',
        outcomePartial: 'El intercambio funciona a medias: te da un vaticinio, pero envuelto en tantos símbolos que vas a tardar el resto del viaje en descifrarlo.',
        outcomeFail: 'Tu historia no le interesa lo suficiente. La sibila vuelve a sus murmullos como si no hubieras hablado. Te vas sin nada, ni siquiera un eco.',
      ),
      RealOptionConfig(
        id: 'opt_oracle_birds', text: '"Leí los pájaros una vez. Hablemos claro."',
        riskLevel: 1, timeCostMinutes: 20, requiredSkills: {},
        requiredFlag: 'read_the_birds',
        setFlags: ['heard_the_sibyl'],
        journalNote: 'La sibila de Cumas sabía que yo había leído los pájaros del augur. Me habló claro, como a un colega.',
        outcomeSuccess: 'La sibila se ríe con todos los dientes que le quedan. "El que le robó el presagio al augur." Te dice el verso entero y después, en prosa, qué significa. Es la primera vez que un oráculo te ahorra tiempo.',
        outcomePartial: 'Te reconoce y se divierte, pero no regala nada: te dice el verso y una pista, no más. "Lo demás lo lees tú, que sabes." Te vas con un acertijo y con la sensación de haber hablado de igual a igual.',
        outcomeFail: 'Te reconoce y le parece una insolencia que te le pongas a la par. Te dice el verso al revés, a propósito, y se mete en la cueva. Te quedas veinte minutos dándolo vuelta. Algo se entiende.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_deserter',
    category: EventCategory.patrol,
    title: 'El desertor de la ruta',
    description: 'Escondido entre unas rocas, un joven con uniforme de legión pero sin armas te pide, en voz baja, que no digas que lo viste. Tiembla más de miedo que de frío.',
    options: [
      RealOptionConfig(
        id: 'opt_deserter_avoid', text: 'Sigues de largo, sin ver nada',
        riskLevel: 1, timeCostMinutes: 30, requiredSkills: {},
        outcomeSuccess: 'Sigues tu camino sin girar la cabeza. Lo que no viste, no lo tienes que explicar. El camino sigue tranquilo el resto de la tarde.',
        outcomePartial: 'Sigues de largo, pero el corazón te late fuerte un buen trecho, esperando gritos de patrulla que nunca llegan.',
        outcomeFail: 'Un legionario de patrulla te para dos leguas después, preguntando si viste a alguien raro por el camino. Mientes mal, y eso te cuesta una revisión completa del bolso.',
      ),
      RealOptionConfig(
        id: 'opt_deserter_help', text: 'Le das tu capa vieja y le señalas un desvío',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.legions: -2, Faction.underworld: 1},
        setFlags: ['helped_deserter'],
        journalNote: 'Ayudé a escapar a un desertor de la legión. Espero que valga la pena, para él y para mí.',
        outcomeSuccess: 'Le tiras la capa vieja y un gesto hacia el bosque. Desaparece sin decir gracias, que es la única forma correcta de decirlo en su situación. Tú sigues, más liviano de una capa y de una duda.',
        outcomePartial: 'Le das la capa, pero duda tanto tiempo en el desvío que casi los agarran juntos. Se va al fin, y tú con el pulso todavía alto.',
        outcomeFail: 'Apenas se aleja, una patrulla lo alcanza a la vista tuya. Te interrogan a ti también, por las dudas. La capa, dicen, "coincide con la descripción".',
      ),
      RealOptionConfig(
        id: 'opt_deserter_talk', text: 'Lo convences de entregarse a un oficial que conoces',
        riskLevel: 2, timeCostMinutes: 60, requiredSkills: {SkillType.contacts: 3},
        repDelta: {Faction.legions: 2},
        outcomeSuccess: 'Conoces a un centurión que trata estas cosas con más cabeza que castigo. Lo convences de presentarse ahí, no en cualquier puesto. Sale mejor de lo que el chico esperaba.',
        outcomePartial: 'Lo convences a medias: acepta ir, pero cambia de opinión dos veces en el camino. Al final lo dejas en manos del centurión, sin garantías de nada.',
        outcomeFail: 'El chico se asusta a mitad de la charla y corre de nuevo hacia el bosque. Te quedas con las manos vacías y la sensación de haber perdido una hora por nada.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_wedding_road',
    category: EventCategory.road,
    title: 'Cortejo de bodas',
    description: 'Una procesión de bodas ocupa el camino entero: antorchas, flautas y un tropel de invitados felices que no tienen ningún apuro. La novia va al centro, cubierta de velo naranja.',
    options: [
      RealOptionConfig(
        id: 'opt_wedding_wait', text: 'Te haces a un lado y dejas pasar la fiesta',
        riskLevel: 1, timeCostMinutes: 45, requiredSkills: {},
        outcomeSuccess: 'Te apartas y la procesión pasa entera, con música y arroz volando. Alguien te tira una flor sin razón aparente. Sigues camino de mejor humor.',
        outcomePartial: 'La fiesta se detiene justo frente a ti para un brindis improvisado. Esperas con la copa que te ofrecen, sin poder decir que no.',
        outcomeFail: 'La procesión se detiene tanto tiempo que empiezas a formar parte del paisaje. Un tío borracho del novio insiste en contarte la genealogía completa de la familia.',
      ),
      RealOptionConfig(
        id: 'opt_wedding_cut', text: 'Te metes entre la gente para cruzar más rápido',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: -1},
        outcomeSuccess: 'Te deslizas entre bailarines e invitados con disculpas rápidas y pasos más rápidos todavía. Sales del otro lado de la procesión antes de que alguien note tu apuro.',
        outcomePartial: 'Cruzas entre la gente, pero chocas con la bandeja de un esclavo que sirve vino. Sales del otro lado con la túnica manchada y varias miradas encima.',
        outcomeFail: 'Te confunden con parte del cortejo y alguien te empuja hacia el centro de la ronda de baile. Tardas en escapar de la fiesta más de lo que hubiera tardado esperando.',
      ),
      RealOptionConfig(
        id: 'opt_wedding_greet', text: 'Saludas a la familia como si te hubieran invitado',
        riskLevel: 2, timeCostMinutes: 15, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'Felicitas a los padres de la novia con la formalidad justa. Te confunden con un invitado lejano y hasta te abren paso de honor entre los bailarines.',
        outcomePartial: 'El saludo funciona, pero alguien pregunta de qué familia vienes. Improvisas un apellido y sales antes de que la pregunta se repita.',
        outcomeFail: 'El padre de la novia te reconoce como nadie de la familia y la fiesta se detiene un instante incómodo. Te disculpas y cruzas rápido, entre risas ajenas.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_landslide',
    category: EventCategory.storm,
    title: 'Derrumbe en la sierra',
    description: 'Un desprendimiento de rocas tapó el paso de montaña esta misma mañana. Piedras del tamaño de un buey bloquean el camino de lado a lado.',
    options: [
      RealOptionConfig(
        id: 'opt_landslide_detour', text: 'Buscas el camino viejo que rodea la sierra',
        riskLevel: 1, timeCostMinutes: 300, requiredSkills: {},
        outcomeSuccess: 'El camino viejo está más largo pero entero: nadie lo usa desde que abrieron el paso nuevo, y hoy eso juega a tu favor. Llegas cansado, no varado.',
        outcomePartial: 'El camino viejo tiene su propio derrumbe, más chico, que rodeas trepando entre matorrales. Pierdes más tiempo del calculado, pero llegas sin sustos.',
        outcomeFail: 'El camino viejo se pierde entre la maleza dos veces y tienes que retroceder para reencontrarlo. El rodeo se estira más de lo que cualquiera hubiera aguantado con paciencia.',
      ),
      RealOptionConfig(
        id: 'opt_landslide_climb', text: 'Trepas directamente sobre las rocas caídas',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Eliges cada roca como si el desprendimiento fuera una escalera hecha a propósito. Cruzas en minutos lo que a otros les va a costar horas de rodeo.',
        outcomePartial: 'Trepas bien, pero una piedra suelta te tuerce el tobillo en el último tramo. Cruzas igual, cojeando, con el orgullo más entero que el pie.',
        outcomeFail: 'A mitad de las rocas, una piedra cede bajo tu peso y ruedas un buen trecho hacia atrás. Vuelves a empezar, magullado y con menos ganas de atajos.',
      ),
      RealOptionConfig(
        id: 'opt_landslide_read', text: 'Lees las rocas y encuentras el paso más firme',
        riskLevel: 3, timeCostMinutes: 40, requiredSkills: {SkillType.survival: 3},
        outcomeSuccess: 'Distingues las rocas asentadas de las que todavía se mueven, y trazas un camino invisible para cualquier otro. Cruzas rápido y sin un solo resbalón.',
        outcomePartial: 'Tu lectura es buena pero no perfecta: encuentras el paso firme a costa de un rodeo extra entre las rocas más grandes.',
        outcomeFail: 'Confías en una roca que parecía firme y no lo era. El tropiezo no te tira, pero te obliga a rehacer media trepada por otro lado.',
      ),
      RealOptionConfig(
        id: 'opt_storm_ridge', text: 'Pasas por la cresta, como aquella noche de tormenta',
        riskLevel: 2, timeCostMinutes: 20, requiredSkills: {},
        requiredFlag: 'walked_the_storm',
        journalNote: 'Crucé el derrumbe por la cresta. Después de aquella tormenta, unas piedras quietas no me asustan.',
        outcomeSuccess: 'La cresta es angosta y el viento empuja, pero tú ya cruzaste un paso con el cielo cayéndose encima. Esto es un paseo. Bajas del otro lado antes de que los arrieros terminen de discutir el camino viejo.',
        outcomePartial: 'La cresta aguanta, aunque una piedra suelta te hace bailar un segundo largo sobre el vacío. El cuerpo se acordó de la tormenta antes que tú. Pasas, con las rodillas protestando.',
        outcomeFail: 'Esta vez no hay tormenta y te confías. Un tramo se desgrana bajo la sandalia y bajas medio paso de culo, abrazado al paquete. Llegas abajo raspado y entero. La montaña también se acuerda de ti.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_spy_drop',
    category: EventCategory.subura,
    title: 'El paquete equivocado',
    description: 'En una plaza vacía, alguien deja caer un rollo sellado justo frente a ti y desaparece entre la gente sin mirar atrás. El rollo no tiene tu nombre, pero ya lo tienes en la mano.',
    options: [
      RealOptionConfig(
        id: 'opt_spy_return', text: 'Lo entregas al primer puesto de guardia que encuentras',
        riskLevel: 2, timeCostMinutes: 90, requiredSkills: {},
        repDelta: {Faction.legions: 2, Faction.underworld: -1},
        outcomeSuccess: 'El oficial de guardia recibe el rollo con seriedad repentina y te agradece con un gesto que dice más que sus palabras. Lo que sea que era, ya no es problema tuyo.',
        outcomePartial: 'El guardia tarda en decidir si el hallazgo es asunto suyo o de otro puesto. Terminas esperando mientras dos oficiales discuten jurisdicciones.',
        outcomeFail: 'El puesto de guardia está vacío justo hoy. Cargas el rollo un tramo más largo del que querías, cada vez más incómodo con lo que sea que llevas encima.',
      ),
      RealOptionConfig(
        id: 'opt_spy_drop_it', text: 'Lo dejas caer donde estaba y te vas rápido',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Lo sueltas exactamente donde cayó y te alejas sin apuro sospechoso. Nadie te vio recogerlo, nadie te ve dejarlo. Como si nunca hubiera pasado.',
        outcomePartial: 'Lo dejas caer, pero un chico de la plaza lo levanta antes de que te alejes del todo. Te preguntas, unas cuadras después, en qué lío quedó metido el chico.',
        outcomeFail: 'Justo cuando lo sueltas, alguien te señala desde una ventana. No sabes si te vieron recoger o dejar el rollo, pero apuras el paso el resto de la tarde.',
      ),
      RealOptionConfig(
        id: 'opt_spy_read', text: 'Lo abres un segundo, apenas para entender qué es',
        riskLevel: 4, timeCostMinutes: 15, requiredSkills: {SkillType.stealth: 2},
        setFlags: ['saw_the_message'],
        journalNote: 'Abrí un rollo que no era mío en una plaza vacía. Lo que leí, no lo cuento. Ni acá.',
        outcomeSuccess: 'Rompes el sello con dedos de cirujano y lo vuelves a cerrar sin que se note. Lo que leíste no era para ti, pero ahora lo sabes igual. Guardas silencio, y el rollo, donde estaba.',
        outcomePartial: 'Alcanzas a leer la mitad antes de que pasos cercanos te obliguen a cerrarlo de golpe. El sello queda un poco torcido, y la mitad del mensaje, sin sentido claro.',
        outcomeFail: 'El sello se rompe mal y queda evidente que alguien lo abrió. Lo dejas donde estaba de todos modos, esperando que nadie relacione el desastre contigo.',
      ),
      RealOptionConfig(
        id: 'opt_spy_known_face', text: 'Reconoces al hombre del norte entre la gente',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {},
        requiredFlag: 'refused_spy',
        repDelta: {Faction.legions: 1},
        journalNote: 'El rollo de la plaza lo soltó el mismo hombre que quiso comprar mi sello en la posada. Lo señalé a la guardia.',
        outcomeSuccess: 'Es él: el de las manos limpias que te ofreció la bolsa en la posada. Se lo señalas al primer vigil con el rollo en la mano. Lo agarran en la esquina. El optio te da las gracias y te pregunta si quieres trabajar para ellos.',
        outcomePartial: 'Lo reconoces y lo sigues con la mirada mientras buscas un guardia. Cuando vuelves con uno, el hombre ya no está. Entregas el rollo con una descripción precisa. Algo es algo.',
        outcomeFail: 'Lo señalas demasiado pronto y él te ve. Se escurre entre los puestos y tú pierdes media hora explicándole a un vigil desconfiado por qué tienes un rollo ajeno. Te creen, al final. A él no lo encuentran.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_heatwave',
    category: EventCategory.road,
    title: 'Ola de calor',
    description: 'El sol de mediodía pega como un castigo personal. El camino tiembla de calor y el agua del odre se terminó hace dos leguas.',
    options: [
      RealOptionConfig(
        id: 'opt_heat_rest', text: 'Buscas sombra y esperas que baje el sol',
        riskLevel: 1, timeCostMinutes: 180, requiredSkills: {},
        outcomeSuccess: 'Encuentras la sombra generosa de un algarrobo viejo y esperas las horas más duras del día. Cuando retomas, el camino es otro: más fresco, más amable.',
        outcomePartial: 'La sombra que encuentras es escasa y compartida con un rebaño de cabras ruidosas. Esperas igual, entre balidos, hasta que el sol afloja un poco.',
        outcomeFail: 'Te duermes más de la cuenta bajo el árbol y despiertas con el sol ya bajando del otro lado. La siesta ganó más tiempo del que pediste.',
      ),
      RealOptionConfig(
        id: 'opt_heat_push', text: 'Sigues caminando bajo el sol de lleno',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Racionas cada trago de lo poco que te queda y encuentras el ritmo justo para no quemarte las fuerzas. Llegas al próximo pueblo con la garganta seca y el plazo intacto.',
        outcomePartial: 'Aguantas el tramo, pero el calor te pasa factura en mareos cortos que te obligan a parar dos veces. Llegas entero, tambaleando un poco.',
        outcomeFail: 'El calor te gana a mitad de camino y terminas sentado a la sombra de una roca, esperando que el mundo deje de dar vueltas antes de seguir.',
      ),
      RealOptionConfig(
        id: 'opt_heat_farmer', text: 'Le pides agua a un granjero del camino',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El granjero llena tu odre sin dudar y hasta te tira un sombrero de paja vieja "para el camino". Sigues fresco, con agua de sobra y una anécdota nueva.',
        outcomePartial: 'El granjero te da agua, pero pide ayuda a cambio: cargar dos baldes hasta el corral. Pagas con sudor lo que ibas a conseguir gratis.',
        outcomeFail: 'El granjero desconfía de un desconocido pidiendo agua a mediodía y te cierra la tranquera sin mucha explicación. Sigues con el odre tan vacío como antes.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_cart_jam',
    category: EventCategory.forum,
    title: 'Embotellamiento en el puente',
    description: 'Dos carros de bueyes trabaron sus ruedas al cruzarse en el puente angosto. Detrás se amontona una fila de carretas, mulas y gritos que no ayudan a nadie.',
    options: [
      RealOptionConfig(
        id: 'opt_jam_wait', text: 'Esperas tu turno en la fila, resignado',
        riskLevel: 1, timeCostMinutes: 90, requiredSkills: {},
        outcomeSuccess: 'Esperas con paciencia mientras dos boyeros discuten de quién fue la culpa. Al final alguien cede, las ruedas se destraban y la fila avanza más rápido de lo esperado.',
        outcomePartial: 'La discusión entre los boyeros se estira con testigos, insultos y una apuesta improvisada. Cruzas al fin, cuando ya nadie recuerda cómo empezó todo.',
        outcomeFail: 'Justo cuando la fila empieza a moverse, una rueda se rompe del todo. Vuelves a esperar mientras alguien va a buscar un carpintero al pueblo más cercano.',
      ),
      RealOptionConfig(
        id: 'opt_jam_walk', text: 'Cruzas el puente a pie, entre los carros',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Te cuelas a pie entre las ruedas trabadas y los bueyes resignados. Cruzas el puente en minutos, dejando atrás gritos que no son problema tuyo.',
        outcomePartial: 'Cruzas a pie, pero un boyero te confunde con parte del problema y te grita instrucciones inútiles todo el trayecto. Sales del otro lado, entero y algo sordo.',
        outcomeFail: 'Al pasar entre los carros, uno de los bueyes se asusta y casi te aplasta contra la baranda. Cruzas igual, con el corazón en la garganta.',
      ),
      RealOptionConfig(
        id: 'opt_jam_organize', text: 'Ayudas a destrabar las ruedas tú mismo',
        riskLevel: 3, timeCostMinutes: 30, requiredSkills: {SkillType.combat: 1},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Con fuerza y maña destrabas la rueda que nadie quería tocar. Los boyeros te aplauden con las manos callosas y la fila entera avanza gracias a ti.',
        outcomePartial: 'Destrabas una rueda, pero la otra necesita más manos de las que ofreces solo. Terminas ayudando igual, más cansado de lo planeado.',
        outcomeFail: 'Haces fuerza en el punto equivocado y la rueda se traba peor. Los boyeros te agradecen el intento con una mirada que dice todo lo contrario.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_temple_theft',
    category: EventCategory.temple,
    title: 'Acusación en el templo',
    description: 'Frente al templo, un sacerdote grita que falta una ofrenda de plata y señala hacia el grupo de viajeros donde justo estás parado tú.',
    options: [
      RealOptionConfig(
        id: 'opt_temple_cooperate', text: 'Te quedas y dejas que revisen tu bolso',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'La revisión es rápida y limpia: tu bolso solo tiene lo que debería. El sacerdote se disculpa con una formalidad exagerada y te bendice, por las dudas.',
        outcomePartial: 'Revisan cada bolsillo dos veces, incómodos por no encontrar nada. Te dejan ir sin disculpas claras, pero al menos sin cadenas.',
        outcomeFail: 'Mientras revisan tu bolso, encuentran la ofrenda real en manos de otro viajero. La escena se resuelve, pero perdiste media hora entera de sospechas ajenas.',
      ),
      RealOptionConfig(
        id: 'opt_temple_flee', text: 'Te alejas rápido antes de que te señalen a ti',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: -2},
        setFlags: ['fled_temple_accusation'],
        outcomeSuccess: 'Te pierdes entre la multitud del atrio antes de que el dedo del sacerdote termine de apuntar. Nadie te sigue. La conciencia, tampoco te sigue tanto.',
        outcomePartial: 'Escapas del grupo, pero un devoto te reconoce después en la plaza y comenta en voz alta que "corriste raro" frente al templo.',
        outcomeFail: 'Corres y justo chocas con un guardia del templo que llegaba a ver el escándalo. Terminas explicando tu apuro con menos convicción de la que quisieras.',
      ),
      RealOptionConfig(
        id: 'opt_temple_identify', text: 'Señalas con calma al verdadero sospechoso',
        riskLevel: 3, timeCostMinutes: 20, requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: 'Notaste antes que nadie el bulto raro en la túnica de otro viajero. Lo señalas con calma y el sacerdote, agradecido, te libera de toda sospecha al instante.',
        outcomePartial: 'Tu sospecha resulta correcta a medias: señalas a alguien que solo escondía pan robado, no monedas. Igual, te libera de la acusación original.',
        outcomeFail: 'Señalas a la persona equivocada y el verdadero ladrón aprovecha la confusión para escapar. El sacerdote te mira con más sospecha que antes.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_ghost_road',
    category: EventCategory.road,
    title: 'El tramo que nadie nombra',
    description: 'Los arrieros del último pueblo se negaron a acompañarte más allá de la piedra tallada. "Ese tramo no se nombra de noche", dijo uno, y ninguno lo contradijo.',
    options: [
      RealOptionConfig(
        id: 'opt_ghost_wait_dawn', text: 'Acampas antes de la piedra y esperas el amanecer',
        riskLevel: 1, timeCostMinutes: 300, requiredSkills: {},
        outcomeSuccess: 'Acampas del lado seguro de la piedra tallada, con el fuego alto toda la noche. Al amanecer el tramo es apenas un camino más, largo y sin sombra.',
        outcomePartial: 'La noche se hace larga entre ruidos que probablemente son animales y una imaginación que no ayuda. Cruzas al alba, cansado de no haber dormido casi nada.',
        outcomeFail: 'Te quedas dormido más tarde de lo planeado y pierdes buena parte de la mañana. El tramo sigue ahí, tan tramo como siempre, esperando sin apuro.',
      ),
      RealOptionConfig(
        id: 'opt_ghost_cross_night', text: 'Cruzas el tramo de noche, solo',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Cruzas con paso firme y la cabeza fría, sin darle cuerpo a ningún ruido de la noche. Al otro lado, el camino sigue siendo solo camino.',
        outcomePartial: 'Cruzas, pero cada rama que cruje te hace mirar atrás. Llegas al otro lado sin nada real que reportar, salvo el pulso todavía alto.',
        outcomeFail: 'Un búho grita justo detrás tuyo y por un instante corres más de lo que caminas. Cruzas igual, agitado y sin ganas de contarle a nadie los detalles.',
      ),
      RealOptionConfig(
        id: 'opt_ghost_ask_local', text: 'Le preguntas a un arriero la historia real del tramo',
        riskLevel: 2, timeCostMinutes: 40, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El arriero, con más vino que miedo, te cuenta la historia real: un accidente viejo, nada sobrenatural. Cruzas al día siguiente, sin supersticiones encima.',
        outcomePartial: 'El arriero cuenta tres versiones distintas de la misma historia, cada vez más exagerada. Cruzas igual, con más dudas que certezas.',
        outcomeFail: 'El arriero se ofende de que dudes de la leyenda y se niega a contarte nada más. Cruzas el tramo con la misma incertidumbre de siempre, solo que más tarde.',
      ),
      RealOptionConfig(
        id: 'opt_ghost_offering', text: 'Dejas una ofrenda en la piedra, como te enseñó el augur',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {},
        requiredFlag: 'paid_the_augur',
        journalNote: 'Dejé pan y sal en la piedra del tramo sin nombre. El augur del cruce tenía razón: los caminos también cobran.',
        outcomeSuccess: 'Pan, sal y una moneda sobre la piedra tallada, como hacía el augur del cruce. Los arrieros te ven hacerlo y uno escupe a un costado, aprobando. Dos te acompañan hasta el otro lado. La noche pasa sin un ruido de más.',
        outcomePartial: 'Dejas la ofrenda y cruzas solo. El tramo está quieto, demasiado quieto, pero nada te sale al paso. Llegas al otro lado con la nuca erizada y el paquete seco.',
        outcomeFail: 'La ofrenda la dejas, pero un zorro se la lleva antes de que des diez pasos. Lo tomas como mala señal y cruzas corriendo, tropezando con cada raíz. Ningún fantasma; muchas raíces.',
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════
// IDs NUEVOS DE ESTA EXPANSIÓN (referencia rápida)
//
// Rutas (expansionMissions):
//   real_04  Roma → Tibur           (30 min,   rank 1)
//   real_05  Roma → Praeneste       (45 min,   rank 1)
//   real_06  Roma → Antium          (60 min,   rank 1)
//   real_07  Neapolis → Pompeii     (90 min,   rank 1)
//   real_08  Roma → Cumae           (180 min,  rank 2)
//   real_09  Roma → Beneventum      (240 min,  rank 2)
//   real_10  Ravenna → Aquileia     (360 min,  rank 2)
//   real_11  Pisae → Genua          (480 min,  rank 2)
//   real_12  Roma → Tarentum        (480 min,  rank 2)
//   real_13  Roma → Brundisium      (720 min,  rank 3)
//   real_14  Roma → Aquileia        (1440 min, rank 3)
//   real_15  Roma → Massilia        (2880 min, rank 3)
//
// Eventos (expansionEvents):
//   evt_flood, evt_tax_collector, evt_lost_child, evt_wolf, evt_ferry,
//   evt_forge_fire, evt_oracle, evt_deserter, evt_wedding_road,
//   evt_landslide, evt_spy_drop, evt_heatwave, evt_cart_jam,
//   evt_temple_theft, evt_ghost_road
// ═══════════════════════════════════════════════════════════════
