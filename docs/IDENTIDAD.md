# Identidad de Cursus

Manual de marca. Cuando el código y este documento difieren, la fuente de los tokens es `lib/presentation/theme/app_theme.dart`.

## Idea

**Un fresco pompeyano que se puede jugar.** Cal, pigmentos minerales y tinta. Roma, 50 a.C., contada como la contaría un mensajero: con calma, con ironía seca y con las decisiones pesando más que la acción.

- **Nombre:** Cursus, por el *cursus publicus*, el correo del Estado romano. Va en versalitas espaciadas: C U R S U S.
- **Bajada:**
  - Español: "Imperio Romano, 50 a.C." en el splash; "Un mensajero en la Roma del 50 a.C." en tienda.
  - Inglés: "Roman Empire, 50 BC"; "A messenger in Rome, 50 BC".
- **Marca:** un sello de cera cinabrio con una V (de Varus y del Gremio). Se dibuja por código (`BrandSealPainter`) y genera también el ícono.

## Color

El papel y la tinta son la base; los pigmentos se usan con medida.

| Rol | Token | Hex | Uso |
|---|---|---|---|
| Cal | `paper` | #F2E8D5 | cards y hojas |
| Pergamino | `paperDeep` | #E6D8BE | fondo de página |
| Línea | `paperLine` | #C4AF88 | bordes y divisores |
| Tinta | `ink` | #231A16 | texto principal |
| Tinta suave | `inkSoft` / `inkMuted` | #3E3129 / #5E4F41 | texto secundario (`inkMuted` es el más claro permitido) |
| Ocre | `ochre` / `ochreDeep` | #D9A441 / #754F10 | la acción principal: relleno / texto |
| Cinabrio | `cinnabar` | #A4302B | marca y peligro real, nada más |
| Azul egipcio | `egyptianBlue` | #2D5A9A | información, Denarios |
| Verdín | `verdigris` | #2E6357 | éxito |
| Púrpura de Tiro | `tyrian` | #6B3E6E | sigilo, secretos, Sellos |

**Reglas:**
- Máximo 4 colores por pantalla.
- Un solo botón ocre por vista.
- El rojo, solo para urgencia real.
- Contraste WCAG AA en todo texto: lo valida `test/contrast_test.dart` sobre `kTextPairs`.

## Tipografía

| Familia | Uso | Carácter |
|---|---|---|
| **Marcellus** | títulos, marca, encabezados | lapidaria romana, versalitas |
| **Literata** | narrativa (eventos, epílogos, diario) | libro, lectura larga |
| **Figtree** | UI (botones, chips, números) | limpia, legible a 12 pt |

Las tres fuentes son OFL y van empaquetadas en la app, con sus licencias.

## Ilustración

- **Estilo:** fresco en siluetas planas por capas, con la paleta de arriba. Prompts y reglas en [ART_PROMPTS.md](ART_PROMPTS.md).
- **Cielo vivo:** el fondo sigue la hora real (alba, día, atardecer, noche; `SkyPalette`).
- **Prohibido:** nada medieval, nada metálico ni brillante, ni navy ni dorado, sin texto dentro de las imágenes.

## Sonido

Materiales (cera, papel, cuero, piedra) y el motivo **D-A-E**: splash, nota S y aviso. Ver [AUDIO.md](AUDIO.md).

## Voz

- **Narrador y personajes:**
  - Español neutro con tuteo (tú, tienes), seco y con algo de ironía.
  - Varus, parco; Lucius, socarrón; Claudius, cortés y frío.
- **UI:** el mismo español neutro, corto y directo. En inglés, segunda persona y presente.
- **Glosario y detalles:** [LOCALIZACION.md](LOCALIZACION.md).
- **Íconos y emojis:** nunca emojis; íconos Material del set ya usado.

## Qué no es Cursus

- No es un juego de reflejos: todo se resuelve eligiendo entre 2 y 3 opciones.
- No usa oscuridad gratuita: el tono es de "cuento para adultos", no grim.
- No es pay-to-win: pagar acelera, no reemplaza jugar.
