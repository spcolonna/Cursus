# Notas de estado — Via Imperia

Punto de partida para un chat nuevo. Los números de diseño viven en `docs/GDD_MASTER_v2.md`; esto es solo estado y pendientes.

## Balance (2026-11-23)

- Resolución: `OutcomeRoller.roll` (`usecases.dart`) con helpers en `skill_tree.dart`. Azar ±25, umbrales 55/30, sin habilidad +15 ("Sentido común").
- Economía simulada: ~390 Denarios/día en rango 1 → ~540 con todo en 5 (objetivo 435). Aureos ~1,43/día (2.º anuncio del día = 1 Aureo, máx. 1).
- Descanso pasivo (`Messenger.recoverWhileResting`, se aplica al cargar Home): sin misión −5 fatiga y +5 salud por hora; el herido vuelve a salir con 50 de salud (~10 h).

## Pendientes

- La recuperación pasiva no se muestra en la UI (solo cambian los números): falta un aviso tipo "descansando: vuelve a salir en ~X h" para el herido.
