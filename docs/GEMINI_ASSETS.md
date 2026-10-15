# CURSUS — Complete image asset specification (for Gemini)

> **To the image model reading this:** this document is your complete brief. Generate the images it requests, **one image per asset**, exactly as specified. Do not invent extra assets, do not merge assets, do not add text to images. When you return an image, label it with its **exact PATH** (for example `assets/art/scenes/road.jpg`) so it can be saved in the right place. If the user asks for "the next batch", continue in the order of section 7.

---

## 0. What the game is (context for every image)

**Cursus** is a narrative mobile game set in **Rome and Italy, 50 BC**, the year before Julius Caesar crosses the Rubicon. The player is a **civilian messenger** working for a courier guild run by an old man called **Varus**. Gameplay is choosing between 2–3 options in short text events ("a patrol blocks the road", "a storm on the Apennines"). The tone is **quiet, dry, slightly mysterious, adult storybook — never grim, never gory, never heroic-epic**.

The images are **illustrations behind the text** and **portraits of recurring characters**. They must look like they belong to one single painted world.

---

## 1. Global output rules (apply to EVERY image)

1. **One image per asset entry.** Never put two assets in one image. Never make a collage, a grid, a diptych or a "before/after".
2. **No text of any kind inside the image:** no letters, no numbers, no Latin inscriptions, no signs with writing, no captions, no titles, no logos, no watermark, no signature, no UI, no speech bubbles. Scrolls and letters are shown **sealed or as blank/illegible marks**, never with readable writing.
3. **Full art, full bleed:** the painting fills 100% of the canvas edge to edge. **No border, no frame, no white margin, no rounded corners, no vignette, no drop shadow, no paper edge, no canvas/photo-of-a-wall effect.** It is a digital illustration in a fresco style, **not a photograph of a fresco on a wall**.
4. **Background:** every asset is **OPAQUE, with a painted background. No transparency, no alpha channel, no cut-out, no checkerboard, no green screen.** (Portraits have a plain painted wall behind the figure, see §5.4.)
5. **Aspect ratio:** generate at the **"Generate at" aspect ratio** of each entry (only these are used: 9:16, 21:9, 4:5, 1:1, 16:9). Use the highest resolution you can. The final pixel size is listed as "Final size"; it will be resized and cropped afterwards, so **respect the composition safe zones** described for each type.
6. **File format:** PNG or high-quality JPG is fine. Name the file with the last part of its PATH (e.g. `road.jpg` → file `road.jpg` or `road.png`).
7. **Consistency:** all images share the style of §2. When a recurring character appears, he/she must match the canonical description in §4 **and** the portrait already generated for that character (see §6).
8. **Historical accuracy:** Late Roman Republic, 50 BC. See the forbidden list in §2.6.
9. **No modern elements**, no fantasy creatures, no magic glows, no gore, no nudity, no blood splatter.

---

## 2. Style bible

