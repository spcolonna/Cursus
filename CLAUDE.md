# The Messenger — guía para Claude

Juego móvil Flutter. Mensajero en la Roma del 50 a.C.: las misiones corren en **tiempo real de reloj**, los eventos son decisiones de 2-3 opciones. Sesiones de 1-3 min, 3-4 por día.

**Docs de diseño (fuente de verdad, leer solo la sección que haga falta):**
- [docs/GDD_MASTER_v2.md](docs/GDD_MASTER_v2.md) — §5 árbol de skills, §6 economía, §7 onboarding, §8 UX/legibilidad.
- [docs/ROADMAP_MEJORAS_v1.md](docs/ROADMAP_MEJORAS_v1.md) — fases y criterios de salida.

## Skills de este proyecto (usalas antes de improvisar)

| Skill | Cuándo |
|---|---|
| `historia` | Escribir/editar eventos, rutas, arcos narrativos, prosa de outcomes, diario, NPCs. |
| `interfaz` | Cualquier pantalla, widget, color, tipografía, layout, animación. |
| `balance` | Tocar fórmulas, precios, XP, fatiga, recompensas, perks, contratos. |

## Mapa del código

```
lib/
├── domain/            reglas puras, sin Flutter
│   ├── entities/entities.dart    User, Messenger, Mission, MissionEvent, EventOption, GameRoute
│   ├── entities/world.dart       Faction, WorldState (reputación, flags, diario, arcos)
│   ├── entities/skill_tree.dart  skillTree (5×10 nodos), sealCostForLevel, SkillPerks
│   ├── entities/guild.dart       contratos diarios (pools easy/medium/seal), paga diaria
│   ├── entities/content.dart     tipos del contenido (TutorialMission, RealEventConfig, StoryMissionConfig…)
│   ├── repositories/             contratos abstractos + GameContentCatalog (contenido inyectado)
│   └── usecases/usecases.dart    17 use cases (ResolveEvent, CompleteMission, AscendSkill…)
├── infrastructure/local/local_repositories.dart   SharedPreferences (sin backend)
├── data/game_content.dart        CONTENIDO: tutorial, rutas fase 1, pool de eventos reales
├── data/story_content.dart       CONTENIDO: arcos narrativos (arc_claudius, 5 caps, 3 finales)
├── data/static_game_content.dart StaticGameContent: implementa GameContentCatalog con lo de data/
└── presentation/
    ├── theme/app_theme.dart      AppColors, AppGradients, AppTextStyles + GameButton, GameCard,
    │                             GradientScaffold, StatBar, RiskChip, DeadlineChip,
    │                             PackageBadge, SkillIcon   ← el design system vive acá
    ├── widgets/widgets.dart      GradeBadge, PulsingDot, SectionHeader
    ├── providers/providers.dart  Riverpod: DI + notifiers (home, guild, world, missionProgress)
    └── screens/                  splash, login, onboarding, character, home, mission, event,
                                  mission_result, profile, shop, skills
```

`router.dart` (go_router) · `main.dart` entry point.

## Cómo navegar sin quemar tokens

Archivos grandes: `home_screen.dart` (1.9k líneas), `mission_screen.dart` (1.2k), `game_content.dart` (1k), `usecases.dart` (885), `shop_screen.dart` (887). **No los leas enteros.** Anclas útiles:

```bash
grep -n "^class \|^const \|^final \|^// ═\|^  // ──" <archivo>   # índice del archivo
grep -n "id: 'evt_" lib/data/game_content.dart                    # eventos existentes
grep -n "^  RealMissionConfig(\|^  StoryMissionConfig(" lib/data/*.dart
grep -n "Widget _build" lib/presentation/screens/home/home_screen.dart
```

Para búsquedas amplias (¿dónde se usa X?, ¿existe Y?), delegá en el subagente `Explore` en vez de leer archivos.

## Invariantes (romperlos es un bug de diseño, no de código)

1. **Nada de destreza.** Todo el gameplay es elegir entre 2-3 opciones. Nunca timing, tapping ni minijuegos.
2. **Ninguna acción del jugador puede requerir >3 min de atención continua.**
3. **Contraste WCAG AA obligatorio** (≥4.5:1; títulos grandes ≥3:1). `textMuted` nunca más oscuro que `#9C9484`.
4. **Sin emojis en UI** — íconos Material (el set ya usado). Los emojis en `SkillTypeX.emoji` son deuda heredada, no los propagues.
5. **`domain/` no importa Flutter ni `data/`** (lo verifica `test/fixes_test.dart`; el contenido llega por `GameContentCatalog`). El contenido (`data/`) no contiene lógica; la lógica (`usecases/`) no contiene prosa.
6. **Las consecuencias narrativas son duras; las mecánicas, suaves.** Nunca se quitan skills, monedas ni mensajeros.
7. **Cap de poder del árbol: +25%** de efectividad por camino maxeado. El azar siempre permite fallar en riesgo 4-5.
8. **Persistencia local:** todo pasa por `local_repositories.dart` (SharedPreferences, JSON con sufijo `_v2`). Al cambiar el esquema de una entidad, agregá migración.

## Estado real (2026-07)

Implementado: loop core con timer real, tutorial de 4 pruebas, 3+ rutas, pool de eventos con prosa propia, arco `arc_claudius`, reputación/flags/diario, árbol de skills 1-10 con Sellos, contratos diarios, paga del gremio, tienda, multi-mensajero (4 slots).

También: avisos locales (eventos, entrega, ocioso, contratos; el tap abre la misión) y auto-resolución de eventos a los 60 min.

Pendiente (ver roadmap): IAP real (`shop_screen.dart` tiene paywall dummy), rewarded ads, migrar contenido a JSON, backend Firebase, auth real (hoy login dummy).

## Comandos

```bash
flutter pub get
flutter run
flutter test              # test/domain_test.dart
flutter analyze
```

## Convenciones

- **Todo el contenido de cara al jugador va en español rioplatense** (vos/tenés/mirá). El código y los comentarios, también en español.
- IDs en snake_case con prefijo: `evt_`, `opt_`, `claudius_`, `boost_`, `route_`.
- Comentarios de sección con `// ─── Título ───` y `// ═══` para bloques grandes: seguí ese estilo.
- Al cerrar una fase del roadmap, actualizá el GDD (es documento vivo: si código y GDD difieren, uno de los dos está mal).
