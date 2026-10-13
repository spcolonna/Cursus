# Analytics y retención

Qué se mide, cómo se calcula cada número y qué decisión dispara. Las definiciones no se escriben dos veces: los eventos y las métricas están en código, en [`lib/domain/entities/analytics.dart`](../lib/domain/entities/analytics.dart), y este documento los explica.

## 1. Preguntas que tiene que contestar

1. **¿Vuelven?** D1, D7 y D30, y la curva por cohorte semanal.
2. **¿Dónde se van?** El embudo de las primeras dos horas y del arco.
3. **¿El loop respira?** Sesiones por día, eventos auto-resueltos (no volvió a tiempo) y misiones aceptadas por sesión.
4. **¿Se gasta el contenido?** El capítulo alcanzado, la repetición de eventos y en qué día de juego deja de subir el rango.
5. **¿La economía se sostiene?** Denarios por día, uso de "adelantar" y compras en la tienda.

## 2. Definiciones

| Métrica | Definición | En código |
|---|---|---|
| **Sesión** | Abrir el juego o volver de segundo plano después de 30 min o más sin uso. Cruzar la medianoche corta la sesión. | `RetentionLog.open`, `kSessionTimeout` |
| **Día de juego** | Días de calendario desde la instalación: 0 es el día que instaló. | `RetentionLog.dayIndex` |
| **D_n clásica** | Porcentaje de la cohorte que abrió el juego **exactamente** el día n. Solo cuenta a quienes instalaron hace n días o más. | `classicRetention` |
| **D_n rolling** | Porcentaje que volvió el día n **o cualquier día después**. Encaja mejor en un juego de temporizador, al que se entra de a ratos. | `rollingRetention` |
| **Stickiness** | DAU promedio de los últimos 30 días dividido el MAU. | `stickiness` |
| **Cohorte** | Jugadores que instalaron la misma semana (ISO). | — |

**Ejemplo con 4 jugadores, todos con más de 30 días desde que instalaron:**

| Jugador | Días en que abrió el juego | Cuenta para D1 clásica | Cuenta para D7 clásica | Cuenta para D7 rolling |
|---|---|---|---|---|
| A | 0, 1, 7, 30 | sí | sí | sí |
| B | 0, 1, 2 | sí | no | no |
| C | 0, 8 | no | no | sí |
| D | 0 | no | no | no |
| **Resultado** | | **D1 = 50%** | **D7 = 25%** | **D7 rolling = 50%** |

## 3. Diccionario de eventos

Los nombres están en snake_case, con 40 caracteres como máximo, y ninguno usa los nombres reservados de Firebase. Un test (`test/analytics_test.dart`) lo verifica. `session_start`, `first_open` y `screen_view` son de Firebase; el juego usa `game_session`.

| Evento | Cuándo | Parámetros |
|---|---|---|
| `game_session` | Empieza una sesión | `day`, `session_of_day`, `days_active` |
| `tutorial_step` | Acepta la prueba N del tutorial | `step` (0-3) |
| `tutorial_complete` | Entrega la última prueba | — |
| `mission_accept` | Acepta una misión | `route_id`, `kind` (real/story/tutorial), `rank`, `minutes`, `busy_messengers` |
| `event_resolved` | Decide en un evento | `event` (id del contenido, como `evt_storm`), `category` (escenario), `outcome`, `risk`, `score` |
| `events_auto_resolved` | Al abrir, había eventos vencidos | `count` |
| `mission_complete` | Entrega | `route_id`, `kind`, `grade`, `denarios` |
| `skip_to_event` | Paga para adelantar | `cost` |
| `rewarded_ad` | Ve un anuncio con premio | `placement` |
| `story_chapter` | Acepta un capítulo | `arc_id`, `chapter` (1-5), `variant` |
| `arc_complete` | Cierra un arco | `arc_id`, `ending` |
| `skill_level` | Sube una habilidad | `skill`, `level`, `via` (xp/pick/ascend) |
| `rank_up` | Sube de rango | `rank` |
| `achievement_unlock` | Gana un logro | `achievement_id` |
| `faction_tier` | Sube de escalón en una facción | `faction`, `tier` |
| `slot_unlock` | Contrata otro mensajero | `slots` |
| `daily_pay_claim` | Cobra la paga diaria | `streak_day` |
| `contract_claim` | Cobra un contrato | `contract_id` |
| `contract_reroll` | Cambia un contrato | — |
| `weekly_claim` | Cobra un encargo semanal | `commission_id` |
| `shop_item` | Compra con Denarios o Aureos | `item_id`, `currency`, `price` |
| `iap_credited` | Se acredita una compra real | `product_id` |

