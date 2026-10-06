# Ilustraciones: prompts y dónde va cada archivo

El juego ya se ve completo sin ninguna ilustración: todo tiene un dibujo por código de respaldo. Cada pieza que se agrega reemplaza a ese dibujo en un solo lugar, sin tocar código.

## 1. Cómo se enchufa una ilustración

1. Generar la imagen con el prompt de la pieza más el **estilo base** (sección 2).
2. Exportarla con el tamaño y el formato de la tabla.
3. Guardarla con el nombre exacto en su carpeta.
4. Correr de nuevo la app (`flutter run`; un hot reload no alcanza para assets nuevos).

`ArtCatalog` lee el manifiesto de assets al arrancar. Si el archivo está, se usa; si no, se dibuja el respaldo. No hace falta registrar nada ni tocar `pubspec.yaml`: las carpetas ya están declaradas.

| Pieza | Carpeta y nombre | Tamaño | Formato | Respaldo por código |
|---|---|---|---|---|
| Escenario por categoría | `assets/art/scenes/<categoría>.jpg` | 1080×1350 | JPG, calidad 82 | `EventScene` |
| Evento puntual (opcional) | `assets/art/events/<id del evento>.jpg` | 1080×1350 | JPG, calidad 82 | El escenario de su categoría |
| Capítulo de historia | `assets/art/story/<id del capítulo>.jpg` | 1080×1350 | JPG, calidad 82 | `EventScene` del primer evento |
| Final de arco | `assets/art/endings/<id del final>.jpg` | 1080×1350 | JPG, calidad 82 | Nada (no ocupa lugar) |
| Retrato de NPC | `assets/art/npcs/<id del NPC>.png` | 768×768 | PNG | La inicial en un medallón |

**Orden de búsqueda de un evento:** primero su ilustración propia, después la de su escenario y al final el escenario pintado. Con los 10 escenarios ya se cubren todos los eventos.

**Peso:** un JPG de 1080×1350 a calidad 82 pesa unos 250 KB. Las 35 piezas suman unos 8 MB.

## 2. Estilo base (va pegado al principio de cada prompt)

```
Flat gouache illustration with visible brush texture, limited palette:
deep navy blue (#0A1628, #142040), warm gold (#FFCC00, #CC9900),
parchment cream (#F7EFDC), terracotta (#A0522D) and muted olive.
Ancient Rome, 50 BC, historically grounded: togas, paenula travel cloaks,
petasos hats, Roman roads with paving stones, no medieval elements,
no castles, no stirrups. Bold simple shapes, soft rim light, gentle
painterly shading in two tones, thick dark outlines on main figures.
Calm, slightly mysterious mood, storybook adventure, not grim.
No text, no letters, no logos, no watermark, no frame.
```

**Para escenarios, eventos, capítulos y finales**, sumar:

```
Vertical composition 4:5. The main subject sits in the upper 60% of the
image. The lower third is darker and simple (ground, shadow, water) because
the game's interface is placed over it.
```

**Para retratos**, sumar:

```
Portrait bust, three-quarter view, head and shoulders, centered, looking
slightly toward the viewer. Plain dark navy background with a soft warm
glow behind the head. Square 1:1, the face fills about 40% of the frame.
```

**Qué evitar:** fotorrealismo, 3D, anime, estética de fantasía medieval, armaduras de placas, escudos con heráldica, banderas con texto, cascos con cuernos y colores saturados de neón.

## 3. Key art (1)

| Archivo | Prompt |
|---|---|
| `assets/images/key_art.jpg` (para la tienda y el splash; no se usa en código todavía) | A lone Roman messenger in a red paenula cloak and a wide-brimmed petasos hat runs along a paved Roman road at dusk, a sealed scroll case strapped across the chest. Rome's hills, temples and an aqueduct glow gold in the distance. Cypress trees line the road. Dramatic but warm sky. |

## 4. Escenarios por categoría (10)

Estos cubren todos los eventos. Conviene hacerlos primero.

