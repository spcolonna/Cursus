# Tokens y contraste

Todo en `lib/presentation/theme/app_theme.dart` (interfaz) y `theme/art_palette.dart` (pintura: mapas, escenas, retratos, cera; **nunca** texto).

## Colores ("Fresco al atardecer")

| Grupo | Tokens | Uso |
|---|---|---|
| Superficies | `paperHigh #F8F1E3` · `paper #F2E8D5` (cal) · `paperDeep #E6D8BE` · `paperNight #E0D3BA` · `paperShade #D5C6A6` · `paperLine #C4AF88` | Cards en `paper`, página en `paperDeep`, deshabilitado y rieles en `paperShade`, bordes finos en `paperLine` |
| Tinta | `ink #231A16` · `inkSoft #3E3129` · `inkMuted #5E4F41` | Texto. `inkMuted` **nunca más clara** (4.5:1 sobre `paperShade`) |
| Acción | `ochre #D9A441` · `ochreLight` (rellenos) · `ochreDeep #754F10` (texto/ícono/borde) | Botón primario, selección, Aureos |
| Marca y peligro | `cinnabar #A4302B` · `cinnabarLight` · `cinnabarDeep` | Sello, logo, eventos urgentes. Peligro siempre con ícono |
| Información | `egyptianBlue #2D5A9A` · `egyptianBlueLight` (rellenos) | Info, Denarios, velocidad |
| Éxito | `verdigris #2E6357` · `verdigrisLight` (rellenos) | Éxito, supervivencia, compra real |
| Secreto | `tyrian #6B3E6E` · `tyrianLight` | Sigilo, historia, opciones secretas, Sellos, nota S |
| Atención | `sienna #8A4614` | Advertencias que no son peligro, riesgo medio |
| Sobre escenas | `onSky #F7EFDC` · `scrimSky` | Solo títulos grandes sobre el cielo |
| Velos | `shadowSoft` · `shadowHard` · `scrim` (de tinta, no negro) | Sombras cálidas, barrera de diálogos |

Riesgo: bajo `verdigris` · medio `sienna` · alto `cinnabar`. Skills: velocidad `egyptianBlue` · sigilo `tyrian` · combate `cinnabar` · supervivencia `verdigris` · contactos `ochreDeep`. Notas: S `tyrian` · A `ochreDeep` · B `verdigris` · C `egyptianBlue` · F `cinnabar` (`gradeColor` / `gradeBackground`).

## Contraste

La tabla viva es `kTextPairs` en `app_theme.dart`; `test/contrast_test.dart` la valida (4.5:1, o 3:1 si `large`). Todos los pigmentos de texto pasan sobre `paper`, `paperDeep` y `paperNight`. Sobre rellenos: tinta sobre `ochre`/`ochreLight`; `paper` sobre `cinnabar`, `egyptianBlue`, `verdigris`, `tyrian`, `sienna`, `ink`.

Fondos teñidos: `paperTint(color)` (opaco, ~12%) o los gradientes `ochreTint`, `cinnabarTint`, `verdigrisTint`, `tyrianTint`, `blueTint`. **No** uses `color.withValues(alpha: …)` como fondo de un panel: sobre papel queda barroso.

## Tipografía

| Estilo | Fuente | Uso |
|---|---|---|
| `heading(size)` · `displayLarge` 32 · `titleLarge` 22 · `titleMedium` 17 ochreDeep | Marcellus (un solo peso: el énfasis es tamaño y aire) | Títulos de pantalla, de evento, de card |
| `ui(size, weight:)` · `titleSmall` (overline) | Figtree 400-700 | Botones, chips, números, etiquetas |
| `bodyLarge` 15 · `bodyMedium` 13 · `bodySmall` 12 | Figtree | Texto de interfaz |
| `prose(size:)` · `proseItalic(size:)` | Literata | **Narrativa**: eventos, desenlaces, diario, capítulos, citas de lore |
| `brandWordmark` · `brandTagline` | Marcellus · Figtree | Solo la marca (`BrandMark`) |

Piso: 12 pt. Sin `TextStyle(` fuera del theme (lo verifica `design_system_test.dart`).

## Gradientes

Casi planos: dos tonos del mismo pigmento. `page` · `paper` · `ochre` · `cinnabar` · `egyptianBlue` · `verdigris` · `tyrian` · `sienna` · `disabled` · los `*Tint` · alias semánticos `event`, `option`, `optionSelected`, `optionSecret`, `story`, `header`, `coverScrim`.

## Fondos por pantalla

`GradientScaffold` pinta la página de papel. Con `background:` (escena de evento) la escena queda arriba y se funde en el papel. De noche (`SkyPalette.dimPaper`) la página baja a `pageNight` (`paperDeep → paperNight`).

### Cielo vivo (`theme/sky.dart`)

Cuatro cielos que se funden sin saltos según la hora real (smoothstep entre anclas; cortes de fase 5.5 / 8 / 18 / 20.5 h):

| Cielo | Arriba | Medio | Horizonte | Tierra | Hora pura |
|---|---|---|---|---|---|
| Alba | `#9DB7D5` | `#E9C3B0` | `#F6C9A6` | `#5B5470` | 6:30 |
| Día | `#8EC3D6` | `#BFD9D6` | `#F4E3B5` | `#6E7F4E` | 9:00-17:00 |
| Atardecer | `#7A3B5C` | `#C4544A` | `#F0A35E` | `#3A2230` | 19:15 |
| Noche | `#0F1024` | `#1B2147` | `#2F5D9E` | `#0A0B18` | 21:00-4:30 |

`titleColor` elige tinta o cal según el cielo de arriba (≥3:1 a toda hora, lo valida `test/sky_test.dart`); `titleHalo` lo sostiene cuando pasa una nube. Con `scrimSky` encima, la cal se lee sobre cualquier cielo.
