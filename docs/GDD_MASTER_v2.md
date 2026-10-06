# THE MESSENGER — GDD Maestro v2.0

**Documento vivo.** Describe (A) el juego que existe hoy en el código, y (B) la dirección aprobada hacia donde lo llevamos. Nada especulativo: lo que no está aprobado va al Apéndice como backlog. Reemplaza como guía de trabajo al `The_Messenger_GDD_v1.docx` (que queda como archivo histórico de la visión original).

Última actualización: 2026-07-27.

---

## 1. Visión y pilares

**The Messenger es el juego que vive en tu día.** Encarnás a un mensajero en la Roma del 50 a.C. Tus misiones transcurren en **tiempo real de reloj**: aceptás una entrega de 2 horas y tu mensajero viaja esas 2 horas, aunque cierres la app. En el camino pasan cosas — patrullas, tormentas, bandidos — y cada una te pide una decisión de 1 minuto que puede salvar o arruinar la entrega.

No competimos por horas de atención: competimos por **momentos**. El jugador ideal abre el juego 3-4 veces al día, 1-3 minutos por vez, y entre sesiones el juego sigue "pasando" — eso genera anticipación, no ansiedad.

### Pilares (en orden de prioridad)

1. **Decisiones, no reflejos.** Todo el gameplay es elegir entre 2-3 opciones con riesgo, costo de tiempo y requisitos de habilidad. Nunca hay ejecución de destreza.
2. **El tiempo real es LA mecánica.** La espera es contenido: mientras no jugás, tu mensajero viaja. El juego te busca a vos (notificaciones), no al revés. *(Implementado: avisos locales de evento y de entrega, con silencio nocturno y opt-out por tipo.)*
3. **Sesiones de 1-3 minutos, 3-4 al día.** Ninguna acción del jugador debe requerir más de 3 minutos de atención continua.
4. **Sabor histórico auténtico, tono liviano.** Roma real (rutas, nombres, oficios) contada con humor y personajes memorables, no lección de historia.

### Target

Jugador **casual, 25-45 años**, que juega en huecos del día (viaje, almuerzo, antes de dormir). Tolera esperas largas si le avisan cuando pasa algo. F2P con IAP y rewarded ads; nunca pay-to-win destructivo: pagar acelera y profundiza, no reemplaza jugar.

### Fantasía central

"Soy un correo de confianza en un mundo peligroso. Cada paquete que entrego intacto y a tiempo construye mi leyenda."

---

## 2. Estado real del código (qué ES el juego hoy)

Flutter, arquitectura limpia (`domain/` → `infrastructure/` → `presentation/` con Riverpod y go_router). **Todo local**: persistencia en SharedPreferences, sin backend, sin Firebase. Login dummy (`test@test.com`/`1234` hardcodeado). Contenido 100% hardcodeado en `lib/data/game_content.dart`.

### 2.1 Loop core (implementado y funcional)

1. En el Home elegís una ruta disponible según tu rank y la aceptás.
2. Corre un **timer real** (`MissionProgressNotifier`, tick de 1s). El progreso es `tiempo transcurrido / duración`.
3. Los eventos se distribuyen en slots a lo largo de la duración. Cuando un evento llega, **el progreso se congela** hasta que lo resuelvas. No hay auto-resolución: si no abrís la app, la misión queda frenada indefinidamente.
4. Cada evento ofrece 2-3 opciones con `riskLevel` (1-5), `timeCostMinutes` y `requiredSkills` (gating: sin el nivel de skill, la opción no está disponible).
5. **Fórmula de resolución** (`ResolveEventUseCase._calculateOutcome` en `lib/domain/usecases/usecases.dart:439`):
   `score = 40 base + (nivel de skill usada × 15) − (riesgo × 8) − fatiga (−10 si ≥40, −20 si ≥70) + azar`
   Resultado: éxito / parcial / fallo. Afecta salud, llegada (el costo de tiempo **demora** la llegada y corre los eventos que faltan; el fallo cuesta el doble) y estado del paquete (intacto → dañado → perdido). Cada evento resuelto suma **+8 de fatiga** y **+25 XP a la skill usada**.
   **Tiradas críticas** (d100 aparte, `mishapPercent` / `kLuckyBreakPercent` en `forecast.dart`): *Imprevisto* = fallo seguro el 5% de las veces en riesgo nominal 4 y el 10% en riesgo 5 (los perks de Sigilo no lo anulan); *Golpe de suerte* = éxito seguro el 5% de las veces en cualquier opción. Garantizan que el maxeado pueda fallar y que una opción sin oficio pueda salir bien. Ambos aparecen en el desglose de la tirada y entran en el pronóstico.
