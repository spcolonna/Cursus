# Prompts para ChatGPT, uno por imagen

Prompts para generar las ilustraciones de Via Imperia con **ChatGPT**. Están en inglés porque así sigue mejor las
instrucciones. Qué pieza va en qué lugar, y por qué, está en [GEMINI_ASSETS.md](GEMINI_ASSETS.md), la especificación
de referencia. Este archivo sale de esa especificación: si cambia una pieza allá, se cambia acá.

**Cómo usarlos:**
- **Un prompt = una imagen = una conversación nueva.** Copiá el bloque gris entero y pegalo; arranca a generar sin
  preguntar. (Por bloques de varias imágenes ChatGPT salteaba o mezclaba piezas.)
- Cada prompt es autosuficiente: repite formato, estilo, personajes y qué no incluir, así sale consistente aunque lo
  corras en otra cuenta.
- **Adjuntos:** cada prompt dice qué imágenes ya integradas adjuntar. `road` es la referencia de estilo de todo el
  juego y los retratos son la referencia de cada personaje. Los originales ya no están en `assets/art_raw/`: usá los
  JPG de `assets/art/scenes/`, `assets/art/npcs/` y `assets/store/`.
- Guardá el PNG en `assets/art_raw/<nombre>.png` y pedile a Claude que lo integre, o corré el comando de esa imagen
  desde `messenger_app/`: `tool/process_art.py` recorta a la proporción final, escala, comprime y deja el archivo con
  el nombre que busca el juego.
- Si se aleja del estilo, respondé en la misma conversación: `Same style as the attached road scene: flatter shapes,
  only the palette colors, no gradients.`

**Tamaños:** ChatGPT genera en 1024×1536, 1536×1024 o 1024×1024. Cada prompt pide uno de esos y deja libre de
detalles la parte que después se recorta (portada a 9:19,5, escenarios a 9:16, capítulos a franja 21:9, finales a
4:5, gráfico de la tienda a 2:1).

---

# Estado

| Qué | Carpeta final | Imágenes | Faltan |
|---|---|---|---|
| **Portada** | `assets/art/title/` | 1 | **1** |
| Capítulos, Arco 3 «El águila de la Decimotercera» | `assets/art/story/` | 10 | **1** (`legion_1`) |
| Escenarios de eventos | `assets/art/scenes/` | 10 | 0 |
| Retratos | `assets/art/npcs/` | 13 | 0 |
| Capítulos, Arco 1 «La sombra del Senado» | `assets/art/story/` | 9 | 0 |
| Capítulos, Arco 2 «La taberna del Buey» | `assets/art/story/` | 9 | 0 |
| Finales de arco + gráfico de Google Play | `assets/art/endings/`, `assets/store/` | 10 | 0 |

Total: 62 imágenes, 60 integradas al 2026-11-02. **Faltan 2**, y son las primeras de este archivo. La del capítulo
`lucius_1` se usa en sus tres caminos. Los retratos se guardan como JPG (fondo opaco, 10 veces más livianos que PNG).

---

# Pendientes, por prioridad

## 1. Portada — `title` (PRIORIDAD)

Es la primera imagen del juego: ocupa toda la pantalla de bienvenida, detrás del sello, el título y el botón
**Empezar**. Mientras no exista, el juego usa `road` con un paneo lento. Vale la pena correr el prompt 4 o 5 veces, cada una en una
conversación nueva, y quedarse con la mejor: tiene que verse como el póster del juego.

**Adjuntá:** `road` (estilo) y el gráfico de Google Play `assets/store/feature_graphic.jpg` (el mensajero y Roma
al atardecer: es el tono buscado, pero en vertical).

Guardala como `assets/art_raw/title.png` y pedile a Claude que la integre, o corré:

```bash
python3 tool/process_art.py assets/art_raw/title.png title
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The TITLE SCREEN key art of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is the first thing a new player sees, full screen on a phone, so it must feel like a beautiful film poster: atmospheric, inviting, with a strong sense of journey. It will be cropped on the left and right to a 9:19.5 phone screen (only the central 70% of the width is guaranteed visible), and the game darkens the lower 45% to place the logo and a button over it.

SUBJECT: The messenger, seen from behind and slightly from the side, stands on a hilltop at the edge of a paved Roman road, small-to-medium in the frame (about one fifth of the image height), looking out over a vast valley toward Rome in the far distance at dusk. The cinnabar-red cloak moves gently in the wind; a sealed scroll case in a leather satchel. Below and beyond: the road winds down through umbrella pines and cypresses into the valley, crossing an arched aqueduct, toward the city on its hills (domed temple, terracotta roofs, tiny warm lamp lights starting to glow). A low sun sits near the horizon; a few birds; long warm light. Must include: the messenger from behind, the winding road, an aqueduct, Rome far away, umbrella pines, cypresses, dusk sun.

COMPOSITION: Vertical, deep, with a strong diagonal of the road leading the eye from the messenger to the city. The messenger stands in the band between 22% and 48% of the height, slightly left or right of center, inside the central 60% of the width. The city and the sun sit around 30–40% of the height. The top 10% is only sky (the phone status bar goes there). The lower 45% is the dark foreground hillside and the beginning of the road: simple, low-detail shapes in deep olive, cypress green and ink, with no figures and no important objects (a logo and a button go there). Generous negative space in the sky.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E, plum land #3A2230; the sun is a flat ochre disc; long flat shadows.

CONTINUITY: THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: seen from behind, face hidden. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. No other people except tiny distant silhouettes.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture, and the attached landscape key art for the messenger's look and the dusk mood.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall). One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet wonder, the beginning of a long journey, slightly mysterious, warm; adult storybook. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere; logo, title, watermark or signature (the game adds its own logo); frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, modern objects, fantasy creatures, magic glows, gore, blood; metallic gold, neon, navy-and-gold combinations; the messenger's face; a big wax seal or emblem in the sky.
```

## 2. Capítulo — `legion_1`

Capítulo 1 del arco «El águila de la Decimotercera». ChatGPT la salteó cuando se generaba por bloques.

**Adjuntá:** `road` y el retrato `varus` (los originales ya no están en `assets/art_raw/`: exportalos desde
`assets/art/scenes/road.jpg` y `assets/art/npcs/varus.jpg`).