**Propiedades del jugador:** `player_rank` y `messengers`. Solo se mandan cuando cambian.

**Para agregar un evento:**
1. Crear la factory en `AnalyticsEvent`.
2. Agregarla a la lista del test.
3. Dispararla desde el notifier con `ref.read(analyticsProvider).track(...)`.
4. Sumar la fila a esta tabla.

Nunca hay que armar un `AnalyticsEvent('nombre')` suelto en una pantalla.

## 4. Embudos y tableros

**Primera experiencia** (en Firebase, un embudo cerrado):
`game_session (day 0)` → `tutorial_step 0` → `tutorial_step 3` → `tutorial_complete` → `mission_accept kind=real` → `mission_complete kind=real` → `story_chapter 1`

**Arco:** `story_chapter` 1 → 2 → 3 → 4 → 5 → `arc_complete`, partido por `ending`.

**Salud del loop** (por día y por jugador activo):
- `game_session` por DAU. El objetivo es 3 o más.
- `events_auto_resolved.count` sobre `event_resolved`. Si pasa de 25%, los avisos no alcanzan o los eventos llegan a mala hora.
- `mission_accept` por sesión. Si es menor que 0,5, el jugador entra a mirar y no encuentra qué hacer.

**Agotamiento del contenido:**
- Distribución de `rank` en `mission_accept` según `day`. Si se aplana antes del día 30, la progresión se estanca.
- Eventos distintos vistos por jugador sobre `event_resolved` totales, contando por `event` (el id del contenido).

**Economía:**
- `mission_complete.denarios` más los contratos, por DAU. El objetivo es ~435 (GDD §6.2).
- `skip_to_event` por DAU. Si sube mucho, sobran Denarios.

## 5. Objetivos y qué hacer si no se cumplen

| Métrica | Objetivo | Si queda por debajo, mirar primero |
|---|---|---|
| D1 | ≥ 40% | Embudo de la primera experiencia: ¿se cae entre `tutorial_step` 0 y 3? Acortar el tutorial o adelantar la primera recompensa. |
| D7 | ≥ 20% | `events_auto_resolved`, el día en que se corta la racha y la repetición de eventos. Es lo que mueve la Fase 5. |
| D30 | ≥ 6% | `story_chapter` alcanzado y la meseta de `rank`. Falta contenido de mediano plazo. |
| Stickiness | ≥ 20% | Sesiones por día. Si es baja con buen D7, juegan pero de a días sueltos: hay que revisar los avisos. |
| Sesiones por día | ≥ 3 | Duración de las rutas aceptadas: si todas son de 8 h o más, no hay motivo para volver. |
| Respuesta a eventos en < 60 min | ≥ 50% | Lo mismo que `events_auto_resolved`. |

Cualquier cambio de diseño se compara **por cohorte**: la semana anterior al cambio contra la semana posterior. Nunca hay que mezclar jugadores viejos con nuevos.

## 6. Beta cerrada

1. **Ahora, sin Firebase:**
   - Llevar 20-50 testers por TestFlight o Play Internal.
   - A los 7 y 14 días, cada uno abre **Ajustes → Datos de uso → Copiar datos para el equipo** y pega el JSON en un mensaje. Incluye su `RetentionLog` y los últimos 500 eventos.
   - Alcanza para ver el embudo y las sesiones por día, pero no la retención: los que se van no mandan nada.
2. **Con Firebase:**
   - 200-500 testers durante 30 días.
   - Con 300 jugadores, un D7 de 15% tiene un margen de ±4 puntos (IC 95%). Sirve para decidir, no para afinar.

## 7. Firebase

Ya está enchufado (fase L1). Firebase es un sink más de `AnalyticsService`; si no inicializa (config rota, tests), el juego sigue con los sinks locales.

- **Proyectos:** `cursus-dev` para los builds debug y `cursus-prod` para release y profile, en la cuenta spcolonna@gmail.com. Cada build toma la config nativa de su proyecto:
  - iOS: `ios/config/<dev|prod>/GoogleService-Info.plist`. La fase *Firebase config* de Runner copia el que corresponde a la configuración.
  - Android: `android/app/src/<debug|profile|release>/google-services.json`.
