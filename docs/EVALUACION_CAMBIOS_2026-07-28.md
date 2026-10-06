# Evaluación de cambios — salto de calidad / engagement

**Fecha:** 2026-07-28  
**Versión app:** `1.0.0+2`  
**Base:** plan de análisis *Cursus* (vertical slice → engagement multi-nivel)

Este documento lista **todo lo que se agregó o tocó** para que puedas playtestear y auditar sin re-descubrir el diff.  
**No incluye** Firebase / FCM / battle pass / época 2 (gated por retención en el GDD).

---

## Resumen ejecutivo

| Palanca del plan | Estado |
|---|---|
| Comprimir fondos + icono de marca | Hecho (JPG &lt;500 KB + AppIcon iOS/Android) |
| Guest login (matar `test@test.com`) | Hecho |
| +12 rutas / +15 eventos | Hecho (Dart + JSON mirror) |
| Migración contenido → JSON | Loader listo; runtime sigue en Dart unificado |
| Tooltips + checklist Primeros pasos | Hecho |
| IAP real | Paquete + sandbox de playtest |
| Rewarded ads (−30 min) | Simulado (diálogo) + cap 4/día |
| SFX pack mínimo | Hecho (WAV + toggle en Ajustes) |
| Cosmética de finales (títulos) | Hecho en Perfil |
| Validar notificaciones en iPhone físico | **Manual** — no automatizable acá |

---

## 1. Assets / empaque

### Fondos comprimidos
- `assets/images/bg_home_day.jpg` (~453 KB)
- `assets/images/bg_home_night.jpg` (~207 KB)
- `assets/images/bg_event.jpg` (~170 KB)
- `assets/images/bg_login.jpg` (~253 KB)
- Referencias actualizadas a `.jpg` en:
  - `lib/presentation/theme/app_theme.dart`
  - `lib/presentation/screens/home/home_screen.dart`
  - `lib/presentation/screens/login/login_screen.dart`
- `cacheWidth: 1080` en Home/Login para menos memoria.