Guardala como `assets/art_raw/legion_1.png` y pedile a Claude que la integre, o corré:

```bash
python3 tool/process_art.py assets/art_raw/legion_1.png story legion_1
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: In the Guild's post house, Varus places a sealed contract (a tablet with a red seal) on a heavy wooden table in front of the messenger, without smiling; on the wall, a painted map of Roman roads (lines only, no writing); a window shows a cold winter sky.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR (post house, daylight from a window). Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre.

CONTINUITY: People in the image: Varus; the messenger. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. VARUS is a recurring character: man in his fifties, broad shoulders, close-cropped grey hair, old pale scar across the chin, plain dark brown wool tunic, ink-stained fingers; stern but paternal, no beard. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of VARUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

---

# Ya integradas (para regenerar si hace falta)

En el orden en que conviene generarlas desde cero: primero `road` (estilo), después los retratos (referencia de
personajes), después el resto.

## Escenarios de eventos (10)

### road

**Adjuntá:** nada. Es la referencia de estilo de todo el juego: si se aleja del estilo, regenerala antes que cualquier otra. Guardala como `assets/art_raw/road.png`.

```bash
python3 tool/process_art.py assets/art_raw/road.png scene road
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: An empty paved Roman road (large polygonal grey-ochre stones with a raised edge) winding from the lower center toward the horizon through rolling olive hills. In the upper third: a stone milestone (a short cylindrical column, no inscription) at the right side of the road, two tall cypresses and one umbrella pine on the left, hills fading in flat layers to the cream horizon. The lower half is the calm wide road surface and plain grass at the edges. Must include: milestone without writing, cypresses, umbrella pine, paved road.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: DAY (late afternoon light from the left). Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

REFERENCES: none. This image is the STYLE MASTER: every later image of the game will copy its style, palette, line weight and texture, so make it a clean, exemplary example of the style below.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; people, carts, text on the milestone, dramatic clouds.
```

### patrol

**Adjuntá:** `road`. Guardala como `assets/art_raw/patrol.png`.

```bash
python3 tool/process_art.py assets/art_raw/patrol.png scene patrol
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: A Roman legion checkpoint across a paved road: a wooden barrier painted cinnabar red on two trestles, two small legionaries with red curved-oval shields (no emblems) and Montefortino helmets standing beside it, a lit torch on a pole, a small wooden guard hut. All of this in the upper third. Behind: hills and a dusk sky. Lower half: the empty road coming toward the viewer, calm. Must include: red barrier, torch, shields without emblems.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: two small generic legionaries in the distance (no recurring characters). Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; banners with letters, eagles with text, faces in detail, crowds in the lower half.
```

### river

**Adjuntá:** `road`. Guardala como `assets/art_raw/river.png`.

```bash
python3 tool/process_art.py assets/art_raw/river.png scene river
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: A three-arched Roman stone bridge crossing a slow river in the upper third, reeds along the bank, a ferry rope stretched across the water to a small flat ferry boat tied at the shore, thin horizontal bands of mist on the water, hills behind in violet-grey. Lower half: calm water surface in Egyptian blue and verdigris with a few flat reflection stripes. Must include: three-arched bridge, mist bands, ferry rope.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: DAWN. Dawn sky: pale blue #9DB7D5 at the top, peach #E9C3B0 in the middle, apricot horizon #F6C9A6; violet-grey distant land #5B5470; long soft shadows.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; people, boats in the lower half, sparkling water effects.
```

### storm

**Adjuntá:** `road`. Guardala como `assets/art_raw/storm.png`.

```bash
python3 tool/process_art.py assets/art_raw/storm.png scene storm
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: A Roman road on the Apennine hills under a violent storm: heavy diagonal rain drawn as thin straight lines, cypresses bent by the wind, a single forked lightning bolt (drawn as a flat ochre-white shape) over the distant hills in the upper third. Lower half: the wet road with flat puddle shapes reflecting the grey sky, calm and simple. Must include: diagonal rain lines, bent cypresses, one lightning bolt.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: DAY darkened by storm (use DAY palette shifted to grey-blue; heavy dark Egyptian-blue clouds). Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; realistic photo rain, splash particles, people.
```

### bandits

**Adjuntá:** `road`. Guardala como `assets/art_raw/bandits.png`.

```bash
python3 tool/process_art.py assets/art_raw/bandits.png scene bandits
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: A narrow dirt road entering a dark forest of oaks and pines. In the upper third, between the trunks, the faint ochre glow of a campfire and a few shadowy silhouettes watching from behind large rocks. Tense but quiet. Lower half: the dark empty road and flat dark grass. Must include: campfire glow between trees, large rocks, watching silhouettes.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: NIGHT. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: three or four tiny dark human silhouettes half hidden among trees (no faces, no weapons raised). Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; fighting, blood, visible weapons pointed at the viewer, glowing eyes, monsters.
```

### temple

**Adjuntá:** `road`. Guardala como `assets/art_raw/temple.png`.

```bash
python3 tool/process_art.py assets/art_raw/temple.png scene temple
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: The front of a Roman temple on a high podium, with a wide flight of steps and six Ionic columns supporting a triangular pediment (plain, no inscription), warm ochre dusk light on the columns, thin incense smoke rising from a bronze tripod at the top of the steps, a tiny priest silhouette in the dark doorway. All in the upper 40%. Lower half: the wide plain stone pavement of the square, calm. Must include: six columns, high podium with steps, incense tripod.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: one tiny silhouette of a veiled priest at the temple door (no face detail). Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; Greek letters or Latin inscription on the pediment, gods' statues with glowing effects, crowds.
```

### forum

**Adjuntá:** `road`. Guardala como `assets/art_raw/forum.png`.

```bash
python3 tool/process_art.py assets/art_raw/forum.png scene forum
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: The Roman Forum in daylight: a two-story basilica with arches on one side, a bronze (verdigris) equestrian statue on a tall pedestal, the steps of a temple, terracotta roofs and the Capitoline hill behind, a few market awnings in ochre and cinnabar, small crowds walking. All in the upper 40%. Lower half: the large plain paved square, empty and calm. Must include: basilica arches, statue on pedestal, terracotta roofs.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: DAY. Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: small generic crowd figures in tunics and togas in the mid distance (no detailed faces). Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; inscriptions, the Colosseum (it does not exist yet), Christian churches, people in the lower half.
```

### inn

**Adjuntá:** `road`. Guardala como `assets/art_raw/inn.png`.

```bash
python3 tool/process_art.py assets/art_raw/inn.png scene inn
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: A roadside Roman inn (caupona) with two floors, plastered walls in parchment, terracotta roof tiles, a wooden balcony, a hanging wooden sign with a painted ox head symbol (no letters), warm ochre light in two small windows, a mule tied to a ring by the door, a stone water trough. In the upper 40%. Lower half: the dirt yard in front, calm and plain. Must include: hanging sign with ox symbol only, lit windows, mule.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: DUSK going to night (warm lamplight in windows). Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; written signs, glass windows, medieval timber framing.
```

### port

**Adjuntá:** `road`. Guardala como `assets/art_raw/port.png`.

```bash
python3 tool/process_art.py assets/art_raw/port.png scene port
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: The port of Ostia: a Roman merchant ship with a single square sail (plain ochre, no emblem) moored at a wooden pier, a stone lighthouse tower on a breakwater in the distance, amphorae stacked on the dock, a crane made of wooden beams, calm sea. In the upper 40%. Lower half: calm flat sea water in verdigris and Egyptian blue. Must include: square-sail merchant ship, lighthouse, amphorae.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: DAY. Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: a few tiny dock workers in the distance. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; lateen/triangular sails, cannons, flags with symbols or letters.
```

### subura

**Adjuntá:** `road`. Guardala como `assets/art_raw/subura.png`.

```bash
python3 tool/process_art.py assets/art_raw/subura.png scene subura
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The full-screen phone background behind a text event of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped slightly on the left and right to 9:16, and a paper text card covers the lower 60% of the screen.

