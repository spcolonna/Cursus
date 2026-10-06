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

`GradientScaffold` pinta la página de papel. Con `background:` (escena de evento) la escena queda arriba y se funde en el papel. El cielo vivo según la hora llega en la Fase I3 (ver plan de identidad).