6. Al llegar al 100%, botón **"ENTREGAR MENSAJE"** (no autocompleta). Nota final = `30% tiempo + 35% paquete + 35% decisiones` → **S/A/B/C/F** → paga **135/90/55/28/10 Denarios × factor de la ruta** (§6.2) y −10 de fatiga. El puntaje de tiempo mide los minutos que costaron las decisiones (`timeScoreFor`: sin retraso = 100, 25% de retraso = 50, piso 20); cuánto tarda el jugador en tocar ENTREGAR no cuenta.
7. **Billetera común:** Denarios, Aureos y Sellos viven en el mensajero principal. La paga de cualquier mensajero va ahí, y de ahí salen las compras de la tienda y "adelantar". En la tienda se elige a qué mensajero se le aplica el efecto.

### 2.2 Contenido actual

- **Tutorial (Phase 0):** las "4 pruebas de Varus" — misiones de 1/5/15/30 min con 8 eventos con prosa específica escrita a mano (éxito/parcial/fallo). Funciona como tutorial encubierto y está bien logrado.
- **Misiones reales (Phase 1):** solo 3 rutas — Roma→Ostia (2h), Roma→Capua (8h), Roma→Lugdunum (72h, requiere rank 2).
- **Eventos reales:** pool de 5 (patrulla, tormenta, puente caído, bandidos, tropiezo). **No tienen prosa propia**: usan 3 textos genéricos random (`_genericSuccess/Partial/Fail`). Se nota y empobrece la narrativa.
- **NPCs:** Varus (superior), Lucius (tabernero), Senador Claudius, centuriones, porteros.

### 2.3 Sistemas de soporte

- **Skills:** 5 ramas (Velocidad, Sigilo, Combate, Supervivencia, Contactos), niveles 1-5, 100 XP/nivel. Sin nombres de habilidad ni perks: son solo un número que gatea opciones y suma al score.
- **Rank:** derivado de la suma de niveles de skill → títulos Correo / Mensajero / Courier / Maestro / Leyenda. Gatea rutas.
- **Fatiga:** 0-100. +8 por evento, −10 por entrega, se limpia con item de tienda. Penaliza el score de eventos.
- **Multi-mensajero:** hasta 4 mensajeros con misiones paralelas. Slots 2/3/4 cuestan **20/50/100 Aureos** (requiere tutorial completo).
- **Economía:** se arranca con **200 Denarios y 5 Aureos**. Tienda (`shop_screen.dart`, catálogo `shopCatalogue`): pociones (50/120 Denarios), descanso (80), manuales de skill (200/500/1.200/2.500 según el nivel; no se venden en nivel 5), Sandalias de Mercurio −20% tiempo (3 Aureos), Mapa del explorador revela evento (5 Aureos). "Adelantar" la misión cuesta 1 Denario/minuto (clamp 5-300).
- **Perfil:** skills con barras de XP + historial de últimas 10 misiones con nota.
- **Día/noche:** el fondo del Home cambia según la hora real del dispositivo. Detalle ambiental muy alineado con el pilar 2.

### 2.4 Lo que NO existe (y el GDD v1 prometía)

