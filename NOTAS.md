# Notas de estado — Via Imperia

Punto de partida para un chat nuevo. Los números de diseño viven en `docs/GDD_MASTER_v2.md`; esto es solo estado y pendientes.

## Balance (2026-11-23)

- Resolución: `OutcomeRoller.roll` (`usecases.dart`) con helpers en `skill_tree.dart`. Azar ±25, umbrales 55/30, sin habilidad +15 ("Sentido común").
- Economía (2026-11-24): paga por nota 110/80/60/45/12 × factor de ruta `0,6 + 0,12·log2(h+1) + 0,15·peligro` (0,7-1,5). Día completo con un mensajero: ~403 en rango 1 → ~498 con todo en 5 (~477 restando la tienda; objetivo 435). La tienda de recuperación consume ~20-45/día por el descanso pasivo. Sellos ~1,06-1,29/día (camino a 10 en ~6 semanas). Aureos ~1,43/día (2.º anuncio del día = 1 Aureo, máx. 1).
- Descanso pasivo (`Messenger.recoverWhileResting`, se aplica al cargar Home): sin misión −5 fatiga y +5 salud por hora; el herido vuelve a salir con 50 de salud (~10 h).

## Pendientes

- Balance: falta el playtest largo. "1 evento cada 8 h" auditado en las 25 rutas (2026-11-24): todas cumplen, hueco máximo 7,2 h (real_03); lo traba `content_validator_test.dart`. El simulador no vive en el repo: se rearma como test temporal (OutcomeRoller + allRealMissions/allRealEvents, 3 sesiones/día).

- El botón de ruta del herido muestra "Herido: descansa ~X h o cúrate" (`Messenger.injuryRestLeft`). La recuperación de fatiga/salud del libre no tiene aviso propio (solo cambian las barras).
