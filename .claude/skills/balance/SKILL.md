---
name: balance
description: Ajustar números y economía de Via Imperia — fórmula de resolución de eventos, notas y paga de misiones, XP y niveles de skill, perks del árbol, Sellos del Gremio, fatiga, precios de tienda, contratos diarios y paga de racha. Usar antes de tocar usecases.dart, skill_tree.dart, guild.dart o cualquier constante numérica de gameplay.
---

# Balance y economía

Regla madre: **el jugador maxeado sigue pudiendo fallar.** Si un cambio elimina el fallo en riesgo 4-5, es un cambio malo aunque se sienta bien.

## Fórmula de resolución (`OutcomeRoller.roll`, `lib/domain/usecases/usecases.dart`)

Constantes compartidas con el pronóstico en `lib/domain/entities/skill_tree.dart` (`skillScore`, `riskPenalty`, `kLuckMin/Max`, `kNoSkillBonus`): tocá ahí, no en dos lugares.

```
score  = 40
       + skillScore(nivel, requerido)   15/nivel hasta requerido+1, después +2/nivel
         (opción sin habilidad: +15 "Sentido común")
       + SkillPerks.scoreBonus(skill, messenger)        Sigilo/Combate hasta +10
       − riskPenalty(riesgo_efectivo)   0/8/16/24/40/56  (Sigilo 10: riesgo −1)
       − 7  si fatiga ≥ 40   |   − 15 si fatiga ≥ 70   (× fatiguePenaltyFactor)
       + azar uniforme −25..+24

score ≥ 55 → éxito   ·   ≥ 30 → parcial   ·   < 30 → fallo
+ tiradas críticas: Imprevisto 5%/10% en riesgo 4/5, Golpe de suerte 5%
```

Consecuencias: +8 fatiga y +25 XP a la skill usada por evento resuelto (la fatiga baja −10 al entregar y −5 por hora sin misión; la salud sube +5 por hora sin misión y el herido vuelve a salir con 50, `kRestRecoveryPerHour`). Fallo: −20 salud (−10 en tutorial) y paquete a `wetMinor`. Parcial: −5 salud. Costo de tiempo topado en ¼ de la ruta (el fallo cuesta el doble). El instinto (evento vencido) tira con la opción más segura, sin XP.

Casos borde de referencia (opción que pide 3, riesgo 5): nivel 3 → 5/41/54 · nivel 5 → 32/42/25 · nivel 10 → 49/41/10 · Combate 10 → 66/24/10. Antes de cambiar cualquier constante, recalculá estos casos y el de nivel 1 / riesgo 5 (≈95% fallo).

## Nota y paga de misión (`CompleteMissionUseCase`, ~línea 431)

`total = 30% tiempo + 35% paquete + 35% decisiones` → **S/A/B/C/F** → **135/90/55/28/10** Denarios (`gradeBaseReward`) **× `mission.payFactor`**, y −10 fatiga. El factor sale de `routePayFactor(minutosNominales, peligro)` (0,7-1,6; historia 1,3), se fija al aceptar y se guarda en la misión. `SkillPerks.gradeSBonus` suma en nota S.

## Progresión de skills

- Niveles **1-5**: curva `kXpCurve` = 100/125/175/250 XP (650 hasta el 5), o manuales de tienda (Denarios, o Aureos 10/15/25/40 si no alcanzan). Todo en `lib/domain/entities/economy.dart`; Remote Config escala la curva y el precio en Aureos (`economy_*`, con topes). Solo gatean opciones y suman al score.
- Niveles **6-10**: XP + **Sellos del Gremio**, `sealCostForLevel = {6:2, 7:4, 8:8, 9:14, 10:22}` (50 por camino, 250 los cinco).
- Rank = suma de niveles: `<8` Correo · `<14` Mensajero · `<20` Courier · `<26` Maestro · resto Leyenda. Gatea rutas.
- Definición de nodos y perks: `lib/domain/entities/skill_tree.dart` (`skillTree`, `SkillPerks`).

**Cap duro: el poder combinado de un camino maxeado ≤ +25% de efectividad.** Los perks nunca eliminan la decisión (no hay auto-ganar) ni rompen el gating de skills: hacen mejores las opciones que el jugador ya elige.