SUBJECT: A narrow cramped alley in the Subura district of Rome: tall insulae apartment blocks of brick and plaster leaning toward each other, laundry hanging on ropes between windows, a single torch in an iron holder on the wall casting warm ochre light, wooden shutters, a strip of night sky between the roofs. In the upper 40%. Lower half: dark wet cobbles with flat reflections, empty and calm. Must include: tall insulae, hanging laundry, one wall torch.

COMPOSITION: Top 6%: sky only. Between 6% and 38% of the height: the place and its focal element (the readable part). Between 38% and 55%: transition, simpler shapes. Lower 45%: calm, low-detail ground (road surface, water, plain floor), with no characters, no important objects and no high contrast. Keep the focal element in the central 75% horizontally. No main characters and no faces; tiny distant silhouettes are fine. The player's messenger does not appear.

TIME OF DAY: NIGHT. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; neon, glass windows, modern street lamps, graffiti with letters.
```

## Retratos (1 de 2) (7)

### varus

**Adjuntá:** `road`. Guardala como `assets/art_raw/varus.png`.

```bash
python3 tool/process_art.py assets/art_raw/varus.png npc varus
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of VARUS: man in his fifties, broad shoulders, close-cropped grey hair, an old pale scar across the chin, plain dark brown wool tunic, ink stains on the fingers of one hand visible at the bottom edge holding the edge of a scroll. Stern, paternal, tired eyes. Background: a plain flat painted wall in yellow ochre #D9A441, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; toga, armor, smile, beard.
```

### decimo

**Adjuntá:** `road`. Guardala como `assets/art_raw/decimo.png`.

```bash
python3 tool/process_art.py assets/art_raw/decimo.png npc decimo
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of DÉCIMO: thin young man (about 20), narrow face, tired eyes with shadows, a wax tablet held against the chest, a stylus tucked behind the ear, faded Egyptian-blue tunic. Background: a plain flat painted wall in warm parchment #E6D8BE, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; paper book, quill pen, glasses.
```

### marco

**Adjuntá:** `road`. Guardala como `assets/art_raw/marco.png`.

```bash
python3 tool/process_art.py assets/art_raw/marco.png npc marco
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of MARCO: wiry man in his twenties, cocky half smile, sunburnt skin, curly black hair, an ochre travel cloak thrown over one shoulder, simple tunic. Background: a plain flat painted wall in yellow ochre #D9A441, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; red cloak (red is the player's color), armor.
```

### sexto

**Adjuntá:** `road`. Guardala como `assets/art_raw/sexto.png`.

```bash
python3 tool/process_art.py assets/art_raw/sexto.png npc sexto
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of SEXTO: stern centurion in his forties, bronze Montefortino helmet with a transverse (side-to-side) red horsehair crest, chain mail, red military cloak on the shoulders, heavy jaw, broken nose, the top of a vine staff visible at the side. Background: a plain flat painted wall in Pompeian red #C4544A (light enough to contrast with the helmet), with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; front-to-back crest, plate armor, eagle emblems.
```

### fulvia

**Adjuntá:** `road`. Guardala como `assets/art_raw/fulvia.png`.

```bash
python3 tool/process_art.py assets/art_raw/fulvia.png npc fulvia
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of FULVIA: patrician woman in her forties, elaborate braided hair pinned up with ochre-gold pins, deep Tyrian-purple palla draped over the shoulders, ochre-gold earrings, a measuring, slightly skeptical gaze. Background: a plain flat painted wall in pale Egyptian blue #9DB7D5, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; crown, tiara, modern makeup.
```

### rufo

**Adjuntá:** `road`. Guardala como `assets/art_raw/rufo.png`.

```bash
python3 tool/process_art.py assets/art_raw/rufo.png npc rufo
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of RUFO: heavy-set boatman, bushy red beard, one missing front tooth in a rough grin, coiled rope over the shoulder, wet off-white linen tunic, warm ochre lantern light from below on the face. Background: a plain flat painted wall in deep verdigris #3F7F72, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; pirate hat, eye patch, parrot.
```

### atia

**Adjuntá:** `road`. Guardala como `assets/art_raw/atia.png`.

```bash
python3 tool/process_art.py assets/art_raw/atia.png npc atia
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of ATIA: young priestess (early twenties), calm serene face, white veil over dark hair, a small bronze caduceus pendant (staff with two snakes) on the chest. Background: a plain flat painted wall in lime white #F2E8D5 with faint thin incense smoke curls, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; halo, glowing magic, nun-like Christian habit.
```

## Retratos (2 de 2) (6)

### cornelia

**Adjuntá:** `road`. Guardala como `assets/art_raw/cornelia.png`.

```bash
python3 tool/process_art.py assets/art_raw/cornelia.png npc cornelia
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of CORNELIA: woman in her thirties, mourning grey stola, hair tied back simply, sharp attentive eyes, a small round bronze messenger's badge hanging on a cord as a necklace. Background: a plain flat painted wall in warm parchment #E6D8BE, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; black veil over the face, tears.
```

### claudius

**Adjuntá:** `road`. Guardala como `assets/art_raw/claudius.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius.png npc claudius
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of CLAUDIUS: senator in his sixties, white toga with a broad Tyrian-purple stripe, receding white hair, thin cold courteous smile, a heavy signet ring on a hand raised near the chest. Background: a plain flat painted wall in pale Egyptian blue #9DB7D5, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; laurel crown, emperor look, beard.
```

### lucius

**Adjuntá:** `road`. Guardala como `assets/art_raw/lucius.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius.png npc lucius
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of LUCIUS: innkeeper in his fifties, completely bald, thick forearms, leather apron over an ochre tunic, suspicious squint, a clay cup in one hand near the chest. Background: a plain flat painted wall in Pompeian red #C4544A, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; beer mug, medieval tavern look, beard.
```

### petro

**Adjuntá:** `road`. Guardala como `assets/art_raw/petro.png`.

```bash
python3 tool/process_art.py assets/art_raw/petro.png npc petro
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of PETRO: plump senator, rosy round cheeks, rings on every finger (ochre), white toga with a laurel-leaf patterned border in ochre, a broad politician smile. Background: a plain flat painted wall in pale Egyptian blue #9DB7D5, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; looking like Claudius (Petro is plump, dark-haired with a little grey, cheerful; Claudius is thin, white-haired, cold).
```

### viuda

**Adjuntá:** `road`. Guardala como `assets/art_raw/viuda.png`.

```bash
python3 tool/process_art.py assets/art_raw/viuda.png npc viuda
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of THE WIDOW: older woman (around sixty), silver hair in a severe bun, black stola, an ochre-gold brooch shaped like a she-wolf on the chest, calm dangerous eyes. Background: a plain flat painted wall in deep verdigris #3F7F72 darkened, with a faint warm candle glow on one side, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; witch look, pointed hat, jewelry overload.
```

### aufidio

**Adjuntá:** `road`. Guardala como `assets/art_raw/aufidio.png`.

```bash
python3 tool/process_art.py assets/art_raw/aufidio.png npc aufidio
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a SQUARE image with a 1:1 aspect ratio (1024×1024), fully opaque.