- **Código:**
  - `infrastructure/firebase/firebase_setup.dart`: `initFirebase()` y Crashlytics, que solo recolecta fuera de debug.
  - `infrastructure/analytics/firebase_analytics_sink.dart`: el sink de Firebase.
  - El opt-out de Ajustes apaga también la recolección automática de Firebase (`AnalyticsCollectionControl`).
- **Ver eventos en vivo:** correr con `-FIRDebugEnabled` (Xcode → scheme → Arguments) o, en Android, `adb shell setprop debug.firebase.analytics.app com.spcolonna.cursus`, y abrir DebugView en la consola de cursus-dev.
- **Ajustes remotos** (Remote Config, `domain/entities/remote_flags.dart`):

  | Clave | Default | Para qué |
  |---|---|---|
  | `min_supported_version` | vacío | Versión mínima: si la instalada es más vieja, `ForceUpdateGate` pide actualizar |
  | `store_url_ios` / `store_url_android` | vacío | Botón "Actualizar" de ese pedido |
  | `travel_ads_per_day` | 4 | Adelantos −30 min con anuncio por día (0 a 10) |
  | `content_bundle_version` | 0 | Paquete de contenido remoto (fase L5) |

  Los valores nuevos se bajan en segundo plano y entran en la **próxima** apertura: nunca cambian las reglas en medio de una partida. Un valor roto cae al default.

**Pendiente en la consola:**

1. **Registrar los parámetros** como dimensiones personalizadas en la consola: `route_id`, `kind`, `grade`, `chapter`, `tier`. Sin eso no se pueden cortar los informes.
2. **Opcional: exportar a BigQuery** (gratis hasta 10 GB). Este SQL calcula la retención clásica por cohorte diaria:
   ```sql
   WITH first AS (
     SELECT user_pseudo_id, MIN(PARSE_DATE('%Y%m%d', event_date)) AS d0
     FROM `PROYECTO.analytics_XXX.events_*`
     WHERE event_name = 'first_open' GROUP BY 1),
   active AS (
     SELECT DISTINCT user_pseudo_id, PARSE_DATE('%Y%m%d', event_date) AS d
     FROM `PROYECTO.analytics_XXX.events_*`
     WHERE event_name = 'game_session')
   SELECT f.d0 AS cohorte,
     COUNT(DISTINCT f.user_pseudo_id) AS instalaron,
     COUNT(DISTINCT IF(DATE_DIFF(a.d, f.d0, DAY) = 1,  a.user_pseudo_id, NULL)) / COUNT(DISTINCT f.user_pseudo_id) AS d1,
     COUNT(DISTINCT IF(DATE_DIFF(a.d, f.d0, DAY) = 7,  a.user_pseudo_id, NULL)) / COUNT(DISTINCT f.user_pseudo_id) AS d7,
     COUNT(DISTINCT IF(DATE_DIFF(a.d, f.d0, DAY) = 30, a.user_pseudo_id, NULL)) / COUNT(DISTINCT f.user_pseudo_id) AS d30
   FROM first f LEFT JOIN active a USING (user_pseudo_id)
   GROUP BY 1 ORDER BY 1;
   ```

## 8. Privacidad

- **Qué se manda:** ningún evento lleva nombre, email ni texto que escriba el jugador. Los nombres de los mensajeros nunca se envían.
- **Opt-out:** se apaga en Ajustes, que está encendido por defecto. Con el switch apagado no sale nada; el registro de días de juego queda solo en el dispositivo.
- **App Store:**
  - Declarar *Datos de uso → Interacción con el producto*, no vinculados a la identidad y no usados para rastreo.
  - Firebase suma un identificador de instancia: hay que revisar su guía de etiquetas de privacidad al publicar.
  - Sin AdMob no hace falta el aviso de ATT. Cuando se integren los anuncios con premio (GDD §6.4), sí.
- **Crashlytics** manda trazas de crash y datos del dispositivo (modelo, versión de SO), sin datos del jugador. En las dos tiendas se declara como *Diagnóstico → Datos de crash*.
- **Google Play:** en *Data safety*, declarar lo mismo.

## 9. Limitaciones conocidas

- **Jugadores que ya existían:** empiezan a contar desde el día en que actualizan. Su día 0 no es la instalación real.
- **Identidad de los eventos:** los guardados de antes de la Fase 4 se reconocen por el título al cargar. Si un título cambió, ese evento se manda con el título en vez del id.
- **Eventos sin red:** el buffer local guarda los últimos 500. Firebase también encola sin conexión y manda al recuperarla.
