// ─────────────────────────────────────────────────────────────────────────────
// CONTENIDO DE HISTORIA — Arcos narrativos
//
// Un arco es una cadena de capítulos (misiones con eventos fijos) que
// ramifica según los flags que el jugador acumula. Editá acá sin tocar lógica.
//
// Arco 1: "La Sombra del Senado" — 5 capítulos, 3 finales.
// ─────────────────────────────────────────────────────────────────────────────

import '../domain/entities/entities.dart';
import '../domain/entities/world.dart';
import 'game_content.dart';

export '../domain/entities/content.dart';

// ═══════════════════════════════════════════════════════════════
// MOTOR — reglas de selección de capítulos
// ═══════════════════════════════════════════════════════════════

/// Capítulo que corresponde jugar para un arco/stage según los flags.
StoryMissionConfig? storyMissionFor(
    String arcId, int stage, Set<String> flags) {
  final atStage =
      storyArcClaudius.where((m) => m.arcId == arcId && m.stage == stage);
  return atStage.where((m) {
        if (m.requiredFlag != null && !flags.contains(m.requiredFlag)) {
          return false;
        }
        if (m.forbiddenFlag != null && flags.contains(m.forbiddenFlag)) {
          return false;
        }
        return true;
      }).firstOrNull ??
      // Red de seguridad: si ningún flag de camino quedó puesto, el arco no
      // se traba — sigue por la variante por defecto.
      atStage.where((m) => m.isDefaultVariant).firstOrNull;
}

/// Cantidad de capítulos del arco (índices 0..n-1).
int arcStageCount(String arcId) => 5;

/// Evento de historia por id (los eventos de historia usan la misma
/// estructura que los del pool real).
RealEventConfig? storyEventById(String id) =>
    storyEventPool.where((e) => e.id == id).firstOrNull;

// ═══════════════════════════════════════════════════════════════
// ARCO 1 — "La Sombra del Senado"
//
// Claudius contrata al jugador por fuera de la red de Varus. La
// correspondencia resulta implicar a un senador rival... que protege
// en secreto a la red del Gremio. Tres lealtades posibles, tres finales.
//
// Flags del arco:
//   told_varus / kept_secret            (capítulo 1)
//   sold_look_claudius / refused_northman (capítulo 2)
//   path_varus / path_claudius / path_underworld (capítulo 3)
//   ending_varus / ending_claudius / ending_underworld (+route_nocturna_unlocked)
// ═══════════════════════════════════════════════════════════════

const String kArcClaudius = 'arc_claudius';