PURPOSE: The portrait of a recurring character of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It is shown cropped into a circle, sometimes as small as 48 pixels.

SUBJECT: Portrait of AUFIDIO: weathered centurion in his late forties, grey stubble, old scars on the forearms, round bronze phalerae medals on a leather harness over chain mail, holding a vine staff, no helmet, short grey hair, tired honest eyes. Background: a plain flat painted wall in Pompeian red #C4544A, with a slightly darker thin band at the very bottom; NOT transparent.

COMPOSITION: Head-and-shoulders bust, three-quarter view, looking slightly toward the viewer, like a Fayum portrait painted in fresco style. The head (chin to top of hair) fills about 50% of the image height, eyes at about 42% from the top, head centered horizontally. Everything important inside the central circle of 90% diameter (the corners are cut off). One defining prop visible inside the circle. No scenery, no other people, no hands covering the face; strong value contrast between face and background.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; looking like Sexto (Aufidio is bareheaded, older, thinner, kinder).
```

## Capítulos, Arco 1 «La sombra del Senado» (9)

### claudius_1

**Adjuntá:** `road`. Guardala como `assets/art_raw/claudius_1.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_1.png story claudius_1
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: In a corner of the Roman Forum at dawn, a slave in patrician livery discreetly hands a folded, unsigned, sealed note to the messenger, glancing over his shoulder. In the background on a hill, the gate of a rich villa catches the first light.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DAWN. Dawn sky: pale blue #9DB7D5 at the top, peach #E9C3B0 in the middle, apricot horizon #F6C9A6; violet-grey distant land #5B5470; long soft shadows.

CONTINUITY: People in the image: the messenger; a slave in patrician livery (generic, Tyrian-purple trimmed tunic). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; readable writing on the note.
```

### claudius_2

**Adjuntá:** `road`. Guardala como `assets/art_raw/claudius_2.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_2.png story claudius_2
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: The messenger climbs the steps of the Temple of Saturn at dusk holding a letter sealed with two black wax seals; a priest waits half hidden behind a column; at the bottom of the steps a fig seller with a basket watches the messenger a little too long.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: the messenger; a fig seller (generic) watching; a priest half hidden. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### claudius_3

**Adjuntá:** `road`. Guardala como `assets/art_raw/claudius_3.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_3.png story claudius_3
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: Close view: a thick scroll sealed three times with cinnabar wax, held tightly in the messenger's hands (cinnabar cloak sleeves) by the light of an oil lamp; behind, a scribe's desk with wax tablets, an inkpot and a brazier with glowing coals (a hint that the letter might have to be burned).

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR / NIGHT. Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: the messenger (only hands and cloak visible). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; readable writing.
```

### claudius_4_varus

**Adjuntá:** `road`. Guardala como `assets/art_raw/claudius_4_varus.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_4_varus.png story claudius_4_varus
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: Night in Rome: the messenger runs across terracotta rooftops toward a senator's villa with lit windows on a hill; the dark city below with tiny torches of patrols in the streets.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: NIGHT. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: the messenger running (small). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### claudius_4_claudius

**Adjuntá:** `road`. Guardala como `assets/art_raw/claudius_4_claudius.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_4_claudius.png story claudius_4_claudius
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: In front of the arched Basilica Aemilia at night, the messenger carries a heavy sealed leather document tube under the arm, walking past armed men in dark cloaks standing in the torchlight.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: NIGHT. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: the messenger; two or three armed men in dark cloaks (generic). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### claudius_4_underworld

