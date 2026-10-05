# THE MESSENGER — Roadmap de mejoras v1

Complementa al [GDD_MASTER_v2.md](GDD_MASTER_v2.md). Fases ordenadas por dependencia: cada una desbloquea la siguiente. Estimaciones para un dev solo, tiempo parcial.

---

## Fase 0 — Saneamiento y quick wins (≈1 semana)

*Arregla la primera impresión y elimina riesgos. No depende de nada.*

| # | Tarea | Detalle |
|---|---|---|
| 0.1 | **Borrar clave VPN del repo** | Eliminar `lib/presentation/widgets/[Interface]` (config WireGuard con PrivateKey real). **Rotar esa clave en el servidor VPN** — considerarla comprometida. Si el proyecto pasa a git, verificar que no quede en el historial. |
| 0.2 | Borrar `lib/presentation/widgets/Untitled-4.json` | 71 KB de datos de otro proyecto (ClashOfWarriors), sin uso. |
| 0.3 | **Fix de legibilidad** | `app_theme.dart`: `textMuted #665544` → tono legible sobre navy (≥4.5:1, ej. `#9A8F7A` o más claro). Quitar `opacity 0.5` de los hints (usar `textSecondary`). Revisar botones "Cancelar" de diálogos. |
| 0.4 | Comprimir fondos | PNG de 8-9 MB → WebP < 500 KB c/u (`bg_home_day/night`, evento, login). |
| 0.5 | Unificar iconografía | Reemplazar emojis sueltos (splash 📜, perfil 🏃, outcomes ✅⚡❌) por íconos Material. |
| 0.6 | Publicar GDD | Este par de documentos + nota en README. ✔ hecho en esta pasada. |

## Fase 1 — El hook: que el juego te busque (≈2-3 semanas)

*Pilar 2. **1.1, 1.2 y 1.3 hechos** (2026-07-27); faltan contratos y racha del listado original, que ya existían en código.*

| # | Tarea | Detalle |
|---|---|---|
| 1.1 | ✅ **Notificaciones locales** | `flutter_local_notifications`. Programar al aceptar misión: una por cada `triggersAt` de evento + una al deadline ("entrega lista"). Reprogramar en cada resolución (los eventos corren el deadline). Triggers extra: ocioso >2h, contratos por vencer. Reglas: máx 4/día, silencio 22-08h, opt-out en ajustes. |
| 1.2 | ✅ Permiso con contexto narrativo | Pedir permiso tras aceptar la primera misión real, con viñeta de Varus (GDD §7). |
| 1.3 | ✅ **Auto-resolución de eventos** | 60 min sin respuesta → opción de menor riesgo, resultado parcial fijo, narrativa propia ("actuaste por instinto"). Evita misiones congeladas para siempre. |
| 1.4 | **Contratos del día** | Tablón del gremio: 3 diarias de un pool (~10 plantillas), reset a medianoche. Recompensas Denarios + 1 Sello en la 3.ª. Persistencia local. |
| 1.5 | **Paga del gremio** | Login diario con racha de 7 días (30→…→2 Aureos + 1 Sello), diálogo al abrir. |
| 1.6 | Introducir **Sellos del Gremio** | Campo nuevo en `Messenger`, faucets de 1.4/1.5, aún sin sink (el sink llega con el árbol en Fase 3). Mostrar en perfil. |

**Criterio de salida:** un jugador que instala el lunes recibe pushes útiles toda la semana y tiene motivo para abrir la app cada día (contratos + racha).

## Fase 2 — Contenido y narrativa (≈3-4 semanas)