| Sistema | Estado |
|---|---|
| **Notificaciones locales** | ✅ Implementadas (`flutter_local_notifications`): aviso de evento y de entrega, programadas al aceptar la misión y reprogramadas al resolver/adelantar. Permiso con contexto narrativo, silencio 22-08, opt-out por tipo en Ajustes y panel de diagnóstico. FCM sigue pendiente (necesita backend). |
| **IAP real** | ❌ Los packs de Aureos ($1.99→50, $3.99→120, $7.99→300, $19.99→800+500 Denarios) y bundles ($2.99, $6.99) abren un paywall que dice "Tienda en construcción" y **no acreditan nada** (`shop_screen.dart:851`, TODO). |
| Auto-resolución de eventos | ✅ A los 60 min sin respuesta: opción de menor riesgo, resultado parcial fijo, narrativa propia y aviso en el Home de lo que pasó mientras no estabas. |
| Recompensas diarias / misiones diarias / eventos | ❌ |
| Árbol de habilidades visual con perks nombrados | ✅ 5 caminos × 10 nodos con nombre, efecto numérico y comparación "ahora → próximo nivel" leída de `SkillPerks`. |
| Ads | ❌ |
| Reputación con efecto jugable | ✅ Escalones por facción que abren rutas, la tarifa +10% y títulos (§4.6). |
| Épocas 2-6, cartas, gremios sociales, Battle Pass | ❌ (backlog, ver Apéndice) |
| Auth real | ❌ (login hardcodeado) |
| Backend | ❌ (todo SharedPreferences) |

### 2.5 Deuda y basura conocida

- ~~`lib/presentation/widgets/[Interface]` (clave WireGuard) y `Untitled-4.json`~~ — ya no están en el repo. Si la clave privada estuvo versionada, rotarla igual en el servidor: borrar el archivo no la desactiva.
- Fondos PNG de 8-9 MB c/u sin optimizar.
- Emojis sueltos en splash y en los encabezados de sección del perfil (el 🏃 del avatar ya no está: lo reemplazó `MessengerAvatar`).

---

## 3. Narrativa y contenido — dirección

**Tono:** Roma vívida y peligrosa, contada con picardía. Los NPCs recurrentes (Varus, Lucius, Claudius) son el hilo emocional: el jugador construye una relación con ellos misión a misión.

**Dirección aprobada:**

1. **Prosa específica por opción.** ✅ Hecho: todos los eventos del pool real y de historia tienen textos propios de éxito/parcial/fallo por opción. Hay tests que lo verifican, más reglas de calidad: ninguna opción normal repite perfil (riesgo + costo + skill) dentro del mismo evento, y todo evento del pool común ofrece una salida prudente y una peligrosa.
2. **Ampliar a ~15 rutas y ~20 eventos** dentro de la época romana, con variedad de duraciones (30 min a 72h) para que siempre haya una misión que encaje en el momento del día del jugador.
3. **Migrar el contenido de `game_content.dart` a JSON data-driven** (assets versionados). Beneficios: escribir contenido sin recompilar, preparar contenido remoto (Fase 4) y habilitar futuras épocas como "packs de datos".
4. **Arcos de personaje:** cadenas de 3-5 misiones con continuidad (ej. la conspiración del Senador Claudius) que se desbloquean por rank. La historia como zanahoria de progresión.

Épocas 2+ (Medieval, Napoleónica, etc.): backlog explícito. No se diseña ni se implementa nada de eso hasta que la época romana esté completa y retenga.

---

## 4. El hook casual: "El correo te espera"

Diseño del ciclo de 3-4 sesiones diarias. La materia prima ya existe (timers reales); falta cerrar el circuito.

### 4.1 Notificaciones (prerrequisito de todo)

Locales primero (`flutter_local_notifications`), FCM cuando haya backend. Triggers, en orden de valor:

1. **"⚠️ Algo pasó en el camino"** — llegó un evento (el disparador n.º 1 de sesión).
2. **"📦 Tu entrega está lista"** — misión al 100%, esperando el botón ENTREGAR.
3. **"💤 Tu mensajero está ocioso"** — sin misión activa hace más de 2h (solo horario diurno).
4. **"📜 El tablón del gremio renueva a medianoche"** — contratos diarios incompletos (una sola, ~20:00 local).

