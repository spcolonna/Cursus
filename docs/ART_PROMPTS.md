# Ilustraciones de Cursus: prompts y dónde va cada archivo

> **Para generar con Gemini usá [GEMINI_ASSETS.md](GEMINI_ASSETS.md):** es la especificación completa y vigente de cada pieza. Este archivo queda como referencia de estilo.

Estilo: **fresco pompeyano en siluetas planas por capas**, la misma paleta que el juego (ver `lib/presentation/theme/sky.dart` y `art_palette.dart`). El juego ya se ve completo sin ninguna ilustración: todo tiene un dibujo por código de respaldo. Cada pieza que se agrega reemplaza a ese dibujo en un solo lugar, sin tocar código.

## 1. Cómo se enchufa una ilustración

1. Generar la imagen con el prompt de la pieza más el **estilo base** (sección 2).
2. Exportarla con el tamaño y el formato de la tabla.
3. Guardarla con el nombre exacto en su carpeta.
4. Correr de nuevo la app (`flutter run`; un hot reload no alcanza para assets nuevos).

`ArtCatalog` lee el manifiesto de assets al arrancar. Si el archivo está, se usa; si no, se dibuja el respaldo. No hace falta registrar nada ni tocar `pubspec.yaml`: las carpetas ya están declaradas.

| Pieza | Carpeta y nombre | Tamaño | Formato | Respaldo por código |
|---|---|---|---|---|
| Escenario por categoría | `assets/art/scenes/<categoría>.jpg` | 1080×1920 (9:16) | JPG, calidad 82 | `EventScene` |
| Evento puntual (opcional) | `assets/art/events/<id del evento>.jpg` | 1080×1920 (9:16) | JPG, calidad 82 | El escenario de su categoría |
| Capítulo de historia | `assets/art/story/<id del capítulo>.jpg` | 1680×720 (21:9, se ve como franja) | JPG, calidad 82 | `EventScene` del primer evento |
| Final de arco | `assets/art/endings/<id del final>.jpg` | 1080×1350 | JPG, calidad 82 | Nada (no ocupa lugar) |
| Retrato de NPC | `assets/art/npcs/<id del NPC>.jpg` | 768×768 | JPG | La inicial en un medallón |

**Orden de búsqueda de un evento:** primero su ilustración propia, después la de su escenario y al final el escenario pintado. Con los 10 escenarios ya se cubren todos los eventos.

**Peso:** un JPG de 1080×1350 a calidad 82 pesa unos 250 KB. Las 37 ilustraciones de juego (sin retratos) suman unos 9 MB; los 12 retratos, unos 4 MB más.

## 2. Estilo base (va pegado al principio de cada prompt)

```
Pompeian fresco painting, flat layered silhouettes, matte mineral pigments
on lime plaster with a subtle plaster texture and faint hairline cracks.
Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre
#D9A441, cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72,
Tyrian purple #6B3E6E (sparingly), olive land #6E7F4E, cypress green
#2C4231, ink brown-black #231A16. Ancient Rome, 50 BC, historically
grounded: tunics, togas, paenula travel cloaks, petasos hats, paved Roman
roads, umbrella pines and cypresses, no medieval elements, no castles, no
stirrups. Simple bold shapes, two-tone shading at most, thin ink-brown
contour lines on figures and buildings, distant layers fade toward the
horizon color. Quiet, slightly mysterious mood, adult storybook, not grim.
No text, no letters, no logos, no watermark, no frame.
```

**La hora del cielo.** El juego pinta el cielo según la hora real. Cuando una pieza tenga cielo, elegí uno de los cuatro y sumá su línea (son los mismos colores que `SkyKeyframe`):

| Hora | Línea para el prompt |
|---|---|
| Alba | `Dawn sky: pale blue #9DB7D5 at the top, peach #E9C3B0, apricot horizon #F6C9A6, violet-grey land #5B5470.` |
| Día | `Day sky: soft cerulean #8EC3D6, sea-glass #BFD9D6, warm cream horizon #F4E3B5, olive land #6E7F4E.` |
| Atardecer | `Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E, plum land #3A2230.` |
| Noche | `Night sky: indigo #0F1024, deep blue #1B2147, Egyptian blue glow on the horizon #2F5D9E, near-black land #0A0B18, a few stars.` |

