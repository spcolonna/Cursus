---
name: balance
description: Ajustar números y economía de The Messenger — fórmula de resolución de eventos, notas y paga de misiones, XP y niveles de skill, perks del árbol, Sellos del Gremio, fatiga, precios de tienda, contratos diarios y paga de racha. Usar antes de tocar usecases.dart, skill_tree.dart, guild.dart o cualquier constante numérica de gameplay.
---

# Balance y economía

Regla madre: **el jugador maxeado sigue pudiendo fallar.** Si un cambio elimina el fallo en riesgo 4-5, es un cambio malo aunque se sienta bien.

## Fórmula de resolución (`_calculateOutcome`, `lib/domain/usecases/usecases.dart:663`)

```
score  = 40
       + Σ (nivel de cada skill requerida × 15)
       + SkillPerks.scoreBonus(skill, messenger)
       − riesgo_efectivo × 8        (riesgo − SkillPerks.riskReduction, clamp 0-5)
       − 7  si fatiga ≥ 40   |   − 15 si fatiga ≥ 70   (× fatiguePenaltyFactor)
       + rng(0..29) − 10

score ≥ 55 → éxito   ·   ≥ 30 → parcial   ·   < 30 → fallo

d100 aparte (tiradas críticas, forecast.dart):
  < mishapPercent(riesgo nominal)   → Imprevisto: fallo   (riesgo 4: 5%, riesgo 5: 10%)
  ≥ 100 − kLuckyBreakPercent (5)    → Golpe de suerte: éxito
```

Consecuencias: +8 fatiga y +25 XP a la skill usada por evento resuelto. Fallo: −20 salud (−10 en tutorial) y paquete a `wetMinor`. Parcial: −5 salud.

**La banda de azar es de solo 30 puntos** — cada punto que agregues al score mueve el resultado mucho. Antes de cambiar cualquier constante, calculá la probabilidad de fallo en los casos borde: skill 1 / riesgo 5, y skill 10 / riesgo 5.

## Nota y paga de misión (`CompleteMissionUseCase`, ~línea 431)

`total = 30% tiempo + 35% paquete + 35% decisiones` → **S/A/B/C/F** → **150/100/60/30/10** Denarios, y −10 fatiga. `SkillPerks.gradeSBonus` suma en nota S.

## Progresión de skills

- Niveles **1-5**: 100 XP por nivel (`kXpPerSkillLevel`), o manuales de tienda. Solo gatean opciones y suman al score.
- Niveles **6-10**: XP + **Sellos del Gremio**, `sealCostForLevel = {6:2, 7:4, 8:8, 9:14, 10:22}` (50 por camino, 250 los cinco).
- Rank = suma de niveles: `<8` Correo · `<14` Mensajero · `<20` Courier · `<26` Maestro · resto Leyenda. Gatea rutas.
- Definición de nodos y perks: `lib/domain/entities/skill_tree.dart` (`skillTree`, `SkillPerks`).

**Cap duro: el poder combinado de un camino maxeado ≤ +25% de efectividad.** Los perks nunca eliminan la decisión (no hay auto-ganar) ni rompen el gating de skills: hacen mejores las opciones que el jugador ya elige.

## Monedas — una moneda, un trabajo

| Moneda | Rol | Faucets | Sinks |
|---|---|---|---|
| **Denarios** | operación diaria | misiones 10-150, contratos, racha | pociones, descanso, manuales, adelantar misión (1 Den/min, clamp 5-300) |
| **Aureos** | premium (la única comprable) | IAP, gotas de racha | slots de mensajero 20/50/100, boosts, Sellos |
| **Sellos** | élite | 3.er contrato diario, día 7 de racha, 1.ª nota S semanal | **solo** niveles 6-10 del árbol |

Presupuesto objetivo del jugador activo (3 sesiones/día): **~435 Denarios · ~1,5 Aureos · ~1,1 Sellos** por día. Meta de diseño: nivel 10 de UN camino ≈ 5-7 semanas gratis.

Si tocás faucets, revisá que no se rompa esto: **inflación de Denarios → "adelantar misión" se vuelve gratis y canibaliza los rewarded ads de −30 min.**

Catálogo y precios: `shopCatalogue` en `lib/presentation/screens/shop/shop_screen.dart`. Costos de slots: `messengerSlotCosts` en `entities.dart`.

## Contratos y racha (`lib/domain/entities/guild.dart`)

3 contratos diarios elegidos de `_easyPool` / `_mediumPool` / `_sealPool` por `contractIdsForDate` (determinístico por fecha). Recompensas 50-150 Denarios; el del pool de sellos da 1 Sello. Racha de 7 días cíclica: 30 → 50 → 70 → 100 Denarios → 1 Aureo → 150 Denarios → 2 Aureos + 1 Sello.

## Ritmo de misión

- Mínimo **1 evento cada 8 h** de duración: una misión de 72 h con pocos eventos se siente muerta.
- Ningún evento debe exigir más de ~90 segundos de atención.
- Los eventos congelan el progreso hasta que se resuelvan (todavía **no** hay auto-resolución a los 60 min — está en el roadmap 1.3).

## Antes de commitear un cambio numérico

- [ ] Calculaste el impacto en los dos casos borde (novato riesgo 5, maxeado riesgo 5).
- [ ] El fallo sigue existiendo en el endgame.
- [ ] No se rompe el presupuesto diario ni el cap de +25%.
- [ ] `flutter test` pasa (`test/domain_test.dart` cubre dominio).
- [ ] Si el cambio contradice el GDD §5/§6, actualizá el GDD en la misma pasada.