Reglas: máximo 4/día, nunca entre 22:00 y 8:00 (salvo la de evento si el jugador inició una misión nocturna), opt-out granular en ajustes. El pedido de permiso se hace **con contexto narrativo** (ver §7).

### 4.2 Auto-resolución de eventos

Si un evento no se responde en **60 minutos**, se auto-resuelve con la opción de menor riesgo a **resultado parcial fijo** (nunca fallo). Presión suave: responder a tiempo siempre es mejor, pero dormirse no destruye la misión. La pantalla de resultado deja claro qué pasó ("Actuaste por instinto…").

### 4.3 Contratos del día (misiones diarias)

Tablón del gremio con **3 contratos diarios** (reset a medianoche local), elegidos de un pool. Ejemplos: "Entregá 2 paquetes", "Resolvé 3 eventos sin fallar", "Usá una opción de Sigilo", "Entregá con nota A o mejor". Recompensas: Denarios (50-150) y el tercer contrato del día otorga **1 Sello del Gremio** (ver §5).

### 4.4 Paga del gremio (login diario)

Racha de 7 días, escalada y cíclica: 30 → 50 → 70 → 100 Denarios → 1 Aureo → 150 Denarios → **2 Aureos + 1 Sello** (día 7). Se pierde la racha al faltar un día. Diálogo al abrir la app.

### 4.5 El día del jugador objetivo

- **Mañana (2-3 min):** cobrar paga del gremio, ver contratos, lanzar misiones en los slots (una corta de 2h + una larga overnight si tiene 2 mensajeros).
- **2-3 toques durante el día (1-2 min c/u):** push de evento → decidir → cerrar.
- **Noche (3 min):** entregar, cobrar, completar contratos, lanzar la misión de 8-72h para dormir.

Con slots llenos y contratos hechos, no hay nada más que "hacer" — y está bien: el juego respeta el tiempo del casual.

### 4.6 Facciones: la reputación abre puertas

Cuatro facciones (Gremio, Legiones, Bajos Fondos, Patricios) con escalones fijos: **Enemigo < −39 · Sospechoso · Desconocido · Conocido ≥ 10 · Respetado ≥ 30 · Leyenda ≥ 60**. Cada ruta real tiene un **patrón**; entregarle con nota B o mejor suma **+1 (+2 con S), una vez por día y por facción** (`WorldState.patronDays`). También suman los encargos semanales y las decisiones del camino.

Lo que abre cada escalón (`data/faction_content.dart`). **Ningún favor suma al score de una decisión** (cap +25%):

| Facción | Conocido | Respetado | Leyenda |
|---|---|---|---|
| Gremio (arranca en 10) | — | Cambiar 1 contrato por día · Correo exprés a Neapolis (rango 2) | Tarifa +10% · título |
| Legiones | Tarifa +10% en sus rutas | Brundisium por la Via Appia (**rango 4**, 36 h) | título |
| Bajos Fondos | Tarifa +10% | Neapolis por mar, de noche (rango 3) | título |
| Patricios | Tarifa +10% | Massilia por mar (**rango 5**, 42 h) | título |

Subir de escalón se anota en el diario y se celebra con una cinta (espera a que termine cualquier aviso de cobro). El perfil (pestaña Mundo) muestra cuánto falta y el próximo favor; tocando una facción se ve la escalera completa.

### 4.7 Encargos semanales

Tres pedidos de gente con nombre (Varus, Décimo, Marco, Sexto, Fulvia, Rufo, Atia, Cornelia) que duran de lunes a domingo (semana ISO), en el tablón del gremio arriba de los contratos. Uno es **siempre** el de Varus: primera nota S de la semana → **1 Sello** (la "nota S semanal" de §6.1). Los otros dos salen de un pool de 11, deterministas por semana, pagan **75-100 Denarios + reputación** y dejan una entrada en el diario al cobrarlos. Metas: entregas, notas A/S, rutas de una facción, rutas de 8 h o más, eventos resueltos o exitosos. Lo no cobrado se pierde el lunes.