**Para escenarios, eventos, capítulos y finales**, sumar:

```
Vertical composition 4:5. The sky and the main subject sit in the upper
40% of the image. The lower 60% is calm and simple (ground, road, water,
plain wall) because the game places a paper card over it. Keep a quiet
band about 10% tall at the very top for the status bar.
```

**Para retratos**, sumar:

```
Portrait bust, three-quarter view, head and shoulders, centered, looking
slightly toward the viewer, like a Fayum portrait painted on a fresco
wall. Plain flat wall background in a single pigment (ochre, Pompeian red,
pale Egyptian blue or lime white), with a thin darker band at the bottom.
Square 1:1, the face fills about 40% of the frame.
```

**Qué evitar:** fotorrealismo, 3D, anime, fantasía medieval, armaduras de placas, escudos con heráldica, banderas con texto, cascos con cuernos, degradés brillantes tipo videojuego, neón y el viejo look navy y dorado. El dorado metálico tampoco: el oro se pinta como ocre.

## 3. Key art (1)

| Archivo | Prompt |
|---|---|
| `assets/images/key_art.jpg` (para la tienda y el splash; no se usa en código todavía) | A lone Roman messenger in a cinnabar paenula cloak and a wide-brimmed petasos hat runs along a paved Roman road at dusk, a sealed scroll case strapped across the chest, a red wax seal on it. Rome in flat layers on the horizon: hills, a domed temple and an aqueduct. Umbrella pines and cypresses line the road. Dusk sky line. |

## 4. Escenarios por categoría (10)

Estos cubren todos los eventos. Conviene hacerlos primero.

| Archivo | Prompt |
|---|---|
| `scenes/road.jpg` | An empty paved Roman road winding through rolling hills toward the horizon, a stone milestone at the side, tall cypress trees, late afternoon light. |
| `scenes/patrol.jpg` | A Roman legion checkpoint on a road: a wooden barrier painted red, two legionaries with red shields and a vexillum banner, torches lit, travellers waiting in line. |
| `scenes/river.jpg` | A three-arched Roman stone bridge over a slow river, reeds on the bank, a ferry rope, mist on the water, hills behind. |
| `scenes/storm.jpg` | A Roman road under a violent storm, heavy diagonal rain, bent cypress trees, a flash of lightning over the hills, puddles reflecting the sky. |
| `scenes/bandits.jpg` | A narrow road through a dark forest, large rocks, the faint glow of a campfire between the trees, shadowy figures watching, tense atmosphere. |
| `scenes/temple.jpg` | The front of a Roman temple on a high podium with wide steps and six columns, incense smoke rising, a priest's silhouette at the door, warm ochre evening light. |
| `scenes/forum.jpg` | The Roman Forum: a basilica with arches, a bronze statue on a pedestal, market stalls, crowds in togas, terracotta roofs. |
| `scenes/inn.jpg` | A roadside Roman inn (caupona) with two floors, terracotta roof tiles, a hanging wooden sign, warm lit windows, a mule tied by the door. |
| `scenes/port.jpg` | The port of Ostia: a Roman merchant ship with a square sail at a wooden pier, a lighthouse, amphorae stacked on the dock, calm sea. |
| `scenes/subura.jpg` | A cramped alley in the Subura: tall insulae apartment blocks, laundry hanging between windows, a single torch, puddles on the cobbles, night. |

## 5. Capítulos del arco de Claudius (9)

