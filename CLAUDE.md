# Cursus — guía para Claude

Juego móvil Flutter. Mensajero en la Roma del 50 a.C.: las misiones corren en **tiempo real de reloj**, los eventos son decisiones de 2-3 opciones. Sesiones de 1-3 min, 3-4 por día.

**Docs de diseño (fuente de verdad, leer solo la sección que haga falta):**
- [docs/GDD_MASTER_v2.md](docs/GDD_MASTER_v2.md) — §5 árbol de skills, §6 economía, §7 onboarding, §8 UX/legibilidad.
- [docs/ROADMAP_MEJORAS_v1.md](docs/ROADMAP_MEJORAS_v1.md) — fases y criterios de salida.
- [docs/ANALYTICS.md](docs/ANALYTICS.md) — eventos, métricas de retención y cómo enchufar Firebase. Todo evento nuevo sale de una factory de `AnalyticsEvent`.
- [docs/IDENTIDAD.md](docs/IDENTIDAD.md) — manual de marca: color, tipografía, ilustración, sonido y voz.
- [docs/GEMINI_ASSETS.md](docs/GEMINI_ASSETS.md) — especificación completa de las 61 ilustraciones para generarlas con Gemini (ruta, tamaño, composición, personajes).
- [docs/CHATGPT_PROMPTS.md](docs/CHATGPT_PROMPTS.md) — las mismas 61 ilustraciones en bloques de hasta 10 para pegar en ChatGPT, con qué adjuntar y el comando de `tool/process_art.py` de cada una.
- [docs/ART_PROMPTS.md](docs/ART_PROMPTS.md) — ilustraciones: estilo base, prompt de cada pieza, flujo con ChatGPT (§11) y dónde va el archivo (`tool/process_art.py` lo deja listo).
- [docs/AUDIO.md](docs/AUDIO.md) — identidad sonora, el motivo D-A-E y la hoja de cues de música, SFX y aviso.
- [docs/CUENTAS.md](docs/CUENTAS.md) — cuenta anónima, guardado en la nube (qué viaja), vincular Google/Apple, borrar cuenta.
- [docs/PUBLICAR.md](docs/PUBLICAR.md) — checklist de publicación (firma, privacidad, tiendas) y [docs/STORE_LISTING.md](docs/STORE_LISTING.md) (fichas ES/EN).
- [docs/LOCALIZACION.md](docs/LOCALIZACION.md) — español/inglés: ARB de la UI, tabla del contenido, glosario y voz.
- [docs/MONETIZACION.md](docs/MONETIZACION.md) — compras (precios, estados, sin doble crédito), AdMob rewarded y consentimiento, qué falta para publicar.

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
│   ├── entities/remote_flags.dart RemoteFlags: ajustes remotos con defaults seguros, compareVersions
│   ├── entities/save_snapshot.dart SaveSnapshot (partida en un paquete), migración y decideSync
│   ├── entities/game_clock.dart  GameClock: la hora del juego (toda regla de tiempo la lee de acá)
│   ├── entities/geo.dart         GeoAtlas: proyección del mapa, trazado de cada ruta (Italia o Roma)
│   ├── repositories/             contratos abstractos + GameContentCatalog (contenido inyectado)
│   ├── usecases/usecases.dart    use cases del loop (ResolveEvent, CompleteMission, AscendSkill…)
│   ├── usecases/event_selection.dart  pickEventsForMission: pool + consecuencias, memoria, eventos de una vez
│   ├── usecases/progression_usecases.dart  GetProgression (migra), RecordProgress, EquipTitle
│   ├── usecases/weekly_usecases.dart       GetWeekly, RecordWeeklyProgress, ClaimWeeklyCommission
│   └── usecases/analytics_usecases.dart    TrackSession (sesiones y días activos)
├── infrastructure/local/local_repositories.dart   SharedPreferences (sin backend)
├── infrastructure/analytics/      AnalyticsService (fachada + opt-out), sinks de consola, buffer local y Firebase
├── infrastructure/firebase/       initFirebase (+ Crashlytics), FirebaseRemoteFlags (Remote Config)
├── infrastructure/cloud/          kCloudSaveKeys, CloudSyncService, Auth (anónimo/Google/Apple) y Firestore
├── infrastructure/monetization/   IapService (precio localizado, estados, PurchaseLedger), RewardedAdsService (AdMob + UMP)
├── infrastructure/time/           TrustedTimeService: ancla GameClock al servidor y al reloj monotónico (canal cursus/clock)
├── infrastructure/audio/sfx_service.dart  enum Sfx + pool de players (los WAV salen de tool/gen_sfx.py)
├── infrastructure/audio/music_service.dart  MusicTrack + MusicService: loop, crossfade, ducking, pausa en 2.º plano
├── data/game_content.dart        CONTENIDO: tutorial, rutas fase 1, pool de eventos reales
├── data/story_content.dart       CONTENIDO: arcos (storyArcs), arc_claudius y el motor de capítulos
├── data/story_lucius.dart        CONTENIDO: arc_lucius "La Taberna del Buey" (5 caps, 3 finales)
├── data/story_legion.dart        CONTENIDO: arc_legion "El Águila de la Decimotercera" (5 caps, 3 finales)
├── data/road_events_v2.dart      CONTENIDO: 22 eventos de camino del lanzamiento (roadEventsV2)
├── data/story_rewards.dart       CONTENIDO: premios de los finales (rutas real_20/21, postas)
├── data/consequence_content.dart CONTENIDO: eventos que solo salen si el jugador hizo algo antes
├── data/progression_content.dart CONTENIDO: 30 logros con premios y títulos
├── data/faction_content.dart    CONTENIDO: rutas de facción, favores por escalón, encargos semanales
├── data/npc_content.dart        CONTENIDO: NPCs con retrato (id = nombre del archivo en assets/art/npcs)
├── data/geo_content.dart        CONTENIDO: coordenadas de ciudades, trazados de rutas, costas, Roma
├── data/static_game_content.dart StaticGameContent: implementa GameContentCatalog con lo de data/
└── presentation/
    ├── theme/app_theme.dart      AppColors (papel, tinta y pigmentos), kTextPairs, AppGradients,
    │                             AppTextStyles (Marcellus/Figtree/Literata), AppSpacing, AppRadii
    │                             + GameButton (variantes), GameCard, PompeianFrieze, GradientScaffold,
    │                             StatBar, RiskChip, DeadlineChip, PackageBadge   ← design system
    ├── theme/motion.dart         AppMotion: duraciones, curvas y movimiento reducido
    ├── theme/sky.dart            SkyPalette: el cielo de la hora real (4 cielos fundidos, astro, título legible)
    ├── theme/art_palette.dart    ArtColors: pigmentos del fresco (mapas, escenas, cera), nunca de texto
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
    ├── widgets/living_sky.dart           LivingSkyBackground: paisaje de la hora (home, splash, login)
    ├── widgets/insignia.dart             WaxSeal, FactionCrest
    ├── widgets/brand.dart                marca Cursus: BrandSealPainter (también genera el ícono), BrandMark
    ├── widgets/skill_tree_board.dart     árbol de caminos visual (5 columnas, sellos 6-10)
    ├── widgets/celebration_host.dart     logros, rangos y escalones de facción sobre toda la app
    ├── widgets/music_director.dart       qué tema suena según ruta, hora y arco (musicTrackFor)
    ├── widgets/force_update_gate.dart    pide actualizar si la versión es menor a min_supported_version
    ├── widgets/cloud_widgets.dart        elegir partida (conflicto) y AccountCard de Ajustes
    ├── providers/providers.dart  Riverpod: DI + notifiers (home, guild, world, titles…) + skyPaletteProvider
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
3. **Contraste WCAG AA obligatorio** (≥4.5:1; títulos grandes ≥3:1). Todo par texto/fondo está en `kTextPairs` y lo valida `test/contrast_test.dart`. `inkMuted` nunca más clara que `#5E4F41`.
4. **Sin emojis en UI** — íconos Material (el set ya usado).
5. **`domain/` no importa Flutter ni `data/`** (lo verifica `test/fixes_test.dart`; el contenido llega por `GameContentCatalog`). El contenido (`data/`) no contiene lógica; la lógica (`usecases/`) no contiene prosa.
6. **Las consecuencias narrativas son duras; las mecánicas, suaves.** Nunca se quitan skills, monedas ni mensajeros.
7. **Cap de poder del árbol: +25%** de efectividad por camino maxeado. El azar siempre permite fallar en riesgo 4-5.
8. **Persistencia local primero:** todo pasa por `local_repositories.dart` (SharedPreferences, JSON con sufijo `_v2`). Al cambiar el esquema de una entidad, agregá migración. Una clave nueva se clasifica como partida (`kCloudSaveKeys`, viaja a la nube) o del teléfono (lo controla `cloud_save_test.dart`).
9. **La hora del juego es `GameClock.now()`, nunca `DateTime.now()`** en reglas, timers, diarios, semanales ni avisos (los avisos se programan con `GameClock.toDevice`). Cambiar la hora del teléfono no tiene que adelantar nada. `test/game_clock_test.dart` traba los `DateTime.now()` nuevos en `domain/`.
10. **El contenido se lee traducido:** nada fuera de `lib/data/` lee las constantes en español directo; se pasa por `StaticGameContent` o `localized_content.dart` (`lTutorialMissions`, `lRealEvents`…).