**Adjuntá:** `road` y `viuda`. Guardala como `assets/art_raw/claudius_4_underworld.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_4_underworld.png story claudius_4_underworld
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: A smoky tavern with no sign in the Subura: around a back table lit by oil lamps, shadowy figures bid in low voices; the Widow presides, the ochre she-wolf brooch on her black stola catching the light; the messenger stands in the foreground, from behind.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR (smoky tavern). Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre.

CONTINUITY: People in the image: the Widow seated; generic bidders; the messenger seen from behind. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. THE WIDOW is a recurring character: older woman around sixty, silver hair in a severe bun, black stola, ochre-gold she-wolf brooch on the chest; calm, dangerous. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of THE WIDOW for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### claudius_5_varus

**Adjuntá:** `road`, `claudius` y `varus`. Guardala como `assets/art_raw/claudius_5_varus.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_5_varus.png story claudius_5_varus
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: On the steps of the Forum in morning light, the messenger calmly hands a formal sealed letter to Claudius, who reads it with a cold face; far behind, near a column, Varus watches with arms crossed.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DAY (morning). Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: the messenger; Claudius on the Forum steps; Petro is NOT shown; Varus watching from a distance. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. CLAUDIUS is a recurring character: thin senator in his sixties, white toga with a broad Tyrian-purple stripe, receding white hair, thin cold courteous smile, heavy signet ring, no beard, no laurel crown. VARUS is a recurring character: man in his fifties, broad shoulders, close-cropped grey hair, old pale scar across the chin, plain dark brown wool tunic, ink-stained fingers; stern but paternal, no beard. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of CLAUDIUS for face, hair, age and clothes; and the attached portrait of VARUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### claudius_5_claudius

**Adjuntá:** `road`. Guardala como `assets/art_raw/claudius_5_claudius.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_5_claudius.png story claudius_5_claudius
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: The messenger walks up the steps of the Curia (the Senate house: a tall plain brick building with a bronze door) in bright daylight, crowds parting to let them pass, scribes waiting at the door.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DAY. Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: the messenger wearing a fine livery over the cinnabar cloak (Tyrian-purple trim); a parting crowd. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### claudius_5_underworld

**Adjuntá:** `road`. Guardala como `assets/art_raw/claudius_5_underworld.png`.

```bash
python3 tool/process_art.py assets/art_raw/claudius_5_underworld.png story claudius_5_underworld
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: Two identical sealed letters on a tavern table side by side, a small knife between them, an oil lamp; through a window behind, two lit villas on opposite hills of night-time Rome.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR looking out to NIGHT. Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

## Capítulos, Arco 2 «La taberna del Buey» (9)

### lucius_1

**Adjuntá:** `road` y `lucius`. Guardala como `assets/art_raw/lucius_1.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_1.png story lucius_1_underworld
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: Inside the Ox tavern: Lucius, bald with a leather apron, leans on a stone counter with built-in clay jars, talking low to the messenger; shelves of amphorae, a wooden trapdoor to the cellar in the floor, warm lamplight.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR (warm tavern). Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre.

CONTINUITY: People in the image: Lucius; the messenger from behind. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. LUCIUS is a recurring character: innkeeper in his fifties, completely bald, thick forearms, leather apron over an ochre tunic, suspicious squint, clay cup in hand, no beard. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of LUCIUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### lucius_2

**Adjuntá:** `road`. Guardala como `assets/art_raw/lucius_2.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_2.png story lucius_2
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: In the tavern cellar lit by a single oil lamp, the young deserter hides behind barrels and amphorae; above, through a barred grate in the ceiling, the shadows of passing legionaries' legs on the street.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR (cellar) / NIGHT. Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: Gaius, a frightened young deserter (about 19, dark hair, a scar on the back of one hand, plain tunic, generic face, NOT a recurring character). Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### lucius_3

**Adjuntá:** `road`. Guardala como `assets/art_raw/lucius_3.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_3.png story lucius_3
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: In a roadside inn at Aricia at night, the messenger opens a thick ledger made of wooden leaves/wax tablets bound with leather (lines of illegible marks, no readable writing) on a table by candlelight; through the window, the Via Appia under the moon with tombs along its sides.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: NIGHT (interior with window). Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: the messenger from behind. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### lucius_4_legion

**Adjuntá:** `road` y `sexto`. Guardala como `assets/art_raw/lucius_4_legion.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_4_legion.png story lucius_4_legion
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: On the paved Via Appia, a column of legionaries led by Sexto marches toward a tall column of black smoke rising from a burning roadside inn on the horizon; the messenger walks with them.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: Sexto at the front; half a century of generic legionaries; the messenger beside them. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. SEXTO is a recurring character: stern centurion in his forties, bronze Montefortino helmet with a TRANSVERSE (side-to-side) red crest, chain mail, vine staff, heavy jaw, broken nose, red military cloak. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of SEXTO for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### lucius_4_book

**Adjuntá:** `road`. Guardala como `assets/art_raw/lucius_4_book.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_4_book.png story lucius_4_book
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: Four hooded men block a road through a dark forest; the messenger stands facing them, clutching a ledger strapped under the cloak; far away, an orange glow of a burning inn on the horizon.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: NIGHT. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: the messenger; four hooded men (generic, faces in shadow). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; fighting, blood.
```

### lucius_4_family

**Adjuntá:** `road`. Guardala como `assets/art_raw/lucius_4_family.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_4_family.png story lucius_4_family
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: A small Roman inn at Forum Appii at dusk; neighbors with wooden clubs and torches guard its door; Livia stands at the threshold with a stern face; smoke from another fire far on the horizon.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: Livia, Lucius's sister (woman in her fifties, grey-streaked hair in a kerchief, stern face, ochre apron — generic, NOT a recurring character); neighbors with clubs and torches. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### lucius_5_legion

**Adjuntá:** `road` y `sexto`. Guardala como `assets/art_raw/lucius_5_legion.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_5_legion.png story lucius_5_legion
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: At the Porta Capena gate of Rome at dawn, the young Gaius in a fresh legionary tunic swears an oath with a raised hand beside the messenger; Sexto holds a standard topped with a bronze bull (no letters).

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DAWN. Dawn sky: pale blue #9DB7D5 at the top, peach #E9C3B0 in the middle, apricot horizon #F6C9A6; violet-grey distant land #5B5470; long soft shadows.