| # | Tarea | Detalle |
|---|---|---|
| 2.1 | ✅ Prosa específica por opción | Textos de éxito/parcial/fallo por opción (como el tutorial). Elimina la narrativa genérica. |
| 2.2 | +12 rutas, +15 eventos | Duraciones variadas (30 min-72h), regla "1 evento cada 8h mínimo". Incluir 1-2 arcos de personaje (cadenas de misiones de Claudius/Lucius) gateados por rank. |
| 2.3 | **Migrar contenido a JSON** | `game_content.dart` → assets JSON versionados + loader. Prepara edición sin recompilar y contenido remoto futuro. |
| 2.4 | Tooltips de onboarding + checklist "Primeros pasos" | GDD §7. Spotlight de primera vez en Home/Evento/Tienda; checklist de 5 tareas con recompensa (3 Aureos + 1 Sello). |

## Fase 3 — Árbol y monetización (≈4-6 semanas)

| # | Tarea | Detalle |
|---|---|---|
| 3.1 | ✅ **Árbol "Caminos del Mensajero"** | Pantalla nueva: 5 caminos × 10 nodos con nombre/efecto. Niveles 1-5 = comportamiento actual renombrado; 6-10 = perks pasivos (GDD §5.2) con costo XP + Sellos (2/4/8/14/22). Cap +25%; revisar banda de azar de `_calculateOutcome`. |
| 3.2 | **IAP real** | `in_app_purchase`: packs de Aureos existentes + Starter Pack mejorado (30 Aureos + 2.º slot + 2 Sellos). Reemplaza el paywall dummy de `shop_screen.dart:851`. Restauración de compras, recibos. |
| 3.3 | **Rewarded ads** | AdMob: −30 min de viaje (cap 4/día), reintento de evento, doblar paga, contrato extra. |
| 3.4 | Sellos en tienda | 1 Sello = 15 Aureos; pack 10 = 120. |

**Criterio de salida:** existe un ciclo económico completo (jugar → Sellos lentos / pagar → Sellos rápidos → árbol → jugar mejor) y el juego genera ingresos reales.

## Fase 4 — Backend y live-ops (continuo)

| # | Tarea | Detalle |
|---|---|---|
| 4.1 | Firebase | Auth real (invitado/Google/Apple, adiós `test@test.com`), perfil en la nube (`firebase_repositories.dart` según el plan del README), Analytics con los KPIs del GDD §9, FCM. |
| 4.2 | Contenido remoto | Los JSON de la Fase 2 servidos/actualizados desde backend; habilita eventos de temporada sin release. |
| 4.3 | Pase mensual "Ruta del César" $4.99 | Pista gratis/premium sobre puntos de contratos. |
| 4.4 | Eventos de temporada | Semanas temáticas (ej. "Idus de Marzo": rutas especiales, paga doble de Sellos). |
| 4.5 | Época 2 (Medieval) | Solo si: 15+ rutas romanas, D7 ≥ 20%, monetización activa. |

---

## Reglas transversales

- **Ninguna feature nueva puede violar la legibilidad WCAG AA** (GDD §8) ni requerir sesiones > 3 min (pilar 3).
- Cada fase termina con un playtest propio de 3+ días con notificaciones reales antes de pasar a la siguiente.
- Actualizar el GDD_MASTER al cerrar cada fase (es un documento vivo: si el código y el GDD difieren, uno de los dos está mal).

---

## Pendiente inmediato (2026-07-27)

1. **Validar las notificaciones en el iPhone físico.** El código y la configuración nativa están; falta la prueba de campo: aceptar una misión corta, cerrar la app por completo y confirmar que llega el aviso. La pantalla de Ajustes tiene un panel de diagnóstico (permiso, cola de avisos con su hora, disparo de prueba a 10 segundos) hecho justamente para eso.
2. Comprimir los fondos PNG de 8-9 MB (tarea 0.4) — la única de la Fase 0 que sigue abierta.

> Las tareas 0.1 y 0.2 (clave de WireGuard y `Untitled-4.json`) ya no aplican: los archivos no están en el repo. **Si esa clave privada llegó a estar versionada alguna vez, sigue habiendo que rotarla en el servidor VPN** — borrar el archivo no la desactiva.
