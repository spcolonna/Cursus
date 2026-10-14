// ═══════════════════════════════════════════════════════════════
// ROAD EVENTS V2 — 22 eventos nuevos del camino.
// Se suman a `allRealEvents` (game_content_expansion.dart) y se reparten en
// los `eventPoolIds` de las rutas existentes.
// No siembra flags nuevos: los callbacks leen flags que ya existían
// (fought_bandits, helped_lost_child, path_underworld, heard_the_sibyl,
// walked_the_storm, helped_deserter).
// Español rioplatense, sin emojis, sin anacronismos (ver .claude/skills/historia).
// ═══════════════════════════════════════════════════════════════

import '../domain/entities/content.dart';
import '../domain/entities/entities.dart';
import '../domain/entities/world.dart';

const List<RealEventConfig> roadEventsV2 = [
  // ─── Obras del acueducto ───
  RealEventConfig(
    id: 'evt_aqueduct_works',
    category: EventCategory.road,
    title: 'Obras del acueducto',
    description: 'Una cuadrilla repara un arco del acueducto y cortó el camino con andamios y bueyes. El capataz grita cifras; nadie mueve una piedra sin su permiso.',
    options: [
      RealOptionConfig(
        id: 'opt_aqueduct_wait', text: 'Esperás a que el capataz abra paso',
        riskLevel: 1, timeCostMinutes: 90, requiredSkills: {},
        outcomeSuccess: 'El capataz termina de contar sillares, te mira de arriba abajo y hace correr a los bueyes. "El agua de Roma puede esperar a un correo. Un rato." Pasás entre el polvo con su bendición.',
        outcomePartial: 'Te dejan pasar cuando bajan la última piedra del día, y no antes. Llegás al otro lado blanco de cal, como una estatua que salió a caminar.',
        outcomeFail: 'Justo cuando te hacen seña, se cae una polea y todos corren a sostener el arco. Terminás tirando de una soga con veinte esclavos y un ingeniero que no para de insultar a Vitruvio.',
      ),
      RealOptionConfig(
        id: 'opt_aqueduct_channel', text: 'Cruzás por el canal seco del acueducto',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Te metés por la boca de inspección y corrés agachado por el canal vacío, con la luz entrando por las rejillas. Salís del otro lado de la obra antes de que el capataz termine de gritar.',
        outcomePartial: 'El canal está seco pero no limpio: barro verde, sapos indignados y un techo más bajo de lo prometido. Salís con la cabeza golpeada y el paquete intacto.',
        outcomeFail: 'A mitad de camino abren la compuerta para probar la reparación. Salís por la primera rejilla empapado, perseguido por un chorro de agua y por la risa de toda la cuadrilla.',
      ),
      RealOptionConfig(
        id: 'opt_aqueduct_curator', text: 'Buscás al ingeniero del curador de aguas',
        riskLevel: 2, timeCostMinutes: 20, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'El ingeniero es un griego flaco que adora hablar de pendientes. Le escuchás tres frases sobre el nivel del agua y a cambio te abre una pasarela que solo usan los inspectores.',
        outcomePartial: 'El ingeniero te deja pasar, pero primero te hace sostener la groma mientras toma una medida. Tardás más de lo pensado; al menos ahora sabés qué es una groma.',
        outcomeFail: 'El ingeniero está dormido bajo un toldo y su asistente no se atreve a despertarlo. Cuando por fin abre un ojo, dice que no y se vuelve a dormir.',
      ),
    ],
  ),

  // ─── Compañía de gladiadores ───
  RealEventConfig(
    id: 'evt_gladiator_troupe',
    category: EventCategory.bandits,
    title: 'Los del lanista',
    description: 'Una carreta de gladiadores encadenados quedó atravesada con un eje partido. El lanista suda y maldice; uno de sus hombres, enorme, te mira como quien mide a un rival.',
    options: [
      RealOptionConfig(
        id: 'opt_gladiator_push', text: 'Ayudás a levantar el eje roto',
        riskLevel: 1, timeCostMinutes: 75, requiredSkills: {},
        outcomeSuccess: 'Entre vos, dos esclavos y el gigante, la carreta sube lo justo para calzar el eje. El lanista te palmea la espalda como si fueras mercadería buena. "Si alguna vez querés comer todos los días, Capua te espera."',
        outcomePartial: 'El eje entra al tercer intento y tu espalda lo va a recordar hasta la próxima posta. El gigante te sonríe con media boca: le caíste bien a alguien que mata por oficio.',
        outcomeFail: 'La carreta cede para el lado equivocado y te aplasta medio pie contra el barro. Nada roto, pero caminás rengo un buen tramo y el lanista ni pide perdón.',
      ),
      RealOptionConfig(
        id: 'opt_gladiator_spar', text: 'Aceptás un round con el gigante',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.combat: 2},
        journalNote: 'Le aguanté un round a un gladiador de Capua en medio del camino. Todavía me suenan los oídos.',
        outcomeSuccess: 'Esquivás el primer golpe, el segundo y el tercero. Al cuarto le metés el hombro en las costillas y el gigante se ríe en el piso. El lanista, encantado, te despeja el camino con sus propios hombres.',
        outcomePartial: 'Aguantás de pie, que ya es mucho. El gigante te suelta un revés que te deja la mejilla caliente, y te deja pasar con un gesto de "otro día terminamos".',
        outcomeFail: 'Un solo golpe y ves el cielo. Cuando te despertás, la carreta ya se fue y alguien te dejó el paquete bajo la cabeza, como almohada. Un gesto casi amable.',
      ),
      RealOptionConfig(
        id: 'opt_gladiator_around', text: 'Rodeás la carreta por la zanja',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.stealth: 1},
        outcomeSuccess: 'Bajás a la zanja mientras el lanista discute con el carretero. Nadie te mira: los gladiadores no miran lo que no pueden pelear. Volvés al camino cien pasos más adelante.',
        outcomePartial: 'La zanja es más honda de lo que parecía y salís con barro hasta las rodillas. Desde la carreta, un gladiador aplaude despacio.',
        outcomeFail: 'El lanista te ve y cree que sos un esclavo fugado de otra escuela. Explicarle que sos un correo libre, con la mano de él en tu cuello, lleva su tiempo.',
      ),
      // Callback: la fama de haber peleado con bandidos llegó a la escuela.
      RealOptionConfig(
        id: 'opt_gladiator_fame', text: '"¿Vos sos el que frenó a los bandidos?"',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'fought_bandits',
        outcomeSuccess: 'El gigante se acerca y te da la mano como a un colega. Los demás gladiadores levantan la carreta solos para que pases, y el lanista te ofrece un contrato que rechazás con elegancia.',
        outcomePartial: 'Te reconocen, pero el lanista quiere que les cuentes la pelea completa. Les das una versión corta; ellos piden la larga. Pasás aplaudido y con la garganta seca.',
        outcomeFail: 'El gigante te reconoce y, por eso mismo, insiste en probar si la historia es cierta. Te escapás del abrazo con una costilla quejosa y la reputación intacta.',
      ),
    ],
  ),

  // ─── Fugitivo en la zanja ───
  RealEventConfig(
    id: 'evt_fugitive',
    category: EventCategory.bandits,
    title: 'Los cazadores de esclavos',
    description: 'Tres fugitivarios a caballo te cortan el paso. Buscan a un esclavo huido. Vos lo viste hace un rato, acurrucado en una zanja, con los ojos de un animal acorralado.',
    options: [
      RealOptionConfig(
        id: 'opt_fugitive_point', text: 'Les señalás la zanja sin decir nada',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        journalNote: 'Señalé la zanja. Los cazadores me tiraron una moneda que todavía no gasté.',
        outcomeSuccess: 'Los cazadores salen al galope hacia donde apuntaste. Uno te tira una moneda sin mirarte. Seguís camino rápido, y el silencio del campo te acompaña más de lo que quisieras.',
        outcomePartial: 'Lo encuentran enseguida. No mirás para atrás, pero lo escuchás igual. El camino está libre y el día, de pronto, más pesado.',
        outcomeFail: 'La zanja está vacía: el hombre ya se había movido. Los cazadores vuelven y te acusan de mandarlos para el lado equivocado. Pasás un buen rato demostrando que no sos su cómplice.',
      ),
      RealOptionConfig(
        id: 'opt_fugitive_lie', text: 'Los mandás para el lado del río',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 2},
        repDelta: {Faction.underworld: 1},
        journalNote: 'Mandé a los fugitivarios al río. El de la zanja me miró una sola vez, y alcanzó.',
        outcomeSuccess: 'Les describís un hombre corriendo hacia el río con tanto detalle que hasta vos te lo creés. Salen al galope. Al pasar junto a la zanja, alguien susurra "gracias" desde el barro.',
        outcomePartial: 'Te creen, pero uno se queda mirándote un rato largo antes de seguir a los otros. Tu cara ya está en la memoria de alguien que caza gente.',
        outcomeFail: 'Te creen a medias: dos van al río y el tercero se queda a vigilarte hasta que vuelvan. Esperás sentado, sudando, mientras el fugitivo sigue quieto a veinte pasos.',
      ),
      RealOptionConfig(
        id: 'opt_fugitive_shrug', text: 'Decís que no viste a nadie',
        riskLevel: 2, timeCostMinutes: 45, requiredSkills: {},
        outcomeSuccess: 'Los cazadores te miran, deciden que no valés el esfuerzo y siguen de largo. No ayudaste a nadie ni entregaste a nadie. El camino no te pide más que eso, por hoy.',
        outcomePartial: 'No te creen del todo y te revisan la bolsa por las dudas. Encuentran pan duro, una carta lacrada y tu mal humor. Te dejan ir con desprecio.',
        outcomeFail: 'El jefe decide que nadie que pasa por acá deja de ver algo. Te tienen parado al sol hasta que encuentran rastros en otra dirección. Perdés media tarde siendo sospechoso de nada.',
      ),
    ],
  ),

  // ─── Salineros ───
  RealEventConfig(
    id: 'evt_salt_road',
    category: EventCategory.road,
    title: 'La carreta de sal',
    description: 'Dos salineros con una carreta cargada hasta el tope te ofrecen subir a cambio de que les cuides la sal. Dicen que en el próximo tramo roban hasta los dientes.',
    options: [
      RealOptionConfig(
        id: 'opt_salt_ride', text: 'Subís y hacés de guardia de la sal',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        outcomeSuccess: 'La carreta es lenta pero tus piernas descansan, y los salineros cantan unas coplas que hacen reír hasta a los bueyes. Nadie roba nada. Te bajás con un puñado de sal de regalo.',
        outcomePartial: 'El tramo es tranquilo y la carreta, más lenta que un sacerdote en ayunas. Llegás descansado, con los labios cuarteados de sal y la paciencia gastada.',
        outcomeFail: 'Una rueda se hunde en un bache y te pasás un buen rato empujando. Los salineros te prometen que la próxima vez te llevan gratis. Ya te llevaban gratis.',
      ),
      RealOptionConfig(
        id: 'opt_salt_decline', text: 'Agradecés y seguís a tu paso',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Les dejás la sal a ellos y el camino a vos. Media hora más tarde los perdés de vista, y con ellos las coplas. Tu paso rinde más que cualquier buey.',
        outcomePartial: 'Seguís solo y el tramo resulta más largo y polvoriento de lo que pensabas. Cuando la carreta te pasa, los salineros te saludan con lástima.',
        outcomeFail: 'Los ladrones de los que hablaban existen, y al no ver carga contigo te piden igual "un peaje por caminar". Te sacan dos monedas y una lección sobre la compañía.',
      ),
      RealOptionConfig(
        id: 'opt_salt_trade', text: 'Les cambiás información por un atajo',
        riskLevel: 2, timeCostMinutes: 10, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'Les contás qué puesto de portazgo cobra menos esta semana. Agradecidos, te marcan un sendero de salineros que corta una curva entera del camino.',
        outcomePartial: 'El atajo existe, pero lo usan también sus burros. Avanzás rápido esquivando lo que los burros dejan atrás.',
        outcomeFail: 'Tu información está vieja: el puesto barato cambió de recaudador. Los salineros se ofenden y su atajo, misteriosamente, termina en un pantano.',
      ),
    ],
  ),

  // ─── Pueblo con fiebre ───
  RealEventConfig(
    id: 'evt_plague_village',
    category: EventCategory.road,
    title: 'Pueblo con fiebre',
    description: 'Una soga con trapos negros cruza el camino a la entrada de un pueblo. Del otro lado, un viejo te grita que hay fiebre adentro y que nadie entra ni sale.',
    options: [
      RealOptionConfig(
        id: 'opt_plague_around', text: 'Rodeás el pueblo por las colinas',
        riskLevel: 1, timeCostMinutes: 150, requiredSkills: {},
        outcomeSuccess: 'Subís por los olivares y bordeás el pueblo desde arriba. Desde ahí se ven las casas cerradas y el humo de las hierbas que queman. Bajás al camino del otro lado, sano y en silencio.',
        outcomePartial: 'Las colinas son más empinadas de lo que prometían y los perros de los pastores no te quieren cerca. Volvés al camino tarde y con un tobillo protestón.',
        outcomeFail: 'Te perdés entre terrazas de olivos que se parecen todas. Cuando por fin encontrás el camino, estás otra vez frente a la soga negra, pero del lado de adentro.',
      ),
      RealOptionConfig(
        id: 'opt_plague_cross', text: 'Cruzás el pueblo con la boca tapada',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Te envolvés la cara en un paño con vinagre y cruzás por el medio sin tocar nada ni a nadie. Del otro lado, te lavás las manos en un arroyo hasta que te arden.',
        outcomePartial: 'Cruzás rápido, pero una mujer te pide agua desde una puerta y no te animás a negarte. Salís bien, aunque esa cara te acompaña varios miliarios.',
        outcomeFail: 'El viejo de la soga da la alarma y medio pueblo sale a impedir que nadie se vaya. Te encierran en un establo hasta que el más sano decide que no tenés fiebre.',
      ),
      RealOptionConfig(
        id: 'opt_plague_letter', text: 'Te ofrecés a llevar su pedido al magistrado',
        riskLevel: 2, timeCostMinutes: 40, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.guild: 1},
        journalNote: 'Llevé la súplica de un pueblo con fiebre. Pesaba más que mi paquete.',
        outcomeSuccess: 'El viejo te tira una tablilla atada a una piedra: piden médicos y grano. La guardás con tu carga. "El correo lleva lo que haga falta", dirías si Varus estuviera mirando.',
        outcomePartial: 'Te dan la tablilla, pero escribirla les lleva un rato porque nadie recuerda bien las letras. Esperás del lado sano de la soga, mirando un pueblo que respira despacio.',
        outcomeFail: 'La piedra con la tablilla cae en una acequia y tenés que pescarla con un palo. Llegás al camino mojado hasta el codo, con la súplica legible a medias.',
      ),
    ],
  ),

  // ─── Compitalia en el cruce ───
  RealEventConfig(
    id: 'evt_compitalia',
    category: EventCategory.temple,
    title: 'Fiesta en el cruce',
    description: 'Es Compitalia y los vecinos celebran a los Lares en el altar del cruce. Cuelgan muñecos de lana, reparten vino aguado y no dejan pasar a nadie sin brindar.',
    options: [
      RealOptionConfig(
        id: 'opt_compitalia_toast', text: 'Brindás con los vecinos y bailás un poco',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Brindás por los Lares del cruce, por los del camino y por los de una abuela que insiste. Te cuelgan una cinta en el bolso "para que el paquete llegue". Salís liviano y bendecido.',
        outcomePartial: 'Un brindis lleva a otro y el baile a una ronda que no termina. Te soltás de la ronda con el sol más bajo de lo que te gustaría.',
        outcomeFail: 'El vino era aguado, pero el tercero ya no tanto. Te despertás a la sombra del altar con un muñeco de lana en la mano y ninguna idea de cuánto tiempo pasó.',
      ),
      RealOptionConfig(
        id: 'opt_compitalia_slip', text: 'Pasás por detrás del altar sin brindar',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 1},
        outcomeSuccess: 'Mientras todos cantan, te escurrís por detrás del altar con la cabeza gacha. Nadie nota que alguien pasó sin brindar. Los Lares, si notaron, no dijeron nada.',
        outcomePartial: 'Pasás, pero una vieja te ve y te grita que vas a tener mala suerte en el camino. No creés en esas cosas. Durante un buen rato, mirás dónde pisás.',
        outcomeFail: 'Te agarran del manto a mitad del cruce. "¡El que no brinda paga ronda!" Pagás ronda para medio barrio y te vas con la bolsa más liviana.',
      ),
      RealOptionConfig(
        id: 'opt_compitalia_offering', text: 'Dejás una ofrenda y pedís paso',
        riskLevel: 2, timeCostMinutes: 15, requiredSkills: {SkillType.contacts: 1},
        outcomeSuccess: 'Dejás un pan y una moneda en el altar con el respeto que pide la fiesta. El magister del barrio aprueba con la cabeza y te abre un hueco entre la gente.',
        outcomePartial: 'La ofrenda gusta, pero el magister quiere además que digas tu nombre a los Lares en voz alta. Lo decís, la gente aplaude, vos te ponés colorado.',
        outcomeFail: 'Tu pan cae del altar y un perro se lo lleva. La gente lo toma como un augurio y discuten un rato largo si te dejan pasar o te bañan en vino para limpiarte.',
      ),
    ],
  ),

  // ─── El censo ───
  RealEventConfig(
    id: 'evt_census',
    category: EventCategory.forum,
    title: 'Los escribas del censo',
    description: 'En la puerta del pueblo, dos escribas del censo anotan a todo el que pasa: nombre, padre, tribu, bienes. La fila es larga y el escriba más viejo escribe muy despacio.',
    options: [
      RealOptionConfig(
        id: 'opt_census_queue', text: 'Hacés la fila y declarás todo',
        riskLevel: 1, timeCostMinutes: 90, requiredSkills: {},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'Declarás nombre, padre, tribu y una lista de bienes que cabe en una línea. El escriba sonríe por primera vez en el día: alguien que no miente. Te despide con un sello en la tablilla.',
        outcomePartial: 'El escriba quiere saber el nombre de tu abuelo y vos no estás seguro. Inventan uno juntos. Salís inscripto y con un antepasado nuevo.',
        outcomeFail: 'Cuando llega tu turno se acaba la cera de la tablilla. Mandan a buscar más. Vuelve el esclavo, se acaba la luz, y el escriba decide que el resto del censo es mañana.',
      ),
      RealOptionConfig(
        id: 'opt_census_official', text: 'Mostrás que viajás por servicio oficial',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: 'Señalás el sello del paquete y decís "correo en servicio" con la voz de quien lo dijo mil veces. El escriba ni levanta la vista: te hace pasar con un gesto.',
        outcomePartial: 'El escriba te deja pasar, pero te anota igual, en una columna aparte que dice "apurados". No sabés qué significa estar en esa columna.',
        outcomeFail: 'El escriba es un purista: "el servicio oficial también tiene padre y tribu". Te anota completo, con lentitud ejemplar, para que aprendas.',
      ),
      RealOptionConfig(
        id: 'opt_census_crowd', text: 'Te mezclás con una familia numerosa',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 2},
        outcomeSuccess: 'Una familia de once pasa en tropel con gallinas y una cabra. Te sumás como el primo callado. El escriba cuenta once, anota once y vos ya estás del otro lado.',
        outcomePartial: 'Pasás con la familia, pero la madre te adopta durante dos miliarios y te hace cargar a un nene que no para de tirarte del pelo.',
        outcomeFail: 'El escriba cuenta doce donde había once. La familia jura que no te conoce, la cabra también. Terminás declarando todo, con fama de colado.',
      ),
    ],
  ),

  // ─── Pastores en la cañada ───
  RealEventConfig(
    id: 'evt_shepherd_dispute',
    category: EventCategory.road,
    title: 'Pleito de pastores',
    description: 'Dos rebaños de trashumancia se mezclaron en el camino y sus pastores pelean por un carnero que los dos juran suyo. Ochocientas ovejas te tapan el paso. Te piden que juzgues.',
    options: [
      RealOptionConfig(
        id: 'opt_shepherd_wait', text: 'Esperás que separen los rebaños',
        riskLevel: 1, timeCostMinutes: 120, requiredSkills: {},
        outcomeSuccess: 'Los perros hacen el trabajo que los pastores no: en dos horas cada oveja vuelve a su lado. El carnero se queda en el medio, digno, sin elegir. Pasás entre balidos.',
        outcomePartial: 'Separan los rebaños a fuerza de gritos y palos, ovejas que se escapan y vuelven. Pasás cuando ya no queda luz para nada más.',
        outcomeFail: 'Cuando por fin separan los rebaños, el carnero se escapa y todo vuelve a mezclarse. Uno de los pastores te ofrece queso como consuelo. Lo aceptás: es buen queso.',
      ),
      RealOptionConfig(
        id: 'opt_shepherd_judge', text: 'Juzgás el pleito como un pretor',
        riskLevel: 2, timeCostMinutes: 20, requiredSkills: {SkillType.contacts: 2},
        journalNote: 'Juzgué un pleito por un carnero en medio de la cañada. El carnero no apeló.',
        outcomeSuccess: 'Mirás la marca de la oreja, escuchás a los dos y decidís como Salomón pero en latín: el carnero cubre a las ovejas de los dos esta temporada. Se dan la mano y te abren paso.',
        outcomePartial: 'Tu fallo convence a uno y ofende al otro, que se va mascullando. Pasás, pero con un pastor que te va a recordar con cariño y otro que no.',
        outcomeFail: 'Fallás a favor del que tenía razón según la marca. El otro pastor apela a su perro, que no acepta tu jurisdicción. Salís con los talones a salvo y el manto mordido.',
      ),
      RealOptionConfig(
        id: 'opt_shepherd_wade', text: 'Te abrís paso entre las ovejas',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 1},
        outcomeSuccess: 'Caminás entre las ovejas como entre olas, empujando con las rodillas y sin mirar atrás. Del otro lado, los pastores siguen gritando. Ni se enteraron de que pasaste.',
        outcomePartial: 'Pasás, pero las ovejas se apiñan y te llevan un trecho de costado. Salís con lana pegada en todo el cuerpo y oliendo a corral por el resto del día.',
        outcomeFail: 'Un carnero que no es el del pleito te toma por rival. Te embiste dos veces, con método. Llegás al otro lado de espaldas y aprendiendo.',
      ),
    ],
  ),

  // ─── El chico que no habla ───
  RealEventConfig(
    id: 'evt_mute_boy',
    category: EventCategory.road,
    title: 'El chico mudo',
    description: 'Hace tres miliarios que un chico flaco te sigue a veinte pasos. Si parás, para. Si le hablás, baja la vista. No dice una palabra; parece que no puede.',
    options: [
      RealOptionConfig(
        id: 'opt_mute_bread', text: 'Le compartís el pan y lo dejás seguirte',
        riskLevel: 1, timeCostMinutes: 45, requiredSkills: {},
        journalNote: 'Un chico mudo me siguió media jornada. Comimos juntos y me mostró un camino que no figura en ninguna piedra.',
        outcomeSuccess: 'Comen sentados en una piedra, sin hablar. Después el chico te tira de la manga y te lleva por un sendero de cabras que te ahorra una vuelta entera. En el cruce, desaparece.',
        outcomePartial: 'Comparten el pan y el chico camina a tu lado, más lento de lo que te conviene. Lo dejás en la puerta de una granja donde alguien lo llama por su nombre.',
        outcomeFail: 'El chico se come todo el pan, el tuyo incluido, y se va corriendo. Te quedás con hambre y con la extraña sensación de haber hecho bien igual.',
      ),
      RealOptionConfig(
        id: 'opt_mute_lose', text: 'Lo perdés en un recodo del camino',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 2},
        outcomeSuccess: 'Te escondés detrás de un sepulcro al costado del camino y esperás. El chico pasa, mira a todos lados y vuelve sobre sus pasos. Seguís solo y rápido.',
        outcomePartial: 'Lo perdés, pero media hora después aparece de nuevo, a veinte pasos, como si nada. Te resignás: es más terco que vos.',
        outcomeFail: 'Te escondés y el chico se sienta a esperarte en el medio del camino. Pasa un carro y casi lo atropella. Salís a buscarlo y él te mira como diciendo "te encontré".',
      ),
      RealOptionConfig(
        id: 'opt_mute_send', text: 'Lo mandás de vuelta a su casa',
        riskLevel: 2, timeCostMinutes: 15, requiredSkills: {},
        outcomeSuccess: 'Le señalás el camino de vuelta con firmeza y un poco de pena. El chico duda, asiente y se va. Al rato, desde una loma, te saluda con la mano.',
        outcomePartial: 'Se va, pero te lleva un rato convencerlo a fuerza de gestos. Cuando por fin seguís, no podés dejar de mirar atrás cada tanto.',
        outcomeFail: 'El chico no se va: se pone a llorar sin sonido, que es peor. Terminás acompañándolo hasta la granja más cercana, que queda justo para el otro lado.',
      ),
      // Callback: es el hermano de la nena que llevaste al pueblo.
      RealOptionConfig(
        id: 'opt_mute_ribbon', text: 'Te muestra una cinta que reconocés',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'helped_lost_child',
        repDelta: {Faction.guild: 1},
        journalNote: 'El hermano de la nena del cruce me encontró en el camino. No habla, pero sabe dar las gracias.',
        outcomeSuccess: 'Es la cinta de la nena que llevaste de la mano. El chico es su hermano y te buscaba para darte algo: un atado de higos y un atajo. Lo seguís sin dudar.',
        outcomePartial: 'Reconocés la cinta y entendés todo. El chico te acompaña un tramo largo, orgulloso, y no hay forma de que camine más rápido. No te importa tanto.',
        outcomeFail: 'Quiere llevarte a su casa para que la familia te agradezca. No podés negarte del todo. La madre te da de comer y la abuela, consejos. Salís tarde y lleno.',
      ),
    ],
  ),

  // ─── El miliario caído ───
  RealEventConfig(
    id: 'evt_fallen_milestone',
    category: EventCategory.road,
    title: 'El miliario caído',
    description: 'En una bifurcación sin señales, el miliario que debería indicar el rumbo está tirado en el pasto, boca abajo. Los dos caminos se ven igual de anchos e igual de vacíos.',
    options: [
      RealOptionConfig(
        id: 'opt_milestone_farm', text: 'Preguntás en una granja cercana',
        riskLevel: 1, timeCostMinutes: 75, requiredSkills: {},
        outcomeSuccess: 'La granjera te indica el camino sin dejar de moler grano. "El de la izquierda. El otro va a la casa de mi cuñado, y no te lo recomiendo." Seguís seguro.',
        outcomePartial: 'En la granja solo hay un viejo sordo que contesta a otra pregunta. Al final entendés por los gestos. Volvés al cruce convencido a medias.',
        outcomeFail: 'La granja está más lejos de lo que parecía y el perro no te deja llegar a la puerta. Volvés al cruce sin respuesta y con el sol bastante más bajo.',
      ),
      RealOptionConfig(
        id: 'opt_milestone_lift', text: 'Das vuelta la piedra y leés',
        riskLevel: 2, timeCostMinutes: 20, requiredSkills: {SkillType.combat: 1},
        journalNote: 'Levanté un miliario caído en un cruce perdido. Alguien más va a llegar a destino gracias a eso.',
        outcomeSuccess: 'Hacés palanca con un tronco y la piedra gira. La inscripción del cónsul indica el rumbo y la distancia. La dejás parada otra vez, para el que venga después.',
        outcomePartial: 'Das vuelta la piedra y te raspás las manos hasta sangrar. La inscripción está gastada, pero se lee el nombre de la ciudad. Alcanza.',
        outcomeFail: 'La piedra gira, pero la cara escrita está partida justo donde importaba. Te queda una mitad de número y el nombre de un cónsul que no te sirve de nada.',
      ),
      RealOptionConfig(
        id: 'opt_milestone_sun', text: 'Elegís el rumbo por el sol',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Mirás la sombra, calculás la hora y sabés hacia dónde queda tu ciudad. Tomás el camino sin dudar. Dos miliarios después, una piedra en pie te da la razón.',
        outcomePartial: 'El sol te da la dirección general, pero el camino que elegís serpentea más de la cuenta. Llegás bien, aunque con la sensación de haber dibujado una S.',
        outcomeFail: 'Una nube tapa el sol justo cuando más lo necesitabas. Elegís mal y lo descubrís tarde, frente al corral del cuñado de alguien. Volver lleva lo suyo.',
      ),
    ],
  ),

  // ─── Dados en la taberna ───
  RealEventConfig(
    id: 'evt_dice_game',
    category: EventCategory.inn,
    title: 'Dados en la taberna',
    description: 'En la taberna de la posta, un grupo juega a los dados con más gritos que monedas. Te invitan a una mano. El que tira tiene los dedos demasiado rápidos.',
    options: [
      RealOptionConfig(
        id: 'opt_dice_refuse', text: 'Comés rápido y no aceptás nada',
        riskLevel: 1, timeCostMinutes: 30, requiredSkills: {},
        outcomeSuccess: 'Comés de espaldas al juego y con la bolsa entre las rodillas. Cuando salís, todavía se oyen los gritos y ninguna de esas monedas es tuya. Ni tampoco tus problemas.',
        outcomePartial: 'Te quedás un rato de más mirando, porque el juego es hipnótico. No perdés nada, salvo el tiempo y un poco de dignidad de mensajero.',
        outcomeFail: 'Un jugador que perdió todo te acusa de traerle mala suerte por mirar. El tabernero te pide que salgas por la cocina, entre ollas y una gata ofendida.',
      ),
      RealOptionConfig(
        id: 'opt_dice_play', text: 'Jugás una mano con cuidado',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'Apostás poco, ganás algo y te retirás cuando todos piden revancha. Te ganaste un lugar en la mesa y un dato: uno de los jugadores conoce un atajo y te lo cuenta entre risas.',
        outcomePartial: 'Ganás una mano y perdés otra. Salís igual que entraste, salvo que ahora saben tu nombre en una taberna donde nadie dice el suyo.',
        outcomeFail: 'Los dados de él tienen opiniones. Perdés lo que apostaste y un poco más, y te vas con la certeza de que fuiste el entretenimiento de la noche.',
      ),
      RealOptionConfig(
        id: 'opt_dice_expose', text: 'Le agarrás la mano al tramposo',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.combat: 2},
        repDelta: {Faction.underworld: -1},
        outcomeSuccess: 'Le apretás la muñeca y cae un tercer dado de la manga. La mesa entera se le tira encima. Vos aprovechás el tumulto para salir, con la gratitud de cinco perdedores.',
        outcomePartial: 'El dado cargado aparece, pero el tramposo tiene amigos. Salís por la ventana con un ojo hinchado y la satisfacción de haber tenido razón.',
        outcomeFail: 'El tramposo es más rápido: cuando le abrís la mano, solo hay una moneda. Toda la mesa te mira mal. Te vas pagando la ronda de la ofensa.',
      ),
      // Callback: los que eligieron el camino de los Bajos Fondos tienen amigos.
      RealOptionConfig(
        id: 'opt_dice_viuda', text: 'Nombrás a la Viuda de la Loba',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'path_underworld',
        outcomeSuccess: 'El nombre cae sobre la mesa como un cuarto dado. El tramposo guarda los suyos y te sirve vino. Antes de irte, te da un dato del camino que vale más que todo lo que había en juego.',
        outcomePartial: 'El nombre funciona, pero el tramposo quiere mandarle saludos a la Viuda y te dicta un mensaje largo. Ahora llevás dos encargos, uno sin paga.',
        outcomeFail: 'Uno de los jugadores le debe dinero a la Viuda y se pone pálido. Te pide que no digas que lo viste. Perdés un rato escuchando por qué, con todo detalle.',
      ),
    ],
  ),

  // ─── Tierras de veteranos ───
  RealEventConfig(
    id: 'evt_veteran_land',
    category: EventCategory.road,
    title: 'Mojones en disputa',
    description: 'Unos veteranos recién asentados discuten con el antiguo dueño de la tierra. Cruzaron arados en el camino para que nadie pase hasta que llegue el agrimensor.',
    options: [
      RealOptionConfig(
        id: 'opt_veteran_wait', text: 'Esperás al agrimensor con ellos',
        riskLevel: 1, timeCostMinutes: 120, requiredSkills: {},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'El agrimensor llega con su groma y su paciencia, mide, clava un mojón nuevo y todos se callan. Los veteranos retiran los arados y te convidan con posca. Los ánimos, por hoy, aguantan.',
        outcomePartial: 'El agrimensor llega tarde y mide dos veces. Los veteranos ganan por un palmo y el viejo dueño se va llorando. Pasás con un nudo en la garganta que no es tuyo.',
        outcomeFail: 'El agrimensor no viene: mandó a decir que mañana. Los veteranos deciden que hasta entonces nadie se mueve, vos tampoco. Te sueltan cuando se aburren.',
      ),
      RealOptionConfig(
        id: 'opt_veteran_jump', text: 'Saltás los arados y seguís',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Saltás el primer arado, esquivás el segundo y ya estás del otro lado antes de que alguien se dé vuelta. Los gritos que te siguen no son para vos.',
        outcomePartial: 'Saltás, pero te enganchás el manto en una reja y lo dejás con un tajo. Un veterano te grita algo del ejército de César. Seguís igual, con el manto ventilado.',
        outcomeFail: 'Un veterano de sesenta años te agarra del cinturón al vuelo con una mano. "Disciplina, muchacho." Te sienta con ellos hasta que se acaba la discusión.',
      ),
      RealOptionConfig(
        id: 'opt_veteran_mediate', text: 'Proponés repartir la cosecha de este año',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.patricians: -1, Faction.legions: 1},
        journalNote: 'Medié entre veteranos y un viejo propietario. Ninguno quedó contento, que es como saber que fue justo.',
        outcomeSuccess: 'Proponés que este año cosechen juntos y que el agrimensor decida el resto. Los dos lados lo piensan, escupen y se dan la mano. Te abren el camino como a un tribuno.',
        outcomePartial: 'Los veteranos aceptan, el viejo no. Igual retiran un arado para que pases, más por cansancio que por convicción.',
        outcomeFail: 'Tu propuesta une a los dos bandos: contra vos. Que quién te creés, que de dónde sacaste eso. Salís con la cara colorada y un rodeo extra.',
      ),
    ],
  ),

  // ─── Peregrinos con Atia ───
  RealEventConfig(
    id: 'evt_pilgrims',
    category: EventCategory.temple,
    npcId: 'atia',
    title: 'Los peregrinos de Fortuna',
    description: 'Atia, la sacerdotisa de Mercurio, guía a un grupo de peregrinos hacia el santuario de Fortuna. Un viejo se desmayó al costado del camino y ella te pide una mano.',
    options: [
      RealOptionConfig(
        id: 'opt_pilgrims_carry', text: 'Cargás al viejo hasta la próxima fuente',
        riskLevel: 1, timeCostMinutes: 90, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        journalNote: 'Cargué a un peregrino hasta la fuente. Atia dijo que Mercurio anota esas cosas.',
        outcomeSuccess: 'El viejo pesa menos que tu culpa si lo dejabas. En la fuente se recupera y te bendice tres veces. Atia te toca la frente: "Mercurio protege a los que cargan algo más que cartas."',
        outcomePartial: 'Llegás a la fuente con los brazos temblando y el viejo quejándose de tu forma de cargar. Atia sonríe y te da un trago de su odre.',
        outcomeFail: 'A mitad de camino el viejo se despierta, se ofende de ir en brazos y se baja. Camina más rápido que vos el resto del tramo.',
      ),
      RealOptionConfig(
        id: 'opt_pilgrims_herbs', text: 'Le preparás hierbas para reanimarlo',
        riskLevel: 2, timeCostMinutes: 20, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Juntás menta silvestre y ruda, las machacás y se las das a oler. El viejo abre los ojos y pide vino. Atia te mira con algo parecido al asombro.',
        outcomePartial: 'Las hierbas lo despiertan, pero también le dan hipo. El viejo sigue viaje entre hipos y bendiciones. Atia no puede dejar de reírse.',
        outcomeFail: 'Te equivocás de yuyo. El viejo estornuda tanto que despierta del todo y te mira con odio. Funcionó, aunque nadie te lo agradece.',
      ),
      RealOptionConfig(
        id: 'opt_pilgrims_pass', text: 'Te disculpás y seguís camino',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Atia asiente sin reproche: "El camino de cada uno es el suyo." Seguís a buen paso y la caravana de peregrinos queda atrás, cantando bajito.',
        outcomePartial: 'Seguís, pero los cantos de los peregrinos te alcanzan durante un buen rato. Cada estrofa suena un poco a reproche.',
        outcomeFail: 'Más adelante el camino se angosta y la caravana te alcanza. Terminás caminando con ellos igual, ahora con el viejo en una camilla y vos de cuarto cargador.',
      ),
      // Callback: Atia sabe que oíste a la Sibila.
      RealOptionConfig(
        id: 'opt_pilgrims_sibyl', text: 'Le contás lo que te dijo la Sibila',
        riskLevel: 1, timeCostMinutes: 10, requiredSkills: {},
        requiredFlag: 'heard_the_sibyl',
        outcomeSuccess: 'Atia escucha el vaticinio en silencio y después te lo explica en dos frases claras, como quien abre una carta. Te despide con una bendición y un camino corto hacia tu destino.',
        outcomePartial: 'Atia escucha, frunce el ceño y te pide que se lo repitas. Te da una interpretación prudente y te deja pensando el resto del camino.',
        outcomeFail: 'Le contás el vaticinio mal, cambiando dos palabras. Atia te corrige con una paciencia infinita y te lo hace recitar entero antes de dejarte ir.',
      ),
    ],
  ),

  // ─── Rehén galo ───
  RealEventConfig(
    id: 'evt_hostage_escort',
    category: EventCategory.patrol,
    title: 'El rehén galo',
    description: 'Una escolta de legionarios custodia a un joven noble galo, rehén de su tribu. Acampan junto al camino. El galo te ve el bolso de correo y te chista en latín torpe.',
    options: [
      RealOptionConfig(
        id: 'opt_hostage_ignore', text: 'Lo ignorás y saludás al decurión',
        riskLevel: 1, timeCostMinutes: 30, requiredSkills: {},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'Saludás al decurión según el protocolo y él te devuelve el saludo y un trago de agua fresca. El galo te mira pasar con la cara de quien no esperaba otra cosa.',
        outcomePartial: 'El decurión quiere saber qué te dijo el galo. Le contás la verdad: nada. Te tiene un rato preguntando lo mismo con otras palabras.',
        outcomeFail: 'El decurión vio el chistido y te revisa la carga por si llevás algo para el rehén. No encuentra nada, pero se toma su tiempo en no encontrarlo.',
      ),
      RealOptionConfig(
        id: 'opt_hostage_letter', text: 'Aceptás en secreto su carta para la madre',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.stealth: 2},
        repDelta: {Faction.underworld: 1},
        journalNote: 'Llevo escondida la carta de un rehén galo para su madre. Si me la encuentran, no la escribió nadie.',
        outcomeSuccess: 'El galo te desliza una tablilla chica mientras el centinela orina detrás de un árbol. La escondés en la suela. Él te mira y por primera vez parece un chico de veinte años.',
        outcomePartial: 'Recibís la carta, pero un legionario te ve guardar algo. Tenés que inventar una historia de amor con una lavandera de Arelate. Te cree, más o menos.',
        outcomeFail: 'El decurión los sorprende. El galo jura que te pidió agua y vos que se la diste. Te dejan ir tarde y con la promesa de que tu nombre va a figurar en un informe.',
      ),
      RealOptionConfig(
        id: 'opt_hostage_talk', text: 'Hablás con los dos en su idioma',
        riskLevel: 2, timeCostMinutes: 20, requiredSkills: {SkillType.contacts: 2},
        outcomeSuccess: 'Con tu latín para el decurión y tus diez palabras de galo para el chico, lográs que el rehén mande su carta abierta, leída y sellada por la escolta. Nadie miente y todos quedan tranquilos.',
        outcomePartial: 'El decurión acepta leer la carta, pero el galo no quiere que la lean. Al final no se manda nada y vos te vas con el tiempo perdido y la conciencia limpia.',
        outcomeFail: 'Tus diez palabras de galo incluyen una ofensa sin querer. El rehén se ofende, el decurión se ríe y vos te vas con las orejas coloradas.',
      ),
    ],
  ),

  // ─── Caballo enfermo en la posta ───
  RealEventConfig(
    id: 'evt_horse_sick',
    category: EventCategory.road,
    title: 'Cólico en la posta',
    description: 'En la mutatio, el único caballo de relevo está echado y se mira la panza. El encargado se rasca la cabeza. Un tratante con cara de zorro ofrece un animal propio, ya ensillado.',
    options: [
      RealOptionConfig(
        id: 'opt_horse_wait', text: 'Esperás el próximo relevo oficial',
        riskLevel: 1, timeCostMinutes: 150, requiredSkills: {},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'El relevo llega de la posta vecina, sano y con ganas. Mientras tanto ayudaste a pasear al enfermo, que ya se para solo. El encargado anota tu nombre entre los buenos.',
        outcomePartial: 'El relevo llega, pero es una yegua vieja que trota a su ritmo. Llegás, sí. Ella decide cuándo.',
        outcomeFail: 'El relevo llega cojo de una mano. Hay que esperar al herrero, y el herrero está en una boda. El día se te va entre bueyes y relinchos.',
      ),
      RealOptionConfig(
        id: 'opt_horse_dealer', text: 'Le comprás el caballo al tratante',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.contacts: 1},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'Regateás como en el Foro Boario y el tratante cede con una sonrisa falsa. El caballo es bueno de verdad. No preguntás de dónde salió y él no te lo cuenta.',
        outcomePartial: 'El caballo corre bien un rato y después se acuerda de que es viejo. Llegás, pero a paso de procesión, y habiendo pagado por un corcel.',
        outcomeFail: 'A los dos miliarios, un jinete te grita que ese caballo es suyo. Tenés que devolverlo y seguir a pie. El tratante, por supuesto, ya no está en la posta.',
      ),
      RealOptionConfig(
        id: 'opt_horse_cure', text: 'Hacés caminar al caballo enfermo',
        riskLevel: 2, timeCostMinutes: 45, requiredSkills: {SkillType.survival: 2},
        outcomeSuccess: 'Lo levantás, lo hacés caminar en círculos y le frotás la panza como te enseñó un arriero. Al rato el caballo suelta lo que lo tenía mal y relincha. Salís montado y con el encargado admirado.',
        outcomePartial: 'El caballo se recupera a medias y te lleva despacio hasta la próxima posta. Ahí lo dejás descansando y te dan otro, que no sabés si es mejor.',
        outcomeFail: 'El caballo se para, te mira y se vuelve a echar, encima de tu manto. El tratante se ríe desde la puerta y te sube el precio.',
      ),
    ],
  ),

  // ─── Niebla en los Apeninos ───
  RealEventConfig(
    id: 'evt_apennine_fog',
    category: EventCategory.storm,
    title: 'Niebla en la sierra',
    description: 'Una niebla espesa baja de los Apeninos y en minutos no ves ni tus sandalias. A lo lejos suenan cencerros. El camino tiene precipicio de un lado, y no sabés de cuál.',
    options: [
      RealOptionConfig(
        id: 'opt_fog_wait', text: 'Te sentás y esperás que levante',
        riskLevel: 1, timeCostMinutes: 180, requiredSkills: {},
        outcomeSuccess: 'Te envolvés en el manto y esperás contando respiraciones. A media tarde la niebla se levanta como un telón y descubrís que estabas a dos pasos del borde. Seguís, con más respeto.',
        outcomePartial: 'La niebla levanta y baja dos veces, burlona. Avanzás de a tramos cortos, con el manto mojado y los dedos fríos.',
        outcomeFail: 'La niebla no se va, se acomoda. Cuando por fin se disipa ya es casi de noche y tenés que bajar la sierra con la última luz.',
      ),
      RealOptionConfig(
        id: 'opt_fog_bells', text: 'Seguís el sonido de los cencerros',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 1},
        outcomeSuccess: 'Los cencerros te llevan hasta un pastor y sus vacas, que conocen la sierra mejor que cualquier mapa. Bajás detrás de ellas, pisando donde pisan.',
        outcomePartial: 'Los cencerros son de cabras, y las cabras van por donde se les canta. Llegás a un sendero bueno, pero arañado y con una cabra que te adoptó.',
        outcomeFail: 'Los cencerros se mueven más rápido que vos y los perdés en la niebla. Terminás en un corral vacío, sin cabras y sin camino.',
      ),
      RealOptionConfig(
        id: 'opt_fog_rope', text: 'Avanzás tanteando el borde con un palo',
        riskLevel: 2, timeCostMinutes: 60, requiredSkills: {SkillType.stealth: 1},
        outcomeSuccess: 'Avanzás despacio, golpeando la piedra del borde con un palo como un ciego del Foro. El método es lento pero exacto, y la niebla no te gana.',
        outcomePartial: 'El palo se te parte a mitad de camino y seguís tanteando con el pie. Llegás, con el corazón en la boca dos o tres veces.',
        outcomeFail: 'El palo encuentra vacío donde esperabas piedra y das un paso atrás tan brusco que caés sentado en un charco. Seguís, pero muy, muy despacio.',
      ),
      // Callback: ya cruzaste una tormenta de pie.
      RealOptionConfig(
        id: 'opt_fog_veteran', text: 'Caminás como cuando cruzaste la tormenta',
        riskLevel: 2, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'walked_the_storm',
        outcomeSuccess: 'El cuerpo se acuerda solo: paso corto, peso atrás, oído atento. La niebla es apenas una tormenta callada. La atravesás sin perder el rumbo.',
        outcomePartial: 'La memoria del cuerpo ayuda, pero la niebla no es tormenta y te confunde en un cruce. Retomás el camino tras un rodeo corto.',
        outcomeFail: 'Te confiás demasiado y apurás el paso. Una raíz te recuerda que cada camino es distinto. Seguís cojeando y con la soberbia más baja.',
      ),
    ],
  ),

  // ─── El poeta ───
  RealEventConfig(
    id: 'evt_poet',
    category: EventCategory.road,
    title: 'Un poeta de viaje',
    description: 'Un joven con toga gastada y tablillas bajo el brazo se te pega en el camino. Dice que escribe un poema sobre los correos y necesita vivir uno. Ya empezó a recitar.',
    options: [
      RealOptionConfig(
        id: 'opt_poet_accept', text: 'Lo dejás acompañarte y lo escuchás',
        riskLevel: 1, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        outcomeSuccess: 'El poeta camina lento y recita hexámetros sobre tus sandalias. Resulta que tiene un patrono en el Senado al que le va a hablar bien de vos. Llegás tarde, pero inmortal.',
        outcomePartial: 'Los versos no están mal, pero el poeta para cada cien pasos a corregir una sílaba. Para el final del tramo sabés más de métrica que de tu propio camino.',
        outcomeFail: 'El poeta te lee el poema entero, que tiene once libros. Vas por el tercero cuando se pone el sol. Te despedís con dolor de cabeza y un papel secundario.',
      ),
      RealOptionConfig(
        id: 'opt_poet_outrun', text: 'Apurás el paso hasta dejarlo atrás',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Apurás el paso, después trotás, después corrés. El poeta te grita que eso también es poesía. Lo perdés de vista antes de la próxima rima.',
        outcomePartial: 'Lo dejás atrás, pero el poeta corre mejor de lo que recita. Te alcanza dos veces antes de rendirse, jadeando versos sobre tu ingratitud.',
        outcomeFail: 'Corrés tanto que te pasás el desvío. Cuando volvés, el poeta te está esperando en el cruce, encantado: "Esto es exactamente lo que necesitaba para el canto cuarto."',
      ),
      RealOptionConfig(
        id: 'opt_poet_story', text: 'Le regalás una historia y te vas',
        riskLevel: 2, timeCostMinutes: 15, requiredSkills: {SkillType.contacts: 1},
        journalNote: 'Le regalé una historia del camino a un poeta. Si algún día me leo en verso, voy a negar todo.',
        outcomeSuccess: 'Le contás algo real del camino, con tus palabras. El poeta escribe frenético y te deja ir sin pelear. Le diste un poema; él te devolvió el silencio.',
        outcomePartial: 'Le gusta la historia, pero te pide detalles: el color del cielo, qué sentías. Inventás un poco. Te vas con la sospecha de que vas a quedar mejor de lo que fuiste.',
        outcomeFail: 'Le contás una historia y él la reconoce: "Eso es de Ennio." Te pide otra, propia esta vez. La encontrás, pero te cuesta un buen tramo.',
      ),
    ],
  ),

  // ─── Abejas ───
  RealEventConfig(
    id: 'evt_bees',
    category: EventCategory.road,
    title: 'Colmenas volcadas',
    description: 'Un carro de apicultor volcó y las colmenas de corcho rodaron por el camino. Un enjambre furioso zumba sobre la ruta. El apicultor, hinchado, hace señas desde una zanja.',
    options: [
      RealOptionConfig(
        id: 'opt_bees_wait', text: 'Esperás lejos a que se calmen',
        riskLevel: 1, timeCostMinutes: 90, requiredSkills: {},
        outcomeSuccess: 'Te sentás a la sombra a cincuenta pasos. Al atardecer las abejas se juntan en una rama y el camino queda libre. El apicultor te regala un panal por la paciencia.',
        outcomePartial: 'Las abejas se calman a medias. Pasás despacito, sin respirar, y una sola te pica en la oreja. Es suficiente para que la oreja te lo recuerde.',
        outcomeFail: 'Una abeja exploradora te encuentra en tu escondite y avisa a las demás. Terminás esperando dentro de una acequia con agua hasta el cuello.',
      ),
      RealOptionConfig(
        id: 'opt_bees_run', text: 'Atravesás el enjambre a toda carrera',
        riskLevel: 4, timeCostMinutes: 0, requiredSkills: {SkillType.speed: 2},
        outcomeSuccess: 'Te tapás la cabeza con el manto y corrés como si te persiguiera un pretor. Las abejas tardan en entender qué pasó. Cuando entienden, ya estás lejos.',
        outcomePartial: 'Pasás corriendo y salís con cuatro picaduras y un zumbido en los oídos que dura una hora. Pero pasaste.',
        outcomeFail: 'El enjambre te sigue medio miliario. Te tirás a un arroyo para sacártelo de encima y salís mojado, picado y sin un poco de tu dignidad.',
      ),
      RealOptionConfig(
        id: 'opt_bees_smoke', text: 'Hacés humo y ayudás al apicultor',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.survival: 2},
        journalNote: 'Ayudé a juntar colmenas con humo de pasto verde. Me pagaron con miel y una sola picadura.',
        outcomeSuccess: 'Prendés pasto húmedo y el humo amansa al enjambre. Entre los dos levantan las colmenas y la reina vuelve a su casa. El apicultor te llena una vasija de miel de tomillo.',
        outcomePartial: 'El humo funciona, pero el viento cambia y te lo tira en la cara. Llorás, tosés y ayudás. Al final, el apicultor te da miel y un trapo para los ojos.',
        outcomeFail: 'El humo amansa a las abejas y espanta a los caballos de un carro que venía. Pasás un buen rato juntando colmenas y calmando a un carretero.',
      ),
    ],
  ),

  // ─── Monedas falsas ───
  RealEventConfig(
    id: 'evt_counterfeit',
    category: EventCategory.forum,
    title: 'Denarios forrados',
    description: 'En el puesto de un cambista, el vuelto que te dan suena raro. Mordés un denario y asoma cobre bajo la plata. El cambista sonríe como si nada.',
    options: [
      RealOptionConfig(
        id: 'opt_counterfeit_accept', text: 'Te las guardás y seguís viaje',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        outcomeSuccess: 'Te guardás las monedas sin decir nada. Más adelante se las das a un tabernero que tampoco las mira. El mundo es una cadena de denarios falsos y vos ya estás afuera.',
        outcomePartial: 'Te las guardás, pero el peso de saberlo te acompaña. En la próxima posta pagás con monedas buenas y las falsas se quedan en tu bolsa, como piedras.',
        outcomeFail: 'En la próxima posta las mordés antes de pagar y el tabernero te ve. "¿Moneda falsa en mi casa?" Explicarlo te lleva un rato largo y el doble de la cuenta.',
      ),
      RealOptionConfig(
        id: 'opt_counterfeit_aedile', text: 'Llamás al edil del mercado',
        riskLevel: 2, timeCostMinutes: 60, requiredSkills: {},
        repDelta: {Faction.legions: 1},
        outcomeSuccess: 'El edil llega, muerde una moneda y hace una mueca. El cambista termina sin puesto y vos con tu vuelto en monedas buenas. Algunos vecinos te aplauden por lo bajo.',
        outcomePartial: 'El edil confisca las monedas, pero también las tuyas, como prueba. Te devuelven la mitad. Justicia, pero cara.',
        outcomeFail: 'El edil es primo del cambista. Te hace un sermón sobre las acusaciones falsas y te deja ir tarde y sin vuelto.',
      ),
      RealOptionConfig(
        id: 'opt_counterfeit_quiet', text: 'Le pedís el cambio bien, en voz baja',
        riskLevel: 3, timeCostMinutes: 10, requiredSkills: {SkillType.contacts: 2},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'Te inclinás y le decís, muy bajito, a qué callejón de Roma pertenecen esas monedas. El cambista palidece, te cambia todo en plata buena y agrega un denario de disculpas.',
        outcomePartial: 'El cambista te cambia las monedas, pero te mira como a alguien que sabe demasiado. Su cara la vas a ver de nuevo, en algún lado.',
        outcomeFail: 'El cambista hace como que no entiende y te pide que te alejes de su puesto. Dos grandotes aparecen detrás de él. Te alejás con las monedas falsas.',
      ),
    ],
  ),

  // ─── Carboneros del monte ───
  RealEventConfig(
    id: 'evt_charcoal_burners',
    category: EventCategory.road,
    title: 'Los carboneros',
    description: 'El camino se mete en un bosque lleno de humo. Hay carboneras humeando entre los árboles y hombres tiznados que te miran sin saludar. Uno se para en medio del sendero.',
    options: [
      RealOptionConfig(
        id: 'opt_charcoal_greet', text: 'Saludás y pedís permiso para pasar',
        riskLevel: 1, timeCostMinutes: 45, requiredSkills: {},
        outcomeSuccess: 'Saludás, decís de dónde venís y adónde vas. El carbonero escupe, asiente y te deja pasar. Uno más joven te acompaña hasta el borde del bosque, para que no te pierdas en el humo.',
        outcomePartial: 'Te dejan pasar, pero antes te hacen esperar hasta que termine de quemar una carbonera, por si sos un espía de los dueños del bosque.',
        outcomeFail: 'No les gusta tu acento. Te hacen dar la vuelta por fuera del bosque, por un sendero lleno de ortigas que nadie usa por algo.',
      ),
      RealOptionConfig(
        id: 'opt_charcoal_push', text: 'Pasás sin detenerte entre el humo',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.combat: 1},
        outcomeSuccess: 'Caminás derecho, sin bajar la vista ni subirla. El hombre del sendero se hace a un lado. Los carboneros respetan a los que no piden nada.',
        outcomePartial: 'Pasás, pero el humo te hace llorar y toser como un fuelle viejo. Los carboneros se ríen. Salís del bosque negro como ellos.',
        outcomeFail: 'El hombre no se corre y vos tampoco. Termina en empujones y en vos sentado sobre carbón tibio. Te dejan pasar después, ya que les diste el gusto.',
      ),
      RealOptionConfig(
        id: 'opt_charcoal_sneak', text: 'Rodeás el campamento por el arroyo',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.stealth: 2},
        outcomeSuccess: 'Bajás al arroyo y seguís el agua entre helechos. El humo te tapa mejor que cualquier sombra. Salís del bosque sin que nadie sepa que estuviste.',
        outcomePartial: 'El arroyo da una vuelta más larga de la que creías y en un tramo te tenés que meter al agua. Salís mojado, pero invisible.',
        outcomeFail: 'Un perro de los carboneros te encuentra en el arroyo y te acompaña ladrando hasta el campamento. Llegás escoltado y sospechoso.',
      ),
      // Callback: el desertor que no delataste vive acá ahora.
      RealOptionConfig(
        id: 'opt_charcoal_fugitive', text: 'Una cara tiznada te resulta conocida',
        riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
        requiredFlag: 'helped_deserter',
        journalNote: 'El desertor que no delaté quema carbón en el monte. Tiene otro nombre y la misma mirada.',
        outcomeSuccess: 'Es el desertor de las rocas. Ahora tiene otro nombre y tizne hasta las cejas. Te reconoce, habla con los demás y te llevan por un atajo que ninguna patrulla conoce.',
        outcomePartial: 'Te reconoce y te hace una seña para que lo sigas sin hablar. El camino es bueno pero lento; él no puede dejar la carbonera mucho tiempo.',
        outcomeFail: 'Te reconoce y se asusta: cree que traés una patrulla detrás. Te lleva un buen rato convencerlo de que venís solo. Al final te da la mano, todavía temblando.',
      ),
    ],
  ),

  // ─── Restos en la playa ───
  RealEventConfig(
    id: 'evt_wreck_salvage',
    category: EventCategory.port,
    title: 'Restos en la playa',
    description: 'Un barco mercante se partió contra las rocas durante la noche. La playa está llena de ánforas y tablones, y los vecinos ya saquean. Una caja lleva el sello de un armador de Ostia.',
    options: [
      RealOptionConfig(
        id: 'opt_wreck_guard', text: 'Custodiás la caja hasta que llegue alguien',
        riskLevel: 1, timeCostMinutes: 120, requiredSkills: {},
        repDelta: {Faction.patricians: 1},
        journalNote: 'Custodié la caja de un armador en una playa de saqueadores. Nadie me lo pidió.',
        outcomeSuccess: 'Te sentás sobre la caja y mirás feo a quien se acerca. A la tarde llega el agente del armador, la abre, comprueba todo y anota tu nombre para una recompensa futura.',
        outcomePartial: 'Cuidás la caja, pero los vecinos se llevan todo lo demás. El agente del armador llega y te agradece la caja con la cara de quien perdió el barco.',
        outcomeFail: 'Te quedás dormido al sol y cuando abrís los ojos la caja sigue ahí, abierta y vacía. Alguien te dejó una ánfora de vino al lado, como disculpa.',
      ),
      RealOptionConfig(
        id: 'opt_wreck_take', text: 'Tomás una ánfora y seguís camino',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {},
        repDelta: {Faction.underworld: 1},
        outcomeSuccess: 'Te cargás una ánfora de vino al hombro como un vecino más y seguís. Lo que el mar trae, el mar regala. El vino resulta ser de Quíos, de lo bueno.',
        outcomePartial: 'El ánfora pesa el doble de lo que pensabas y te retrasa todo el tramo. Al llegar, la abrís: es garum, y medio podrido.',
        outcomeFail: 'Un guardia del puerto te ve con el ánfora y te obliga a devolverla y declarar. Perdés tiempo y reputación de correo honesto.',
      ),
      RealOptionConfig(
        id: 'opt_wreck_survivors', text: 'Buscás sobrevivientes entre las rocas',
        riskLevel: 3, timeCostMinutes: 30, requiredSkills: {SkillType.survival: 2},
        repDelta: {Faction.guild: 1},
        outcomeSuccess: 'Entre las rocas encontrás a un marinero aferrado a un mástil. Lo sacás del agua y lo dejás junto a un fuego. Te dice el nombre del barco, que mañana todo Ostia querrá saber.',
        outcomePartial: 'Encontrás al marinero, pero el mar te da un revolcón al sacarlo. Los dos llegan a la arena tosiendo, vivos y agradecidos cada uno a su dios.',
        outcomeFail: 'Te metés entre las rocas y no encontrás a nadie, solo un perro del barco que te sigue moviendo la cola. Ahora tenés un perro. No era el plan.',
      ),
    ],
  ),

  // ─── Barcaza de las Paludes ───
  RealEventConfig(
    id: 'evt_pontine_barge',
    category: EventCategory.river,
    title: 'Barcaza de las Paludes',
    description: 'En las Paludes Pontinas, la Appia corre junto a un canal. Una barcaza tirada por mula cruza de noche. El barquero está borracho y los mosquitos, sobrios y con hambre.',
    options: [
      RealOptionConfig(
        id: 'opt_barge_ride', text: 'Subís a la barcaza y aguantás',
        riskLevel: 1, timeCostMinutes: 90, requiredSkills: {},
        outcomeSuccess: 'La barcaza se desliza en la oscuridad mientras las ranas cantan y los mosquitos cenan. Al amanecer estás del otro lado de las Paludes, picado pero descansado.',
        outcomePartial: 'El barquero se duerme a mitad de camino y la mula se para a comer. Perdés una hora larga quieto en el canal, peleando contra los mosquitos con el manto.',
        outcomeFail: 'El barquero ata la mula y se va a dormir a la orilla. Al alba, un pasajero le tira un balde de agua y por fin arrancan. Llegás picado hasta en los párpados.',
      ),
      RealOptionConfig(
        id: 'opt_barge_walk', text: 'Seguís a pie por la calzada',
        riskLevel: 3, timeCostMinutes: 0, requiredSkills: {SkillType.survival: 1},
        outcomeSuccess: 'Caminás de noche por la Appia, sobre la piedra seca, con el canal a un costado. Los mosquitos te siguen, pero no te alcanzan. Llegás antes que la barcaza.',
        outcomePartial: 'La calzada está bien, pero la niebla del pantano sube y tenés que ir más despacio. Llegás al alba, con los huesos húmedos.',
        outcomeFail: 'Te desviás por un tramo de calzada hundida y terminás con barro hasta las rodillas. La barcaza te pasa con el barquero cantando.',
      ),
      RealOptionConfig(
        id: 'opt_barge_drive', text: 'Tomás vos las riendas de la mula',
        riskLevel: 2, timeCostMinutes: 30, requiredSkills: {SkillType.contacts: 1},
        journalNote: 'Crucé las Paludes llevando yo la mula de la barcaza. El barquero roncaba y los pasajeros me pagaron el vino.',
        outcomeSuccess: 'Convencés al barquero de que descanse y tomás las riendas. La mula, contenta con alguien sobrio, trota. Los pasajeros te aplauden en la orilla y te invitan una copa.',
        outcomePartial: 'La mula tira bien, pero en cada curva quiere comer. Avanzás a tirones y con los pasajeros dando consejos que nadie pidió.',
        outcomeFail: 'La mula no te reconoce como autoridad y se sienta. El barquero se despierta, ofendido, y retoma las riendas con lentitud vengativa.',
      ),
    ],
  ),
];