---

## 5. Árbol de habilidades: "Caminos del Mensajero"

La mejora de progresión central. Convierte las 5 skills numéricas en **5 caminos visuales con habilidades nombradas**, extendidos de nivel 5 a **nivel 10**.

### 5.1 Estructura

Una pantalla nueva (pestaña o desde el perfil): 5 columnas/caminos — **Velocidad, Sigilo, Combate, Supervivencia, Contactos** — de 10 nodos cada uno. Cada nodo = un nivel con **nombre y efecto visible** (recuperando el espíritu del GDD v1: "Paso firme", "Invisible", "Nadar"…).

### 5.2 Efectos: incidencia real sin romper el sistema

- **Niveles 1-5 (base):** mantienen exactamente el rol actual — gatean opciones de evento y suman `nivel × 15` al score. Solo ganan nombre y descripción.
- **Niveles 6-10 (élite):** además del score, cada nivel otorga un **perk pasivo**. Ejemplos iniciales:

| Camino | Nv. 6 | Nv. 8 | Nv. 10 (capstone) |
|---|---|---|---|
| Velocidad | −3% duración de misiones | −6% duración | "Correo del César": −10% duración y las notas S pagan +25 Denarios |
| Sigilo | Los eventos de patrulla siempre ofrecen opción de sigilo | −1 de riesgo efectivo en opciones de sigilo | "Invisible": 1 evento por misión puede evitarse sin tirada |
| Combate | +10 al score en opciones de combate | Los fallos de combate no dañan el paquete | "Gladiador": los bandidos pueden rendirse (éxito automático 25%) |
| Supervivencia | Fatiga por evento 8→6 | Clima: −50% costo de tiempo en eventos de tormenta | "Incansable": la fatiga nunca penaliza el score |
| Contactos | +5% paga de misiones | Descuento 20% en la tienda de Denarios | "Red imperial": 1 reintento gratis de evento fallado por día |

**Legibilidad (implementado):** la pantalla del árbol lee `SkillPerks` y muestra el efecto con números — "Suma a tus tiradas +45", "Duración de las misiones −7%" — más un bloque "qué ganás" con el antes → después de cada nivel y el costo en Sellos de todos los nodos élite, no solo el próximo.

**Regla dura de balance:** el poder total combinado de un camino al máximo ≤ **+25%** de efectividad. Los perks nunca eliminan la decisión (no hay "auto-ganar eventos") ni rompen el gating: hacen mejores las opciones que el jugador ya elige.

### 5.3 Costos y el gate premium

- **Niveles 1-5:** XP como hoy (100 XP/nivel) o manuales de tienda (200 Denarios el nivel 2; los manuales de niveles 3-5 escalan: 500/1.200/2.500 Denarios).
- **Niveles 6-10:** XP **+ Sellos del Gremio**, escalado geométrico: **2 / 4 / 8 / 14 / 22 Sellos** (50 Sellos por camino completo; 250 los cinco).

**Sellos del Gremio** (recurso de élite, nuevo):
- Faucets gratis: 3.er contrato diario (1), día 7 de racha (1), primera nota S de la semana (1). → **~1-2/día jugando bien, ~8-10/semana.**
- Tienda: **1 Sello = 15 Aureos** (pack 10 Sellos = 120 Aureos).
- Resultado: nivel 10 de UN camino ≈ **5-7 semanas de juego constante**, o ~USD 15-20 comprando Aureos. Los 5 caminos al máximo: proyecto de meses o gasto de ballena. Exactamente el perfil pedido: el tope es realmente difícil gratis o se paga.

### 5.4 Riesgo y mitigación

El árbol no debe trivializar los eventos: con cap +25% y la fórmula actual, un jugador maxeado sigue pudiendo fallar opciones de riesgo 4-5. Lo garantiza el *Imprevisto* (§2.1): 5% de fallo seguro en riesgo 4 y 10% en riesgo 5, sin importar el nivel.

---

## 6. Economía

