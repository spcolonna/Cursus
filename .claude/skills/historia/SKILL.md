---
name: historia
description: Escribir o editar contenido narrativo de Cursus — eventos del camino, opciones y su prosa de éxito/parcial/fallo, rutas nuevas, arcos de personaje multi-capítulo, entradas de diario, reputación y flags. Usar siempre que se toque lib/data/game_content.dart, lib/data/story_content.dart o lib/data/faction_content.dart (rutas de facción y encargos semanales con NPCs), o cuando se pida "un evento nuevo", "una ruta", "más historia", "un arco", "textos de resultado".
---

# Escribir historia en Cursus

La narrativa es el diferencial del juego. Un evento sin prosa propia es contenido roto.

## Antes de escribir

1. Mirá qué existe, sin leer archivos enteros:
   ```bash
   grep -n "id: 'evt_\|id: 'route_\|title:" lib/data/game_content.dart
   grep -n "chapterTitle:\|setFlags\|requiredFlag" lib/data/story_content.dart
   ```
2. Leé **un** evento completo como referencia de voz: `evt_patrol` en `lib/data/game_content.dart` (arranca en el bloque `realEventPool`). Es el estándar de calidad.
3. Si vas a escribir prosa: leé `references/voz-y-tono.md`.
4. Si es un arco de varios capítulos: leé `references/arcos.md`.
5. Plantillas exactas de código: `references/plantillas.md`.

## Reglas duras

- **Toda opción nueva lleva `outcomeSuccess`, `outcomePartial` y `outcomeFail` propios.** Los textos genéricos (`_genericSuccess/Partial/Fail`) son deuda: no se agregan más.
- **2-4 opciones por evento**, con perfiles distintos: una segura y lenta (riesgo 1-2, `timeCostMinutes` alto), una arriesgada y rápida (riesgo 3-5, costo 0), una gateada por skill (`requiredSkills`). La cuarta, si va, es una opción secreta con `requiredFlag`.
- **Ninguna opción es basura.** Si el jugador siempre elegiría la misma, el evento está mal diseñado: cada una gana algo y paga algo.
- **Los efectos narrativos representan la decisión, no el resultado**: `repDelta`, `setFlags` y `journalNote` se aplican con cualquier outcome.
- **Consecuencias duras en lo narrativo, suaves en lo mecánico.** Traicionar a Varus cierra puertas y cambia diálogos; nunca borra skills, monedas ni mensajeros.
- **Español rioplatense** (vos, tenés, mirá, salís). Sin emojis. Sin anacronismos (nada de "OK", "chequear el mapa").
- Los eventos de tutorial (`tutorialEvents`) usan `TutorialOption`, que **exige** los tres outcomes y no tiene efectos de mundo. Los eventos reales y de historia usan `RealOptionConfig`.

## Presupuesto de texto (respetar el pilar de 1-3 min)

| Campo | Largo |
|---|---|
| `title` | 2-4 palabras |
| `description` (situación) | 1-2 oraciones, ≤ 240 caracteres |
| `text` (opción) | 4-9 palabras, verbo en 2ª persona ("Rodeás el puesto por un camino lateral") |
| `outcome*` | 1-3 oraciones, ≤ 320 caracteres |
| `journalNote` | 1 oración en primera persona, pasado |
| `narrativeIntro` / `epilogue` | 2-4 oraciones |
| `lore` (card del Home) | 1 oración, ≤ 120 caracteres |

## Checklist antes de dar por terminado

- [ ] Los 3 outcomes de cada opción son distintos entre sí y **específicos de esa opción** (no reusables).
- [ ] El fallo es interesante, no solo "perdés tiempo": complica, no castiga.
- [ ] Riesgo y `timeCostMinutes` coherentes: más riesgo → menos tiempo, y viceversa.
- [ ] `requiredSkills` no pide más de nivel 3 salvo en rutas de rank alto.
- [ ] Si toca reputación, el delta es ±1 o ±2 (±3 solo en momentos de arco).
- [ ] IDs únicos y con prefijo (`evt_`, `opt_`).
- [ ] El evento está referenciado desde `eventPoolIds` de alguna ruta (si no, es contenido muerto).
- [ ] Inglés agregado en `assets/l10n/content_en.json` para cada clave nueva (`flutter test test/content_l10n_test.dart` las lista; voz y glosario en `docs/LOCALIZACION.md`).
- [ ] `flutter analyze` limpio.