CONTINUITY: People in the image: Sexto; Gaius (young soldier, now in a clean tunic of the Tenth Legion); the messenger. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. SEXTO is a recurring character: stern centurion in his forties, bronze Montefortino helmet with a TRANSVERSE (side-to-side) red crest, chain mail, vine staff, heavy jaw, broken nose, red military cloak. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of SEXTO for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### lucius_5_book

**Adjuntá:** `road` y `viuda`. Guardala como `assets/art_raw/lucius_5_book.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_5_book.png story lucius_5_book
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: The back table of the Golden She-Wolf tavern in the Subura: four buyers in rich cloaks sit around a closed ledger, the Widow presides at the head of the table, candles, deep shadows.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR (candlelit tavern). Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre.

CONTINUITY: People in the image: the Widow; four rich buyers in fine cloaks (generic); the messenger from behind. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. THE WIDOW is a recurring character: older woman around sixty, silver hair in a severe bun, black stola, ochre-gold she-wolf brooch on the chest; calm, dangerous. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of THE WIDOW for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### lucius_5_family

**Adjuntá:** `road` y `lucius`. Guardala como `assets/art_raw/lucius_5_family.png`.

```bash
python3 tool/process_art.py assets/art_raw/lucius_5_family.png story lucius_5_family
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: A dozen innkeepers sit around the big table of the closed Ox tavern at night, clay cups raised together; Lucius at the head; in the hearth behind them, a ledger burns.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR / NIGHT. Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: Lucius; about ten generic innkeepers; the messenger at the end of the table. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. LUCIUS is a recurring character: innkeeper in his fifties, completely bald, thick forearms, leather apron over an ochre tunic, suspicious squint, clay cup in hand, no beard. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of LUCIUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

## Capítulos, Arco 3 «El águila de la Decimotercera» (9; `legion_1` está en Pendientes)

### legion_1_sexto

**Adjuntá:** `road` y `sexto`. Guardala como `assets/art_raw/legion_1_sexto.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_1_sexto.png story legion_1_sexto
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: At the Porta Capena gate of Rome in winter, Sexto stops the messenger and hands over a sealed letter; on the messenger's chest a small bronze plaque with a bull; beyond the gate the Via Flaminia heads north toward distant snowy hills.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DAY (winter, pale cold light). Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: Sexto; the messenger. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. SEXTO is a recurring character: stern centurion in his forties, bronze Montefortino helmet with a TRANSVERSE (side-to-side) red crest, chain mail, vine staff, heavy jaw, broken nose, red military cloak. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of SEXTO for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### legion_2

**Adjuntá:** `road`. Guardala como `assets/art_raw/legion_2.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_2.png story legion_2
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: The Rubicon: a narrow, muddy, unimpressive river with low banks and bare winter trees; the messenger wades/crosses at a ford carrying a satchel; on the far bank in the distance, the wooden palisade and tents of a legion camp (the Thirteenth at Ravenna).

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DAY (winter, overcast). Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: the messenger (small, crossing). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; a big dramatic river; it is small and humble.
```

### legion_3

**Adjuntá:** `road`. Guardala como `assets/art_raw/legion_3.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_3.png story legion_3
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: At the camp gate of a legion fort, two tribunes search civilians leaving toward the south; the messenger waits in line, a sealed letter hidden in the sandal (suggested by the messenger looking down at the foot); the muddy road south leads to the river.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DUSK (winter). Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: the messenger; two military tribunes (generic officers with plumed helmets) checking travelers. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### legion_4_caesar

**Adjuntá:** `road` y `aufidio`. Guardala como `assets/art_raw/legion_4_caesar.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_4_caesar.png story legion_4_caesar
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: Inside the legate's tent, the messenger hands the legate a sealed letter; in the shadow at the tent entrance, Aufidio watches, understanding what is happening; maps and a lamp on a camp table.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR (command tent, lamplight). Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre.

CONTINUITY: People in the image: a legate (generic senior officer, red cloak, muscled bronze cuirass painted flat); Aufidio standing apart; the messenger. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. AUFIDIO is a recurring character: weathered centurion in his late forties, bareheaded, short grey hair, grey stubble, old scars on the forearms, round bronze phalerae medals on a leather harness over chain mail, vine staff, tired honest eyes. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of AUFIDIO for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; readable maps.
```

### legion_4_senate

**Adjuntá:** `road`. Guardala como `assets/art_raw/legion_4_senate.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_4_senate.png story legion_4_senate
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: On the Via Flaminia heading south toward Rome, the messenger hurries on foot with a satchel; far behind on a hill, two riders in red cloaks are coming (without stirrups).

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DAY (winter). Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: the messenger on a road; two horsemen of the Thirteenth far behind (generic). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### legion_4_guild

**Adjuntá:** `road`. Guardala como `assets/art_raw/legion_4_guild.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_4_guild.png story legion_4_guild
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: On the road between Ravenna and Ariminum, the messenger stands between two men who both reach for the messenger's sealed leather satchel bearing the Guild's red wax seal; the messenger holds it close.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DUSK (winter). Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: the messenger in the middle; one officer of Caesar's side (red cloak) on the left; one agent of Pompey's side (dark blue-grey cloak, civilian) on the right (both generic). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### legion_5_caesar

**Adjuntá:** `road`. Guardala como `assets/art_raw/legion_5_caesar.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_5_caesar.png story legion_5_caesar
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: At night, the Thirteenth Legion forms up in silence on the bank of the narrow Rubicon, no torches, only starlight; the messenger walks ahead toward the water carrying sealed orders.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: NIGHT. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: the messenger; rows of legionaries without torches (generic). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### legion_5_senate

**Adjuntá:** `road` y `claudius`. Guardala como `assets/art_raw/legion_5_senate.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_5_senate.png story legion_5_senate
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: On the steps of the Curia, Claudius guides the travel-stained messenger past a crowd of senators in white togas who look at the messenger with contempt, toward the open bronze doors.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: DAY. Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: the messenger; Claudius; messengers waiting on the steps (generic). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. CLAUDIUS is a recurring character: thin senator in his sixties, white toga with a broad Tyrian-purple stripe, receding white hair, thin cold courteous smile, heavy signet ring, no beard, no laurel crown. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of CLAUDIUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### legion_5_guild