const List<StoryMissionConfig> storyArcClaudius = [

  // ── Capítulo I ───────────────────────────────────────────────
  StoryMissionConfig(
    id: 'claudius_1',
    arcId: kArcClaudius,
    stage: 0,
    chapterTitle: 'Capítulo I — El encargo fuera de la red',
    origin: 'Roma — Foro',
    destination: 'Villa de Claudius',
    packageDescription: 'Nada. Esta vez, el paquete sos vos.',
    durationMinutes: 30,
    lore: 'Un esclavo con librea patricia te dejó una nota sin firma: el Senador Claudius quiere verte. A vos. Sin Varus.',
    narrativeIntro:
        'La nota es breve y el papel, carísimo: "Al mensajero que no miente. '
        'Mi villa, al caer el sol. Vení solo." Te acordás del Senador: la prueba '
        'de Varus, sus preguntas de ajedrecista. Los senadores no invitan '
        'mensajeros a sus villas. Los usan. Y sin embargo, acá estás, '
        'con la nota quemándote el bolsillo y una decisión que tomar antes de salir.',
    epilogue:
        'Claudius te recibe sin testigos, en un estudio lleno de mapas. '
        '"Necesito un correo que no exista", dice. "Cartas que no pasen por '
        'ninguna red. Ni siquiera la de tu comandante." Te estudia con esos '
        'ojos que ya te pesaron una vez. "Pagás bien tu fama de honesto. '
        'Volvé mañana. Habrá una carta." Al salir, la noche de Roma parece '
        'tener más oídos que antorchas.',
    journalEntry:
        'El Senador Claudius me quiere como su correo privado. Fuera de la red. Fuera de los registros.',
    fixedEventIds: ['s1_varus_dilemma', 's1_villa_gate'],
  ),

  // ── Capítulo II ──────────────────────────────────────────────
  StoryMissionConfig(
    id: 'claudius_2',
    arcId: kArcClaudius,
    stage: 1,
    chapterTitle: 'Capítulo II — El precio de la curiosidad',
    origin: 'Villa de Claudius',
    destination: 'Templo de Saturno',
    packageDescription: 'Una carta con doble sello y sin remitente',
    durationMinutes: 60,
    lore: 'La primera carta de Claudius. Doble sello, cero preguntas. El destino: un sacerdote del Templo de Saturno que "sabrá qué hacer".',
    narrativeIntro:
        'El mayordomo te entrega la carta como quien entrega una brasa: rápido '
        'y sin mirarla. Doble sello de cera negra. "El Senador dice que no '
        'existe, que vos no existís, y que esta carta menos." En la calle, '
        'notás que un vendedor de higos te sostiene la mirada medio segundo '
        'de más. Empieza el oficio de no existir.',
    epilogue:
        'El sacerdote del templo toma la carta sin abrirla y la deja caer en '
        'un brasero. La cera negra chisporrotea en verde. "Decile al que te '
        'manda que Saturno guarda silencio", recita, como quien repite una '
        'contraseña vieja. Salís del templo con la sensación de haber '
        'entregado algo mucho más pesado que papel.',
    journalEntry:
        'Entregué la primera carta de Claudius. La quemaron sin leerla frente a mí. ¿Qué clase de mensaje se escribe para el fuego?',
    fixedEventIds: ['s2_northman_offer', 's2_temple_watchers'],
  ),

  // ── Capítulo III ─────────────────────────────────────────────
  StoryMissionConfig(
    id: 'claudius_3',
    arcId: kArcClaudius,
    stage: 2,
    chapterTitle: 'Capítulo III — La carta que quema',
    origin: 'Villa de Claudius',
    destination: 'Casa del escriba Tiro',
    packageDescription: 'Un rollo grueso, sellado tres veces',
    durationMinutes: 45,
    lore: 'La tercera carta es distinta: gruesa, urgente, y Claudius en persona te la puso en la mano. "Esta no puede caerse. Esta no puede mojarse. Esta no puede existir."',
    narrativeIntro:
        'Nunca viste a Claudius nervioso hasta hoy. "El escriba Tiro. Antes '
        'de medianoche. Y mensajero..." — te retiene del brazo — "...si te '
        'paran, la quemás. ¿Entendido?" Un rollo que vale más quemado que '
        'leído. En tu oficio, esas cartas tienen nombre: sentencias.',
    epilogue:
        'Lo que pasó en el camino te sigue dando vueltas mientras Tiro — un '
        'hombrecito con dedos manchados de tinta — recibe lo que queda de tu '
        'encargo. Ahora sabés lo que llevabas: pruebas contra el Senador '
        'Petro. El mismo Petro que, según la carta, financia en secreto '
        'la red de mensajeros de Varus. Tu red. Tu comandante. '
        'Claudius no está limpiando Roma: está cortando la rama '
        'donde vos estás parado.',
    journalEntry:
        'La carta implica al Senador Petro: el protector secreto de la red de Varus. Claudius va a por él. Y yo elegí mi bando en un camino oscuro.',
    fixedEventIds: ['s3_broken_seal'],
  ),

  // ── Capítulo IV — tres variantes según el bando ──────────────
  StoryMissionConfig(
    id: 'claudius_4_varus',
    arcId: kArcClaudius,
    stage: 3,
    requiredFlag: 'path_varus',
    isDefaultVariant: true,
    chapterTitle: 'Capítulo IV — La noche de los cuchillos',
    origin: 'Cuartel de Varus',
    destination: 'Villa del Senador Petro',
    packageDescription: 'El aviso que puede salvar la red',
    durationMinutes: 45,
    lore: 'Varus leyó tu copia en silencio. Después dijo tres palabras: "Avisale a Petro." Esta noche, la red se juega entera.',
    narrativeIntro:
        'Varus no te agradeció. Los hombres como él agradecen con confianza, '
        'no con palabras. "Claudius va a mover sus piezas esta noche. Petro '
        'tiene que saberlo antes del amanecer o la red entera amanece '
        'colgada. Corré, mensajero. Corré como nunca." Afuera, Roma '
        'afila cuchillos en la oscuridad.',
    epilogue:
        'Petro lee tu aviso a la luz de una sola vela, y por un momento el '
        'patricio imperturbable deja ver el alivio. "Varus eligió bien a su '
        'gente." Antes del alba, los testigos de Claudius cambian de '
        'testimonio y sus pruebas, de dueño. La red respira. '
        'Claudius, en algún lugar de Roma, rompe algo caro.',
    journalEntry:
        'Corrí toda la noche para salvar la red. Petro está a salvo. Claudius sabe que fui yo. Que lo sepa.',
    fixedEventIds: ['s4_night_patrol', 's4_claudius_men'],
  ),
  StoryMissionConfig(
    id: 'claudius_4_claudius',
    arcId: kArcClaudius,
    stage: 3,
    requiredFlag: 'path_claudius',
    chapterTitle: 'Capítulo IV — La noche de los cuchillos',
    origin: 'Villa de Claudius',
    destination: 'Basílica Emilia',
    packageDescription: 'El expediente completo contra Petro',
    durationMinutes: 45,
    lore: 'Entregaste la carta como si nada. Claudius lo notó. "Sos mi correo ahora." Esta noche se define todo: el expediente tiene que llegar a los jueces.',
    narrativeIntro:
        '"Petro cae esta noche", dice Claudius, y te entrega un tubo de cuero '
        'sellado con su anillo. "Y con él, la red clandestina que financia. '
        'Sé que era la tuya. Por eso confío en vos: elegiste el futuro por '
        'encima de la nostalgia." El tubo pesa como una lápida. '
        'La de Varus, quizás.',
    epilogue:
        'El presidente del tribunal recibe el expediente con dedos ansiosos. '
        'Al amanecer, Roma tiene un escándalo nuevo y vos, un patrón poderoso. '
        'La red de Varus no cae — Petro negoció, los patricios siempre '
        'negocian — pero queda herida y lo sabe. En el cuartel ya no te '
        'guardan lugar junto al fuego. En la villa de Claudius, en cambio, '
        'tu copa siempre está llena. Elegiste. Se paga.',
    journalEntry:
        'Llevé el expediente que hirió a la red que me formó. Claudius me llama "mi correo". Varus no me llama más.',
    fixedEventIds: ['s4_night_patrol', 's4_guild_shadow'],
  ),
  StoryMissionConfig(
    id: 'claudius_4_underworld',
    arcId: kArcClaudius,
    stage: 3,
    requiredFlag: 'path_underworld',
    chapterTitle: 'Capítulo IV — La noche de los cuchillos',
    origin: 'Roma — Subura',
    destination: 'La Loba Dorada — taberna sin cartel',
    packageDescription: 'Una copia que no debería existir',
    durationMinutes: 45,
    lore: 'Copiaste lo que había que copiar antes de entregar. En la Subura hay gente que paga fortunas por secretos de senadores. Esta noche se subasta el tuyo.',
    narrativeIntro:
        'La contraseña es "el cuervo bebe solo". La taberna no tiene cartel '
        'y el que atiende no tiene preguntas. Al fondo, la Viuda — nadie '
        'sabe de quién — colecciona secretos como otros coleccionan ánforas. '
        'Tu copia del expediente puede hundir a dos senadores a la vez. '
        'O sostenerlos a ambos del cuello. Eso vale oro. Y enemigos.',
    epilogue:
        'La Viuda lee, sonríe, y te desliza una bolsa que no necesitás contar. '
        '"Ni Claudius ni Petro. Los dos van a pagar por que esto no salga a '
        'la luz. Y vos, mensajero..." — te estudia con respeto profesional — '
        '"...vos acabás de aprender que la información pesa menos que el oro '
        'y vale más." Desde esta noche, la Subura te conoce. '
        'Y las puertas que se abren de noche no se cierran más.',
    journalEntry:
        'Vendí el secreto a la Viuda de la Subura. Ahora dos senadores duermen mal y yo camino de noche como en casa.',
    fixedEventIds: ['s4_night_patrol', 's4_rival_buyer'],
  ),

  // ── Capítulo V — tres finales ────────────────────────────────
  StoryMissionConfig(
    id: 'claudius_5_varus',
    arcId: kArcClaudius,
    stage: 4,
    requiredFlag: 'path_varus',
    isDefaultVariant: true,
    chapterTitle: 'Capítulo V — El hombre de Varus',
    origin: 'Cuartel de Varus',
    destination: 'Roma — Foro',
    packageDescription: 'El último mensaje del asunto Claudius',
    durationMinutes: 90,
    lore: 'Queda un cabo suelto: la respuesta formal de Petro a Claudius. Varus quiere que la lleves vos. "Que Claudius vea la cara del que lo frenó."',
    narrativeIntro:
        'Varus te entrega la carta de Petro con algo rarísimo en él: '
        'una media sonrisa. "Claudius pidió que no fueras vos. Por eso vas '
        'vos. En este oficio, la lealtad se paga con confianza — y hoy sos '
        'el hombre de más confianza que tengo." El Foro te espera, '
        'y en su escalinata, un senador con la derrota fresca.',
    epilogue:
        'Claudius lee la carta de Petro de pie, sin invitarte a pasar. '
        'Cuando termina, te mira largo. "Elegiste al soldado sobre el '
        'senador. Espero que su lealtad te abrigue en invierno." No hay '
        'amenaza en su voz; hay algo peor: te tachó de su lista. '
        'Esa noche, en el cuartel, Varus levanta su copa sin decir '
        'discursos. No hace falta. Toda la red sabe lo que hiciste. '
        'Sos el hombre de Varus. En Roma, eso ahora significa algo.',
    journalEntry:
        'Fin del asunto Claudius. Elegí la red, elegí a Varus. El Senador me tachó de su lista y el Gremio me escribió en la suya.',
    fixedEventIds: ['s5_petro_gift', 's5_claudius_face'],
    setFlagsOnComplete: ['ending_varus', 'claudius_vetoed'],
    repDeltaOnComplete: {Faction.guild: 10, Faction.legions: 5, Faction.patricians: -5},
    endingId: 'end_varus',
    endingTitle: 'El hombre de Varus',
  ),
  StoryMissionConfig(
    id: 'claudius_5_claudius',
    arcId: kArcClaudius,
    stage: 4,
    requiredFlag: 'path_claudius',
    chapterTitle: 'Capítulo V — El protegido del Senador',
    origin: 'Villa de Claudius',
    destination: 'Curia — Senado de Roma',
    packageDescription: 'La primera carta de tu nueva vida',
    durationMinutes: 90,
    lore: 'Claudius te manda al mismísimo Senado con su correspondencia oficial. A la luz del día, con su librea. El mensaje es para Roma entera: este correo es mío.',
    narrativeIntro:
        'La librea es de lana buena y el salvoconducto lleva el sello grande. '
        '"Caminá por el medio de la calle", dice Claudius. "Que te vean. '
        'Un senador se mide por la calidad de los hombres que compra... '
        'perdón, que contrata." Su sonrisa es un contrato con letra chica. '
        'El Senado te espera, y Roma entera mira quién entra por esa puerta.',
    epilogue:
        'Entregás en la Curia ante escribas que anotan tu nombre — tu '
        'nombre — en el registro oficial. Al salir, un mensajero del Gremio '
        'te cruza en la escalinata: te mira la librea, después la cara, y '
        'sigue de largo sin saludar. Así se siente el precio. Esa noche, '
        'la paga de Claudius es generosa y el vino de su mesa, excelente. '
        'Brindás solo. Los protegidos de los senadores siempre brindan solos.',
    journalEntry:
        'Entré al Senado con la librea de Claudius. La paga es real, el poder es real. Los amigos del cuartel, ya no.',
    fixedEventIds: ['s5_senate_steps', 's5_varus_cold'],
    setFlagsOnComplete: ['ending_claudius', 'varus_cold'],
    repDeltaOnComplete: {Faction.patricians: 10, Faction.guild: -5},
    endingId: 'end_claudius',
    endingTitle: 'El protegido del Senador',
  ),
  StoryMissionConfig(
    id: 'claudius_5_underworld',
    arcId: kArcClaudius,
    stage: 4,
    requiredFlag: 'path_underworld',
    chapterTitle: 'Capítulo V — El que sabe demasiado',
    origin: 'La Loba Dorada',
    destination: 'Roma — los dos extremos',
    packageDescription: 'Dos cartas idénticas para dos senadores enemigos',
    durationMinutes: 90,
    lore: 'La Viuda tiene un último encargo: entregar el mismo mensaje a Claudius y a Petro. El mensaje dice: "Sabemos. Cobramos a fin de mes."',
    narrativeIntro:
        'Dos cartas, misma letra, distinto destinatario. "El arte", explica '
        'la Viuda, "no está en el secreto. Está en que ambos sepan que el '
        'otro también paga." Te toca ser la cara visible de un chantaje '
        'elegante a dos de los hombres más peligrosos de Roma. '
        'La Subura te mira caminar hacia la luz con su carga favorita: '
        'la verdad, bien administrada.',
    epilogue:
        'Claudius palidece al leer. Petro, en cambio, se ríe — una risa corta '
        'de jugador que reconoce la jugada. Ninguno te toca: matar al '
        'mensajero de la Viuda es declararle la guerra a la mitad oscura de '
        'Roma. Al volver a la Loba Dorada, hay una mesa con tu nombre y un '
        'camino nuevo en tu mapa: el correo nocturno, el que no figura, el '
        'que paga triple. Sabés demasiado para ser inocente y demasiado poco '
        'para estar muerto. En la Subura, a eso le dicen "socio".',
    journalEntry:
        'Entregué el chantaje de la Viuda a dos senadores en un mismo día. Ahora la noche de Roma tiene un camino con mi nombre.',
    fixedEventIds: ['s5_two_doors', 's5_widow_toast'],
    setFlagsOnComplete: ['ending_underworld', 'route_nocturna_unlocked'],
    repDeltaOnComplete: {Faction.underworld: 10, Faction.guild: -3, Faction.patricians: -3},
    endingId: 'end_underworld',
    endingTitle: 'El que sabe demasiado',
  ),
];