| Archivo | Prompt |
|---|---|
| `story/claudius_1.jpg` | A slave in patrician livery hands a folded unsigned note to a young Roman messenger in the Forum at dawn, looking over the shoulder. In the background, the gate of a rich villa on a hill. |
| `story/claudius_2.jpg` | A messenger climbs the steps of the Temple of Saturn at dusk holding a letter with two wax seals. A priest waits half hidden behind a column. |
| `story/claudius_3.jpg` | Close view of a thick scroll sealed three times with red wax, held tightly in a messenger's hands by candlelight, a scribe's desk with tablets behind. |
| `story/claudius_4_varus.jpg` | Night in Rome: a messenger runs across rooftops toward a lit senator's villa, the city dark below, distant torches of patrols. |
| `story/claudius_4_claudius.jpg` | The Basilica Aemilia at night, a messenger carries a heavy leather case of documents past armed men in dark cloaks. |
| `story/claudius_4_underworld.jpg` | A smoky tavern with no sign in the Subura, people bidding around a table, a golden she-wolf brooch on an older woman's black stola. |
| `story/claudius_5_varus.jpg` | A messenger stands calmly before an old senator at the Forum steps in morning light, handing over a formal letter, Varus watching from a distance. |
| `story/claudius_5_claudius.jpg` | A messenger in a senator's livery walks up to the Curia, the Senate house, in bright daylight, crowds parting. |
| `story/claudius_5_underworld.jpg` | Two identical sealed letters on a tavern table, a knife between them, two senators' villas visible through the window on opposite hills. |

## 6. Finales (3)

| Archivo | Prompt |
|---|---|
| `endings/end_varus.jpg` | An old courier master and a young messenger share a quiet cup of wine in a modest post house at night, a map of Roman roads on the wall. Earned trust. |
| `endings/end_claudius.jpg` | A young messenger in fine patrician livery stands on the steps of a marble villa overlooking Rome, the senator's hand on the shoulder. Ambition, warm ochre light. |
| `endings/end_underworld.jpg` | A messenger counting coins in the shadows of the Subura, a ledger of secrets open on the table, a golden wolf brooch glinting. Dangerous freedom. |

## 6b. Arco de Lucius: capítulos (11) y finales (3)

| Archivo | Prompt |
|---|---|
| `story/lucius_1_varus.jpg`, `story/lucius_1_claudius.jpg`, `story/lucius_1_underworld.jpg` | A bald innkeeper with thick forearms and a leather apron leans on the counter of a warm Roman tavern, the Ox, talking low to a young messenger. A trapdoor to the cellar in the floor, wine jars on shelves. (Las tres entradas pueden usar la misma imagen.) |
| `story/lucius_2.jpg` | A frightened young deserter with a scar on his hand hides behind barrels in a tavern cellar, lit by a single oil lamp, while legionaries' shadows pass on the street above through a grate. |
| `story/lucius_3.jpg` | A messenger opens a thick ledger on a table in a roadside inn at Aricia at night: long lists of names by candlelight, the Via Appia visible through the window. |
| `story/lucius_4_family.jpg` | A small Roman inn at Forum Appii at dusk, neighbors with clubs and torches guarding the door, a woman with a stern face at the threshold. |
| `story/lucius_4_legion.jpg` | A half century of legionaries marching on the Via Appia toward a column of black smoke rising from a burning inn, a centurion with a transverse crest at the front. |
| `story/lucius_4_book.jpg` | Four hooded men block a road through a dark forest, a messenger clutching a ledger strapped to the chest. |
| `story/lucius_5_family.jpg` | A dozen innkeepers around the big table of a closed tavern at night, cups raised, a ledger burning in the hearth. |
| `story/lucius_5_legion.jpg` | At the Porta Capena at dawn, a young soldier in a fresh tunic of the Tenth Legion swears an oath beside a messenger, a centurion holding a standard with a bull. |
| `story/lucius_5_book.jpg` | The back table of a candlelit Subura tavern, four buyers in rich cloaks around a ledger, an older woman with a gold she-wolf brooch presiding. |
| `endings/end_lucius_family.jpg` | The Ox tavern with a new post-house sign over the door, travelers' mules tied outside, warm light, the innkeeper waving. Belonging. |
| `endings/end_lucius_legion.jpg` | A messenger riding along the Via Appia with a bronze bull plaque on the chest, legion milestones and a camp in the distance. Duty. |
| `endings/end_lucius_book.jpg` | A messenger in a dark alley of the Subura unfolding a hand-drawn smuggler's map, coins on the table, a she-wolf brooch glinting. Secrets as currency. |

## 6c. Arco de la Decimotercera: finales (3)

Los capítulos (`story/legion_*.jpg`) son opcionales; los finales valen la pena.