**Adjuntá:** `road` y `varus`. Guardala como `assets/art_raw/legion_5_guild.png`.

```bash
python3 tool/process_art.py assets/art_raw/legion_5_guild.png story legion_5_guild
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The wide cinematic banner of a story chapter of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to a thin 21:9 strip: only the horizontal band between 18% and 82% of the height survives.

SUBJECT: In the Guild's post house at night, Varus sits at the head of a plain wooden table with two enemies seated far apart on each side; the messenger enters with the sealed satchel; lamplight, tense silence.

COMPOSITION: Establishing shot of one place and one moment, one or two prominent figures at most, medium-small and readable as silhouettes. Keep everything important inside the central 85% horizontally and inside the band between 20% and 80% of the height; the top and bottom 20% are only sky, ground or plain wall.

TIME OF DAY: INTERIOR / NIGHT (post house). Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: Varus at the head of a table; a tribune of Caesar (red cloak) and an agent of Pompey (blue-grey cloak) at the sides; the messenger arriving with the satchel. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. VARUS is a recurring character: man in his fifties, broad shoulders, close-cropped grey hair, old pale scar across the chin, plain dark brown wool tunic, ink-stained fingers; stern but paternal, no beard. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of VARUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

## Finales de arco + gráfico de Google Play (10)

### end_varus

**Adjuntá:** `road` y `varus`. Guardala como `assets/art_raw/end_varus.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_varus.png ending end_varus
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: In the modest post house at night, Varus and the messenger share a quiet cup of wine at a small table; a painted map of Roman roads (no writing) on the wall behind, a single oil lamp between them. Emotion: earned trust.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: INTERIOR / NIGHT. Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: Varus; the messenger (hood down but face turned away / in shadow). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. VARUS is a recurring character: man in his fifties, broad shoulders, close-cropped grey hair, old pale scar across the chin, plain dark brown wool tunic, ink-stained fingers; stern but paternal, no beard. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of VARUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### end_claudius

**Adjuntá:** `road` y `claudius`. Guardala como `assets/art_raw/end_claudius.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_claudius.png ending end_claudius
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: On the marble terrace of a villa overlooking Rome at dusk, Claudius rests a hand on the messenger's shoulder as they both look at the city below; warm ochre light, long shadows. Emotion: ambition with a price.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: Claudius; the messenger in fine livery (cinnabar cloak with Tyrian-purple trim), seen from behind. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. CLAUDIUS is a recurring character: thin senator in his sixties, white toga with a broad Tyrian-purple stripe, receding white hair, thin cold courteous smile, heavy signet ring, no beard, no laurel crown. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of CLAUDIUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### end_underworld

**Adjuntá:** `road`. Guardala como `assets/art_raw/end_underworld.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_underworld.png ending end_underworld
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: In the shadows of a Subura tavern, the messenger counts coins (ochre) on a table next to an open ledger of secrets (illegible marks); an ochre she-wolf brooch lies on the table; through the open door, the dark alley. Emotion: dangerous freedom.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: NIGHT (Subura interior with open door). Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: the messenger (face in shadow). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### end_lucius_legion

**Adjuntá:** `road`. Guardala como `assets/art_raw/end_lucius_legion.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_lucius_legion.png ending end_lucius_legion
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: The messenger rides along the Via Appia (no stirrups) with a bronze bull plaque on the chest; legion milestones and a fortified camp in the distance; tombs and umbrella pines along the road. Emotion: duty and protection.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: DAY. Day sky: soft cerulean #8EC3D6 at the top, sea-glass #BFD9D6, warm cream horizon #F4E3B5; olive land #6E7F4E; short shadows.

CONTINUITY: People in the image: the messenger on horseback (seen from behind/side, hood up). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### end_lucius_book

**Adjuntá:** `road`. Guardala como `assets/art_raw/end_lucius_book.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_lucius_book.png ending end_lucius_book
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: In a dark alley of the Subura, the messenger unfolds a hand-drawn smuggler's map on a barrel top (paths and dots only, no writing), coins and an ochre she-wolf brooch beside it, a single torch above. Emotion: secrets as currency.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: NIGHT. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches.

CONTINUITY: People in the image: the messenger (face hidden). THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### end_lucius_family

**Adjuntá:** `road` y `lucius`. Guardala como `assets/art_raw/end_lucius_family.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_lucius_family.png ending end_lucius_family
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: The Ox tavern seen from the road at dusk, with a new post-house sign over the door showing a red wax-seal symbol (no letters); travelers' mules tied outside, warm light from the door where Lucius waves. Emotion: belonging, home.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: Lucius at the door waving; travelers (generic). LUCIUS is a recurring character: innkeeper in his fifties, completely bald, thick forearms, leather apron over an ochre tunic, suspicious squint, clay cup in hand, no beard. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of LUCIUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### end_legion_caesar

**Adjuntá:** `road`. Guardala como `assets/art_raw/end_legion_caesar.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_legion_caesar.png ending end_legion_caesar
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: The messenger wades through the narrow muddy Rubicon at night holding sealed orders above the head; on the bank behind, the legion waits without torches; a general on horseback, alone at the edge, looks at the water; the first pale light at the horizon. Emotion: fate, the die is cast.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: NIGHT going to DAWN at the horizon. Night sky: indigo #0F1024 at the top, deep blue #1B2147, an Egyptian-blue glow on the horizon #2F5D9E; near-black land #0A0B18; a few small stars; warm ochre light only from lamps and torches. Dawn sky: pale blue #9DB7D5 at the top, peach #E9C3B0 in the middle, apricot horizon #F6C9A6; violet-grey distant land #5B5470; long soft shadows.

CONTINUITY: People in the image: the messenger wading; a general on horseback watching the water (generic, red cloak, seen from behind — do NOT draw a recognizable Julius Caesar portrait); the legion waiting. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### end_legion_senate