## Estado real (2026-07)

Implementado: cielo vivo según la hora real (home, splash, login, escenas, mapa); arte por código al estilo fresco (mapas de ruta, escenarios de evento, mensajero, sellos y árbol visual) (ilustraciones opcionales encima); identidad sonora: 18 SFX de materiales, motivo D-A-E (splash, nota S, avisos) y música por hora, viaje y arco (placeholders sintetizados); loop core con timer real, paga por ruta, 30 logros con títulos equipables y celebraciones, galería de 9 finales con recorrido de arcos, escalones de facción con rutas y favores, encargos semanales, tutorial de 4 pruebas, 25 rutas, 59 eventos de camino con prosa propia y selección con memoria (12 últimos), 9 eventos de consecuencia, arcos `arc_claudius`, `arc_lucius` y `arc_legion` con finales que abren rutas/postas/tienda, reputación/flags/diario, árbol de skills 1-10 con Sellos, contratos diarios, paga del gremio, tienda, multi-mensajero (4 slots).

También: avisos locales (eventos, entrega, ocioso, contratos; el tap abre la misión) y auto-resolución de eventos a los 60 min.

Firebase (L1): cursus-dev en debug y cursus-prod en release; Crashlytics, Analytics y Remote Config (ver docs/ANALYTICS.md §7).
Cuentas (L2): cuenta anónima, guardado en Firestore con elección de partida, borrar cuenta; Google/Apple listos en código, apagados hasta configurar la consola (docs/CUENTAS.md). **La nube está apagada** (`kCloudSaveReady = false` en `firebase_cloud.dart`): mientras no haya nada online la partida vive solo en el teléfono y Ajustes ofrece "Borrar partida". Todo en plan Spark: nada de Cloud Functions.
iPad: misma app, solo vertical y a pantalla completa; `TabletFrame` (`widgets/widgets.dart`) agranda la UI ×1,2 y la limita a una hoja de 600 de ancho centrada.
Reloj confiable (L3): `GameClock` anclado a la hora del servidor (cabecera Date de HTTPS) y, sin red, al reloj monotónico del sistema.
Contenido (L5): validador de todo el contenido (`test/content_validator_test.dart`: ids únicos, referencias, presupuesto de texto, nada muerto); el inglés irá como traducción encima, indexada por id (sin migrar la estructura a JSON).
Idiomas (L6): español neutro en UI e inglés completo (UI, contenido, dominio, avisos); selector en Ajustes, por defecto el del teléfono.
Monetización (L4): precios de la tienda localizados, estados de compra y crédito idempotente por transacción; AdMob rewarded con ids de prueba y consentimiento UMP. Sin validar recibos en servidor (necesita Blaze).