| Archivo | Prompt |
|---|---|
| `endings/end_legion_caesar.jpg` | A messenger wading a narrow muddy river at night with orders held above the head, a legion waiting without torches on the bank behind, a general watching the water. Fate. |
| `endings/end_legion_senate.jpg` | A dusty messenger standing alone in the middle of the Curia, hundreds of senators in white togas shouting from the benches, an older senator with a purple stripe nodding. A voice. |
| `endings/end_legion_guild.jpg` | A plain table in a courier post house at dawn, two enemies in military cloaks at each end, an old courier master signing last, a sealed leather satchel in the middle. Neutrality. |

## 7. Retratos (13)

Cada prompt arranca con el estilo base más el bloque de retrato. La descripción física sale de `look` en [`lib/data/npc_content.dart`](../lib/data/npc_content.dart): si un personaje cambia en la historia, se cambia ahí y se regenera.

| Archivo | Personaje | Descripción (de `look`) |
|---|---|---|
| `npcs/varus.jpg` | Varus, jefe de la casa de postas | man in his fifties, broad shoulders, close-cropped grey hair, old scar across the chin, plain dark wool tunic, ink-stained fingers |
| `npcs/decimo.jpg` | Décimo, escriba del Gremio | thin young man, narrow face, tired eyes, wax tablet under the arm, stylus behind the ear, faded blue tunic |
| `npcs/marco.jpg` | Marco, mensajero de la casa | wiry man in his twenties, cocky half smile, sunburnt, curly black hair, travel cloak thrown over one shoulder |
| `npcs/sexto.jpg` | Sexto, centurión de la Puerta Capena | stern centurion in his forties, transverse red crest on the helmet, chain mail, vine staff, heavy jaw, broken nose |
| `npcs/fulvia.jpg` | Fulvia, matrona del Palatino | patrician woman in her forties, elaborate braided hair with pins, deep violet palla, gold earrings, measuring gaze |
| `npcs/rufo.jpg` | Rufo, barquero del Muelle Viejo | heavy-set boatman, red beard, missing tooth, rope coiled on the shoulder, wet linen tunic, lantern light |
| `npcs/atia.jpg` | Atia, sacerdotisa de Mercurio | young priestess, calm face, white veil over dark hair, small caduceus pendant, incense smoke |
| `npcs/cornelia.jpg` | Cornelia, viuda de un mensajero | woman in her thirties, mourning grey stola, sharp eyes, a messenger's bronze badge as a necklace |
| `npcs/claudius.jpg` | Claudius, senador | senator in his sixties, toga with broad purple stripe, thin smile, heavy signet ring, receding white hair |
| `npcs/lucius.jpg` | Lucius, tabernero del Buey | innkeeper in his fifties, bald, thick forearms, leather apron, suspicious squint, clay cup in hand |
| `npcs/petro.jpg` | Petro, senador rival | plump senator, rosy cheeks, rings on every finger, laurel-patterned toga border, politician smile |
| `npcs/viuda.jpg` | la Viuda, dueña de La Loba Dorada | older woman, silver hair in a severe bun, black stola, gold she-wolf brooch, candlelit tavern behind |
| `npcs/aufidio.jpg` | Aufidio, centurión de la Decimotercera | weathered centurion in his late forties, grey stubble, Gallic campaign scars on the forearms, phalerae on a leather harness, vine staff, tired honest eyes |

## 8. Eventos puntuales (opcional)

Solo valen la pena para los eventos de historia, que el jugador ve una sola vez y recuerda. El nombre es el id del evento: por ejemplo, `events/s3_broken_seal.jpg` para "La carta que quema". Los ids están en [`lib/data/story_content.dart`](../lib/data/story_content.dart), en `storyEventPool`. El prompt sale de la descripción del evento, con el estilo base.

## 9. Control de calidad antes de sumar una pieza

- [ ] Sin texto ni letras en la imagen.
- [ ] Nada medieval: ni castillos, ni armaduras de placas, ni estribos.
- [ ] Solo colores de la paleta del estilo base; nada de navy ni de dorado metálico.
- [ ] El 60% inferior es calmo. Para verificarlo, probar la pantalla de evento en el simulador: la card de papel tapa esa parte y el cielo de arriba se tiene que ver.
- [ ] Si tiene cielo, coincide con una de las cuatro horas (no mezclar atardecer con sombras de mediodía).
- [ ] El retrato se lee a 48 px (el tamaño del medallón en el Gremio).