### 6.1 Roles de moneda (una moneda, un trabajo)

| Moneda | Rol | Se gana | Se gasta |
|---|---|---|---|
| **Denarios** | Operación diaria | Misiones (7-216 según nota y ruta), contratos, racha, logros (una vez) | Pociones, descanso, manuales 1-5, adelantar misión |
| **Aureos** | Premium (única comprable con dinero) | IAP, gotas F2P (racha) — los logros **nunca** dan Aureos | Slots de mensajero (20/50/100), boosts, Sellos |
| **Sellos del Gremio** | Progresión de élite | Contratos, racha día 7, nota S semanal | Exclusivamente niveles 6-10 del árbol |

### 6.2 Presupuesto diario del jugador activo (objetivo)

Jugador que hace 3 sesiones, completa 2-3 misiones y los 3 contratos:

| Faucet | Denarios | Aureos | Sellos |
|---|---|---|---|
| Misiones (una corta + una larga, nota A/B) | ~152 | — | — |
| Encargos semanales (2 de Denarios + el del Sello) | ~25 | — | ~0,14 |
| Contratos del día | ~141 | — | 1 |
| Paga del gremio (promedio) | ~75 | ~0,4 | ~0,15 |
| Rewarded ads (2-3 vistas) | ~60 | ~1 | — |
| **Total/día** | **~435** | **~1,5** | **~1,1-1,3** |

**Paga por ruta (implementado).** Cada ruta tiene un factor que se fija al aceptar, con la duración *nominal* (un boost de velocidad no baja la paga): `factor = clamp(0,6 + 0,15·log2(horas+1) + 0,3·peligro, 0,7, 1,6)`. Ruta de 2 h ≈ ×0,9 · 8 h ≈ ×1,2 · 3 días = ×1,6. Crece con el logaritmo: la ruta larga paga más en total pero menos por hora. Los capítulos de historia pagan ×1,3. La card de ruta muestra "Paga ~N" (nota A) y el resultado explica "Nota A: 90 × ruta 1,2". Lo verifica `test/progression_test.dart` (día típico 435 ±10%; hoy da ~449).

**Logros y títulos (implementado).** 26 logros en `data/progression_content.dart` (camino, notas, gremio, oficio, historia, fortuna). Premios: Denarios de una sola vez, un título, y como mucho 1 Sello por logro con **tope de 8 Sellos en toda la partida**; nunca Aureos. Las estadísticas viven en `progression_v2`; al migrar se reconstruyen desde el historial y los logros ya cumplidos se pagan en silencio. Celebraciones: cinta de logro desde arriba y laurel a pantalla completa al subir de rango; nunca durante un evento.

**Sellos con el encargo semanal.** El Sello de "primera S de la semana" estaba en §6.1 pero no en este presupuesto: suma ~0,14/día. Con eso, nivel 10 de un camino (50 Sellos) baja de ~6 a ~5,5 semanas, todavía dentro de la meta de 5-7. La tarifa de facción (+10% en las rutas de un patrón) solo llega tras semanas de reputación y no cambia el día típico.

Sinks de referencia: curación completa 120, descanso 80, manual nivel 3 = 500 (≈ 2 días de ahorro), adelantar una misión de 2h ≈ 120. El Denario debe sentirse abundante para operar y justo para acelerar. Revisar estos números tras el primer playtest largo.

### 6.3 IAP (a activar con `in_app_purchase`)

El catálogo actual de la tienda ya está bien tirado, se mantiene:
- **Packs de Aureos:** $1.99→50 · $3.99→120 · $7.99→300 · $19.99→800 + 500 Denarios.
- **Starter Pack $2.99** (una compra, tras el tutorial): curación + descanso + 20 Aureos → **mejorar a:** 30 Aureos + 2.º slot de mensajero + 2 Sellos. Es el conversor principal: el 2.º mensajero es el momento "ajá" del juego paralelo.
- **Pack del Guerrero $6.99:** 2 niveles de skill + 50 Aureos.
- **Pase mensual "Ruta del César" $4.99** (Fase 4): pista gratis/premium sobre puntos de contratos completados; premium da Sellos (6-8/mes), Aureos y un título/cosmético de temporada.