// ═══════════════════════════════════════════════════════════════
// EVENTOS DE HISTORIA
// ═══════════════════════════════════════════════════════════════

const List<RealEventConfig> storyEventPool = [

  // ── Capítulo I ───────────────────────────────────────────────
  RealEventConfig(
    id: 's1_varus_dilemma',
    title: 'La lealtad tiene horario',
    description: 'Antes de salir hacia la villa, pasás frente al cuartel. La luz de Varus está encendida, como siempre. Un senador te citó a escondidas de tu comandante. Podés entrar y contárselo. O podés seguir de largo y que esta historia sea solo tuya.',
    options: [
      RealOptionConfig(
        id: 'opt_tell_varus', text: 'Entrás y le contás todo a Varus',
        riskLevel: 1, timeCostMinutes: 15, requiredSkills: {},
        repDelta: {Faction.guild: 2},
        setFlags: ['told_varus'],
        journalNote: 'Le conté a Varus lo de Claudius antes de ir. Si esto sale mal, al menos no me hundo solo.',
        outcomeSuccess: 'Varus escucha sin interrumpir, como escucha él: con todo el cuerpo. "Andá", dice al final. "Escuchá más de lo que hables. Y acordate de quién te enseñó a caminar estas calles." Salís del cuartel más liviano.',
        outcomePartial: 'Varus frunce el ceño largo rato. "No me gusta. Andá igual — mejor adentro que afuera. Pero esto queda entre nosotros." Su confianza pesa tanto como su duda.',
        outcomeFail: 'Varus está reunido y te toca esperar. Cuando al fin le contás, la ventana del sol ya se cierra. "Corré", es todo lo que dice. Lo importante quedó dicho.',
      ),
      RealOptionConfig(
        id: 'opt_keep_secret', text: 'Seguís de largo — esto es tuyo',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        setFlags: ['kept_secret'],
        journalNote: 'No le conté a Varus lo de Claudius. Cada uno tiene derecho a un secreto. Este es el mío.',
        outcomeSuccess: 'Pasás frente al cuartel sin aflojar el paso. La luz de Varus queda atrás. Por primera vez desde que empezaste, llevás un mensaje que nadie más conoce. Se siente a vértigo. Se siente a crecer.',
        outcomePartial: 'Seguís de largo, aunque en la esquina dudás un instante — el suficiente para que un colega te vea y te salude. ¿Le dirá a Varus que te vio salir de noche? El secreto ya nació con testigos.',
        outcomeFail: 'Al pasar frente al cuartel, la puerta se abre: Varus en persona, despidiendo a alguien. "¿Adónde tan elegante, mensajero?" Improvisás una excusa de taberna. Te mira un segundo de más antes de asentir.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's1_villa_gate',
    title: 'La puerta de servicio',
    description: 'La villa de Claudius de noche es una fortaleza de mármol. La nota decía "vení solo", pero no decía cómo entrar. El portón principal tiene dos guardias. La puerta de servicio, un cocinero fumando. El muro, hiedra vieja.',
    options: [
      RealOptionConfig(
        id: 'opt_front_gate', text: 'Vas de frente y mostrás la nota',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'El guardia lee la nota, palidece apenas, y te escolta en silencio por el jardín principal. Ser esperado por un senador abre más puertas que cualquier ganzúa.',
        outcomePartial: 'Los guardias discuten cinco minutos si la nota es auténtica, hasta que el mayordomo aparece y corta la cuestión con un gesto. Entrás, pero ya no discreto: media servidumbre te vio la cara.',
        outcomeFail: 'El primer guardia no sabe leer y el segundo desconfía de lo que lee. Para cuando aparece el mayordomo, ya sos la anécdota de la guardia nocturna. Claudius va a enterarse de la entrada poco elegante.',
      ),
      RealOptionConfig(
        id: 'opt_service_door', text: 'Charlás con el cocinero de la puerta de servicio',
        riskLevel: 2, timeCostMinutes: 10, requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: 'Diez minutos de charla sobre el precio del garum y el cocinero ya te considera gente decente. Te cuela por las cocinas: entrás a la villa oliendo a laurel y sin que ningún guardia sepa tu cara.',
        outcomePartial: 'El cocinero te hace ganar la entrada escuchando sus quejas sobre el mayordomo. Entrás por las cocinas, sí, pero conociendo la vida y obra de cada empleado de la villa.',
        outcomeFail: 'El cocinero resulta ser el chismoso oficial de la villa. Te cuela, pero mañana toda la servidumbre sabrá que "un mensajero misterioso" visitó al amo de noche. Discreción: cero.',
      ),
      RealOptionConfig(
        id: 'opt_climb_ivy', text: 'Trepás por la hiedra del muro oeste',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 3},
        outcomeSuccess: 'La hiedra aguanta y vos también. Caés en el jardín interior sin un ruido, justo cuando Claudius sale a tomar aire. "Puntual y por el muro", murmura, genuinamente impresionado. "Mejor de lo que me dijeron."',
        outcomePartial: 'Trepás bien hasta que la hiedra decide jubilarse a mitad del muro. El aterrizaje en el rosal no es digno, pero nadie lo vio. Casi nadie: un pavo real te mira con desprecio.',
        outcomeFail: 'La hiedra cede con vos encima y el estruendo despierta a los perros. Terminás explicando la nota rodeado de tres mastines y un guardia sin sentido del humor. Claudius tendrá que bajar a rescatarte.',
      ),
    ],
  ),

  // ── Capítulo II ──────────────────────────────────────────────
  RealEventConfig(
    id: 's2_northman_offer',
    title: 'El hombre del norte',
    description: 'A tres cuadras del templo, un hombre de acento norteño te corta el paso con educación quirúrgica. "Doscientos denarios. Solo por dejarme ver el sello. Ni abrirla, ni tocarla. Ver el sello." Nadie ofrece doscientos denarios por mirar cera. Salvo que la cera diga todo.',
    options: [
      RealOptionConfig(
        id: 'opt_show_seal', text: 'Le mostrás el sello — solo el sello',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.underworld: 2, Faction.patricians: -2},
        setFlags: ['sold_look_claudius'],
        followUpEventId: 's2_followed',
        journalNote: 'Dejé que un espía norteño viera el sello de la carta de Claudius. Doscientos denarios por dos segundos de cera. Baratísimo. Carísimo.',
        outcomeSuccess: 'Le mostrás el sello dos segundos exactos. Al hombre le basta: "Cera negra. Entonces es cierto." Paga sin regatear y desaparece. Acabás de confirmarle algo a alguien, y ni sabés qué.',
        outcomePartial: 'El hombre estudia el sello con una lupa que aparece y desaparece de su manga. Paga, pero al irse te dice: "Decile a tu amo que el norte también lee." Escalofrío gratis.',
        outcomeFail: 'Mientras mira el sello, sus dedos rozan la carta un instante de más. La apartás de un tirón. Paga igual, pero la duda te queda: ¿alcanzó a leer algo al trasluz?',
      ),
      RealOptionConfig(
        id: 'opt_refuse_northman', text: '"El sello no se mira. Correte."',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: 2},
        setFlags: ['refused_northman'],
        journalNote: 'Un espía ofreció 200 denarios por mirar el sello de Claudius. Le dije que se corra. Mi palabra no tiene precio. Todavía.',
        outcomeSuccess: 'El hombre sonríe como si hubieras pasado un examen. "Claudius sabe elegir. Lástima." Se disuelve entre la gente. Tenés la sensación de que la oferta era la mitad prueba, la mitad trampa.',
        outcomePartial: 'Insiste subiendo a trescientos. Tu silencio lo aburre antes que tu negativa. "Todos tienen precio, mensajero. El tuyo será en otra moneda." Se va sin apuro.',
        outcomeFail: 'Tu negativa suena fuerte y dos transeúntes se dan vuelta. El hombre desaparece al instante, dejándote como el loco que le grita al aire. Ahora media calle recuerda tu cara y tu bolso.',
      ),
      RealOptionConfig(
        id: 'opt_grill_northman', text: 'Preguntás primero: "¿Quién paga por mirar cera?"',
        riskLevel: 3, timeCostMinutes: 15, requiredSkills: {SkillType.contacts: 3},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'Jugás su juego: pregunta por pregunta, silencio por silencio. Al final suelta más de lo que quería: "Petro paga. Petro paga por saber qué trama tu amo." Te vas sin vender nada y sabiendo un nombre que vale más que doscientos denarios.',
        outcomePartial: 'La conversación es un ajedrez de sobreentendidos. No te saca nada; no le sacás casi nada. "El norte", dice al irse, "siempre paga mejor que el sur." Anotado.',
        outcomeFail: 'Tus preguntas lo espantan: los profesionales no conversan. Se esfuma a media frase y te deja hablando solo, sin plata y sin datos. Al menos el sello está intacto.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's2_followed',
    title: 'Sombras propias',
    description: 'Desde que el norteño pagó, tenés compañía: dos hombres que cambian de vereda cuando vos cambiás, que miran vidrieras sin vidrio. Al templo no podés llevar cola.',
    options: [
      RealOptionConfig(
        id: 'opt_lose_them', text: 'Los perdés en el mercado de pescado',
        riskLevel: 3, timeCostMinutes: 20, requiredSkills: {SkillType.stealth: 2},
        outcomeSuccess: 'El mercado de pescado a esta hora es un campo de batalla de canastos y gritos. Entrás siendo uno y salís siendo nadie, por la puerta de las vísceras. Tus sombras siguen esperándote junto a los atunes.',
        outcomePartial: 'Los perdés, pero el precio es oler a sardina hasta el templo. El sacerdote va a arrugar la nariz. Mejor sardina que espías.',
        outcomeFail: 'Son buenos: uno cubre cada salida. Terminás perdiéndolos recién en los baños públicos, con un cambio de túnica de emergencia que te cuesta la dignidad y unos denarios.',
      ),
      RealOptionConfig(
        id: 'opt_confront_shadow', text: 'Encarás al más flaco en un callejón',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.combat: 2},
        outcomeSuccess: 'Lo esperás donde el callejón se angosta y lo ponés contra la pared antes de que respire. "Decile al que te paga que el correo de Claudius no se sigue." Se va corriendo. El otro también. Mensaje entregado — y este era gratis.',
        outcomePartial: 'El flaco zafa del agarre pero pierde una sandalia y el orgullo. Los dos desaparecen. Te queda la sandalia y la sospecha de que volverán con refuerzos otro día.',
        outcomeFail: 'El flaco resultó ser el cebo: el grandote te sujeta por atrás. Te sacuden un poco, pero un vigilante nocturno silba a lo lejos y se esfuman. Llegás al templo golpeado y con más preguntas.',
      ),
      RealOptionConfig(
        id: 'opt_long_route', text: 'Tomás el camino largo: que sigan, que se cansen',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        outcomeSuccess: 'Tres horas de vueltas sin sentido: entrás a dos tabernas por una puerta y salís por otra, rezás en un templo equivocado, comprás higos que no querés. Tus sombras se rinden a la segunda hora. La paciencia también es un arma.',
        outcomePartial: 'El paseo eterno funciona, pero te cuesta una hora larga y los pies. Cuando al fin llegás al templo, las sombras son solo las de las columnas.',
        outcomeFail: 'Son pacientes como cobradores. Al final los perdés de pura casualidad, cuando una procesión de Isis inunda la calle. Los dioses ayudan, pero cobran en tiempo.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's2_temple_watchers',
    title: 'Los ojos del templo',
    description: 'El Templo de Saturno de noche tiene más vigilantes que fieles. En la escalinata, un mendigo que no pide, un barrendero que no barre. Todos miran sin mirar. La carta te pesa en la túnica como si supiera.',
    options: [
      RealOptionConfig(
        id: 'opt_pilgrim_act', text: 'Entrás como un fiel más, con ofrenda y todo',
        riskLevel: 2, timeCostMinutes: 15, requiredSkills: {},
        outcomeSuccess: 'Comprás dos velas y un puñado de incienso, y entrás murmurando plegarias con cara de deudor arrepentido. Nadie mira dos veces a un fiel con problemas de plata. El sacerdote te reconoce por la contraseña de Claudius.',
        outcomePartial: 'Tu actuación de fiel es correcta, aunque casi te delatás al no saber de qué lado se deja la ofrenda. Un acólito te corrige con paciencia. Llegás al sacerdote justo.',
        outcomeFail: 'Te arrodillás del lado equivocado del altar y un sacerdote menor te sermonea cinco minutos sobre liturgia. El barrendero-que-no-barre te estudia todo ese tiempo. Entregás igual, pero fichado.',
      ),
      RealOptionConfig(
        id: 'opt_wait_shift', text: 'Esperás el cambio de guardia de los "mendigos"',
        riskLevel: 2, timeCostMinutes: 45, requiredSkills: {SkillType.stealth: 2},
        outcomeSuccess: 'A la hora undécima, el mendigo-que-no-pide se levanta y otro viene a reemplazarlo. En los treinta pasos que caminan para cruzarse, la escalinata queda ciega. Ya estás adentro.',
        outcomePartial: 'El cambio de guardia tarda más de lo esperado y esperar sin hacer nada es un arte que todavía no dominás. Un vendedor te ofrece castañas tres veces. Entrás al fin, con hambre.',
        outcomeFail: 'El relevo no llega nunca: hoy el mendigo hace doble turno. Terminás entrando por la puerta de los sacrificios, entre balidos de corderos que conocen su destino. El olor no se va más.',
      ),
    ],
  ),

  // ── Capítulo III ─────────────────────────────────────────────
  RealEventConfig(
    id: 's3_broken_seal',
    title: 'La carta que quema',
    description: 'Cruzando el Tíber, un carro te obliga a saltar y el rollo cae al empedrado. El tercer sello — solo el tercero — se parte limpio, y el rollo se abre lo justo. No querías leer. Leíste: "...las pruebas contra Petro, cuyo oro sostiene la red clandestina de mensajeros del llamado Varus..." El mundo se te para. Claudius no limpia Roma. Corta la rama donde estás parado vos.',
    options: [
      RealOptionConfig(
        id: 'opt_loyal_varus', text: 'Esto lo tiene que ver Varus. Esta noche.',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {},
        repDelta: {Faction.guild: 3},
        setFlags: ['path_varus'],
        journalNote: 'Leí lo que no debía: Claudius va a por Petro, y con Petro cae la red. Elegí: Varus tiene que saberlo.',
        outcomeSuccess: 'Copiás lo esencial en la corteza de un plátano con mano firme, recomponés el sello con cera de vela como te enseñó el oficio, y entregás en lo de Tiro sin que nada se note. La copia quema en tu túnica. Varus la verá antes del alba.',
        outcomePartial: 'La copia te sale torpe — las manos no te dejan de temblar — pero legible. El sello recompuesto pasaría una inspección distraída. Rezás que Tiro sea distraído.',
        outcomeFail: 'Copiás rápido y mal, y el sello recompuesto queda visiblemente tocado. Tiro lo va a notar. Que lo note: para cuando avise a Claudius, Varus ya va a saber todo.',
      ),
      RealOptionConfig(
        id: 'opt_loyal_claudius', text: 'No leíste nada. Sos el correo de Claudius.',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: 3},
        setFlags: ['path_claudius'],
        journalNote: 'Leí lo que no debía y elegí olvidarlo. Claudius juega a ganador, y yo cambié de mesa. Varus me enseñó el oficio. Claudius me va a enseñar el poder.',
        outcomeSuccess: 'Respirás hondo, recomponés el sello con pulso de cirujano y seguís caminando. La red de Varus te dio un oficio; Claudius te ofrece un futuro. Los sentimentales no llegan a viejos en Roma. Entregás perfecto.',
        outcomePartial: 'Recomponés el sello lo mejor que podés y enterrás lo leído bien hondo. En el puente, tu reflejo en el Tíber te mira raro. Que mire. Entregás y punto.',
        outcomeFail: 'El sello queda torcido por más que lo trabajás. Decidís contárselo a Claudius vos mismo: "se cayó, se abrió, no leí". Te estudia un siglo entero... y te cree. O decide creerte, que es mejor todavía: ahora sabe que sabés, y seguís vivo. Eso es confianza patricia.',
      ),
      RealOptionConfig(
        id: 'opt_sell_secret', text: 'Esto vale una fortuna en la Subura',
        riskLevel: 4, timeCostMinutes: 45, requiredSkills: {},
        repDelta: {Faction.underworld: 3},
        setFlags: ['path_underworld'],
        journalNote: 'Leí lo que no debía y vi lo que nadie ve: una mina de oro. Ni Varus ni Claudius. La información es del que la lleva.',
        outcomeSuccess: 'Sos mensajero: memorizar texto es tu oficio. Grabás cada palabra, recomponés el sello impecable y entregás a Tiro con cara de nada. La carta, intacta. El secreto, tuyo. En la Subura conocés una taberna sin cartel donde esto vale más que la villa de Claudius.',
        outcomePartial: 'Memorizás lo esencial — los nombres, las sumas, las fechas — y entregás con el sello aceptablemente recompuesto. Esa noche no dormís: en tu cabeza, dos senadores pelean y vos cobrás entrada.',
        outcomeFail: 'Con los nervios, olvidás la mitad de los detalles apenas entregás. Pero los nombres no: Claudius, Petro, la red. Con los nombres alcanza. La Viuda de la Subura completa cualquier historia si le traés el principio.',
      ),
    ],
  ),

  // ── Capítulo IV — eventos compartidos y por variante ─────────
  RealEventConfig(
    id: 's4_night_patrol',
    title: 'Roma después del toque',
    description: 'La ciudad de noche es de las patrullas, y esta noche hay más que nunca: alguien importante movió hilos y los vigiles paran a todo lo que camina. Vos no podés parar.',
    options: [
      RealOptionConfig(
        id: 'opt_rooftops', text: 'Por los techos del barrio bajo',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 3},
        outcomeSuccess: 'Los techos de la Subura son un camino que pocos conocen y menos se animan. Corrés sobre Roma dormida, saltando callejones, con la luna de cómplice. Abajo, las antorchas de los vigiles buscan a alguien que ya no está.',
        outcomePartial: 'El camino de los techos funciona hasta que una teja cede. Te agarrás de una cornisa, el corazón en la boca, y seguís más despacio. Roma de noche no perdona distracciones.',
        outcomeFail: 'Un salto corto termina en un toldo que amortigua tu caída y despierta a media cuadra. Corrés entre gritos y perros hasta perderte. El tobillo se acuerda de cada teja.',
      ),
      RealOptionConfig(
        id: 'opt_night_pass', text: 'Mostrás tu insignia de mensajero y la urgencia',
        riskLevel: 2, timeCostMinutes: 20, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'El optio de la patrulla examina tu insignia a la luz de la antorcha. "¿Correo urgente a esta hora? Andá. Y decile a tu jefe que nos debe una." Los vigiles respetan a los que trabajan de noche como ellos.',
        outcomePartial: 'La insignia funciona, pero el optio insiste en escoltarte tres cuadras "por tu seguridad". Tres cuadras de charla sobre lo mal que pagan en los vigiles. Sonreís y asentís. El tiempo corre.',
        outcomeFail: 'Esta patrulla tiene órdenes de parar TODO, insignia o no. Te retienen contra un muro hasta verificar con el puesto central. La noche se acorta y tu paciencia también.',
      ),
      RealOptionConfig(
        id: 'opt_sewer_path', text: 'La Cloaca Máxima no tiene toque de queda',
        riskLevel: 3, timeCostMinutes: 30, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Bajás a las entrañas de Roma con una antorcha robada de un altar. La Cloaca Máxima huele a imperio digerido, pero es recta, rápida y absolutamente desierta. Salís a dos cuadras del destino, oliendo a historia.',
        outcomePartial: 'El túnel funciona, aunque dos ratas del tamaño de gatos te disputan el paso y una cascada inesperada te bautiza. Llegás. Mojado, pero llegás.',
        outcomeFail: 'Te equivocás de ramal y terminás bajo el mercado de ganado, que gotea lo que gotea el ganado. Salís por la primera rejilla que cede. La túnica va a necesitar un funeral.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's4_claudius_men',
    title: 'Los hombres de Claudius',
    description: 'A cinco cuadras de la villa de Petro, tres hombres con capas buenas y espadas mejores te cierran el paso. El del medio sonríe: "El Senador Claudius lamenta informarte que tu carrera de correo termina esta noche." Saben adónde vas. Saben qué llevás.',
    options: [
      RealOptionConfig(
        id: 'opt_fight_through', text: 'La red te enseñó a pelear. Demostralo.',
        riskLevel: 5, timeCostMinutes: 0, requiredSkills: {SkillType.combat: 3},
        outcomeSuccess: 'El primero espera un mensajero asustado y recibe un rodillazo profesional. Al segundo lo frena el banco de piedra que le ponés de sombrero. El tercero decide que Claudius no paga tanto. El camino a lo de Petro queda libre y con estilo.',
        outcomePartial: 'Peleás sucio y rápido, como se pelea de noche. Recibís un tajo en el antebrazo pero abrís el hueco que necesitabas. Corrés las últimas cuadras sangrando y sonriendo.',
        outcomeFail: 'Son profesionales: te reducen en segundos. Pero registran tu bolso buscando un rollo... que ya no está. Lo tragaste — la copia chica, la de emergencia. Te dejan ir "sin el mensaje". Idiotas. El mensaje sos vos.',
      ),
      RealOptionConfig(
        id: 'opt_decoy_run', text: 'Tirás tu bolso a un lado y corrés al otro',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 3},
        outcomeSuccess: 'El bolso vuela a la izquierda con tu cantimplora y tu pan; vos volás a la derecha con lo que importa en la túnica. Para cuando entienden el truco, ya sos una sombra a tres cuadras. El pan era bueno. La libertad, mejor.',
        outcomePartial: 'El señuelo funciona a medias: uno va por el bolso, dos van por vos. Los perdés en el laberinto de la Subura, con los pulmones en llamas y las sandalias pidiendo perdón.',
        outcomeFail: 'El del medio ni mira el bolso: "El rollo lo lleva encima." Corrés igual, más rápido de lo que corriste nunca, y la noche te salva por un pelo de toga. Llegás a lo de Petro por los fondos, temblando.',
      ),
      RealOptionConfig(
        id: 'opt_bluff_delivered', text: '"Llegan tarde. Petro leyó todo hace una hora."',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 3},
        outcomeSuccess: 'Lo decís con el aburrimiento exacto del que ya cobró. Los tres se miran: si es cierto, matarte es gratis y al pedo. El del medio maldice en griego fino y se van a reportar el fracaso. Mentir bien es un arte marcial.',
        outcomePartial: 'Dudan. "Registralo." Te palpan de armas y rollos — la copia va en la bota, donde nadie con apuro busca. Te sueltan con un empujón y una amenaza de oficio. Caminás sin apurarte hasta la esquina. En la esquina, corrés.',
        outcomeFail: 'El del medio sonríe más: "Entonces no te necesitamos entero." Zafás del primer manotazo de milagro y la persecución es brutal. Llegás a lo de Petro con la túnica rota y el mensaje intacto. Contá la milagrosa después: ahora, entregá.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's4_guild_shadow',
    title: 'Una cara conocida',
    description: 'En el puente, una figura espera apoyada en la baranda. La conocés: Marco, mensajero de la red, el que te enseñó los atajos del río. "Varus sabe lo que llevás", dice sin saludar. "Me mandó a pedírtelo. A vos. Por la amistad."',
    options: [
      RealOptionConfig(
        id: 'opt_refuse_marco', text: '"Decile a Varus que elegí. Correte, Marco."',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: -2},
        journalNote: 'Marco me pidió el expediente en nombre de Varus y de la amistad. Le dije que no a las dos cosas. El puente nunca fue tan largo.',
        outcomeSuccess: 'Marco te estudia largo, buscando al pibe que conoció. No lo encuentra. "Que los dioses te paguen bien, porque nosotros no te vamos a cobrar barato." Se aparta. Cruzás el puente con los ojos secos a fuerza de orgullo.',
        outcomePartial: 'Marco no se aparta enseguida: te recuerda la noche que te salvó de la patrulla en Ostia. Jugadas sucias de la memoria. "Ya pagué esa deuda", mentís, y pasás. Los dos saben que no.',
        outcomeFail: 'Marco intenta manotearte el tubo — sin ganas, para poder decirle a Varus que lo intentó. Forcejean dos amigos que ya no lo son. Ganás vos, que tenés más que perder. "Cuidate", te dice al final. Y lo peor es que lo dice en serio.',
      ),
      RealOptionConfig(
        id: 'opt_pay_marco', text: 'Le ofrecés tu paga entera por mirar al río',
        riskLevel: 2, timeCostMinutes: 10, requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: '"No quiero tu plata", dice Marco, y mira al río igual. "Quiero poder decirle a Varus que no te vi. Andate rápido, que mentir me sale mal." Cruzás. Hay amistades que sobreviven hasta a las lealtades.',
        outcomePartial: 'Marco acepta la bolsa sin mirarte y la tira al Tíber entera. "Ahí está tu paga. Ahora los dos perdimos algo esta noche." Te deja pasar. El chapoteo te acompaña hasta la Basílica.',
        outcomeFail: 'Marco rechaza la plata con un asco que duele más que un golpe. "¿Ahora sobornás colegas? Claudius te enseña rápido." Te deja pasar solo porque pelear le daría náuseas. El expediente pesa el doble el resto del camino.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's4_rival_buyer',
    title: 'La contraoferta',
    description: 'En la puerta de la Loba Dorada, una litera lujosa te corta el paso. Adentro, un hombre de anillos pesados: agente de Petro. "Sabemos qué vendés y a quién. Petro paga el doble por exclusividad... y el triple por saber quién más lo compra."',
    options: [
      RealOptionConfig(
        id: 'opt_loyal_widow', text: '"Ya tengo compradora. La Viuda no comparte."',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.underworld: 2},
        journalNote: 'El agente de Petro ofreció el triple por traicionar a la Viuda. En la Subura, la palabra vale más que el oro. Y da más miedo.',
        outcomeSuccess: 'El agente palidece al escuchar el nombre. "¿La Viuda? Haber empezado por ahí." La litera se va casi al trote. En los negocios de la noche, hay nombres que son armadura.',
        outcomePartial: 'El agente insiste con cifras que marean. Repetís el nombre de la Viuda como un amuleto, y funciona: se va mascullando sobre "el monopolio de la información". Casi suena a elogio.',
        outcomeFail: 'El agente sube la oferta tres veces antes de rendirse, y la última cifra te persigue hasta la puerta de la taberna. La lealtad de la Subura se paga cara. La traición, carísima. Elegiste bien. Creés.',
      ),
      RealOptionConfig(
        id: 'opt_double_sell', text: 'Escuchás la cifra... y le vendés una versión "editada"',
        riskLevel: 5, timeCostMinutes: 20, requiredSkills: {SkillType.contacts: 3},
        repDelta: {Faction.underworld: 1, Faction.patricians: -1},
        outcomeSuccess: 'Le vendés al agente una versión con los nombres correctos y las sumas cambiadas: cierta donde importa poco, falsa donde importa todo. Cobrás dos veces por el mismo secreto. La Viuda, cuando se entere — porque se va a enterar — va a aplaudir.',
        outcomePartial: 'La venta doble sale, pero el agente es menos tonto de lo que viste: paga la mitad "hasta verificar". Igual: dos pagas por una carta. La matemática de la Subura te empieza a gustar.',
        outcomeFail: 'A mitad de la "edición" improvisada, el agente huele el truco y corta la charla. Se va sin pagar y con sospechas. Ahora Petro sabe que alguien vende... y que ese alguien es creativo. La Viuda mejor que escuche tu versión primero.',
      ),
    ],
  ),

  // ── Capítulo V — eventos de los finales ──────────────────────
  RealEventConfig(
    id: 's5_petro_gift',
    title: 'La gratitud de un patricio',
    description: 'Antes de salir hacia el Foro, un esclavo de Petro te intercepta con una caja pequeña: "El Senador insiste." Adentro, un anillo de plata con un cuervo grabado. Los regalos de los senadores nunca son solo regalos.',
    options: [
      RealOptionConfig(
        id: 'opt_accept_ring', text: 'Aceptás el anillo con una reverencia justa',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: 2},
        journalNote: 'Petro me regaló un anillo con un cuervo. Varus dice que los favores patricios son anzuelos. Los anzuelos también sacan peces del agua.',
        outcomeSuccess: 'El anillo te queda justo, cosa que inquieta: alguien averiguó hasta la medida de tus dedos. "El Senador dice que un cuervo siempre reconoce a otro", recita el esclavo. Aliado o fichado — en Roma, la diferencia es de matiz.',
        outcomePartial: 'Aceptás con la reverencia exacta que Varus te enseñó para patricios: respeto sin sumisión. El esclavo asiente apenas, como aprobando la técnica. El anillo pesa poco. El favor que representa, ya veremos.',
        outcomeFail: 'La reverencia te sale más profunda de lo digno y el esclavo sonríe con superioridad de esclavo de senador, que es la peor. Anillo aceptado, estilo entregado. Varus no tiene por qué enterarse de los detalles.',
      ),
      RealOptionConfig(
        id: 'opt_decline_ring', text: '"Serví a la red, no al Senador. No hay deuda."',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.guild: 2},
        journalNote: 'Rechacé el anillo de Petro. La red no cobra por lealtad. Que los senadores aprendan la diferencia.',
        outcomeSuccess: 'El esclavo parpadea: nadie rechaza regalos de Petro. "El Senador va a encontrar esto... interesante." A la hora, un mensaje de Varus: "Petro pregunta si todos mis hombres son así. Le dije que los buenos, sí." Mejor que cualquier anillo.',
        outcomePartial: 'El esclavo insiste tres veces — rechazar dos es cortesía, rechazar tres es postura. Sostenés la postura. Se va confundido. Los patricios entienden el oro; el orgullo de un mensajero les queda grande.',
        outcomeFail: 'Tu rechazo sale más brusco de lo planeado y el esclavo se ofende en nombre ajeno, que es su oficio. Con suerte, Petro lo tomará como rudeza de soldado y no como insulto. Varus va a tener que suavizarlo. Otra vez.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's5_claudius_face',
    title: 'La escalinata del Foro',
    description: 'Claudius te espera en la escalinata, más viejo que la semana pasada. Los que pierden en Roma envejecen por derrota. Te reconoce desde lejos y no cambia la cara: los patricios pierden con la misma expresión con la que ganan.',
    options: [
      RealOptionConfig(
        id: 'opt_respectful_delivery', text: 'Entregás con el protocolo completo, sin una palabra de más',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Protocolo perfecto: la distancia justa, la inclinación justa, la carta con las dos manos. Claudius la toma y algo parecido al respeto le cruza la cara. "Varus entrena bien", concede. De un enemigo, es una condecoración.',
        outcomePartial: 'El protocolo te sale correcto aunque el pulso te tiembla un pelo al final. Claudius lo nota — lo nota todo — pero no dice nada. Hoy no muerde. Hoy solo cobra su derrota.',
        outcomeFail: 'Los nervios te hacen trastabillar el saludo y Claudius alza una ceja que vale un discurso. "Decile a Varus que hasta sus victorias son torpes." La carta cambió de manos igual. Las palabras hirientes son gratis para el que pierde.',
      ),
      RealOptionConfig(
        id: 'opt_last_word', text: '"Ninguna carta es solo papel, Senador. Usted me lo enseñó."',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 3},
        outcomeSuccess: 'Claudius se queda un instante inmóvil... y suelta una risa corta, auténtica, la primera que le escuchás. "Insolente y con memoria. Si algún día Varus te aburre, mi puerta tiene mala memoria para los rencores." Perder con estilo también es patricio.',
        outcomePartial: 'La frase le llega: aprieta apenas la mandíbula y te despide con un gesto. En la política romana, hacer callar a un senador un segundo entero es victoria de mensajero.',
        outcomeFail: 'La frase suena mejor en tu cabeza que en el Foro. "Los mensajeros con filosofía llegan tarde", responde seco, y te despide como a un vendedor de higos. Te vas con la carta entregada y la lengua mordida.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's5_senate_steps',
    title: 'Las gradas de la Curia',
    description: 'La escalinata del Senado es un desfile de togas que te miran como a un mueble nuevo: la librea de Claudius en un cuerpo de mensajero de la red. Algunos murmullos te preceden. Otros te siguen.',
    options: [
      RealOptionConfig(
        id: 'opt_walk_proud', text: 'Subís por el medio, mentón alto, como te dijo Claudius',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'Subís las gradas como si fueran tuyas. Los murmullos cambian de tono: de la burla a la pregunta, que en el Senado es un ascenso. "El nuevo correo de Claudius", escuchás. Nuevo. Correo. De Claudius. Tres palabras, tres cadenas, un futuro.',
        outcomePartial: 'El mentón alto te dura hasta la mitad de la escalinata, donde un ex-cónsul te mira como a una mancha en su toga. Terminás de subir digno pero sudado. Adentro, al menos, la carta habla por vos.',
        outcomeFail: 'A tres gradas del final, pisás el borde de tu propia librea nueva y el traspié arranca risitas de dos escribas. Roma es un teatro y hoy fuiste el gracioso. La entrega sale bien; el orgullo, magullado.',
      ),
      RealOptionConfig(
        id: 'opt_servant_entrance', text: 'Preguntás por la entrada de servicio — sin público',
        riskLevel: 1, timeCostMinutes: 15, requiredSkills: {},
        outcomeSuccess: 'Un ujier veterano te guía por el pasillo de los escribas, donde nadie mira a nadie porque todos cargan secretos. Entregás sin testigos ni teatro. Claudius quería espectáculo; vos preferiste eficacia. Ya habrá tiempo de discutirlo.',
        outcomePartial: 'La entrada de servicio existe pero está custodiada: quince minutos de verificaciones. Entregás al fin, discreto como querías. Claudius va a fruncir el ceño por el perfil bajo. Que frunza.',
        outcomeFail: 'El ujier de servicio resulta más ceremonioso que el protocolo principal: te anuncia a los gritos en la sala de escribas. "¡El correo del Senador Claudius!" Tanto esconderte para esto. Roma no permite entregas anónimas. Nunca.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's5_varus_cold',
    title: 'El último saludo',
    description: 'Volviendo del Senado, el destino te cruza con Varus en el puente Emilio. Va con dos de los nuevos. Te ve. Ve la librea. Los nuevos miran al río, incómodos. Roma entera cabe en este puente.',
    options: [
      RealOptionConfig(
        id: 'opt_salute_varus', text: 'Lo saludás como siempre: "Comandante."',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: '"Comandante", decís, y la palabra sale entera. Varus se detiene un segundo. "Mensajero", responde — no tu nombre, tu oficio — y sigue de largo. Es frío, pero es un saludo. De Varus, después de todo, es casi un abrazo.',
        outcomePartial: 'Tu saludo queda flotando en el aire del puente. Varus asiente una vez, un movimiento de milímetros, y pasa. Los nuevos te esquivan la mirada. El puente nunca fue tan largo ni tan angosto.',
        outcomeFail: '"Comandante", decís. Varus pasa como si el viento hubiera hablado. Los nuevos apuran el paso detrás. Te quedás mirando el río, con la librea de Claudius pesando como cota de malla. Elegiste. Se paga. Se paga cada día.',
      ),
      RealOptionConfig(
        id: 'opt_look_away', text: 'Mirás el río hasta que pasen',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Estudiás el Tíber como si debieras plata. Los pasos de Varus pasan detrás sin frenar. Nadie dijo nada; nadie tuvo que mentir ni perdonar. Hay silencios que son el último favor entre dos hombres que se respetaron.',
        outcomePartial: 'Mirás el agua marrón pasar. Los pasos se alejan... y al final, la voz de Varus, sin darse vuelta: "El río no te va a devolver nada, mensajero." Tenía que tener él la última palabra. Siempre la tuvo.',
        outcomeFail: 'Mirás el río, pero el río te traiciona: en el reflejo del agua quieta junto al pilar, tus ojos y los de Varus se cruzan igual. Un instante. Suficiente. Los dos siguen su camino sabiendo que el otro vio.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's5_two_doors',
    title: 'Dos puertas, un mensaje',
    description: 'Primera entrega: la villa de Claudius. Segunda: la de Petro. El mismo sobre, la misma letra de la Viuda, el mismo mensaje sin firma. Tu trabajo: que ambos lo reciban en mano y te vean la cara al leerlo. Esa es la parte del contrato que nadie explica.',
    options: [
      RealOptionConfig(
        id: 'opt_claudius_first', text: 'Claudius primero — el más peligroso, mejor temprano',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Claudius lee y sus manos, entrenadas en no temblar, tiemblan. Te busca la cara y encuentra la nada profesional que la Viuda te enseñó a poner. En lo de Petro, en cambio: risa corta, un "era cuestión de tiempo", y hasta te ofrece agua. Dos senadores, dos estilos de perder.',
        outcomePartial: 'Claudius te retiene con preguntas que no vas a contestar; salís de la villa con la nuca fría. Petro recibe el suyo con calma de ajedrecista. "Decile a tu patrona que acepto los términos." Un día raro en el oficio de los días raros.',
        outcomeFail: 'El mayordomo de Claudius te hace esperar una hora de puro despecho, y llegás a lo de Petro pasada la medianoche. Ambos leyeron, ambos palidecieron, ambos pagarán. La Viuda va a perdonar la demora. Los pies, no.',
      ),
      RealOptionConfig(
        id: 'opt_same_hour', text: 'Contratás un pibe de la Subura y entregan a la misma hora',
        riskLevel: 4, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 3},
        outcomeSuccess: 'El pibe entrega en lo de Petro al mismo tiempo exacto que vos en lo de Claudius: ninguno puede avisarle al otro, ninguno puede negociar primero. La Viuda, cuando se entera de la coreografía, sonríe: "Contratado. Para siempre." En la Subura, eso es un título nobiliario.',
        outcomePartial: 'La sincronización sale casi perfecta — el pibe se demora comprando castañas con tu adelanto. Los dos senadores reciben el golpe con media hora de diferencia: suficiente para el efecto, insuficiente para conspirar. Aprobado con lo justo.',
        outcomeFail: 'El pibe se asusta del portero de Petro y vuelve con el sobre. Terminás haciendo las dos entregas igual, corriendo entre villas como en tus peores tiempos. Funciona, pero la próxima el ayudante lo elegís mejor.',
      ),
    ],
  ),

  RealEventConfig(
    id: 's5_widow_toast',
    title: 'El brindis de la Viuda',
    description: 'De vuelta en la Loba Dorada, la Viuda te espera con dos copas servidas y la mesa del fondo despejada. En la Subura, que la Viuda te sirva el vino es un contrato, una adopción y una advertencia, todo junto.',
    options: [
      RealOptionConfig(
        id: 'opt_drink_toast', text: 'Levantás la copa: "Por los que saben."',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.underworld: 2},
        journalNote: 'Brindé con la Viuda en la mesa del fondo. En la Subura ya soy "el correo de la noche". Los títulos de acá no se compran: se beben.',
        outcomeSuccess: 'El vino es mejor que todo lo que tomaste en tu vida, lo cual también es un mensaje. "Por los que saben", repite la Viuda, "y por los que saben callar." La mesa del fondo tiene un lugar tuyo ahora. Las noches de Roma acaban de cambiar de dueño.',
        outcomePartial: 'Brindás intentando que no se note que el vino te da vueltas: la Viuda sirve fuerte para ver cómo aguantan sus socios. Aguantás. Con lo justo, pero aguantás. Ella anota todo, hasta eso.',
        outcomeFail: 'El brindis sale torpe: chocás la copa demasiado fuerte y el vino salta. La Viuda ríe — una risa de verdad, rara como lluvia de verano. "Torpe con las copas, fino con los secretos. Prefiero eso que lo contrario." Aprobado igual.',
      ),
      RealOptionConfig(
        id: 'opt_ask_price', text: '"Antes de brindar: ¿qué me va a costar esta copa?"',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'La Viuda te mira con deleite profesional. "Ah, aprendés rápido. Esta copa es gratis; la tercera va a costarte un favor; la décima, un secreto tuyo. Bebé sabiendo." Es la primera persona en semanas que te dice la verdad completa. Brindás a gusto.',
        outcomePartial: '"Costar, costar..." — la Viuda hace girar su copa — "digamos que las mesas del fondo tienen memoria." No es una respuesta y es todas las respuestas. Brindás con los ojos abiertos, que es lo que ella quería enseñarte.',
        outcomeFail: 'La pregunta la ofende un grado — un grado exacto, medido, pedagógico. "En mi mesa no se pregunta el precio: se confía o se va." Te quedás. Bebés. La lección era esa.',
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════
// QUÉ SIGNIFICA CADA FLAG — para contárselo al jugador
//
// Los flags son ids internos ('spared_thief'). Cuando una decisión activa
// uno, la pantalla de resultado muestra ESTE texto, nunca el id: el jugador
// tiene que sentir que el mundo lo recuerda, no leer una variable.
// Un flag sin entrada acá simplemente no se anuncia.
// ═══════════════════════════════════════════════════════════════

const Map<String, String> flagDescriptions = {
  // ── Camino: decisiones sueltas que vuelven más adelante
  'spared_thief':
      'El chico al que dejaste ir no se olvida de una deuda.',
  'paid_bandits':
      'En los caminos ya saben que pagás. Eso abre puertas y atrae problemas.',
  'fought_bandits':
      'Corrió la voz: el correo que no se deja robar.',
  'fled_bandits': 'Preferiste tus piernas al acero. Nadie te lo reprocha.',
  'helped_traveler':
      'Un viajero le debe la tarde a un mensajero sin nombre.',
  'left_traveler': 'Seguiste de largo. El camino también toma nota de eso.',
  'helped_rival':
      'Un correo rival te debe una. En el gremio esas cosas se saben.',
  'reported_smuggler':
      'Las legiones anotaron tu nombre en la lista de los confiables.',
  'rode_contraband':
      'Llevaste carga que no era tuya. Alguien en los bajos fondos lo sabe.',
  'refused_spy': 'Dijiste que no a la primera oferta. Habrá una segunda.',
  'sold_a_look': 'Vendiste un vistazo. Barato hoy, caro después.',
  'walked_the_storm':
      'Cruzaste un paso con la tormenta encima. Eso se cuenta en las tabernas.',
  'paid_the_augur': 'Los dioses del cruce quedaron conformes con vos.',
  'read_the_birds':
      'Dejaste a un augur sin presagio. Alguien lo vio y le causó gracia.',
  'helped_lost_child':
      'Una nena volvió a su casa de tu mano. En ese pueblo te van a recordar.',
  'heard_the_sibyl':
      'Escuchaste el vaticinio entero. Las palabras de la sibila no se olvidan.',
  'helped_deserter':
      'Un desertor anda por ahí con tu capa vieja. Te debe la vida.',
  'saw_the_message':
      'Leíste lo que no era para vos. Ahora sabés algo que otros pagarían por saber.',
  'fled_temple_accusation':
      'Te fuiste del templo antes de tiempo. Alguien anotó tu cara.',

  // ── Arco 1: La Sombra del Senado
  'told_varus': 'Varus sabe del encargo. Confía en vos, y ahora espera más.',
  'kept_secret': 'Varus no sabe nada. Por ahora.',
  'sold_look_claudius': 'Claudius sabe que se te puede comprar.',
  'refused_northman': 'El norteño se fue con las manos vacías y buena memoria.',
  'path_varus': 'Elegiste al gremio. Varus lo tendrá presente.',
  'path_claudius': 'Elegiste al Senado. Claudius abre sus puertas.',
  'path_underworld': 'Elegiste los bajos fondos. Roma tiene otra cara ahora.',
  'ending_varus': 'La Sombra del Senado terminó del lado del gremio.',
  'ending_claudius': 'La Sombra del Senado terminó del lado de Claudius.',
  'ending_underworld':
      'La Sombra del Senado terminó del lado de los bajos fondos.',
  'claudius_vetoed': 'Claudius ya no te va a ofrecer trabajo.',
  'varus_cold': 'Varus te sigue dando misiones, pero ya no te mira igual.',
  'route_nocturna_unlocked':
      'Se abrió la Ruta Nocturna: encargos que no existen de día.',
};

/// Texto para mostrar de un flag recién activado (null si es interno).
String? flagDescription(String flag) => flagDescriptions[flag];