## 10. Piezas de tienda y marca

No las usa el código: son para App Store, Google Play y redes. Van en `assets/store/` (fuera del bundle; no se declaran en `pubspec.yaml`).

| Archivo | Tamaño | Prompt o contenido |
|---|---|---|
| `store/icon_painted.png` | 1024×1024, PNG sin transparencia | Ícono alternativo pintado: `A round cinnabar wax seal stamped with a Roman letter V, slightly irregular edge, lying on lime plaster, soft top-left light, fresco texture, centered, fills 70% of the frame.` El ícono oficial sigue siendo el de código (`tool/gen_icon_test.dart`); este es para probar en un A/B de tienda. |
| `store/key_art_iphone.jpg` | 1290×2796 | El key art de la sección 3, recompuesto vertical: el mensajero en el tercio de abajo, el cielo arriba y lugar libre en el tercio superior para el logo, que se agrega después en diseño (no en el prompt). |
| `store/key_art_ipad.jpg` | 2048×2732 | Igual que el anterior, más aire a los costados. |
| `store/feature_graphic.jpg` | 1024×500 | `Wide panoramic fresco of the Roman countryside at dusk: a paved road crossing the frame from left to right, a small running messenger in a cinnabar cloak at the left third, Rome in flat layers on the right horizon, umbrella pines.` La mitad derecha queda calma para el logo. |

**Capturas de tienda (6).**
- **Marco:** banda de cal arriba con el texto en Marcellus color tinta; la captura del simulador va debajo, con borde de tinta de 2 px.
- **Textos y orden:** en [STORE_LISTING.md](STORE_LISTING.md), en español neutro e inglés. Se capturan en los dos idiomas (Ajustes → Idioma).
- **Tamaños:** 1320×2868 o 1290×2796 (iPhone 6,9"), y 1080×1920 (Android).
- **Cielos:** capturar con `debugSkyHour` fijo (Ajustes, solo debug) para que cada una tenga un cielo distinto.

## 11. Generar con ChatGPT

ChatGPT genera en 1024×1024, 1024×1536 (vertical) o 1536×1024 (horizontal). El recorte y el tamaño final los pone `tool/process_art.py`.

**Sesión con estilo fijo:**
1. Abrí una conversación nueva por tanda de piezas: escenarios, retratos o finales.
2. El primer mensaje es el **estilo base** (sección 2) con esta línea al final: `Keep exactly this style for every image in this conversation. Reply only with the image.`
3. Después, un mensaje por pieza con su prompt. Si una pieza se aleja del estilo, respondé `Same style as the first image: flatter shapes, only the palette colors, no gradients.`

**Formato por pieza:**

| Pieza | Pedir en ChatGPT | Comando |
|---|---|---|
| Escenario, evento, capítulo, final | vertical 1024×1536, con lo importante en el 40% de arriba | `python3 tool/process_art.py img.png scene road` (tipos `scene`, `event`, `story`, `ending` + id) |
| Retrato de NPC | cuadrado 1024×1024, cara centrada | `python3 tool/process_art.py img.png npc varus --focus 0.3` |
| Feature graphic | horizontal 1536×1024 | `python3 tool/process_art.py img.png feature` |
| Key art | vertical 1024×1536 (después se reencuadra) | `key_iphone` / `key_ipad` |

**Personajes consistentes:**
1. Generá primero el retrato.
2. En las escenas donde aparece, subí ese retrato como referencia, con `Use the attached portrait as the reference for this character's face, hair and clothes.`

Varus, Lucius, Claudius y Aufidio necesitan el mismo rostro en todas las piezas.

**Entrega:** pasame las imágenes (o dejalas en una carpeta) con el nombre de la pieza. Yo corro el script, controlo contraste y scrim en el simulador (§9) y las integro. Si preferís hacerlo vos, el script deja cada archivo en su lugar y con su nombre; después alcanza con `flutter run`.

**Música:** ChatGPT no genera audio usable. Los cues, el motivo y los formatos están en [AUDIO.md](AUDIO.md). Opciones: Suno o Udio (en plan pago, por la licencia comercial) o una librería CC0. Cada archivo reemplaza al placeholder con el mismo nombre en `assets/audio/`, sin tocar código.