## Monedas — una moneda, un trabajo

| Moneda | Rol | Faucets | Sinks |
|---|---|---|---|
| **Denarios** | operación diaria | misiones (nota × ruta), contratos, racha, logros (una vez) | pociones, descanso, manuales, adelantar misión (2 Den/min, clamp 10-1200, ajustable en remoto) |
| **Aureos** | premium (la única comprable) | IAP, gotas de racha, 1 cada 2 anuncios (tope 1/día) | slots de mensajero 20/50/100, boosts, Sellos |
| **Sellos** | élite | 3.er contrato diario, día 7 de racha, 1.ª nota S semanal | **solo** niveles 6-10 del árbol |

Presupuesto objetivo del jugador activo (3 sesiones/día): **~435 Denarios · ~1,5 Aureos · ~1,1 Sellos** por día. Meta de diseño: nivel 10 de UN camino ≈ 5-7 semanas gratis.

Si tocás faucets, revisá que no se rompa esto: **inflación de Denarios → "adelantar misión" se vuelve gratis y canibaliza los rewarded ads de −30 min.**

Catálogo y precios: `shopCatalogue` en `lib/presentation/screens/shop/shop_screen.dart`. Costos de slots: `messengerSlotCosts` en `entities.dart`.

## Contratos y racha (`lib/domain/entities/guild.dart`)

3 contratos diarios elegidos de `_easyPool` / `_mediumPool` / `_sealPool` por `contractIdsForDate` (determinístico por fecha). Recompensas 50-90 Denarios; el del pool de sellos da 1 Sello. Racha de 7 días cíclica: 30 → 50 → 70 → 100 Denarios → 1 Aureo → 150 Denarios → 2 Aureos + 1 Sello.

## Facciones y encargos semanales

- **Reputación** −100..100, escalones en 10 / 30 / 60 (`FactionTier`, `lib/domain/entities/world.dart`). Entregar en una ruta de su patrón con B+ suma +1 (+2 con S), **una vez por día y por facción**. Encargos: +1 a +3. Eventos: ±1-2 (±3 solo en arcos).
- **Favores** (`data/faction_content.dart`): solo `contractReroll` y `patronPay` (+10% de paga en las rutas del patrón, `kPatronPayBonus`). **Nunca** un favor que sume al score o baje el riesgo: eso lo hace el árbol, con su cap de +25%.
- **Encargos semanales** (`weeklyCommissionPool`): 3 por semana ISO; el de Varus (1.ª S → 1 Sello) siempre, los otros dos pagan 75-100 Denarios (~25/día). El test de presupuesto lee el promedio real del pool: si subís un encargo, revisalo.
- Una ruta nueva de facción necesita `patron`, `minReputation` = umbral del escalón y su entrada en `factionUnlocks` (lo verifica `test/faction_weekly_test.dart`).

## Ritmo de misión

- Mínimo **1 evento cada 8 h** de duración: una misión de 72 h con pocos eventos se siente muerta.
- Ningún evento debe exigir más de ~90 segundos de atención.
- Los eventos congelan el progreso hasta que se resuelvan; a los 60 min se auto-resuelven con la opción prudente y aplican sus efectos narrativos (flags, reputación, diario). La espera corre toda la misión en el tiempo (`Mission.frozenBy`): no suma duración, paga, XP ni minutos semanales.

## Logros

`data/progression_content.dart`. Nunca Aureos; ≤1 Sello por logro y ≤8 en total (lo verifica `test/progression_test.dart`). Los Denarios de logros son de una sola vez y no cuentan en el presupuesto diario.

## Antes de commitear un cambio numérico

- [ ] Calculaste el impacto en los dos casos borde (novato riesgo 5, maxeado riesgo 5).
- [ ] El fallo sigue existiendo en el endgame.
- [ ] No se rompe el presupuesto diario ni el cap de +25%.
- [ ] `flutter test` pasa (`test/progression_test.dart` simula el día típico: 435 ±10%).
- [ ] Si el cambio contradice el GDD §5/§6, actualizá el GDD en la misma pasada.
