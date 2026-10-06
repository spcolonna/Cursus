# Cursus — guía para Claude

Juego móvil Flutter. Mensajero en la Roma del 50 a.C.: las misiones corren en **tiempo real de reloj**, los eventos son decisiones de 2-3 opciones. Sesiones de 1-3 min, 3-4 por día.

**Docs de diseño (fuente de verdad, leer solo la sección que haga falta):**
- [docs/GDD_MASTER_v2.md](docs/GDD_MASTER_v2.md) — §5 árbol de skills, §6 economía, §7 onboarding, §8 UX/legibilidad.
- [docs/ROADMAP_MEJORAS_v1.md](docs/ROADMAP_MEJORAS_v1.md) — fases y criterios de salida.
- [docs/ANALYTICS.md](docs/ANALYTICS.md) — eventos, métricas de retención y cómo enchufar Firebase. Todo evento nuevo sale de una factory de `AnalyticsEvent`.
- [docs/ART_PROMPTS.md](docs/ART_PROMPTS.md) — ilustraciones: estilo base, prompt de cada pieza y dónde va el archivo.

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
│   ├── entities/world.dart       Faction, FactionTier/FactionUnlock, WorldState (reputación, flags, diario, arcos)
│   ├── entities/skill_tree.dart  skillTree (5×10 nodos), sealCostForLevel, SkillPerks
│   ├── entities/guild.dart       contratos diarios (pools easy/medium/seal), paga diaria
│   ├── entities/content.dart     tipos del contenido (TutorialMission, RealEventConfig, StoryMissionConfig…)
│   ├── entities/progression.dart paga por ruta, PlayerStats, AchievementDef, ProgressionState
│   ├── entities/weekly.dart      encargos semanales: WeeklyCommissionDef, WeeklyState, semana ISO
│   ├── entities/analytics.dart   diccionario de eventos (AnalyticsEvent), RetentionLog, D_n/stickiness
│   ├── entities/geo.dart         GeoAtlas: proyección del mapa, trazado de cada ruta (Italia o Roma)
│   ├── repositories/             contratos abstractos + GameContentCatalog (contenido inyectado)
│   ├── usecases/usecases.dart    use cases del loop (ResolveEvent, CompleteMission, AscendSkill…)
│   ├── usecases/event_selection.dart  pickEventsForMission: pool + consecuencias, memoria, eventos de una vez
│   ├── usecases/progression_usecases.dart  GetProgression (migra), RecordProgress, EquipTitle
│   ├── usecases/weekly_usecases.dart       GetWeekly, RecordWeeklyProgress, ClaimWeeklyCommission
│   └── usecases/analytics_usecases.dart    TrackSession (sesiones y días activos)
├── infrastructure/local/local_repositories.dart   SharedPreferences (sin backend)
├── infrastructure/analytics/      AnalyticsService (fachada + opt-out), sinks de consola y buffer local
├── infrastructure/audio/sfx_service.dart  enum Sfx + pool de players (los WAV salen de tool/gen_sfx.py)
├── data/game_content.dart        CONTENIDO: tutorial, rutas fase 1, pool de eventos reales
├── data/story_content.dart       CONTENIDO: arcos (storyArcs), arc_claudius y el motor de capítulos
├── data/story_lucius.dart        CONTENIDO: arc_lucius "La Taberna del Buey" (5 caps, 3 finales)
├── data/story_rewards.dart       CONTENIDO: premios de los finales (rutas real_20/21, postas)
├── data/consequence_content.dart CONTENIDO: eventos que solo salen si el jugador hizo algo antes
├── data/progression_content.dart CONTENIDO: 26 logros con premios y títulos
├── data/faction_content.dart    CONTENIDO: rutas de facción, favores por escalón, encargos semanales
├── data/npc_content.dart        CONTENIDO: NPCs con retrato (id = nombre del archivo en assets/art/npcs)
├── data/geo_content.dart        CONTENIDO: coordenadas de ciudades, trazados de rutas, costas, Roma
├── data/static_game_content.dart StaticGameContent: implementa GameContentCatalog con lo de data/
└── presentation/
    ├── theme/app_theme.dart      AppColors, AppGradients, AppTextStyles, AppSpacing, AppRadii
    │                             + GameButton (variantes), GameCard, GradientScaffold, StatBar,
    │                             RiskChip, DeadlineChip, PackageBadge   ← design system
    ├── theme/motion.dart         AppMotion: duraciones, curvas y movimiento reducido
    ├── theme/art_palette.dart    ArtColors: colores de pintura (mapas, escenas, cera), nunca de texto
    ├── feedback/feedback.dart    AppFeedback: sonido + vibración en un solo lugar
    ├── widgets/components.dart   GameChip, GameIconButton/BackButton, GameDialog/Sheet,
    │                             Loading/Empty/ErrorState, LiveProgressBar, PeriodicBuilder,
    │                             CountUpText, ParticleBurst, showGameSnack/showErrorSnack
    ├── widgets/widgets.dart      CurrencyChip, RewardAmount, showRewardToast, GradeBadge…
    ├── widgets/progression_widgets.dart  AchievementMedal, RankLaurel, TitlePicker
    ├── widgets/faction_widgets.dart      FactionBadge, NpcPortrait, FactionUnlockList
    ├── widgets/art_image.dart            ArtImage + ArtPaths: ilustración opcional con respaldo por código
    ├── widgets/route_map.dart            RouteMapView (en vivo) y RouteMapThumbnail
    ├── widgets/event_scene.dart          EventBackdrop / EventScene: escenario del evento por categoría
    ├── widgets/insignia.dart             WaxSeal, FactionCrest
    ├── widgets/brand.dart                marca Cursus: BrandSealPainter (también genera el ícono), BrandMark
    ├── widgets/skill_tree_board.dart     árbol de caminos visual (5 columnas, sellos 6-10)
    ├── widgets/celebration_host.dart     logros, rangos y escalones de facción sobre toda la app
    ├── providers/providers.dart  Riverpod: DI + notifiers (home, guild, world, titles…)
    └── screens/                  splash, login, onboarding, character, home (+ home/parts/),
                                  mission, event, mission_result, profile, shop, skills, achievements
