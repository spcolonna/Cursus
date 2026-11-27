# Notas de estado — Via Imperia

Punto de partida para un chat nuevo. Los números de diseño viven en `docs/GDD_MASTER_v2.md`; esto es solo estado y pendientes.

## Balance (2026-11-23)

- Resolución: `OutcomeRoller.roll` (`usecases.dart`) con helpers en `skill_tree.dart`. Azar ±25, umbrales 55/30, sin habilidad +15 ("Sentido común").
- Economía (2026-11-24): factor de ruta `0,6 + 0,12·log2(h+1) + 0,15·peligro` (0,7-1,5). Paga por nota 98/72/55/42/12 desde 2026-11-27 (ver abajo); día completo ~350 al arrancar → ~435 avanzado (objetivo 435). La tienda de recuperación consume ~20-45/día por el descanso pasivo. Sellos ~1,06-1,29/día (camino a 10 en ~6 semanas). Aureos ~1,43/día (2.º anuncio del día = 1 Aureo, máx. 1).
- Descanso pasivo (`Messenger.recoverWhileResting`, se aplica al cargar Home): sin misión −5 fatiga y +5 salud por hora; el herido vuelve a salir con 50 de salud (~10 h).

## Pendientes

- Balance: "1 evento cada 8 h" auditado en las 25 rutas (2026-11-24): todas cumplen, hueco máximo 7,2 h (real_03); lo traba `content_validator_test.dart`. El simulador no vive en el repo: se rearma como test temporal (OutcomeRoller + allRealMissions/allRealEvents, 3 sesiones/día).

- Balance aplicado (2026-11-27) tras la simulación de 8 semanas (200 jugadores por perfil, 3 sesiones/día):
  - **Trampa de entrenamiento resuelta:** la opción sin habilidad da 10 XP a la skill más baja (`kFreeOptionXp`, `freeOptionXpSkill`). Antes, quien elegía siempre lo más seguro seguía en nivel 1 a las 8 semanas; ahora llega a rango 3 en la semana 2-3.
  - **Parcial = medio éxito** en "Decisiones" (`kPartialDecisionWeight`, `decisionScoreFor`). Para compensar, la paga por nota bajó a 98/72/55/42/12. Día completo: ~350 al arrancar, ~435 avanzado. Notas en nivel 1: S 26 · A 23 · B 22 · C 24 · F 4 %.
  - El anuncio de −30 min ya no se ofrece en el tutorial ni con menos de 30 min para llegar.
  - **Opción segura** (`kSafeRiskMax` = 1, `optionCannotFail` en `forecast.dart`): riesgo nominal 0-1 nunca falla, lo peor es parcial (factor "Camino seguro"). Afecta 114 opciones y a la auto-resolución. Re-simulado: misiones ~180 → ~260/día, día ~360 → ~440; F en nivel 1 = 0 %. El "prudente" cobra ~170/día de misiones: lo seguro no domina.
  - El simulador no vive en el repo; se rearma como test temporal.

- El botón de ruta del herido muestra "Herido: descansa ~X h o cúrate" (`Messenger.injuryRestLeft`). La recuperación del libre se avisa en la tarjeta "Pasó mientras no estabas" del Home (`RestRecovery`, desde 10 puntos o al curarse). El aviso se acumula entre recargas del Home (`HomeNotifier._awayEvents/_awayRested`) y se borra al pasar a segundo plano.
