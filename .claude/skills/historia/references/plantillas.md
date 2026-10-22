# Plantillas de contenido

Copiá, no inventes la forma. Todas las estructuras están definidas al final de `lib/data/game_content.dart`.

## Evento del camino → `realEventPool` en `lib/data/game_content.dart`

```dart
RealEventConfig(
  id: 'evt_<slug>',
  title: 'Título corto',
  description: 'La situación en 1-2 oraciones. Termina en tensión, no en pregunta.',
  options: [
    // Segura y lenta
    RealOptionConfig(
      id: 'opt_<slug>', text: 'Acción en 2ª persona',
      riskLevel: 1, timeCostMinutes: 120, requiredSkills: {},
      repDelta: {Faction.legions: 1},
      outcomeSuccess: '…',
      outcomePartial: '…',
      outcomeFail: '…',
    ),
    // Arriesgada y rápida, gateada por skill
    RealOptionConfig(
      id: 'opt_<slug>', text: '…',
      riskLevel: 4, timeCostMinutes: 0,
      requiredSkills: {SkillType.survival: 2},
      outcomeSuccess: '…', outcomePartial: '…', outcomeFail: '…',
    ),
    // Opción secreta (callback): solo aparece con el flag
    RealOptionConfig(
      id: 'opt_<slug>', text: 'Una figura conocida te hace señas…',
      riskLevel: 1, timeCostMinutes: 0, requiredSkills: {},
      requiredFlag: 'spared_thief',
      setFlags: ['debt_repaid'],
      journalNote: 'Frase de diario en primera persona.',
      outcomeSuccess: '…', outcomePartial: '…', outcomeFail: '…',
    ),
  ],
),
```

Campos opcionales de `RealOptionConfig`: `repDelta`, `setFlags`, `requiredFlag`, `forbiddenFlag`, `minReputation` + `lockedHint` (opción visible pero bloqueada, con motivo narrativo), `followUpEventId` (encadena otro evento en la misma misión), `journalNote`.

## Ruta nueva → `phase1Missions`

```dart
RealMissionConfig(
  id: 'route_<slug>',
  origin: 'Roma', destination: 'Neapolis',
  distanceKm: 220, durationMinutes: 480,   // ver tabla de duraciones
  danger: 0.6,                              // 0.0-1.0 → dangerLevel 1-5
  requiredRank: 2,                          // 1 Correo · 2 Mensajero · 3 Courier · 4 Maestro · 5 Leyenda
  lore: 'Una oración que da ganas de aceptarla.',
  packageOptions: ['Un cofre lacrado', 'Cartas de un armador'],
  eventPoolIds: ['evt_patrol', 'evt_storm', 'evt_bandits'],
  minEvents: 2, maxEvents: 3,
  // requiredFlag: 'ending_varus',           // ruta desbloqueada por historia
),
```

**Regla del GDD:** mínimo **1 evento cada 8h** de misión, y las misiones largas pagan acorde. Duraciones que conviene cubrir para que siempre haya algo que encaje en el día del jugador: 30 min · 2 h · 4 h · 8 h · 24 h · 72 h.

## Evento de tutorial → `tutorialEvents`

`TutorialOption` **obliga** los tres outcomes (no son nullable) y no acepta efectos de mundo. Las 4 pruebas de Varus escalan 1 → 5 → 15 → 30 min y enseñan, en orden: que el tiempo corre, que hay riesgo, que las skills abren opciones, que la nota importa.

## Entrada de diario

`journalNote` en la opción, o `journalEntry` en un capítulo de arco. Primera persona, pasado, una oración. Se guardan las últimas 40 (`WorldState.addJournal`).

## Flags

- Nombre en snake_case, sin prefijo: `spared_thief`, `told_varus`, `path_underworld`.
- Se setean con `setFlags` (opción) o `setFlagsOnComplete` (capítulo).
- Se consultan con `requiredFlag` / `forbiddenFlag` en opciones, capítulos y rutas.
- Un flag nuevo sin ningún consumidor es contenido muerto: sembralo y cosechalo en la misma PR.

## Reputación

`repDelta: {Faction.guild: 2}` — rango −100..100, títulos en `reputationTitle()` (`world.dart`).
`minReputation` + `lockedHint` muestra la opción bloqueada con motivo narrativo ("Los patricios no confían en ti").