| Archivo | Prompt |
|---|---|
| `scenes/road.jpg` | An empty paved Roman road winding through rolling hills toward the horizon, a stone milestone at the side, tall cypress trees, late afternoon light. |
| `scenes/patrol.jpg` | A Roman legion checkpoint on a road: a wooden barrier painted red, two legionaries with red shields and a vexillum banner, torches lit, travellers waiting in line. |
| `scenes/river.jpg` | A three-arched Roman stone bridge over a slow river, reeds on the bank, a ferry rope, mist on the water, hills behind. |
| `scenes/storm.jpg` | A Roman road under a violent storm, heavy diagonal rain, bent cypress trees, a flash of lightning over the hills, puddles reflecting the sky. |
| `scenes/bandits.jpg` | A narrow road through a dark forest, large rocks, the faint glow of a campfire between the trees, shadowy figures watching, tense atmosphere. |
| `scenes/temple.jpg` | The front of a Roman temple on a high podium with wide steps and six columns, incense smoke rising, a priest's silhouette at the door, golden evening light. |
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
| `endings/end_claudius.jpg` | A young messenger in fine patrician livery stands on the steps of a marble villa overlooking Rome, the senator's hand on the shoulder. Ambition, gold light. |
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

## 7. Retratos (12)

Cada prompt arranca con el estilo base más el bloque de retrato. La descripción física sale de `look` en [`lib/data/npc_content.dart`](../lib/data/npc_content.dart): si un personaje cambia en la historia, se cambia ahí y se regenera.

| Archivo | Personaje | Descripción (de `look`) |
|---|---|---|
| `npcs/varus.png` | Varus, jefe de la casa de postas | man in his fifties, broad shoulders, close-cropped grey hair, old scar across the chin, plain dark wool tunic, ink-stained fingers |
| `npcs/decimo.png` | Décimo, escriba del Gremio | thin young man, narrow face, tired eyes, wax tablet under the arm, stylus behind the ear, faded blue tunic |
| `npcs/marco.png` | Marco, mensajero de la casa | wiry man in his twenties, cocky half smile, sunburnt, curly black hair, travel cloak thrown over one shoulder |
| `npcs/sexto.png` | Sexto, centurión de la Puerta Capena | stern centurion in his forties, transverse red crest on the helmet, chain mail, vine staff, heavy jaw, broken nose |
| `npcs/fulvia.png` | Fulvia, matrona del Palatino | patrician woman in her forties, elaborate braided hair with pins, deep violet palla, gold earrings, measuring gaze |
| `npcs/rufo.png` | Rufo, barquero del Muelle Viejo | heavy-set boatman, red beard, missing tooth, rope coiled on the shoulder, wet linen tunic, lantern light |
| `npcs/atia.png` | Atia, sacerdotisa de Mercurio | young priestess, calm face, white veil over dark hair, small caduceus pendant, incense smoke |
| `npcs/cornelia.png` | Cornelia, viuda de un mensajero | woman in her thirties, mourning grey stola, sharp eyes, a messenger's bronze badge as a necklace |
| `npcs/claudius.png` | Claudius, senador | senator in his sixties, toga with broad purple stripe, thin smile, heavy signet ring, receding white hair |
| `npcs/lucius.png` | Lucius, tabernero del Buey | innkeeper in his fifties, bald, thick forearms, leather apron, suspicious squint, clay cup in hand |
| `npcs/petro.png` | Petro, senador rival | plump senator, rosy cheeks, rings on every finger, laurel-patterned toga border, politician smile |
| `npcs/viuda.png` | la Viuda, dueña de La Loba Dorada | older woman, silver hair in a severe bun, black stola, gold she-wolf brooch, candlelit tavern behind |

## 8. Eventos puntuales (opcional)

Solo valen la pena para los eventos de historia, que el jugador ve una sola vez y recuerda. El nombre es el id del evento: por ejemplo, `events/s3_broken_seal.jpg` para "La carta que quema". Los ids están en [`lib/data/story_content.dart`](../lib/data/story_content.dart), en `storyEventPool`. El prompt sale de la descripción del evento, con el estilo base.

## 9. Control de calidad antes de sumar una pieza

- [ ] Sin texto ni letras en la imagen.
- [ ] Nada medieval: ni castillos, ni armaduras de placas, ni estribos.
- [ ] El tercio inferior es oscuro y simple. Para verificarlo, probar la pantalla de evento en el simulador: el título y las opciones se tienen que leer.
- [ ] Los colores cálidos no compiten con el oro de los botones.
- [ ] El retrato se lee a 48 px (el tamaño del medallón en el Gremio).