Release (L8, parte de código): firma Android por key.properties, PrivacyInfo.xcprivacy, alarmas exactas opcionales, política y términos en site/ con enlaces en Ajustes.

Pendiente (plan de lanzamiento L7-L9): arte final y música (los generás vos), cuentas de tienda y AdMob, beta.

## Comandos

```bash
flutter pub get
flutter run
flutter test              # test/domain_test.dart
flutter analyze
python3 tool/gen_sfx.py   # regenera assets/audio/sfx_*.wav y el sonido de aviso (Android/iOS)
python3 tool/gen_music.py # regenera assets/audio/music_*.m4a (placeholders; necesita afconvert de macOS)
flutter test tool/gen_icon_test.dart && dart run flutter_launcher_icons && dart run flutter_native_splash:create   # ícono y launch screen
```

## Convenciones

- **Idiomas: español (fuente) e inglés.** Todo el español que ve el jugador (UI, contenido, narrador, personajes) va en **español neutro con tuteo** (tienes/mira), sin voseo. La UI va en `lib/l10n/app_*.arb` — nunca texto literal en `presentation/` (`test/ui_literals_test.dart`). Del contenido (`lib/data/`), el inglés va en `assets/l10n/content_en.json` y los textos que arma el dominio en `kDomainStrings` (`ds()`). Contenido nuevo → agregá su inglés (`test/content_l10n_test.dart` lo exige). Ver docs/LOCALIZACION.md.
- El código y los comentarios, en español.
- IDs en snake_case con prefijo: `evt_`, `opt_`, `claudius_`, `boost_`, `route_`.
- Comentarios de sección con `// ─── Título ───` y `// ═══` para bloques grandes: seguí ese estilo.
- Al cerrar una fase del roadmap, actualizá el GDD (es documento vivo: si código y GDD difieren, uno de los dos está mal).