### Icono de marca
- Generado desde `logo-removebg.png` sobre navy.
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`

### Splash
- Emoji 📜 reemplazado por logo real (`splash_screen.dart`).

### Audio nuevo
- `assets/audio/sfx_success.wav`
- `assets/audio/sfx_partial.wav`
- `assets/audio/sfx_fail.wav`
- `assets/audio/sfx_delivery.wav`
- `assets/audio/sfx_tap.wav`

---

## 2. Guest login

**Archivos:**
- `lib/domain/usecases/usecases.dart` — `SignInUseCase.executeAsGuest`
- `lib/presentation/screens/login/login_screen.dart` — UI “ENTRAR COMO INVITADO”
- `lib/presentation/providers/providers.dart` — `AuthNotifier.signInAsGuest`

**Cómo probar:**
1. Borrar datos de la app / reinstalar.
2. Splash → Login: **no** debe aparecer `test@test.com`.
3. Tap “ENTRAR COMO INVITADO” → onboarding (primera vez) o Home.

---

## 3. Contenido (+12 rutas, +15 eventos)

**Archivos nuevos:**
- `lib/data/game_content_expansion.dart` — `expansionMissions` + `expansionEvents` + getters `allRealMissions` / `allRealEvents`
- `assets/content/routes_expansion.json`
- `assets/content/events_expansion.json`
- `lib/data/content_json_loader.dart` — parser JSON (pipeline Fase 2)

**Cableado runtime:**
- `lib/infrastructure/local/local_repositories.dart` → usa `allRealMissions` / `allRealEvents`
- `lib/domain/usecases/usecases.dart` → follow-ups desde `allRealEvents`

### Rutas nuevas (`real_04` … `real_15`)
| ID | Ruta | Duración | Rank |
|---|---|---|---|
| real_04 | Roma → Tibur | 30m | 1 |
| real_05 | Roma → Praeneste | 45m | 1 |
| real_06 | Roma → Antium | 60m | 1 |
| real_07 | Neapolis → Pompeii | 90m | 1 |
| real_08 | Roma → Cumae | 3h | 2 |
| real_09 | Roma → Beneventum | 4h | 2 |
| real_10 | Ravenna → Aquileia | 6h | 2 |
| real_11 | Pisae → Genua | 8h | 2 |
| real_12 | Roma → Tarentum | 8h | 2 |
| real_13 | Roma → Brundisium | 12h | 3 |
| real_14 | Roma → Aquileia | 24h | 3 |
| real_15 | Roma → Massilia | 48h | 3 |

### Eventos nuevos
`evt_flood`, `evt_tax_collector`, `evt_lost_child`, `evt_wolf`, `evt_ferry`, `evt_forge_fire`, `evt_oracle`, `evt_deserter`, `evt_wedding_road`, `evt_landslide`, `evt_spy_drop`, `evt_heatwave`, `evt_cart_jam`, `evt_temple_theft`, `evt_ghost_road`

**Cómo probar:**
1. Completar tutorial.
2. En Home deben aparecer rutas cortas nuevas (Tibur/Praeneste/Antium) con rank 1.
3. Verificar prosa específica en outcomes (no textos genéricos).
4. Opcional: cargar JSON con `ContentJsonLoader` en un test / debug.

---

## 4. Onboarding engagement

### Checklist “Primeros pasos”
- Widget: `lib/presentation/widgets/primeros_pasos.dart`
- Persistencia: `lib/infrastructure/progress/player_progress.dart`
- Provider: `primerosPasosProvider`
- Insertado en Home post-tutorial.

**Tareas:**
1. Primera ruta real  
2. Comprar ítem  
3. Subir skill  
4. Mirar tablón  
5. Activar notificaciones  

**Recompensa:** 3 Aureos + 1 Sello.

### Spotlights (primera vez)
- Home (`_HomeScaffold`)
- Evento (`EventScreen`)
- Tienda (`ShopScreen`)

**Cómo probar:** cuenta nueva → completar tutorial → ver checklist → completar 5 tareas → reclamar.

---

## 5. Audio (SFX)

- Servicio: `lib/infrastructure/audio/sfx_service.dart`
- Init en `lib/main.dart`
- Hooks:
  - `event_screen.dart` — success / partial / fail
  - `mission_result_screen.dart` — delivery / grade
- Toggle en Ajustes: `_SfxToggleCard`

**Cómo probar:** resolver evento → escuchar tono; Ajustes → apagar SFX → no debe sonar.

---

## 6. Monetización

### IAP
- `lib/infrastructure/monetization/iap_service.dart` (`in_app_purchase`)
- Paywall de `shop_screen.dart` ya **no** dice “Tienda en construcción”
- En **debug sin productos de store**: compra = sandbox y acredita Aureos/Denarios
- Pack del Correo mejorado: 30 Aureos + 2.º slot + 2 Sellos + curación
- Sellos en tienda: `seal_single` (15 Aureos), `seal_pack_10` (120 Aureos)

**Product IDs a crear en stores:**
- `messenger_aureos_50` / `_120` / `_300` / `_800`
- `messenger_starter_pack` / `messenger_warrior_pack`

### Rewarded ads
- `lib/infrastructure/monetization/rewarded_ads_service.dart` — diálogo simulado 2s
- Botón en misión: “Ver anuncio · −30 min” (`_TravelAdButton`)
- Cap 4/día persistido

**Cómo probar:** misión activa → ver anuncio simulado → progreso adelanta 30 min.

---

## 7. Cosmética / long-tail

- Al completar final de arco, se guarda `endingTitle` en prefs.
- Perfil muestra sección **Títulos ganados** (`_TitlesCard`).
- Emojis de headers del perfil reemplazados por texto limpio.

**Cómo probar:** terminar un final de `arc_claudius` → Perfil muestra el título.

---

## 8. Dependencias (`pubspec.yaml`)

Nuevas:
- `audioplayers: ^6.1.0`
- `in_app_purchase: ^3.2.0`

Assets:
- `assets/images/`
- `assets/audio/`
- `assets/content/`

---

## 9. Archivos tocados (checklist de review)

### Nuevos
- `lib/data/game_content_expansion.dart`
- `lib/data/content_json_loader.dart`
- `lib/infrastructure/audio/sfx_service.dart`
- `lib/infrastructure/progress/player_progress.dart`
- `lib/infrastructure/monetization/iap_service.dart`
- `lib/infrastructure/monetization/rewarded_ads_service.dart`
- `lib/presentation/widgets/primeros_pasos.dart`
- `assets/audio/*`
- `assets/content/*`
- `docs/EVALUACION_CAMBIOS_2026-07-28.md` (este archivo)

### Modificados (principales)
- `pubspec.yaml`, `lib/main.dart`, `lib/presentation/providers/providers.dart`
- `lib/domain/usecases/usecases.dart`
- `lib/infrastructure/local/local_repositories.dart`
- Login / Splash / Home / Event / Mission / MissionResult / Shop / Profile / Skills / Settings / Theme
- Iconos iOS + Android mipmaps

---

## 10. Plan de pruebas sugerido (1–2 sesiones)

1. **Cold start:** icono de marca en launcher, splash con logo, login invitado.
2. **Tutorial → Home:** checklist visible; spotlight Home.
3. **Ruta corta nueva** (Tibur 30m): aceptar, forzar evento (o skip), prosa propia, SFX.
4. **Tienda:** comprar poción (checklist “comprá”); IAP sandbox (bolsa de Aureos).
5. **Árbol:** subir un nivel (checklist skill).
6. **Tablón:** abrir Home (checklist gremio).
7. **Notifs:** aceptar misión real → diálogo Varus → permiso (checklist notifs) → reclamar recompensa.
8. **Ad −30 min:** en misión media, 4 veces máx.
9. **Perf:** Home day/night carga rápido (sin PNG 9 MB).
10. **Device físico:** validar push con panel Diagnóstico en Ajustes (pendiente de campo).

---

## 11. Pendiente explícito (fuera de este lote)

- Validación de notificaciones en iPhone físico
- Productos IAP reales en App Store Connect / Play Console
- AdMob con App ID / unit IDs de producción
- Firebase Auth + cloud save + Analytics + FCM (Fase 4)
- Servir contenido 100% desde JSON remoto
- Battle pass / época 2 (gateado por D7)
- Bundle IDs `com.example.*` → IDs de producción
- Inicializar git/CI

---

## 12. Criterios de éxito del playtest

- Jugador nuevo **no** ve credenciales dummy.
- Tras tutorial hay **variedad** de rutas ≤2h disponibles.
- Checklist se completa y paga 3 Aureos + 1 Sello.
- Outcomes suenan; se pueden silenciar.
- IAP sandbox acredita; ads adelantan viaje.
- App arranca sin jank obvio por fondos.