```

`router.dart` (go_router) · `main.dart` entry point.

## Cómo navegar sin quemar tokens

Archivos grandes: `mission_screen.dart` (900), `game_content.dart` (1k), `usecases.dart` (885), `shop_screen.dart` (887). **No los leas enteros.** Anclas útiles:

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

Implementado: mapas de ruta, escenarios de evento, mensajero ilustrado y árbol visual por código (ilustraciones opcionales encima), 17 SFX; loop core con timer real, paga por ruta, 26 logros con títulos equipables y celebraciones, escalones de facción con rutas y favores, encargos semanales, tutorial de 4 pruebas, 22 rutas, pool de eventos con prosa propia y selección con memoria, 9 eventos de consecuencia, arcos `arc_claudius` y `arc_lucius` con finales que abren rutas/postas/tienda, reputación/flags/diario, árbol de skills 1-10 con Sellos, contratos diarios, paga del gremio, tienda, multi-mensajero (4 slots).

También: avisos locales (eventos, entrega, ocioso, contratos; el tap abre la misión) y auto-resolución de eventos a los 60 min.

Pendiente (ver roadmap): IAP real (`shop_screen.dart` tiene paywall dummy), rewarded ads, migrar contenido a JSON, backend Firebase, auth real (hoy login dummy).

## Comandos

```bash
flutter pub get
flutter run
flutter test              # test/domain_test.dart
flutter analyze
python3 tool/gen_sfx.py   # regenera assets/audio/sfx_*.wav
flutter test tool/gen_icon_test.dart && dart run flutter_launcher_icons && dart run flutter_native_splash:create   # ícono y launch screen
```

## Convenciones

- **Todo el contenido de cara al jugador va en español rioplatense** (vos/tenés/mirá). El código y los comentarios, también en español.
- IDs en snake_case con prefijo: `evt_`, `opt_`, `claudius_`, `boost_`, `route_`.
- Comentarios de sección con `// ─── Título ───` y `// ═══` para bloques grandes: seguí ese estilo.
- Al cerrar una fase del roadmap, actualizá el GDD (es documento vivo: si código y GDD difieren, uno de los dos está mal).
