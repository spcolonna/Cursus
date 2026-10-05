// ═══════════════════════════════════════════════════════════════
// GAME CONTENT — EXPANSION PACK
// 12 rutas nuevas (real_04..real_15) y 15 eventos nuevos del camino.
// No modifica game_content.dart: se importa y se agrega por separado.
// Español rioplatense, sin emojis, sin anacronismos (ver .claude/skills/historia).
// ═══════════════════════════════════════════════════════════════

import 'game_content.dart';
import '../domain/entities/entities.dart';
import '../domain/entities/world.dart';

// ═══════════════════════════════════════════════════════════════
// EXPANSION MISSIONS — real_04 .. real_15
// ═══════════════════════════════════════════════════════════════

/// Todas las rutas jugables: base + expansión.
List<RealMissionConfig> get allRealMissions =>
    [...phase1Missions, ...expansionMissions];

/// Todo el pool de eventos del camino: base + expansión.
List<RealEventConfig> get allRealEvents =>
    [...realEventPool, ...expansionEvents];

const List<RealMissionConfig> expansionMissions = [
  RealMissionConfig(
    id: 'real_04',
    origin: 'Roma',
    destination: 'Tibur',
    distanceKm: 25,
    durationMinutes: 30,
    danger: 0.10,
    requiredRank: 1,
    lore: 'Un recado breve a Tibur, entre villas de veraneo y el rumor fresco de las cascadas.',
    packageOptions: [
      'Una invitación para una cena de verano',
      'Un recado personal para la villa de un magistrado',
    ],
    eventPoolIds: ['evt_patrol', 'evt_pickpocket', 'evt_tax_collector', 'evt_lost_child'],
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
    lore: 'El Templo de la Fortuna en Praeneste espera un mensaje que no puede demorarse ni un día.',
    packageOptions: [
      'Una ofrenda sellada para el templo',
      'Correspondencia de un sacerdote a su familia en Roma',
    ],
    eventPoolIds: ['evt_patrol', 'evt_omen', 'evt_temple_theft', 'evt_wedding_road'],
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
    lore: 'La costa de Antium, villa de patricios, aguarda correspondencia que prefiere no viajar sola.',
    packageOptions: [
      'Cartas entre dos villas de la costa',
      'Un pedido urgente de un patricio retirado',
    ],
    eventPoolIds: ['evt_patrol', 'evt_merchant_offer', 'evt_cart_jam', 'evt_tax_collector', 'evt_ferry'],
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
    lore: 'Un salto corto entre Neapolis y Pompeii, por caminos que huelen a mar y a azufre.',
    packageOptions: [
      'Un cargamento de pergaminos comerciales',
      'Una carta entre comerciantes de vino',
    ],
    eventPoolIds: ['evt_bandits', 'evt_heatwave', 'evt_wolf', 'evt_pickpocket', 'evt_oracle'],
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
    lore: 'La cueva de la Sibila espera en Cumae. Dicen que ahí los caminos también hablan.',
    packageOptions: [
      'Una consulta escrita para la Sibila',
      'Correspondencia de un senador supersticioso',
    ],
    eventPoolIds: ['evt_storm', 'evt_oracle', 'evt_omen', 'evt_ghost_road', 'evt_bandits', 'evt_merchant_offer'],
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
    lore: 'Beneventum, cruce de caminos del sur, necesita noticias que no esperen la próxima caravana.',
    packageOptions: [
      'Órdenes administrativas para el cruce de caminos',
      'Correspondencia militar de rutina',
    ],
    eventPoolIds: ['evt_bandits', 'evt_injured', 'evt_wolf', 'evt_deserter', 'evt_old_soldier', 'evt_heatwave'],
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
    lore: 'Entre pantanos del norte, Ravenna y Aquileia se hablan por mensajeros, no por mapas confiables.',
    packageOptions: [
      'Registros de aduana entre puertos del norte',
      'Correspondencia de mercaderes de ámbar',
    ],
    eventPoolIds: ['evt_flood', 'evt_ferry', 'evt_landslide', 'evt_patrol', 'evt_storm', 'evt_spy_drop'],
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
    lore: 'La costa entre Pisae y Genua es hermosa y traicionera a partes iguales. Llevá abrigo.',
    packageOptions: [
      'Cartas entre astilleros de la costa',
      'Un contrato de compra de madera naval',
    ],
    eventPoolIds: ['evt_landslide', 'evt_storm', 'evt_wolf', 'evt_bridge', 'evt_forge_fire', 'evt_injured'],
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
    lore: 'Tarentum, puerto del sur, paga bien a quien llega antes que el rumor.',
    packageOptions: [
      'Correspondencia de un armador del sur',
      'Documentos de embarque hacia Oriente',
    ],
    eventPoolIds: ['evt_tax_collector', 'evt_deserter', 'evt_spy_drop', 'evt_heatwave', 'evt_merchant_offer', 'evt_rival_messenger'],
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
    lore: 'Brundisium embarca hacia Oriente. Lo que llega tarde, se queda en el muelle.',
    packageOptions: [
      'Órdenes de embarque para las legiones de Oriente',
      'Correspondencia diplomática sellada',
    ],
    eventPoolIds: ['evt_deserter', 'evt_spy_drop', 'evt_tax_collector', 'evt_letter_bribe', 'evt_heatwave', 'evt_old_soldier', 'evt_wedding_road'],
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
    lore: 'Un día entero de camino hasta la frontera de Aquileia, donde Roma empieza a dudar de sus propios mapas.',
    packageOptions: [
      'Tratados fronterizos para el gobernador de la región',
      'Correspondencia militar confidencial',
    ],
    eventPoolIds: ['evt_flood', 'evt_landslide', 'evt_ghost_road', 'evt_wolf', 'evt_storm', 'evt_patrol', 'evt_omen', 'evt_deserter'],
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
    lore: 'Dos días de camino hasta Massilia, en la Galia. La ruta más larga que un mensajero puede aceptar sin preguntar por qué.',
    packageOptions: [
      'Un tratado comercial con la Galia',
      'Correspondencia diplomática de largo alcance',
    ],
    eventPoolIds: ['evt_storm', 'evt_bandits', 'evt_ghost_road', 'evt_wolf', 'evt_landslide', 'evt_oracle', 'evt_merchant_offer', 'evt_old_soldier', 'evt_letter_bribe', 'evt_deserter'],
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
    title: 'Crecida en el vado',
    description: 'La lluvia de la noche crece un río que ayer se cruzaba caminando. El vado desapareció bajo agua marrón y rápida. Del otro lado, el camino sigue esperando.',
    options: [
      RealOptionConfig(
        id: 'opt_flood_wait', text: 'Esperás en la orilla a que baje la corriente',
        riskLevel: 1, timeCostMinutes: 180, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Te sentás bajo un sauce y ves bajar la corriente hora tras hora. Al atardecer el vado reaparece, manso como si nunca hubiera crecido. Cruzás con los pies secos.',
        outcomePartial: 'La espera se estira más de lo pensado: la lluvia vuelve, chica pero terca. Cruzás igual, ya de noche, con el barro hasta las rodillas.',
        outcomeFail: 'Te quedás dormido contra el tronco y quien te despierta es el frío del atardecer. El vado bajó hace rato; vos, no tanto.',
      ),
      RealOptionConfig(
        id: 'opt_flood_cross', text: 'Cruzás a pie con el agua a la cintura',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Leés la corriente como un vadeador viejo: paso firme, cuerpo de costado, el paquete en alto. Salís del otro lado empapado hasta el pecho y nada más.',
        outcomePartial: 'La corriente te corre más de lo calculado y salís veinte metros más abajo, entre juncos. Mojado hasta el cuello, pero con todo lo que llevabas.',
        outcomeFail: 'Un remolino te hace perder pie a mitad de camino. Nadás más de lo que caminás y llegás a la otra orilla tosiendo agua marrón y maldiciendo al cielo.',
      ),
      RealOptionConfig(
        id: 'opt_flood_plank', text: 'Pagás a un pastor por su puente de tablas',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'El pastor guarda tres tablones justo para estos días. Cobra caro y sonríe más caro todavía, pero cruzás seco y rápido sobre su puente de fortuna.',
        outcomePartial: 'Las tablas ceden un poco a mitad de camino y terminás con un pie mojado y el corazón acelerado. El pastor cobra igual, sin descuento por el susto.',
        outcomeFail: 'El pastor cambió de idea a último momento: "hoy no, muchacho". Perdés el tiempo de la negociación y cruzás igual, por donde ibas a cruzar de entrada.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_tax_collector',
    title: 'El recaudador del portazgo',
    description: 'En el puesto de portazgo, un recaudador con tablilla de cera revisa cada carga dos veces. Tu paquete no tiene el sello que él quiere ver, y él no tiene apuro.',
    options: [
      RealOptionConfig(
        id: 'opt_tax_pay', text: 'Pagás el portazgo completo, sin discutir',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'Pagás sin poner cara y el recaudador, sorprendido de no discutir con nadie por una vez, hasta te marca el camino más corto en la tablilla. Rareza total.',
        outcomePartial: 'Pagás, pero el recaudador tarda una eternidad en anotar cada moneda, como si desconfiara de los números. Salís libre y aburrido.',
        outcomeFail: 'El recaudador encuentra un impuesto nuevo que inventó esta misma mañana. Pagás dos veces por el mismo cruce y aprendés que la cera se puede reescribir.',
      ),
      RealOptionConfig(
        id: 'opt_tax_dodge', text: 'Rodeás el puesto por el campo arado',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 2},
        outcomeSuccess: 'El campo recién arado esconde tus pasos mejor que cualquier excusa. Salís al camino trescientos metros más allá, con las sandalias sucias y el portazgo intacto en el bolsillo.',
        outcomePartial: 'El barro del campo te frena más de lo esperado y perdés una sandalia en el intento. Llegás al otro lado descalzo de un pie y con la dignidad embarrada.',
        outcomeFail: 'Un perro de guardia del campo te delata a mitad de camino. Volvés al puesto escoltado por sus ladridos y terminás pagando el doble por la vergüenza.',
      ),
      RealOptionConfig(
        id: 'opt_tax_permit', text: 'Mostrás un salvoconducto del gremio',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'El recaudador reconoce el sello del gremio de mensajeros y no necesita más. Te hace un gesto casi respetuoso, y el paso queda libre.',
        outcomePartial: 'El recaudador mira el salvoconducto largo rato, comparándolo con uno viejo que guarda. Al final te deja pasar, no sin dejar constancia de la demora.',
        outcomeFail: 'El salvoconducto es de un gremio que ya no existe hace dos años. El recaudador se ríe, no de mala manera, y te cobra el portazgo completo por la ocurrencia.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_lost_child',
    title: 'La nena del cruce',
    description: 'En el cruce de caminos, una nena de no más de seis años llora sola, sin nadie a la vista. Repite un nombre entre lágrimas: el de un pueblo, o quizás el de su madre.',
    options: [
      RealOptionConfig(
        id: 'opt_child_walk', text: 'La llevás de la mano hasta el pueblo más cercano',
        riskLevel: 1, timeCostMinutes: 120, requiredSkills: {},
        repDelta: {Faction.guild: 2},
        setFlags: ['helped_lost_child'],
        journalNote: 'Llevé a una nena perdida hasta el pueblo. Llegué tarde a destino. Fue lo correcto igual.',
        outcomeSuccess: 'Caminan juntos hasta el pueblo, ella contándote cada flor del camino. En la plaza, una mujer grita su nombre y corre. "Gracias, mensajero" no alcanza, pero lo dice igual.',
        outcomePartial: 'El pueblo queda más lejos de lo que pensabas y la nena se cansa a mitad de camino. Termina las últimas cuadras en tus hombros, más liviana que el paquete.',
        outcomeFail: 'Se hace tarde y el pueblo resulta ser el equivocado: nadie la conoce ahí. Volvés sobre tus pasos con la nena dormida en brazos y el sol ya bajo.',
      ),
      RealOptionConfig(
        id: 'opt_child_leave', text: 'Le señalás el camino y seguís apurado',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: -1},
        journalNote: 'Le señalé un camino a una nena perdida y seguí de largo. El plazo ganó. No sé si hice bien.',
        outcomeSuccess: 'Le indicás el camino recto al pueblo y la ves alejarse, insegura pero decidida. Seguís tu ruta con la conciencia apenas incómoda.',
        outcomePartial: 'Le señalás el camino y a los cien pasos escuchás que sigue llorando en el mismo lugar, sin animarse a caminar sola. Dudás, pero seguís.',
        outcomeFail: 'El camino que le indicaste tiene una bifurcación que olvidaste mencionar. Te enterás recién en el próximo pueblo, cuando alguien pregunta por una nena perdida.',
      ),
      RealOptionConfig(
        id: 'opt_child_ask', text: 'Preguntás en la posada más cercana por su familia',
        riskLevel: 2, timeCostMinutes: 45, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El posadero conoce a media comarca: reconoce el nombre que repite la nena y manda a un mozo a buscar a su tío. Antes de que se enfríe tu vino, ya se la llevan.',
        outcomePartial: 'Nadie en la posada la reconoce, pero el posadero se ofrece a cuidarla hasta que alguien la busque. Te vas confiando en la palabra de un desconocido amable.',
        outcomeFail: 'Preguntás de mesa en mesa sin suerte y la posada entera termina mirándote como sospechoso de algo. Te vas sin respuestas y con el tiempo perdido.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_wolf',
    title: 'Aullidos cerca del camino',
    description: 'El sol cae y los aullidos suenan más cerca de lo cómodo, en un tramo de bosque sin pueblos a la vista. Algo grande se mueve entre los árboles, al ritmo de tus pasos.',
    options: [
      RealOptionConfig(
        id: 'opt_wolf_fire', text: 'Armás una fogata y esperás la luz del día',
        riskLevel: 1, timeCostMinutes: 360, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El fuego alto mantiene a la manada a distancia toda la noche. Al amanecer solo quedan huellas alrededor del campamento, círculo perfecto de curiosidad y respeto.',
        outcomePartial: 'El fuego se apaga dos veces por el viento y pasás la noche alimentándolo con manos temblorosas. Amanecés agotado pero entero, y con leña de sobra.',
        outcomeFail: 'Te quedás dormido pasada la medianoche y el fuego muere solo. Despertás al alba con el corazón latiendo fuerte y unas huellas frescas a un metro de tu manta.',
      ),
      RealOptionConfig(
        id: 'opt_wolf_run', text: 'Apurás el paso sin mirar atrás',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Corrés el tramo boscoso al ritmo de tu propio miedo, que resulta ser bastante rápido. Salís al claro sin mirar atrás ni una vez. Los aullidos se quedan atrás también.',
        outcomePartial: 'Corrés y tropezás con una raíz que casi te cuesta el paquete. Llegás al claro con las rodillas raspadas, pero los aullidos ya suenan lejos.',
        outcomeFail: 'En la corrida perdés el sendero y das tres vueltas sobre el mismo grupo de árboles antes de encontrar la salida. La manada, al parecer, solo miraba.',
      ),
      RealOptionConfig(
        id: 'opt_wolf_read', text: 'Leés el terreno y encontrás dónde no están',
        riskLevel: 3, timeCostMinutes: 30, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Reconocés las señales: pisadas frescas, marcaciones en la corteza. La manada caza río abajo, no acá. Cruzás el tramo tranquilo, casi curioso de tu propio oficio.',
        outcomePartial: 'Tu lectura del terreno es correcta a medias: evitás a la manada pero no a un zorro nervioso que te sigue gruñendo un buen trecho.',
        outcomeFail: 'Confundís marcas viejas con frescas y el atajo que elegís te acerca más de la cuenta. Retrocedés despacio, sin apuro, con el corazón en la garganta.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_ferry',
    title: 'El transbordador del estuario',
    description: 'El único cruce del estuario es una barcaza vieja que un barquero maneja según su humor del día. Hoy, por lo visto, el humor no es bueno.',
    options: [
      RealOptionConfig(
        id: 'opt_ferry_wait', text: 'Esperás el próximo turno, sin apurar al barquero',
        riskLevel: 1, timeCostMinutes: 150, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Esperás tu turno en la orilla, mirando pasar gaviotas y carros. El barquero, al ver que no protestás, te acomoda antes de lo que decía la fila.',
        outcomePartial: 'El turno tarda el doble de lo prometido: el barquero prioriza a quien paga de más. Cruzás igual, ya con el sol bajando.',
        outcomeFail: 'Cuando por fin te toca, la marea baja demasiado y la barcaza no puede zarpar. Esperás una vuelta completa de la marea, mirando el estuario vacío.',
      ),
      RealOptionConfig(
        id: 'opt_ferry_bribe', text: 'Le ofrecés el doble por saltar la fila',
        riskLevel: 3, timeCostMinutes: 20, requiredSkills: {},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'El barquero cuenta las monedas con una sonrisa torcida y te hace subir antes que a nadie. Cruzás el estuario mientras los que esperaban todavía protestan en la orilla.',
        outcomePartial: 'Acepta el doble, pero te hace esperar "un ratito" que se estira. Cruzás igual, aunque con la sensación de haber pagado de más por poco.',
        outcomeFail: 'El barquero acepta tu plata y la de otros tres al mismo tiempo, sin aclarar el orden. Terminás discutiendo tu lugar en la fila que creías haber comprado.',
      ),
      RealOptionConfig(
        id: 'opt_ferry_swim', text: 'Cruzás el estuario a nado, lejos de la barcaza',
        riskLevel: 5, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 3},
        outcomeSuccess: 'Conocés las corrientes del estuario mejor que el barquero mismo: entrás por donde el agua empuja a favor y salís del otro lado antes de que la barcaza zarpe.',
        outcomePartial: 'La corriente del estuario es más fuerte que cualquier río y te empuja bien lejos del punto que buscabas. Llegás río arriba, agotado pero con todo intacto.',
        outcomeFail: 'A mitad de estuario un banco de arena te frena en el peor momento: el agua te llega al pecho y tenés que caminar media legua hundido hasta encontrar salida.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_forge_fire',
    title: 'Fuego en la herrería',
    description: 'Al pasar por un pueblo de posta, ves llamas saliendo del techo de paja de la herrería. Adentro alguien grita y afuera nadie parece decidirse a actuar.',
    options: [
      RealOptionConfig(
        id: 'opt_forge_help', text: 'Te sumás a la cadena de baldes',
        riskLevel: 2, timeCostMinutes: 90, requiredSkills: {},
        repDelta: {Faction.guild: 2},
        journalNote: 'Ayudé a apagar un incendio en una herrería de paso. Llegué tarde a destino, pero el pueblo tiene techo.',
        outcomeSuccess: 'La cadena de baldes gana terreno al fuego de a poco, y con tus brazos de más se apaga antes de llegar al establo vecino. El herrero, tiznado y agradecido, jura recordar tu cara.',
        outcomePartial: 'El fuego cede pero no sin llevarse la mitad del techo. Salís oliendo a humo y con las manos ampolladas, pero el pueblo entero te palmea la espalda.',
        outcomeFail: 'El humo te gana antes que las llamas y terminás tosiendo a un costado mientras otros terminan el trabajo. Igual, nadie te reprocha el intento.',
      ),
      RealOptionConfig(
        id: 'opt_forge_pass', text: 'Rodeás la conmoción y seguís tu camino',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: -1},
        outcomeSuccess: 'Rodeás el gentío y seguís de largo. El fuego, según te enterás después, se apagó solo antes de mayores daños. Tu plazo, intacto.',
        outcomePartial: 'Seguís de largo, pero el griterío te sigue dos cuadras completas antes de perderse detrás. Llegás al próximo tramo con la cabeza en otro lado.',
        outcomeFail: 'El humo cambia de dirección justo cuando pasás y terminás corriendo un tramo con los ojos llorando y la garganta áspera, sin haber ayudado ni evitado nada.',
      ),
      RealOptionConfig(
        id: 'opt_forge_smart', text: 'Organizás el rescate: agua por un lado, tierra por el otro',
        riskLevel: 3, timeCostMinutes: 45, requiredSkills: {SkillType.survival: 2},
        repDelta: {Faction.guild: 2, Faction.patricians: 1},
        outcomeSuccess: 'Repartís tareas como si lo hubieras hecho toda la vida: unos con agua, otros cortando el paso al viento con tierra húmeda. El fuego muere rápido y el pueblo entero pregunta tu nombre.',
        outcomePartial: 'Tu método funciona a medias: el fuego principal cede, pero una chispa prende el corral de al lado. Terminás ayudando ahí también, más cansado de lo planeado.',
        outcomeFail: 'Das órdenes con confianza, pero nadie te conoce y nadie obedece del todo. El caos gana la primera media hora, hasta que el fuego decide apagarse por cuenta propia.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_oracle',
    title: 'La sibila de Cumas',
    description: 'En la boca de una cueva, una anciana de ojos blancos susurra versos que nadie pidió. Te señala directo a vos: "El mensaje que llevás no es el que creés que es." Después, extiende la mano.',
    options: [
      RealOptionConfig(
        id: 'opt_oracle_listen', text: 'Te quedás a escuchar el resto del vaticinio',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        setFlags: ['heard_the_sibyl'],
        outcomeSuccess: 'El vaticinio completo es largo, extraño y en varios idiomas. Al final, algo en sus palabras encaja con algo que vas a ver más adelante en el camino. Salís pensativo, no asustado.',
        outcomePartial: 'Escuchás gran parte del vaticinio antes de que otro viajero interrumpa con su propia consulta. Te vas con la mitad de un mensaje que quizás nunca necesites.',
        outcomeFail: 'El vaticinio se pierde entre el eco de la cueva y el viento. Salís sin entender nada, salvo que perdiste una hora entera escuchando ecos.',
      ),
      RealOptionConfig(
        id: 'opt_oracle_ignore', text: 'Le dejás una moneda chica y seguís de largo',
        riskLevel: 2, timeCostMinutes: 10, requiredSkills: {},
        repDelta: {Faction.patricians: -1},
        outcomeSuccess: 'La moneda tintinea en su cuenco y la sibila no dice nada más. Seguís camino liviano de bolsillo y de superstición.',
        outcomePartial: 'Dejás la moneda y la anciana la rechaza con un gesto: quiere algo más, algo que no tenés para dar. Te vas con la moneda todavía en la mano.',
        outcomeFail: 'La moneda rueda y se pierde entre las piedras de la cueva. La sibila se ríe, un sonido que te acompaña varios pasos más de los que quisieras.',
      ),
      RealOptionConfig(
        id: 'opt_oracle_bargain', text: 'Le ofrecés una historia a cambio de un vaticinio claro',
        riskLevel: 3, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: 'Le contás algo real del camino y ella, complacida, te devuelve un vaticinio sin acertijos: una advertencia concreta sobre lo que viene más adelante. Rarísimo trato, bien cerrado.',
        outcomePartial: 'El intercambio funciona a medias: te da un vaticinio, pero envuelto en tantos símbolos que vas a tardar el resto del viaje en descifrarlo.',
        outcomeFail: 'Tu historia no le interesa lo suficiente. La sibila vuelve a sus murmullos como si no hubieras hablado. Te vas sin nada, ni siquiera un eco.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_deserter',
    title: 'El desertor de la ruta',
    description: 'Escondido entre unas rocas, un joven con uniforme de legión pero sin armas te pide, en voz baja, que no digas que lo viste. Tiembla más de miedo que de frío.',
    options: [
      RealOptionConfig(
        id: 'opt_deserter_avoid', text: 'Seguís de largo, sin ver nada',
        riskLevel: 1, timeCostMinutes: 30, requiredSkills: {},
        outcomeSuccess: 'Seguís tu camino sin girar la cabeza. Lo que no viste, no lo tenés que explicar. El camino sigue tranquilo el resto de la tarde.',
        outcomePartial: 'Seguís de largo, pero el corazón te late fuerte un buen trecho, esperando gritos de patrulla que nunca llegan.',
        outcomeFail: 'Un legionario de patrulla te para dos leguas después, preguntando si viste a alguien raro por el camino. Mentís mal, y eso te cuesta una revisión completa del bolso.',
      ),
      RealOptionConfig(
        id: 'opt_deserter_help', text: 'Le das tu capa vieja y le señalás un desvío',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.legions: -2, Faction.underworld: 1},
        setFlags: ['helped_deserter'],
        journalNote: 'Ayudé a escapar a un desertor de la legión. Espero que valga la pena, para él y para mí.',
        outcomeSuccess: 'Le tirás la capa vieja y un gesto hacia el bosque. Desaparece sin decir gracias, que es la única forma correcta de decirlo en su situación. Vos seguís, más liviano de una capa y de una duda.',
        outcomePartial: 'Le das la capa, pero duda tanto tiempo en el desvío que casi los agarran juntos. Se va al fin, y vos con el pulso todavía alto.',
        outcomeFail: 'Apenas se aleja, una patrulla lo alcanza a la vista tuya. Te interrogan a vos también, por las dudas. La capa, dicen, "coincide con la descripción".',
      ),
      RealOptionConfig(
        id: 'opt_deserter_talk', text: 'Lo convencés de entregarse a un oficial que conocés',
        riskLevel: 2, timeCostMinutes: 60, requiredSkills: {SkillType.contacts: 3},
        repDelta: {Faction.legions: 2},
        outcomeSuccess: 'Conocés a un centurión que trata estas cosas con más cabeza que castigo. Lo convencés de presentarse ahí, no en cualquier puesto. Sale mejor de lo que el chico esperaba.',
        outcomePartial: 'Lo convencés a medias: acepta ir, pero cambia de opinión dos veces en el camino. Al final lo dejás en manos del centurión, sin garantías de nada.',
        outcomeFail: 'El chico se asusta a mitad de la charla y corre de nuevo hacia el bosque. Te quedás con las manos vacías y la sensación de haber perdido una hora por nada.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_wedding_road',
    title: 'Cortejo de bodas',
    description: 'Una procesión de bodas ocupa el camino entero: antorchas, flautas y un tropel de invitados felices que no tienen ningún apuro. La novia va al centro, cubierta de velo naranja.',
    options: [
      RealOptionConfig(
        id: 'opt_wedding_wait', text: 'Te hacés a un lado y dejás pasar la fiesta',
        riskLevel: 1, timeCostMinutes: 45, requiredSkills: {},
        outcomeSuccess: 'Te apartás y la procesión pasa entera, con música y arroz volando. Alguien te tira una flor sin razón aparente. Seguís camino de mejor humor.',
        outcomePartial: 'La fiesta se detiene justo frente a vos para un brindis improvisado. Esperás con la copa que te ofrecen, sin poder decir que no.',
        outcomeFail: 'La procesión se detiene tanto tiempo que empezás a formar parte del paisaje. Un tío borracho del novio insiste en contarte la genealogía completa de la familia.',
      ),
      RealOptionConfig(
        id: 'opt_wedding_cut', text: 'Te metés entre la gente para cruzar más rápido',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: -1},
        outcomeSuccess: 'Te deslizás entre bailarines e invitados con disculpas rápidas y pasos más rápidos todavía. Salís del otro lado de la procesión antes de que alguien note tu apuro.',
        outcomePartial: 'Cruzás entre la gente, pero chocás con la bandeja de un esclavo que sirve vino. Salís del otro lado con la túnica manchada y varias miradas encima.',
        outcomeFail: 'Te confunden con parte del cortejo y alguien te empuja hacia el centro de la ronda de baile. Tardás en escapar de la fiesta más de lo que hubiera tardado esperando.',
      ),
      RealOptionConfig(
        id: 'opt_wedding_greet', text: 'Saludás a la familia como si te hubieran invitado',
        riskLevel: 2, timeCostMinutes: 15, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'Felicitás a los padres de la novia con la formalidad justa. Te confunden con un invitado lejano y hasta te abren paso de honor entre los bailarines.',
        outcomePartial: 'El saludo funciona, pero alguien pregunta de qué familia venís. Improvisás un apellido y salís antes de que la pregunta se repita.',
        outcomeFail: 'El padre de la novia te reconoce como nadie de la familia y la fiesta se detiene un instante incómodo. Te disculpás y cruzás rápido, entre risas ajenas.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_landslide',
    title: 'Derrumbe en la sierra',
    description: 'Un desprendimiento de rocas tapó el paso de montaña esta misma mañana. Piedras del tamaño de un buey bloquean el camino de lado a lado.',
    options: [
      RealOptionConfig(
        id: 'opt_landslide_detour', text: 'Buscás el camino viejo que rodea la sierra',
        riskLevel: 1, timeCostMinutes: 300, requiredSkills: {},
        outcomeSuccess: 'El camino viejo está más largo pero entero: nadie lo usa desde que abrieron el paso nuevo, y hoy eso juega a tu favor. Llegás cansado, no varado.',
        outcomePartial: 'El camino viejo tiene su propio derrumbe, más chico, que rodeás trepando entre matorrales. Perdés más tiempo del calculado, pero llegás sin sustos.',
        outcomeFail: 'El camino viejo se pierde entre la maleza dos veces y tenés que retroceder para reencontrarlo. El rodeo se estira más de lo que cualquiera hubiera aguantado con paciencia.',
      ),
      RealOptionConfig(
        id: 'opt_landslide_climb', text: 'Trepás directamente sobre las rocas caídas',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Elegís cada roca como si el desprendimiento fuera una escalera hecha a propósito. Cruzás en minutos lo que a otros les va a costar horas de rodeo.',
        outcomePartial: 'Trepás bien, pero una piedra suelta te tuerce el tobillo en el último tramo. Cruzás igual, cojeando, con el orgullo más entero que el pie.',
        outcomeFail: 'A mitad de las rocas, una piedra cede bajo tu peso y rodás un buen trecho hacia atrás. Volvés a empezar, magullado y con menos ganas de atajos.',
      ),
      RealOptionConfig(
        id: 'opt_landslide_read', text: 'Leés las rocas y encontrás el paso más firme',
        riskLevel: 3, timeCostMinutes: 40, requiredSkills: {SkillType.survival: 3},
        outcomeSuccess: 'Distinguís las rocas asentadas de las que todavía se mueven, y trazás un camino invisible para cualquier otro. Cruzás rápido y sin un solo resbalón.',
        outcomePartial: 'Tu lectura es buena pero no perfecta: encontrás el paso firme a costa de un rodeo extra entre las rocas más grandes.',
        outcomeFail: 'Confiás en una roca que parecía firme y no lo era. El tropiezo no te tira, pero te obliga a rehacer media trepada por otro lado.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_spy_drop',
    title: 'El paquete equivocado',
    description: 'En una plaza vacía, alguien deja caer un rollo sellado justo frente a vos y desaparece entre la gente sin mirar atrás. El rollo no tiene tu nombre, pero ya lo tenés en la mano.',
    options: [
      RealOptionConfig(
        id: 'opt_spy_return', text: 'Lo entregás al primer puesto de guardia que encontrás',
        riskLevel: 2, timeCostMinutes: 90, requiredSkills: {},
        repDelta: {Faction.legions: 2, Faction.underworld: -1},
        outcomeSuccess: 'El oficial de guardia recibe el rollo con seriedad repentina y te agradece con un gesto que dice más que sus palabras. Lo que sea que era, ya no es problema tuyo.',
        outcomePartial: 'El guardia tarda en decidir si el hallazgo es asunto suyo o de otro puesto. Terminás esperando mientras dos oficiales discuten jurisdicciones.',
        outcomeFail: 'El puesto de guardia está vacío justo hoy. Cargás el rollo un tramo más largo del que querías, cada vez más incómodo con lo que sea que llevás encima.',
      ),
      RealOptionConfig(
        id: 'opt_spy_drop_it', text: 'Lo dejás caer donde estaba y te vas rápido',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Lo soltás exactamente donde cayó y te alejás sin apuro sospechoso. Nadie te vio recogerlo, nadie te ve dejarlo. Como si nunca hubiera pasado.',
        outcomePartial: 'Lo dejás caer, pero un chico de la plaza lo levanta antes de que te alejes del todo. Te preguntás, unas cuadras después, en qué lío quedó metido el chico.',
        outcomeFail: 'Justo cuando lo soltás, alguien te señala desde una ventana. No sabés si te vieron recoger o dejar el rollo, pero apurás el paso el resto de la tarde.',
      ),
      RealOptionConfig(
        id: 'opt_spy_read', text: 'Lo abrís un segundo, apenas para entender qué es',
        riskLevel: 4, timeCostMinutes: 15, requiredSkills: {SkillType.stealth: 2},
        setFlags: ['saw_the_message'],
        journalNote: 'Abrí un rollo que no era mío en una plaza vacía. Lo que leí, no lo cuento. Ni acá.',
        outcomeSuccess: 'Rompés el sello con dedos de cirujano y lo volvés a cerrar sin que se note. Lo que leíste no era para vos, pero ahora lo sabés igual. Guardás silencio, y el rollo, donde estaba.',
        outcomePartial: 'Alcanzás a leer la mitad antes de que pasos cercanos te obliguen a cerrarlo de golpe. El sello queda un poco torcido, y la mitad del mensaje, sin sentido claro.',
        outcomeFail: 'El sello se rompe mal y queda evidente que alguien lo abrió. Lo dejás donde estaba de todos modos, esperando que nadie relacione el desastre con vos.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_heatwave',
    title: 'Ola de calor',
    description: 'El sol de mediodía pega como un castigo personal. El camino tiembla de calor y el agua del odre se terminó hace dos leguas.',
    options: [
      RealOptionConfig(
        id: 'opt_heat_rest', text: 'Buscás sombra y esperás que baje el sol',
        riskLevel: 1, timeCostMinutes: 180, requiredSkills: {},
        outcomeSuccess: 'Encontrás la sombra generosa de un algarrobo viejo y esperás las horas más duras del día. Cuando retomás, el camino es otro: más fresco, más amable.',
        outcomePartial: 'La sombra que encontrás es escasa y compartida con un rebaño de cabras ruidosas. Esperás igual, entre balidos, hasta que el sol afloja un poco.',
        outcomeFail: 'Te dormís más de la cuenta bajo el árbol y despertás con el sol ya bajando del otro lado. La siesta ganó más tiempo del que pediste.',
      ),
      RealOptionConfig(
        id: 'opt_heat_push', text: 'Seguís caminando bajo el sol de lleno',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Racionás cada trago de lo poco que te queda y encontrás el ritmo justo para no quemarte las fuerzas. Llegás al próximo pueblo con la garganta seca y el plazo intacto.',
        outcomePartial: 'Aguantás el tramo, pero el calor te pasa factura en mareos cortos que te obligan a parar dos veces. Llegás entero, tambaleando un poco.',
        outcomeFail: 'El calor te gana a mitad de camino y terminás sentado a la sombra de una roca, esperando que el mundo deje de dar vueltas antes de seguir.',
      ),
      RealOptionConfig(
        id: 'opt_heat_farmer', text: 'Le pedís agua a un granjero del camino',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El granjero llena tu odre sin dudar y hasta te tira un sombrero de paja vieja "para el camino". Seguís fresco, con agua de sobra y una anécdota nueva.',
        outcomePartial: 'El granjero te da agua, pero pide ayuda a cambio: cargar dos baldes hasta el corral. Pagás con sudor lo que ibas a conseguir gratis.',
        outcomeFail: 'El granjero desconfía de un desconocido pidiendo agua a mediodía y te cierra la tranquera sin mucha explicación. Seguís con el odre tan vacío como antes.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_cart_jam',
    title: 'Embotellamiento en el puente',
    description: 'Dos carros de bueyes trabaron sus ruedas al cruzarse en el puente angosto. Detrás se amontona una fila de carretas, mulas y gritos que no ayudan a nadie.',
    options: [
      RealOptionConfig(
        id: 'opt_jam_wait', text: 'Esperás tu turno en la fila, resignado',
        riskLevel: 1, timeCostMinutes: 90, requiredSkills: {},
        outcomeSuccess: 'Esperás con paciencia mientras dos boyeros discuten de quién fue la culpa. Al final alguien cede, las ruedas se destraban y la fila avanza más rápido de lo esperado.',
        outcomePartial: 'La discusión entre los boyeros se estira con testigos, insultos y una apuesta improvisada. Cruzás al fin, cuando ya nadie recuerda cómo empezó todo.',
        outcomeFail: 'Justo cuando la fila empieza a moverse, una rueda se rompe del todo. Volvés a esperar mientras alguien va a buscar un carpintero al pueblo más cercano.',
      ),
      RealOptionConfig(
        id: 'opt_jam_walk', text: 'Cruzás el puente a pie, entre los carros',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Te colás a pie entre las ruedas trabadas y los bueyes resignados. Cruzás el puente en minutos, dejando atrás gritos que no son problema tuyo.',
        outcomePartial: 'Cruzás a pie, pero un boyero te confunde con parte del problema y te grita instrucciones inútiles todo el trayecto. Salís del otro lado, entero y algo sordo.',
        outcomeFail: 'Al pasar entre los carros, uno de los bueyes se asusta y casi te aplasta contra la baranda. Cruzás igual, con el corazón en la garganta.',
      ),
      RealOptionConfig(
        id: 'opt_jam_organize', text: 'Ayudás a destrabar las ruedas vos mismo',
        riskLevel: 3, timeCostMinutes: 30, requiredSkills: {SkillType.combat: 1},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Con fuerza y maña destrabás la rueda que nadie quería tocar. Los boyeros te aplauden con las manos callosas y la fila entera avanza gracias a vos.',
        outcomePartial: 'Destrabás una rueda, pero la otra necesita más manos de las que ofrecés solo. Terminás ayudando igual, más cansado de lo planeado.',
        outcomeFail: 'Hacés fuerza en el punto equivocado y la rueda se traba peor. Los boyeros te agradecen el intento con una mirada que dice todo lo contrario.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_temple_theft',
    title: 'Acusación en el templo',
    description: 'Frente al templo, un sacerdote grita que falta una ofrenda de plata y señala hacia el grupo de viajeros donde justo estás parado vos.',
    options: [
      RealOptionConfig(
        id: 'opt_temple_cooperate', text: 'Te quedás y dejás que revisen tu bolso',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'La revisión es rápida y limpia: tu bolso solo tiene lo que debería. El sacerdote se disculpa con una formalidad exagerada y te bendice, por las dudas.',
        outcomePartial: 'Revisan cada bolsillo dos veces, incómodos por no encontrar nada. Te dejan ir sin disculpas claras, pero al menos sin cadenas.',
        outcomeFail: 'Mientras revisan tu bolso, encuentran la ofrenda real en manos de otro viajero. La escena se resuelve, pero perdiste media hora entera de sospechas ajenas.',
      ),
      RealOptionConfig(
        id: 'opt_temple_flee', text: 'Te alejás rápido antes de que te señalen a vos',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: -2},
        setFlags: ['fled_temple_accusation'],
        outcomeSuccess: 'Te perdés entre la multitud del atrio antes de que el dedo del sacerdote termine de apuntar. Nadie te sigue. La conciencia, tampoco te sigue tanto.',
        outcomePartial: 'Escapás del grupo, pero un devoto te reconoce después en la plaza y comenta en voz alta que "corriste raro" frente al templo.',
        outcomeFail: 'Corrés y justo chocás con un guardia del templo que llegaba a ver el escándalo. Terminás explicando tu apuro con menos convicción de la que quisieras.',
      ),
      RealOptionConfig(
        id: 'opt_temple_identify', text: 'Señalás con calma al verdadero sospechoso',
        riskLevel: 3, timeCostMinutes: 20, requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: 'Notaste antes que nadie el bulto raro en la túnica de otro viajero. Lo señalás con calma y el sacerdote, agradecido, te libera de toda sospecha al instante.',
        outcomePartial: 'Tu sospecha resulta correcta a medias: señalás a alguien que solo escondía pan robado, no plata. Igual, te libera de la acusación original.',
        outcomeFail: 'Señalás a la persona equivocada y el verdadero ladrón aprovecha la confusión para escapar. El sacerdote te mira con más sospecha que antes.',
      ),
    ],
  ),
  RealEventConfig(
    id: 'evt_ghost_road',
    title: 'El tramo que nadie nombra',
    description: 'Los arrieros del último pueblo se negaron a acompañarte más allá de la piedra tallada. "Ese tramo no se nombra de noche", dijo uno, y ninguno lo contradijo.',
    options: [
      RealOptionConfig(
        id: 'opt_ghost_wait_dawn', text: 'Acampás antes de la piedra y esperás el amanecer',
        riskLevel: 1, timeCostMinutes: 300, requiredSkills: {},
        outcomeSuccess: 'Acampás del lado seguro de la piedra tallada, con el fuego alto toda la noche. Al amanecer el tramo es apenas un camino más, largo y sin sombra.',
        outcomePartial: 'La noche se hace larga entre ruidos que probablemente son animales y una imaginación que no ayuda. Cruzás al alba, cansado de no haber dormido casi nada.',
        outcomeFail: 'Te quedás dormido más tarde de lo planeado y perdés buena parte de la mañana. El tramo sigue ahí, tan tramo como siempre, esperando sin apuro.',
      ),
      RealOptionConfig(
        id: 'opt_ghost_cross_night', text: 'Cruzás el tramo de noche, solo',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Cruzás con paso firme y la cabeza fría, sin darle cuerpo a ningún ruido de la noche. Al otro lado, el camino sigue siendo solo camino.',
        outcomePartial: 'Cruzás, pero cada rama que cruje te hace mirar atrás. Llegás al otro lado sin nada real que reportar, salvo el pulso todavía alto.',
        outcomeFail: 'Un búho grita justo detrás tuyo y por un instante corrés más de lo que caminás. Cruzás igual, agitado y sin ganas de contarle a nadie los detalles.',
      ),
      RealOptionConfig(
        id: 'opt_ghost_ask_local', text: 'Le preguntás a un arriero la historia real del tramo',
        riskLevel: 2, timeCostMinutes: 40, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El arriero, con más vino que miedo, te cuenta la historia real: un accidente viejo, nada sobrenatural. Cruzás al día siguiente, sin supersticiones encima.',
        outcomePartial: 'El arriero cuenta tres versiones distintas de la misma historia, cada vez más exagerada. Cruzás igual, con más dudas que certezas.',
        outcomeFail: 'El arriero se ofende de que dudes de la leyenda y se niega a contarte nada más. Cruzás el tramo con la misma incertidumbre de siempre, solo que más tarde.',
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