### 2.1 Medium and look
**Digital illustration imitating a Pompeian fresco**, in **flat layered silhouettes**:
- Shapes are simple and bold, built in **3 to 5 depth layers**: foreground, midground, background, horizon, sky. Each layer is a mostly flat area of color.
- **Two-tone shading at most** per shape (one base tone + one darker tone). No soft airbrush gradients on objects. The sky may have a gentle gradient.
- **Thin ink-brown contour lines** (#231A16, about 2–3 px at final size) on figures, buildings and important objects. Landscape layers far away have no outlines.
- **Matte mineral pigments on lime plaster**: a very subtle plaster grain texture over everything, and at most a few faint hairline cracks. The texture must be **subtle**; the image must not look damaged, old or dirty.
- **Distant layers fade toward the horizon color** (atmospheric perspective by flattening and lightening, not by blur).
- Figures are stylized but naturally proportioned (about 7 heads tall), with **simple faces**: almond eyes, straight Roman noses, small mouths, like figures in Roman wall paintings or Fayum portraits. Not cartoonish, not anime, not chibi, not realistic photography.
- Lighting: one clear light direction per image; shadows are flat shapes in the darker tone.

### 2.2 Strict palette (use only these colors and their mixes with white or ink)

| Name | Hex | Typical use |
|---|---|---|
| Lime white | #F2E8D5 | highlights, walls, togas |
| Warm parchment | #E6D8BE | light ground, plaster, linen |
| Yellow ochre | #D9A441 | warm light, gold (gold is ALWAYS painted as ochre, never metallic) |
| Cinnabar red | #A8322D | the messenger's cloak, wax seals, legion shields, accents |
| Egyptian blue | #2F5D9E | water, night, cool shadows, some fabrics |
| Verdigris | #3F7F72 | bronze, sea, some fabrics |
| Tyrian purple | #6B3E6E | senators' stripes, secrets — **sparingly** |
| Olive land | #6E7F4E | fields, hills |
| Cypress green | #2C4231 | cypresses, umbrella pines, dark foliage |
| Ink brown-black | #231A16 | outlines, deepest shadows |

No other dominant colors. **Forbidden colors:** navy blue + shiny gold combinations, neon, saturated pure primaries, pastel candy colors, metallic gold, chrome.

### 2.3 Composition principles
- Clear silhouette readability: the main subject must be recognizable at small size.
- Calm negative space where text or UI will sit (each type in §5 says where).
- Low horizon or high horizon chosen per type; never tilted horizons.
- No lens effects (no bokeh, no lens flare, no chromatic aberration, no motion blur, no depth-of-field blur).

### 2.4 Mood
Quiet, slightly mysterious, warm even at night. Adult storybook. Danger is suggested, never shown graphically. Faces are restrained; no screaming, no exaggerated expressions.

### 2.5 Period details to use
Tunics, togas (only for citizens in formal settings; senators have a broad Tyrian-purple stripe), paenula hooded travel cloaks, petasos wide-brimmed hats, caligae and sandals, Roman legionaries of the late Republic (chain mail *lorica hamata*, oval or curved-oval red shields **without heraldic emblems**, Montefortino bronze helmets, centurions with a **transverse** red crest and a vine staff), paved Roman roads with large polygonal stones and milestones, aqueducts, umbrella pines and cypresses, insulae apartment blocks, terracotta roof tiles, amphorae, oil lamps, wax tablets, scrolls in leather cases, red wax seals.

### 2.6 Forbidden (never draw these)
Medieval elements, castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets, stirrups on saddles, crossbows, banners with letters, crosses or Christian symbols, gunpowder, glass windows with panes, modern clothes, eyeglasses, paper books with bound pages (use scrolls, wax tablets or a ledger of stacked tablets/codex of wooden leaves), fantasy creatures, dragons, magic, glowing runes, Greek-key borders around the image, any text.

---

## 3. Sky and time of day

Each scene has a fixed time of day. When an entry says a time, **use exactly this sky line**:

| Time | Sky description |
|---|---|
| DAWN | Pale blue #9DB7D5 at the top, peach #E9C3B0 in the middle, apricot horizon #F6C9A6; violet-grey distant land #5B5470; long soft shadows. |
| DAY | Soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows. |
| DUSK | Mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows. |
| NIGHT | Indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches. |
| INTERIOR | No sky. Warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre. |

---

## 4. Recurring characters — canonical descriptions

Whenever one of these appears, **copy the description exactly**. Their **portrait** (section 7.B) is the visual reference: once generated, every later image with that character must match the portrait's face, hair, age and clothes.

### 4.0 THE MESSENGER (the player) — special rule
The player chooses their messenger (man or woman, different looks), so **the messenger must never have a defined face or gender**:
- Always shown **from behind, in profile under a hood, in silhouette, or small in the distance**. Face hidden or in shadow.
- Canonical outfit: **cinnabar-red (#A8322D) hooded paenula travel cloak**, plain parchment tunic underneath, **wide-brimmed straw petasos hat** (worn or hanging on the back), **leather shoulder satchel/scroll case** with a **red wax seal** on its flap, sturdy sandals.
- Build: slim, medium height, ambiguous. Never armor, never weapons in hand (a small knife at the belt is OK).

### 4.1 Characters
| ID | Name | Role | Canonical description |
|---|---|---|---|
| varus | Varus | master of the courier post house (the Guild) | man in his fifties, broad shoulders, close-cropped grey hair, old scar across the chin, plain dark wool tunic (dark brown/ink), ink-stained fingers; stern but paternal |
| decimo | Décimo | the Guild's scribe | thin young man, narrow face, tired eyes, wax tablet under the arm, stylus behind the ear, faded Egyptian-blue tunic |
| marco | Marco | a messenger of the house | wiry man in his twenties, cocky half smile, sunburnt, curly black hair, travel cloak (ochre) thrown over one shoulder, worn sandals |
| sexto | Sexto | centurion of the Porta Capena gate (Tenth Legion) | stern centurion in his forties, bronze helmet with a **transverse** red crest, chain mail, vine staff, heavy jaw, broken nose, red military cloak |
| fulvia | Fulvia | patrician matron of a Palatine villa | woman in her forties, elaborate braided hair with pins, deep violet (Tyrian purple) palla, gold earrings painted in ochre, measuring gaze |
| rufo | Rufo | boatman of the Old Dock (Ostia) | heavy-set boatman, red beard, missing tooth, rope coiled on the shoulder, wet linen tunic, lantern light on the face |
| atia | Atia | priestess of the temple of Mercury | young priestess, calm face, white veil over dark hair, small caduceus pendant, thin incense smoke drifting |
| cornelia | Cornelia | widow of a messenger | woman in her thirties, mourning grey stola, sharp eyes, a messenger's small bronze badge worn as a necklace |
| claudius | Claudius | senator | senator in his sixties, white toga with a broad Tyrian-purple stripe, thin smile, heavy signet ring, receding white hair, cold courteous manner |
| lucius | Lucius | innkeeper of the Ox tavern | innkeeper in his fifties, bald, thick forearms, leather apron over an ochre tunic, suspicious squint, clay cup in hand |
| petro | Petro | rival senator of Claudius | plump senator, rosy cheeks, rings on every finger (painted ochre), white toga with a laurel-patterned border, politician smile |
| viuda | the Widow | owner of the Golden She-Wolf tavern (underworld boss) | older woman, silver hair in a severe bun, black stola, ochre-gold she-wolf brooch on the chest; calm, dangerous |
| aufidio | Aufidio | centurion of the Thirteenth Legion | weathered centurion in his late forties, grey stubble, old campaign scars on the forearms, phalerae (round medal discs) on a leather harness over chain mail, vine staff, tired honest eyes |

Secondary unnamed figures (legionaries, crowds, priests, senators, innkeepers) have simple generic faces and must **never** look like the recurring characters.

---

## 5. Asset types — composition templates

### 5.1 SCENE (event background) — `assets/art/scenes/*.jpg`
- **Generate at 9:16 (vertical). Final size 1080×1920.** Opaque, full art, no transparency.
- Used as the **full-screen background of the phone** behind an event. A paper text card covers the **lower ~60%** of the screen, and the top status bar covers the **top ~6%**.
- **Safe zones:**
  - Top 0–6%: sky only, nothing important.
  - **6%–38%: the place and its focal element (the readable part of the image).**
  - 38%–55%: transition, simpler shapes.
  - 55%–100%: calm, low-detail ground (road surface, water, plain floor, plain wall), no characters, no important objects, no high contrast.
- **No main characters and no faces** (the event text tells the story). Tiny distant silhouettes are OK. The messenger is NOT in scenes.
- The image may be cropped a little on the left/right on some phones: keep the focal element in the central 70% horizontally.

### 5.2 CHAPTER BANNER — `assets/art/story/*.jpg`
- **Generate at 21:9 (wide horizontal). Final size 1680×720.** Opaque, full art.
- Shown as a **wide strip (about 2.7:1)** on top of a story card, with rounded corners, so the top and bottom ~8% may be cropped.
- **Safe zone:** all important content inside the **central 85% horizontally and the central 75% vertically**. No important detail touching the edges.
- It is a **cinematic establishing shot** of the chapter: a place, a moment, one or two figures at most. Figures medium-small, readable as silhouettes. Recurring characters are recognizable by clothing and silhouette (see §4); the messenger follows §4.0.

### 5.3 ENDING — `assets/art/endings/*.jpg`
- **Generate at 4:5 (vertical). Final size 1080×1350.** Opaque, full art.
- Shown whole (with rounded corners) on the result screen when the player reaches an ending of a story arc. It is **the reward image**: the most beautiful and emotional pieces of the game.
- **Safe zone:** keep a 4% margin free of important details on all sides. Composition can use the whole frame; this is a complete painting.
- One clear emotional idea per ending (written in the entry).

### 5.4 PORTRAIT (recurring character) — `assets/art/npcs/*.png`
- **Generate at 1:1 (square). Final size 768×768.** Opaque. **NOT transparent**: the background is a **plain flat painted wall in a single pigment** (given per character) with a slightly darker thin band at the very bottom.
- The game shows the portrait **cropped to a circle** at very small size (**48×48 px**) and sometimes larger. Therefore:
  - **Head and shoulders bust, three-quarter view, looking slightly toward the viewer**, like a Fayum mummy portrait painted in fresco style.
  - **The face must be large: the head (chin to top of hair) occupies about 50% of the image height**; eyes at about 42% from the top; the head centered horizontally.
  - **Everything important inside the central circle of 90% diameter** (the corners will be cut off).
  - Simple, readable silhouette; strong value contrast between face and background; no busy background, no scenery, no other people, no hands covering the face.
- One defining prop per character, visible within the circle (wax tablet, vine staff, brooch...), as described.

### 5.5 STORE GRAPHIC — `assets/store/*.jpg`
- Described in its entry (feature graphic for Google Play).

---

## 6. Generation order and references (important for consistency)

1. **First generate `assets/art/scenes/road.jpg`. It is the STYLE MASTER.** Every later image must match its style, palette, line weight and texture. If you are in a new conversation, the user will attach it: use it as the style reference.
2. Then generate **the 13 portraits** (section 7.B). Each portrait becomes the **CHARACTER REFERENCE** for that character.
3. Then the other scenes, then chapters, then endings, then the store graphic.
4. **When an entry lists "References: …", use those previously generated images** (from this conversation or attached by the user) to keep the style and the character identical.

---

## 7. Asset list (61 images, 63 file paths)

Format of each entry:
- **PATH:** where the file goes (return the image labeled with this path).
- **Type:** scene / chapter / ending / portrait / store (composition template from §5).
- **Generate at / Final size.**
- **Background:** opaque full art (always; portraits have a plain wall).
- **Time:** sky line from §3.
- **Characters:** who appears (copy their §4 description).
- **References:** images to match.
- **Description:** what to paint.
- **Must include / Must avoid.**

---

### 7.A SCENES — event backgrounds (10)

These cover every road event of the game. **No characters with faces; no messenger.**

#### A1 — Road (STYLE MASTER)
- **PATH:** `assets/art/scenes/road.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** DAY (late afternoon light from the left)
- **Characters:** none.
- **References:** none (this image defines the style).
- **Description:** An empty paved Roman road (large polygonal grey-ochre stones with a raised edge) winding from the lower center toward the horizon through rolling olive hills. In the upper third: a stone milestone (a short cylindrical column, no inscription) at the right side of the road, two tall cypresses and one umbrella pine on the left, hills fading in flat layers to the cream horizon. The lower half is the calm wide road surface and plain grass at the edges.
- **Must include:** milestone without writing, cypresses, umbrella pine, paved road.
- **Must avoid:** people, carts, text on the milestone, dramatic clouds.

#### A2 — Patrol
- **PATH:** `assets/art/scenes/patrol.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** DUSK
- **Characters:** two small generic legionaries in the distance (no recurring characters).
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** A Roman legion checkpoint across a paved road: a wooden barrier painted cinnabar red on two trestles, two small legionaries with red curved-oval shields (no emblems) and Montefortino helmets standing beside it, a lit torch on a pole, a small wooden guard hut. All of this in the upper third. Behind: hills and a dusk sky. Lower half: the empty road coming toward the viewer, calm.
- **Must include:** red barrier, torch, shields without emblems.
- **Must avoid:** banners with letters, eagles with text, faces in detail, crowds in the lower half.

#### A3 — River
- **PATH:** `assets/art/scenes/river.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** DAWN
- **Characters:** none.
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** A three-arched Roman stone bridge crossing a slow river in the upper third, reeds along the bank, a ferry rope stretched across the water to a small flat ferry boat tied at the shore, thin horizontal bands of mist on the water, hills behind in violet-grey. Lower half: calm water surface in Egyptian blue and verdigris with a few flat reflection stripes.
- **Must include:** three-arched bridge, mist bands, ferry rope.
- **Must avoid:** people, boats in the lower half, sparkling water effects.

#### A4 — Storm
- **PATH:** `assets/art/scenes/storm.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** DAY darkened by storm (use DAY palette shifted to grey-blue; heavy dark Egyptian-blue clouds)
- **Characters:** none.
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** A Roman road on the Apennine hills under a violent storm: heavy diagonal rain drawn as thin straight lines, cypresses bent by the wind, a single forked lightning bolt (drawn as a flat ochre-white shape) over the distant hills in the upper third. Lower half: the wet road with flat puddle shapes reflecting the grey sky, calm and simple.
- **Must include:** diagonal rain lines, bent cypresses, one lightning bolt.
- **Must avoid:** realistic photo rain, splash particles, people.

#### A5 — Bandits
- **PATH:** `assets/art/scenes/bandits.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** NIGHT
- **Characters:** three or four tiny dark human silhouettes half hidden among trees (no faces, no weapons raised).
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** A narrow dirt road entering a dark forest of oaks and pines. In the upper third, between the trunks, the faint ochre glow of a campfire and a few shadowy silhouettes watching from behind large rocks. Tense but quiet. Lower half: the dark empty road and flat dark grass.
- **Must include:** campfire glow between trees, large rocks, watching silhouettes.
- **Must avoid:** fighting, blood, visible weapons pointed at the viewer, glowing eyes, monsters.

#### A6 — Temple
- **PATH:** `assets/art/scenes/temple.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** DUSK
- **Characters:** one tiny silhouette of a veiled priest at the temple door (no face detail).
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** The front of a Roman temple on a high podium, with a wide flight of steps and six Ionic columns supporting a triangular pediment (plain, no inscription), warm ochre dusk light on the columns, thin incense smoke rising from a bronze tripod at the top of the steps, a tiny priest silhouette in the dark doorway. All in the upper 40%. Lower half: the wide plain stone pavement of the square, calm.
- **Must include:** six columns, high podium with steps, incense tripod.
- **Must avoid:** Greek letters or Latin inscription on the pediment, gods' statues with glowing effects, crowds.

#### A7 — Forum
- **PATH:** `assets/art/scenes/forum.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** DAY
- **Characters:** small generic crowd figures in tunics and togas in the mid distance (no detailed faces).
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** The Roman Forum in daylight: a two-story basilica with arches on one side, a bronze (verdigris) equestrian statue on a tall pedestal, the steps of a temple, terracotta roofs and the Capitoline hill behind, a few market awnings in ochre and cinnabar, small crowds walking. All in the upper 40%. Lower half: the large plain paved square, empty and calm.
- **Must include:** basilica arches, statue on pedestal, terracotta roofs.
- **Must avoid:** inscriptions, the Colosseum (it does not exist yet), Christian churches, people in the lower half.

#### A8 — Inn
- **PATH:** `assets/art/scenes/inn.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** DUSK going to night (warm lamplight in windows)
- **Characters:** none (a mule is fine).
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** A roadside Roman inn (caupona) with two floors, plastered walls in parchment, terracotta roof tiles, a wooden balcony, a hanging wooden sign with **a painted ox head symbol (no letters)**, warm ochre light in two small windows, a mule tied to a ring by the door, a stone water trough. In the upper 40%. Lower half: the dirt yard in front, calm and plain.
- **Must include:** hanging sign with ox symbol only, lit windows, mule.
- **Must avoid:** written signs, glass windows, medieval timber framing.

#### A9 — Port
- **PATH:** `assets/art/scenes/port.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** DAY
- **Characters:** a few tiny dock workers in the distance.
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** The port of Ostia: a Roman merchant ship with a single square sail (plain ochre, no emblem) moored at a wooden pier, a stone lighthouse tower on a breakwater in the distance, amphorae stacked on the dock, a crane made of wooden beams, calm sea. In the upper 40%. Lower half: calm flat sea water in verdigris and Egyptian blue.
- **Must include:** square-sail merchant ship, lighthouse, amphorae.
- **Must avoid:** lateen/triangular sails, cannons, flags with symbols or letters.

#### A10 — Subura (city slum alley)
- **PATH:** `assets/art/scenes/subura.jpg`
- **Type:** scene · **Generate at:** 9:16 · **Final size:** 1080×1920 · **Background:** opaque full art · **Time:** NIGHT
- **Characters:** none (maybe one tiny distant cloaked silhouette).
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** A narrow cramped alley in the Subura district of Rome: tall insulae apartment blocks of brick and plaster leaning toward each other, laundry hanging on ropes between windows, a single torch in an iron holder on the wall casting warm ochre light, wooden shutters, a strip of night sky between the roofs. In the upper 40%. Lower half: dark wet cobbles with flat reflections, empty and calm.
- **Must include:** tall insulae, hanging laundry, one wall torch.
- **Must avoid:** neon, glass windows, modern street lamps, graffiti with letters.

---

### 7.B PORTRAITS — recurring characters (13)

Common to all portraits: **Type portrait, Generate at 1:1, Final size 768×768, Background: plain flat painted wall (color given) with a slightly darker thin band at the bottom, opaque, NO transparency. Head and shoulders, three-quarter view, head ≈50% of image height, eyes at ≈42% from top, everything important inside the central 90% circle. References: `assets/art/scenes/road.jpg` (style).** Expression restrained.

#### B1 — Varus
- **PATH:** `assets/art/npcs/varus.png`
- **Wall color:** yellow ochre #D9A441.
- **Description:** man in his fifties, broad shoulders, close-cropped grey hair, an old pale scar across the chin, plain dark brown wool tunic, ink stains on the fingers of one hand visible at the bottom edge holding the edge of a scroll. Stern, paternal, tired eyes.
- **Must avoid:** toga, armor, smile, beard.

#### B2 — Décimo
- **PATH:** `assets/art/npcs/decimo.png`
- **Wall color:** warm parchment #E6D8BE.
- **Description:** thin young man (about 20), narrow face, tired eyes with shadows, a wax tablet held against the chest, a stylus tucked behind the ear, faded Egyptian-blue tunic.
- **Must avoid:** paper book, quill pen, glasses.

#### B3 — Marco
- **PATH:** `assets/art/npcs/marco.png`
- **Wall color:** yellow ochre #D9A441.
- **Description:** wiry man in his twenties, cocky half smile, sunburnt skin, curly black hair, an ochre travel cloak thrown over one shoulder, simple tunic.
- **Must avoid:** red cloak (red is the player's color), armor.

#### B4 — Sexto
- **PATH:** `assets/art/npcs/sexto.png`
- **Wall color:** Pompeian red #C4544A (light enough to contrast with the helmet).
- **Description:** stern centurion in his forties, bronze Montefortino helmet with a **transverse** (side-to-side) red horsehair crest, chain mail, red military cloak on the shoulders, heavy jaw, broken nose, the top of a vine staff visible at the side.
- **Must avoid:** front-to-back crest, plate armor, eagle emblems.

#### B5 — Fulvia
- **PATH:** `assets/art/npcs/fulvia.png`
- **Wall color:** pale Egyptian blue #9DB7D5.
- **Description:** patrician woman in her forties, elaborate braided hair pinned up with ochre-gold pins, deep Tyrian-purple palla draped over the shoulders, ochre-gold earrings, a measuring, slightly skeptical gaze.
- **Must avoid:** crown, tiara, modern makeup.

#### B6 — Rufo
- **PATH:** `assets/art/npcs/rufo.png`
- **Wall color:** deep verdigris #3F7F72.
- **Description:** heavy-set boatman, bushy red beard, one missing front tooth in a rough grin, coiled rope over the shoulder, wet off-white linen tunic, warm ochre lantern light from below on the face.
- **Must avoid:** pirate hat, eye patch, parrot.

#### B7 — Atia
- **PATH:** `assets/art/npcs/atia.png`
- **Wall color:** lime white #F2E8D5 with faint thin incense smoke curls.
- **Description:** young priestess (early twenties), calm serene face, white veil over dark hair, a small bronze caduceus pendant (staff with two snakes) on the chest.
- **Must avoid:** halo, glowing magic, nun-like Christian habit.

#### B8 — Cornelia
- **PATH:** `assets/art/npcs/cornelia.png`
- **Wall color:** warm parchment #E6D8BE.
- **Description:** woman in her thirties, mourning grey stola, hair tied back simply, sharp attentive eyes, a small round bronze messenger's badge hanging on a cord as a necklace.
- **Must avoid:** black veil over the face, tears.

#### B9 — Claudius
- **PATH:** `assets/art/npcs/claudius.png`
- **Wall color:** pale Egyptian blue #9DB7D5.
- **Description:** senator in his sixties, white toga with a broad Tyrian-purple stripe, receding white hair, thin cold courteous smile, a heavy signet ring on a hand raised near the chest.
- **Must avoid:** laurel crown, emperor look, beard.

#### B10 — Lucius
- **PATH:** `assets/art/npcs/lucius.png`
- **Wall color:** Pompeian red #C4544A.
- **Description:** innkeeper in his fifties, completely bald, thick forearms, leather apron over an ochre tunic, suspicious squint, a clay cup in one hand near the chest.
- **Must avoid:** beer mug, medieval tavern look, beard.

#### B11 — Petro
- **PATH:** `assets/art/npcs/petro.png`
- **Wall color:** pale Egyptian blue #9DB7D5.
- **Description:** plump senator, rosy round cheeks, rings on every finger (ochre), white toga with a laurel-leaf patterned border in ochre, a broad politician smile.
- **Must avoid:** looking like Claudius (Petro is plump, dark-haired with a little grey, cheerful; Claudius is thin, white-haired, cold).

#### B12 — The Widow
- **PATH:** `assets/art/npcs/viuda.png`
- **Wall color:** deep verdigris #3F7F72 darkened, with a faint warm candle glow on one side.
- **Description:** older woman (around sixty), silver hair in a severe bun, black stola, an ochre-gold brooch shaped like a she-wolf on the chest, calm dangerous eyes.
- **Must avoid:** witch look, pointed hat, jewelry overload.

#### B13 — Aufidio
- **PATH:** `assets/art/npcs/aufidio.png`
- **Wall color:** Pompeian red #C4544A.
- **Description:** weathered centurion in his late forties, grey stubble, old scars on the forearms, round bronze phalerae medals on a leather harness over chain mail, holding a vine staff, no helmet, short grey hair, tired honest eyes.
- **Must avoid:** looking like Sexto (Aufidio is bareheaded, older, thinner, kinder).

---

### 7.C CHAPTER BANNERS — story chapters (30 paths, 28 images)

Common to all: **Type chapter, Generate at 21:9, Final size 1680×720, Background opaque full art, important content inside the central 85% × 75%. References: `assets/art/scenes/road.jpg` (style) + the portraits of the characters listed.** The messenger always follows §4.0 (cinnabar hooded cloak, face hidden).

#### Arc 1 — "The Shadow of the Senate" (Claudius)

##### C1 — Claudius I: The job outside the network
- **PATH:** `assets/art/story/claudius_1.jpg`
- **Time:** DAWN · **Characters:** the messenger (§4.0); a slave in patrician livery (generic, Tyrian-purple trimmed tunic).
- **Description:** In a corner of the Roman Forum at dawn, a slave in patrician livery discreetly hands a folded, unsigned, sealed note to the messenger, glancing over his shoulder. In the background on a hill, the gate of a rich villa catches the first light.
- **Must avoid:** readable writing on the note.

##### C2 — Claudius II: The price of curiosity
- **PATH:** `assets/art/story/claudius_2.jpg`
- **Time:** DUSK · **Characters:** the messenger; a fig seller (generic) watching; a priest half hidden.
- **Description:** The messenger climbs the steps of the Temple of Saturn at dusk holding a letter sealed with two black wax seals; a priest waits half hidden behind a column; at the bottom of the steps a fig seller with a basket watches the messenger a little too long.

##### C3 — Claudius III: The burning letter
- **PATH:** `assets/art/story/claudius_3.jpg`
- **Time:** INTERIOR / NIGHT · **Characters:** the messenger (only hands and cloak visible).
- **Description:** Close view: a thick scroll sealed three times with cinnabar wax, held tightly in the messenger's hands (cinnabar cloak sleeves) by the light of an oil lamp; behind, a scribe's desk with wax tablets, an inkpot and a brazier with glowing coals (a hint that the letter might have to be burned).
- **Must avoid:** readable writing.

##### C4 — Claudius IV (Varus path): The night of knives
- **PATH:** `assets/art/story/claudius_4_varus.jpg`
- **Time:** NIGHT · **Characters:** the messenger running (small).
- **Description:** Night in Rome: the messenger runs across terracotta rooftops toward a senator's villa with lit windows on a hill; the dark city below with tiny torches of patrols in the streets.

##### C5 — Claudius IV (Claudius path): The night of knives
- **PATH:** `assets/art/story/claudius_4_claudius.jpg`
- **Time:** NIGHT · **Characters:** the messenger; two or three armed men in dark cloaks (generic).
- **Description:** In front of the arched Basilica Aemilia at night, the messenger carries a heavy sealed leather document tube under the arm, walking past armed men in dark cloaks standing in the torchlight.

##### C6 — Claudius IV (Underworld path): The night of knives
- **PATH:** `assets/art/story/claudius_4_underworld.jpg`
- **Time:** INTERIOR (smoky tavern) · **Characters:** the Widow (§4, viuda) seated; generic bidders; the messenger seen from behind.
- **References add:** `assets/art/npcs/viuda.png`.
- **Description:** A smoky tavern with no sign in the Subura: around a back table lit by oil lamps, shadowy figures bid in low voices; the Widow presides, the ochre she-wolf brooch on her black stola catching the light; the messenger stands in the foreground, from behind.

##### C7 — Claudius V (Varus path): Varus's man
- **PATH:** `assets/art/story/claudius_5_varus.jpg`
- **Time:** DAY (morning) · **Characters:** the messenger; Claudius (§4) on the Forum steps; Petro is NOT shown; Varus (§4) watching from a distance.
- **References add:** `assets/art/npcs/claudius.png`, `assets/art/npcs/varus.png`.
- **Description:** On the steps of the Forum in morning light, the messenger calmly hands a formal sealed letter to Claudius, who reads it with a cold face; far behind, near a column, Varus watches with arms crossed.

##### C8 — Claudius V (Claudius path): The Senator's protégé
- **PATH:** `assets/art/story/claudius_5_claudius.jpg`
- **Time:** DAY · **Characters:** the messenger wearing a fine livery over the cinnabar cloak (Tyrian-purple trim); a parting crowd.
- **Description:** The messenger walks up the steps of the Curia (the Senate house: a tall plain brick building with a bronze door) in bright daylight, crowds parting to let them pass, scribes waiting at the door.

##### C9 — Claudius V (Underworld path): The one who knows too much
- **PATH:** `assets/art/story/claudius_5_underworld.jpg`
- **Time:** INTERIOR looking out to NIGHT · **Characters:** none (or only the messenger's hand).
- **Description:** Two identical sealed letters on a tavern table side by side, a small knife between them, an oil lamp; through a window behind, two lit villas on opposite hills of night-time Rome.

#### Arc 2 — "The Ox Tavern" (Lucius)

##### C10 — Lucius I: An old debt (same image for three paths)
- **PATHS (same image, deliver it once and list the three paths):** `assets/art/story/lucius_1_varus.jpg`, `assets/art/story/lucius_1_claudius.jpg`, `assets/art/story/lucius_1_underworld.jpg`
- **Time:** INTERIOR (warm tavern) · **Characters:** Lucius (§4); the messenger from behind.
- **References add:** `assets/art/npcs/lucius.png`.
- **Description:** Inside the Ox tavern: Lucius, bald with a leather apron, leans on a stone counter with built-in clay jars, talking low to the messenger; shelves of amphorae, a wooden trapdoor to the cellar in the floor, warm lamplight.

##### C11 — Lucius II: Gaius, the deserter
- **PATH:** `assets/art/story/lucius_2.jpg`
- **Time:** INTERIOR (cellar) / NIGHT · **Characters:** Gaius, a frightened young deserter (about 19, dark hair, a scar on the back of one hand, plain tunic, generic face, NOT a recurring character).
- **Description:** In the tavern cellar lit by a single oil lamp, the young deserter hides behind barrels and amphorae; above, through a barred grate in the ceiling, the shadows of passing legionaries' legs on the street.

##### C12 — Lucius III: The list of the Appia
- **PATH:** `assets/art/story/lucius_3.jpg`
- **Time:** NIGHT (interior with window) · **Characters:** the messenger from behind.
- **Description:** In a roadside inn at Aricia at night, the messenger opens a thick ledger made of wooden leaves/wax tablets bound with leather (lines of illegible marks, no readable writing) on a table by candlelight; through the window, the Via Appia under the moon with tombs along its sides.

##### C13 — Lucius IV (Legion path): The Appia burns
- **PATH:** `assets/art/story/lucius_4_legion.jpg`
- **Time:** DUSK · **Characters:** Sexto (§4) at the front; half a century of generic legionaries; the messenger beside them.
- **References add:** `assets/art/npcs/sexto.png`.
- **Description:** On the paved Via Appia, a column of legionaries led by Sexto marches toward a tall column of black smoke rising from a burning roadside inn on the horizon; the messenger walks with them.

##### C14 — Lucius IV (Book path): The Appia burns
- **PATH:** `assets/art/story/lucius_4_book.jpg`
- **Time:** NIGHT · **Characters:** the messenger; four hooded men (generic, faces in shadow).
- **Description:** Four hooded men block a road through a dark forest; the messenger stands facing them, clutching a ledger strapped under the cloak; far away, an orange glow of a burning inn on the horizon.
- **Must avoid:** fighting, blood.

##### C15 — Lucius IV (Family path): The Appia burns
- **PATH:** `assets/art/story/lucius_4_family.jpg`
- **Time:** DUSK · **Characters:** Livia, Lucius's sister (woman in her fifties, grey-streaked hair in a kerchief, stern face, ochre apron — generic, NOT a recurring character); neighbors with clubs and torches.
- **Description:** A small Roman inn at Forum Appii at dusk; neighbors with wooden clubs and torches guard its door; Livia stands at the threshold with a stern face; smoke from another fire far on the horizon.

##### C16 — Lucius V (Legion path): The Ox
- **PATH:** `assets/art/story/lucius_5_legion.jpg`
- **Time:** DAWN · **Characters:** Sexto (§4); Gaius (young soldier, now in a clean tunic of the Tenth Legion); the messenger.
- **References add:** `assets/art/npcs/sexto.png`.
- **Description:** At the Porta Capena gate of Rome at dawn, the young Gaius in a fresh legionary tunic swears an oath with a raised hand beside the messenger; Sexto holds a standard topped with a bronze bull (no letters).

##### C17 — Lucius V (Book path): The Ox
- **PATH:** `assets/art/story/lucius_5_book.jpg`
- **Time:** INTERIOR (candlelit tavern) · **Characters:** the Widow (§4); four rich buyers in fine cloaks (generic); the messenger from behind.
- **References add:** `assets/art/npcs/viuda.png`.
- **Description:** The back table of the Golden She-Wolf tavern in the Subura: four buyers in rich cloaks sit around a closed ledger, the Widow presides at the head of the table, candles, deep shadows.

##### C18 — Lucius V (Family path): The Ox
- **PATH:** `assets/art/story/lucius_5_family.jpg`
- **Time:** INTERIOR / NIGHT · **Characters:** Lucius (§4); about ten generic innkeepers; the messenger at the end of the table.
- **References add:** `assets/art/npcs/lucius.png`.
- **Description:** A dozen innkeepers sit around the big table of the closed Ox tavern at night, clay cups raised together; Lucius at the head; in the hearth behind them, a ledger burns.

#### Arc 3 — "The Eagle of the Thirteenth" (the Legion, the Rubicon)

##### C19 — Legion I (Sexto entry): The satchel from the north
- **PATH:** `assets/art/story/legion_1_sexto.jpg`
- **Time:** DAY (winter, pale cold light) · **Characters:** Sexto (§4); the messenger.
- **References add:** `assets/art/npcs/sexto.png`.
- **Description:** At the Porta Capena gate of Rome in winter, Sexto stops the messenger and hands over a sealed letter; on the messenger's chest a small bronze plaque with a bull; beyond the gate the Via Flaminia heads north toward distant snowy hills.

##### C20 — Legion I (default): The satchel from the north
- **PATH:** `assets/art/story/legion_1.jpg`
- **Time:** INTERIOR (post house, daylight from a window) · **Characters:** Varus (§4); the messenger.
- **References add:** `assets/art/npcs/varus.png`.
- **Description:** In the Guild's post house, Varus places a sealed contract (a tablet with a red seal) on a heavy wooden table in front of the messenger, without smiling; on the wall, a painted map of Roman roads (lines only, no writing); a window shows a cold winter sky.

##### C21 — Legion II: The centurion Aufidio
- **PATH:** `assets/art/story/legion_2.jpg`
- **Time:** DAY (winter, overcast) · **Characters:** the messenger (small, crossing).
- **Description:** The Rubicon: a narrow, muddy, unimpressive river with low banks and bare winter trees; the messenger wades/crosses at a ford carrying a satchel; on the far bank in the distance, the wooden palisade and tents of a legion camp (the Thirteenth at Ravenna).
- **Must avoid:** a big dramatic river; it is small and humble.

##### C22 — Legion III: The letter that crosses the river
- **PATH:** `assets/art/story/legion_3.jpg`
- **Time:** DUSK (winter) · **Characters:** the messenger; two military tribunes (generic officers with plumed helmets) checking travelers.
- **Description:** At the camp gate of a legion fort, two tribunes search civilians leaving toward the south; the messenger waits in line, a sealed letter hidden in the sandal (suggested by the messenger looking down at the foot); the muddy road south leads to the river.

##### C23 — Legion IV (Caesar path): The price of the warning
- **PATH:** `assets/art/story/legion_4_caesar.jpg`
- **Time:** INTERIOR (command tent, lamplight) · **Characters:** a legate (generic senior officer, red cloak, muscled bronze cuirass painted flat); Aufidio (§4) standing apart; the messenger.
- **References add:** `assets/art/npcs/aufidio.png`.
- **Description:** Inside the legate's tent, the messenger hands the legate a sealed letter; in the shadow at the tent entrance, Aufidio watches, understanding what is happening; maps and a lamp on a camp table.
- **Must avoid:** readable maps.

##### C24 — Legion IV (Senate path): The price of the warning
- **PATH:** `assets/art/story/legion_4_senate.jpg`
- **Time:** DAY (winter) · **Characters:** the messenger on a road; two horsemen of the Thirteenth far behind (generic).
- **Description:** On the Via Flaminia heading south toward Rome, the messenger hurries on foot with a satchel; far behind on a hill, two riders in red cloaks are coming (without stirrups).

##### C25 — Legion IV (Guild path): The price of the warning
- **PATH:** `assets/art/story/legion_4_guild.jpg`
- **Time:** DUSK (winter) · **Characters:** the messenger in the middle; one officer of Caesar's side (red cloak) on the left; one agent of Pompey's side (dark blue-grey cloak, civilian) on the right (both generic).
- **Description:** On the road between Ravenna and Ariminum, the messenger stands between two men who both reach for the messenger's sealed leather satchel bearing the Guild's red wax seal; the messenger holds it close.

##### C26 — Legion V (Caesar ending chapter): The night of the river
- **PATH:** `assets/art/story/legion_5_caesar.jpg`
- **Time:** NIGHT · **Characters:** the messenger; rows of legionaries without torches (generic).
- **Description:** At night, the Thirteenth Legion forms up in silence on the bank of the narrow Rubicon, no torches, only starlight; the messenger walks ahead toward the water carrying sealed orders.

##### C27 — Legion V (Senate ending chapter): The voice in the Curia
- **PATH:** `assets/art/story/legion_5_senate.jpg`
- **Time:** DAY · **Characters:** the messenger; Claudius (§4); messengers waiting on the steps (generic).
- **References add:** `assets/art/npcs/claudius.png`.
- **Description:** On the steps of the Curia, Claudius guides the travel-stained messenger past a crowd of senators in white togas who look at the messenger with contempt, toward the open bronze doors.

##### C28 — Legion V (Guild ending chapter): The satchel without a side
- **PATH:** `assets/art/story/legion_5_guild.jpg`
- **Time:** INTERIOR / NIGHT (post house) · **Characters:** Varus (§4) at the head of a table; a tribune of Caesar (red cloak) and an agent of Pompey (blue-grey cloak) at the sides; the messenger arriving with the satchel.
- **References add:** `assets/art/npcs/varus.png`.
- **Description:** In the Guild's post house at night, Varus sits at the head of a plain wooden table with two enemies seated far apart on each side; the messenger enters with the sealed satchel; lamplight, tense silence.

---

### 7.D ENDINGS — arc endings (9)

Common to all: **Type ending, Generate at 4:5, Final size 1080×1350, Background opaque full art, 4% safe margin. References: `assets/art/scenes/road.jpg` (style) + listed portraits.** These are the most emotional, carefully composed images of the game.

#### D1 — End: Varus's man (loyalty)
- **PATH:** `assets/art/endings/end_varus.jpg`
- **Time:** INTERIOR / NIGHT · **Characters:** Varus (§4); the messenger (hood down but face turned away / in shadow).
- **References add:** `assets/art/npcs/varus.png`.
- **Emotion:** earned trust.
- **Description:** In the modest post house at night, Varus and the messenger share a quiet cup of wine at a small table; a painted map of Roman roads (no writing) on the wall behind, a single oil lamp between them.

#### D2 — End: The Senator's protégé (ambition)
- **PATH:** `assets/art/endings/end_claudius.jpg`
- **Time:** DUSK · **Characters:** Claudius (§4); the messenger in fine livery (cinnabar cloak with Tyrian-purple trim), seen from behind.
- **References add:** `assets/art/npcs/claudius.png`.
- **Emotion:** ambition with a price.
- **Description:** On the marble terrace of a villa overlooking Rome at dusk, Claudius rests a hand on the messenger's shoulder as they both look at the city below; warm ochre light, long shadows.

#### D3 — End: The one who knows too much (dangerous freedom)
- **PATH:** `assets/art/endings/end_underworld.jpg`
- **Time:** NIGHT (Subura interior with open door) · **Characters:** the messenger (face in shadow).
- **Emotion:** dangerous freedom.
- **Description:** In the shadows of a Subura tavern, the messenger counts coins (ochre) on a table next to an open ledger of secrets (illegible marks); an ochre she-wolf brooch lies on the table; through the open door, the dark alley.

#### D4 — End: Herald of the Appia (duty)
- **PATH:** `assets/art/endings/end_lucius_legion.jpg`
- **Time:** DAY · **Characters:** the messenger on horseback (seen from behind/side, hood up).
- **Emotion:** duty and protection.
- **Description:** The messenger rides along the Via Appia (no stirrups) with a bronze bull plaque on the chest; legion milestones and a fortified camp in the distance; tombs and umbrella pines along the road.

#### D5 — End: The one who carries the book (secrets as currency)
- **PATH:** `assets/art/endings/end_lucius_book.jpg`
- **Time:** NIGHT · **Characters:** the messenger (face hidden).
- **Emotion:** secrets as currency.
- **Description:** In a dark alley of the Subura, the messenger unfolds a hand-drawn smuggler's map on a barrel top (paths and dots only, no writing), coins and an ochre she-wolf brooch beside it, a single torch above.

#### D6 — End: Guest of the Ox (belonging)
- **PATH:** `assets/art/endings/end_lucius_family.jpg`
- **Time:** DUSK · **Characters:** Lucius (§4) at the door waving; travelers (generic).
- **References add:** `assets/art/npcs/lucius.png`.
- **Emotion:** belonging, home.
- **Description:** The Ox tavern seen from the road at dusk, with a new post-house sign over the door showing a red wax-seal symbol (no letters); travelers' mules tied outside, warm light from the door where Lucius waves.

#### D7 — End: Courier of the Rubicon (fate)
- **PATH:** `assets/art/endings/end_legion_caesar.jpg`
- **Time:** NIGHT going to DAWN at the horizon · **Characters:** the messenger wading; a general on horseback watching the water (generic, red cloak, seen from behind — do NOT draw a recognizable Julius Caesar portrait); the legion waiting.
- **Emotion:** fate, the die is cast.
- **Description:** The messenger wades through the narrow muddy Rubicon at night holding sealed orders above the head; on the bank behind, the legion waits without torches; a general on horseback, alone at the edge, looks at the water; the first pale light at the horizon.

#### D8 — End: Voice of the Curia (a voice)
- **PATH:** `assets/art/endings/end_legion_senate.jpg`
- **Time:** INTERIOR (the Curia, daylight from high windows) · **Characters:** the messenger standing alone in the center (dusty cinnabar cloak, from behind); hundreds of senators in white togas on the benches (generic, small); Claudius (§4) nodding on the front bench.
- **References add:** `assets/art/npcs/claudius.png`.
- **Emotion:** a small voice changing history.
- **Description:** Inside the Senate house, tiered benches full of senators in white togas shout and gesture; in the center of the floor, alone, the travel-stained messenger stands; Claudius, in the front row, nods slightly.

#### D9 — End: The satchel without a side (neutrality)
- **PATH:** `assets/art/endings/end_legion_guild.jpg`
- **Time:** DAWN (window light in an interior) · **Characters:** Varus (§4) signing; two enemies in military cloaks (red and blue-grey) at each end of the table; the messenger standing.
- **References add:** `assets/art/npcs/varus.png`.
- **Emotion:** neutrality as strength.
- **Description:** At a plain table in the post house at dawn, two enemies sit at opposite ends; Varus signs last on a wax tablet; in the middle of the table lies a sealed leather satchel with the Guild's red wax seal; pale dawn light through the window.

---

### 7.E STORE (1)

#### E1 — Google Play feature graphic
- **PATH:** `assets/store/feature_graphic.jpg`
- **Type:** store · **Generate at:** 16:9 · **Final size:** 1024×500 (it will be cropped top and bottom to about 2:1 — keep everything important in the central 70% vertically) · **Background:** opaque full art · **Time:** DUSK
- **Characters:** the messenger (§4.0), small, running.
- **References:** `assets/art/scenes/road.jpg` (style).
- **Description:** A wide panoramic view of the Roman countryside at dusk: a paved road crosses the frame from left to right; the messenger in the cinnabar hooded cloak runs on the road in the **left third**; Rome in flat layers on the right horizon (hills, a domed temple, an aqueduct); umbrella pines along the road. **The right half must stay calm and simple** (sky and soft hills) because the game logo will be placed there later.
- **Must avoid:** any text or logo (it will be added later).

---

## 8. Final checklist for every image (verify before returning it)

- [ ] Exactly one asset, labeled with its exact PATH.
- [ ] Generated at the requested aspect ratio.
- [ ] Full bleed, opaque, no border, no frame, no vignette, no transparency.
- [ ] **No text, letters or numbers anywhere**, including signs, scrolls, maps and seals.
- [ ] Palette of §2.2 only; gold painted as ochre; no navy-and-gold look.
- [ ] Flat layered fresco style matching the style master (`assets/art/scenes/road.jpg`).
- [ ] Recurring characters match §4 and their portraits; the messenger's face is never shown.
- [ ] Safe zones of its type respected (scenes: focal in 6–38% height, calm lower half; chapters: central 85%×75%; portraits: face large inside the central circle).
- [ ] Nothing from the forbidden list (§2.6): no medieval, no stirrups, no heraldry, no modern objects.