Compliance: si algún paquete futuro tiene contenido aleatorio, publicar odds (política de Apple/Google).

### 6.4 Rewarded ads (AdMob, a integrar)

1. **−30 min de viaje** de una misión activa (cap 4/día) — el placement estrella.
2. **Reintentar un evento fallado** (1/misión).
3. **Doblar la paga** de una entrega (1/día).
4. **+1 contrato extra** en el tablón (1/día).

Nunca ads forzados/interstitials: rompen el pilar de respeto al tiempo casual.

---

## 7. Onboarding e introducción

Lo que ya funciona y se conserva: onboarding narrativo de 5 slides, selección de personaje (género + nombre), y las **4 pruebas de Varus** como tutorial encubierto de dificultad creciente (1→30 min).

Mejoras aprobadas:

1. **Explicar el tiempo real, explícitamente.** Tras aceptar la primera misión real (2h), una viñeta de Varus: *"El camino toma lo que toma. Cerrá los ojos si querés — yo te aviso si pasa algo."* → ahí se pide el **permiso de notificaciones con contexto narrativo** (nunca en frío al abrir la app).
2. **Tooltips de primera vez** (spotlight): Home (slots y progreso), primer evento (riesgo/skills/costo de tiempo), tienda (monedas). Uno por pantalla, descartables.
3. **Checklist "Primeros pasos"** post-tutorial (5 tareas: completá tu primera ruta real, comprá un item, subí una skill, mirá el tablón, activá las notificaciones) → recompensa final 3 Aureos + 1 Sello.
4. **Reemplazar el login falso** por modo invitado inmediato (auth real recién con backend, Fase 4). Nadie debe ver `test@test.com` en producción.

---

## 8. UX/UI y legibilidad

### Identidad (se conserva)

Navy profundo + oro/pergamino, tipografías **Fredoka** (títulos) + **Nunito** (cuerpo), botones 3D con sombra dura, acento rojo solo para peligro, fondo día/noche según hora real. La identidad funciona; el problema es de contraste, no de estilo.

### Reglas de legibilidad (obligatorias)

1. **Todo texto cumple WCAG AA: contraste ≥ 4.5:1** (títulos grandes ≥ 3:1) sobre su fondo real.
2. **Fix concreto:** en `lib/presentation/theme/app_theme.dart`, `textMuted = #665544` (marrón oscuro) falla sobre los fondos navy (`bgDark #0F1E36`, `bgCard #142040`, `bgCard2 #0D1830`). Reemplazar por un tono legible que mantenga la paleta cálida, p. ej. **`#9A8F7A`** (o más claro; validar contraste). Afecta `bodySmall`, labels de stats, "Nv.X" de skills y botones "Cancelar".
3. **Hints de inputs:** hoy usan `textMuted` con opacity 0.5 — doble penalización. Los hints usan `textSecondary` sin opacity.
4. `textSecondary #AA9966` queda al límite: usarlo solo en tamaños ≥ 14 y nunca sobre imágenes sin scrim (gradiente negro 60%).
5. **Iconografía:** un solo criterio. Los avatares custom marcan el estándar → reemplazar los emojis sueltos (📜 splash, 🏃 perfil, ✅⚡❌ outcomes) por íconos del set Material ya usado en la tienda.
6. **Performance percibida:** comprimir los fondos PNG de 8-9 MB (objetivo < 500 KB c/u, WebP).

---

## 9. Datos técnicos y KPIs

