# Notas de estado — Via Imperia

Punto de partida para un chat nuevo. Los números de diseño viven en `docs/GDD_MASTER_v2.md`; esto es solo estado y pendientes.

## Balance (2026-11-23)

- Resolución: `OutcomeRoller.roll` (`usecases.dart`) con helpers en `skill_tree.dart`. Azar ±25, umbrales 55/30, sin habilidad +15 ("Sentido común").
- Economía (2026-11-24): paga por nota 110/80/60/45/12 × factor de ruta `0,6 + 0,12·log2(h+1) + 0,15·peligro` (0,7-1,5). Día completo con un mensajero: ~403 en rango 1 → ~498 con todo en 5 (~477 restando la tienda; objetivo 435). La tienda de recuperación consume ~20-45/día por el descanso pasivo. Sellos ~1,06-1,29/día (camino a 10 en ~6 semanas). Aureos ~1,43/día (2.º anuncio del día = 1 Aureo, máx. 1).
- Descanso pasivo (`Messenger.recoverWhileResting`, se aplica al cargar Home): sin misión −5 fatiga y +5 salud por hora; el herido vuelve a salir con 50 de salud (~10 h).

## Pendientes

- Balance: "1 evento cada 8 h" auditado en las 25 rutas (2026-11-24): todas cumplen, hueco máximo 7,2 h (real_03); lo traba `content_validator_test.dart`. El simulador no vive en el repo: se rearma como test temporal (OutcomeRoller + allRealMissions/allRealEvents, 3 sesiones/día).

- Simulación de 8 semanas (2026-11-26, 200 jugadores por perfil, 3 sesiones/día en ventanas de 5/8/11 h, sin decidir nada todavía):
  - **Trampa de entrenamiento:** quien elige siempre la opción con más chance de éxito no sube nunca de nivel (8 semanas en nivel 1, rango 1). En nivel 1 la skill suma 15, lo mismo que "Sentido común", y las opciones con skill ≤1 tienen más riesgo (2,33 de media contra 1,48 de las libres). La opción sin skill no da XP.
  - Quien prefiere opciones con skill llega a rango 3 en la semana 3 y a rango 4 en la 7. Su mejor camino llega a 9 en la semana 4 y a 10 en la 7 (Sellos 1,1/día; cumple la meta de 5-7 semanas).
  - **Paga solo de misiones (Den/día):** ~157 en nivel 1, ~250 una vez avanzado. Contratos (~139) más racha (~71), menos tienda (30), dan ~337 al arrancar y ~430 avanzado, contra el objetivo de 435. La cuenta anterior (~403 en rango 1) era optimista.
  - **Notas en nivel 1:** C 38%, F 12%, S 23%. Los eventos salen 37% éxito, 47% parcial, 16% fallo. La opción fácil sale 38% éxito / 15% fallo; para quien entrena, más adelante sube a ~35% de fallo por la fatiga.
  - Si un **parcial valiera medio éxito** en "Decisiones": en nivel 1 C pasa de 38% a 22% y F de 12% a 5%, con +27 Den/día. Avanzado: S 39% y ~291 Den/día de misiones (~470 en total, 8% sobre el objetivo; habría que compensar).
  - El simulador queda fuera del repo (scratchpad de la sesión); se rearma como test temporal.

- Playtest en simulador (2026-11-26), para decidir junto con la simulación de balance:
  - Opción "Fácil" (riesgo 1, sin skill) da 47 ± 25: 34% éxito, 50% parcial, 16% fallo, también en el tutorial (en la prueba salieron 2 fallos y 2 parciales en 5 eventos).
  - Un parcial suma 0 en "Decisiones" de la nota, igual que un fallo, y la pantalla lo rotula "Malas decisiones".
  - El anuncio de −30 min se ofrece aunque falten menos de 30 min (o en el tutorial).

- El botón de ruta del herido muestra "Herido: descansa ~X h o cúrate" (`Messenger.injuryRestLeft`). La recuperación del libre se avisa en la tarjeta "Pasó mientras no estabas" del Home (`RestRecovery`, desde 10 puntos o al curarse). El aviso se acumula entre recargas del Home (`HomeNotifier._awayEvents/_awayRested`) y se borra al pasar a segundo plano.