**Adjuntá:** `road` y `claudius`. Guardala como `assets/art_raw/end_legion_senate.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_legion_senate.png ending end_legion_senate
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: Inside the Senate house, tiered benches full of senators in white togas shout and gesture; in the center of the floor, alone, the travel-stained messenger stands; Claudius, in the front row, nods slightly. Emotion: a small voice changing history.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: INTERIOR (the Curia, daylight from high windows). Interior: no sky; warm ochre lamplight or torchlight with deep ink shadows; walls in parchment, Pompeian red or ochre.

CONTINUITY: People in the image: the messenger standing alone in the center (dusty cinnabar cloak, from behind); hundreds of senators in white togas on the benches (generic, small); Claudius nodding on the front bench. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. CLAUDIUS is a recurring character: thin senator in his sixties, white toga with a broad Tyrian-purple stripe, receding white hair, thin cold courteous smile, heavy signet ring, no beard, no laurel crown. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of CLAUDIUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### end_legion_guild

**Adjuntá:** `road` y `varus`. Guardala como `assets/art_raw/end_legion_guild.png`.

```bash
python3 tool/process_art.py assets/art_raw/end_legion_guild.png ending end_legion_guild
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a TALL PORTRAIT image with a 2:3 aspect ratio (1024×1536), fully opaque.

PURPOSE: The reward image shown when the player reaches an ending of a story arc in a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild: one of the most beautiful and emotional paintings of the game. It will be cropped to 4:5, losing about 9% at the top and at the bottom.

SUBJECT: At a plain table in the post house at dawn, two enemies sit at opposite ends; Varus signs last on a wax tablet; in the middle of the table lies a sealed leather satchel with the Guild's red wax seal; pale dawn light through the window. Emotion: neutrality as strength.

COMPOSITION: A complete painting with one clear emotional idea. Keep important details away from the top and bottom 10% and from a 4% margin on the sides.

TIME OF DAY: DAWN (window light in an interior). Dawn sky: pale blue #9DB7D5 at the top, peach #E9C3B0 in the middle, apricot horizon #F6C9A6; violet-grey distant land #5B5470; long soft shadows.

CONTINUITY: People in the image: Varus signing; two enemies in military cloaks (red and blue-grey) at each end of the table; the messenger standing. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. VARUS is a recurring character: man in his fifties, broad shoulders, close-cropped grey hair, old pale scar across the chin, plain dark brown wool tunic, ink-stained fingers; stern but paternal, no beard. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture; and the attached portrait of VARUS for face, hair, age and clothes.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations.
```

### feature_graphic

**Adjuntá:** `road`. Guardala como `assets/art_raw/feature_graphic.png`.

```bash
python3 tool/process_art.py assets/art_raw/feature_graphic.png feature
```

```
Generate exactly 1 image. Start generating immediately, without asking questions or requesting confirmation. One single image, not a grid or collage.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: The Google Play feature graphic of a narrative mobile game set in Rome and Italy in 50 BC, about a civilian courier of a messenger guild. It will be cropped to about 2:1, losing about 13% at the top and at the bottom; the game logo is added later on the right half.

SUBJECT: A wide panoramic view of the Roman countryside at dusk: a paved road crosses the frame from left to right; the messenger in the cinnabar hooded cloak runs on the road in the left third; Rome in flat layers on the right horizon (hills, a domed temple, an aqueduct); umbrella pines along the road. The right half must stay calm and simple (sky and soft hills) because the game logo will be placed there later.

COMPOSITION: Everything important inside the central 70% of the height. The messenger is in the left third; the right half stays calm and simple (sky and soft hills) because the logo goes there.

TIME OF DAY: DUSK. Dusk sky: mulberry #7A3B5C at the top, Pompeian red #C4544A, orange horizon #F0A35E; plum distant land #3A2230; long warm shadows.

CONTINUITY: People in the image: the messenger, small, running. THE MESSENGER is the player character, so they must NEVER have a visible face or a defined gender: always seen from behind, in profile under the hood, in silhouette or small in the distance, face hidden or in shadow. Outfit: cinnabar-red (#A8322D) hooded paenula travel cloak, plain parchment tunic, wide-brimmed straw petasos hat (worn or hanging on the back), leather shoulder satchel with a red wax seal on the flap, sturdy sandals. Slim, medium height, ambiguous build. No armor, no weapon in hand. Any other person is generic and must not resemble the recurring characters.

REFERENCES: If images are attached, match the attached road scene (style master) for style, palette, line weight and texture.

STYLE: Digital illustration imitating a Pompeian fresco, in flat layered silhouettes: simple bold shapes in 3 to 5 depth layers, two-tone shading at most per shape (no airbrush gradients; only the sky may have a gentle gradient), thin ink-brown contour lines (#231A16) on figures, buildings and important objects, matte mineral pigments on lime plaster with a very subtle plaster grain (the image must not look damaged, old or dirty), distant layers fade toward the horizon color. Figures stylized but naturally proportioned (about 7 heads tall) with simple faces like Roman wall paintings or Fayum portraits: almond eyes, straight noses, small mouths, restrained expressions. One clear light direction, flat shadow shapes. Strict palette: lime white #F2E8D5, warm parchment #E6D8BE, yellow ochre #D9A441 (gold is always painted as ochre, never metallic), cinnabar red #A8322D, Egyptian blue #2F5D9E, verdigris #3F7F72, Tyrian purple #6B3E6E (sparingly), olive #6E7F4E, cypress green #2C4231, ink brown-black #231A16. Mood: quiet, slightly mysterious, warm even at night, adult storybook; danger is suggested, never shown. Late Roman Republic, Italy, 50 BC, historically grounded. Not cartoonish, not anime, not a photograph, not a 3D render.

DO NOT INCLUDE: any text, letters, numbers or inscriptions anywhere (signs, scrolls, maps, seals, pediments, milestones; writing is only sealed or illegible marks); logo, watermark or signature; frame, border, white margin, rounded corners, vignette, paper edge or a photo of a fresco on a wall (the painting fills the canvas edge to edge); transparency or checkerboard; a grid, collage or diptych; lens effects (bokeh, flare, blur); medieval elements (castles, Gothic arches, plate armor, knights, heraldic shields, horned helmets), stirrups, crossbows, banners with letters, crosses, paper books with bound pages, glass window panes, modern objects, fantasy creatures, magic glows, gore, blood, nudity; metallic gold, neon, navy-and-gold combinations; any text or logo (it will be added later).
```