- **Hoy:** Flutter + Riverpod + go_router, todo local (SharedPreferences con migración de esquemas `_v2`). Sin backend.
- **Camino técnico:** la arquitectura limpia ya deja el enchufe listo — Fase 4 crea `firebase_repositories.dart` y cambia los providers (documentado en el README). Orden: notificaciones locales (sin backend) → IAP (sin backend) → Firebase (auth, perfil en la nube, contenido remoto, FCM, Analytics).
- **Analytics (v2.3):** instrumentado. 22 eventos (sesión, embudo del tutorial, loop, historia, progresión, gremio, tienda), registro local de días activos y opt-out en Ajustes. Hoy salen a consola y a un buffer que el tester copia desde Ajustes; Firebase se enchufa como un sink más. Definiciones, diccionario, embudos y umbrales de decisión: [ANALYTICS.md](ANALYTICS.md).

**KPIs objetivo (para validar el diseño):**

| Métrica | Objetivo |
|---|---|
| Retención D1 | ≥ 40% |
| Retención D7 | ≥ 20% (meta del GDD v1) |
| Retención D30 | ≥ 6% |
| Stickiness (DAU/MAU) | ≥ 20% |
| Sesiones/día (jugador activo) | ≥ 3 |
| Respuesta a push de evento en < 60 min | ≥ 50% |
| Conversión a pagador (mes 3) | 2-3% |

---

## 10. Apéndice

### Backlog heredado del GDD v1 (no ahora)

Épocas 2-6 (Medieval → Guerra Fría) con transportes y árboles propios · sistema de cartas (mazo de 10) · reputación/facciones · gremios y social · PvP de rutas · cosméticos · misiones premium. **Criterio para retomarlos:** época romana completa (15 rutas, 20 eventos) + D7 ≥ 20% + monetización activa.

### Riesgos de diseño

1. **Timers largos sin notificaciones = churn.** El jugador acepta una misión de 8h, se olvida, y al volver la encuentra congelada en un evento. Push es prerrequisito de todo lo demás; ninguna feature de retención compensa su ausencia.
2. **Auto-resolución mal calibrada** puede sentirse castigo (si es muy mala) o hacer el juego jugable-sin-jugar (si es muy buena). Parcial fijo con la opción segura es el punto de partida; ajustar con datos.
3. **Inflación de Denarios** si contratos + racha pagan de más: el "adelantar misión" (1 Denario/min) se vuelve gratis y canibaliza los ads de −30 min. Vigilar el presupuesto de §6.2.
4. **El árbol no debe trivializar los eventos** (cap +25%, el azar siempre permite fallo en riesgo alto). P2W en PvE es tolerable, pero un jugador que nunca falla se aburre y churnea.
5. **Misión "vacía"** (riesgo señalado ya en el GDD v1): una misión de 72h con pocos eventos se siente muerta. Regla: mínimo 1 evento cada 8h de misión; las misiones largas deben pagar acorde.

### Historial

- **v2.3 (2026-10-06):** analytics. Diccionario de eventos y métricas de retención definidos en código, sesión con corte a los 30 min, registro local de días activos, exportación para la beta y opt-out (§9, ANALYTICS.md).
- **v2.2 (2026-10-05):** paga por ruta, 26 logros con títulos y celebraciones; reputación con escalones que abren rutas (las primeras de rango 4 y 5), tarifa de facción y cambio de contrato; encargos semanales con NPCs (§4.6-4.7).

- **v2.1 (2026-07-27):** feedback visible de todo lo que hace el jugador. Retrato del mensajero por género/slot/rango/estado en todas las pantallas; contadores de moneda animados y compartidos; pronóstico narrativo antes de decidir (con chip de riesgo, que antes no se mostraba) y desglose "por qué pasó" después; sección "lo que cambió" al entregar (reputación, diario, flags traducidos a lenguaje narrativo, título de arco, XP y fatiga); notificaciones locales completas con pantalla de Ajustes y diagnóstico; auto-resolución a los 60 min alineada al diseño; árbol con efectos numéricos.
- **v2.0 (2026-07-09):** reescritura completa desde el código real + dirección aprobada (hooks casual, árbol Caminos del Mensajero, economía de 3 recursos, guía de legibilidad). Autoría: análisis de código + diseño asistido.
- **v1.0:** `../The_Messenger_GDD_v1.docx` — visión original de 6 épocas. Archivo histórico.
