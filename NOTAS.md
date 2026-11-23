# Notas de estado — Via Imperia

Punto de partida para un chat nuevo. Los números de diseño viven en `docs/GDD_MASTER_v2.md`; esto es solo estado y pendientes.

## Balance (2026-11-23)

- Resolución: `OutcomeRoller.roll` (`usecases.dart`) con helpers en `skill_tree.dart`. Azar ±25, umbrales 55/30, sin habilidad +15 ("Sentido común").
- Economía simulada: ~390 Denarios/día en rango 1 → ~540 con todo en 5 (objetivo 435). Aureos ~1,43/día (2.º anuncio del día = 1 Aureo, máx. 1).
- Fatiga: +8 por evento, −10 al entregar, −5 por hora sin misión (`Messenger.recoverIdleFatigue`, se aplica al cargar Home).

## Pendientes

- La salud tampoco se recupera sola: solo pociones/descanso/racha. Decidir si conviene.
- La recuperación de fatiga no se muestra en la UI (solo baja el número).
