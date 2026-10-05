# Arcos narrativos

Un arco es una cadena de capítulos (misiones con eventos fijos) que ramifica según los flags acumulados. Viven en `lib/data/story_content.dart`. El de referencia es **"La Sombra del Senado"** (`kArcClaudius`): 5 capítulos, 3 finales.

## Anatomía

```dart
StoryMissionConfig(
  id: 'claudius_3', arcId: kArcClaudius, stage: 2,   // stage es 0-based
  chapterTitle: 'Capítulo III — …',
  origin: 'Roma — Foro', destination: 'Ostia',
  packageDescription: 'Un tubo de cuero sin sello.',
  durationMinutes: 120,
  lore: 'Card del Home, 1 oración.',
  narrativeIntro: 'Viñeta al aceptar, 2-4 oraciones.',
  epilogue: 'Texto al entregar: qué cambió en el mundo.',
  journalEntry: 'Entrada de diario, 1ª persona, pasado.',
  fixedEventIds: ['evt_story_…'],        // eventos de storyEventPool
  requiredFlag: 'told_varus',            // variante de capítulo
  forbiddenFlag: 'kept_secret',
  setFlagsOnComplete: ['path_varus'],
  repDeltaOnComplete: {Faction.guild: 5},
  // Solo el capítulo final:
  endingId: 'end_varus', endingTitle: 'Título que gana el jugador',
),
```

`storyMissionFor(arcId, stage, flags)` elige **la primera variante cuyo flag matchea** — por eso el orden dentro de la lista importa: poné primero las variantes específicas y última la genérica (sin `requiredFlag`).

Los eventos del arco van en `storyEventPool` (misma estructura `RealEventConfig`) y se resuelven por `storyEventById`.

## Estructura que funciona (5 capítulos)

1. **El encargo raro.** Una decisión chica que parece inocente y planta el primer par de flags opuestos (`told_varus` / `kept_secret`).
2. **La sospecha.** El jugador descubre qué está transportando de verdad. Segunda bifurcación.
3. **La lealtad.** El capítulo bisagra: los flags previos abren distintas variantes y se elige camino (`path_*`).
4. **El precio.** El camino elegido cobra algo. Sin bifurcación nueva: acá se paga lo decidido.
5. **El final.** Una variante por `path_*`, cada una con `endingId`, `endingTitle` y un desbloqueo real (ruta nueva, opción permanente).

## Reglas

- **Cada capítulo debe poder jugarse solo.** El jugador vuelve dos días después: `narrativeIntro` recuerda dónde estábamos en una oración.
- **Duraciones cortas en arcos** (30 min-4 h). Un capítulo de 72 h mata el ritmo de la historia.
- **Ramifica pronto, converge tarde.** Máximo 3 caminos; no escribas 2^n variantes.
- **Todo final desbloquea algo tangible** — una ruta con `requiredFlag`, una opción secreta en un evento del pool común, un título.
- **Sembrá callbacks fuera del arco:** un flag del capítulo 2 que aparece como opción secreta en un evento común es lo que hace sentir que el mundo recuerda.
- Los arcos se gatean por rank vía la ruta que los ofrece; no arranques un arco antes de que el tutorial esté completo.
- Al agregar un arco nuevo: `arcStageCount()` en `story_content.dart` hoy devuelve 5 fijo — actualizalo si el arco tiene otra cantidad de capítulos.
