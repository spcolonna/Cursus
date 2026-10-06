---
name: interfaz
description: Diseñar o modificar UI de Cursus — pantallas, widgets, colores, tipografía, layout, animaciones, diálogos, estados vacíos y de carga. Usar siempre que se toque lib/presentation/ (theme, widgets, screens) o cuando se pida "una pantalla nueva", "que se vea mejor", "arreglar el contraste", "un botón/card/chip".
---

# Interfaz de Cursus

Identidad: **navy profundo + oro/pergamino**, Fredoka (títulos) + Nunito (cuerpo), botones 3D con sombra dura offset, rojo **solo** para peligro, fondo día/noche según hora real. La identidad ya funciona: los problemas son de contraste y consistencia, no de estilo.

## Lo primero: no inventes componentes

El design system vive en `lib/presentation/theme/app_theme.dart`. Antes de escribir un widget, buscá si ya existe:

- `app_theme.dart`: `GradientScaffold` · `GameButton` (primary/secondary/danger; se hunde, suena y vibra solo) · `GameCard` (tocable con `onTap`) · `StatBar` · `RiskChip` · `DeadlineChip` · `PackageBadge`.
- `widgets/components.dart`: `GameChip` (toda etiqueta) · `GameIconButton` / `GameBackButton` (44 px) · `showGameDialog` + `GameDialog` · `showGameSheet` · `LoadingState` / `EmptyState` / `ErrorState` · `showGameSnack` / `showErrorSnack` (nunca `Text('$e')`) · `LiveProgressBar` (progreso por tiempo, 60 fps sin rebuilds) · `PeriodicBuilder` (relojes) · `CountUpText` · `ParticleBurst`.
- `widgets/widgets.dart`: `CurrencyChip` · `RewardAmount` · `showRewardToast` · `GradeBadge` · `SectionHeader`. `MessengerHero` (retrato con Hero) en `messenger_avatar.dart`.

Fuentes: Fredoka y Nunito van empaquetadas en `assets/fonts/` (OFL, licencia registrada en `main.dart`); se usan por `fontFamily` vía `AppTextStyles`. No vuelvas a `google_fonts`: descargaba en runtime.

Celebraciones (logros, rango nuevo): no las muestres a mano; encolá un `ProgressionUpdate` vía `progressionProvider.notifier.record(...)` y las pinta `CelebrationHost`.

Tokens: `AppColors`, `AppGradients`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppMotion`. **Nunca escribas un `Color(0x…)`, un `Colors.xxx` ni un `TextStyle` crudo en una pantalla** (lo verifica `test/design_system_test.dart`). Si falta un token, agregalo al theme.

Movimiento: duraciones y curvas de `AppMotion` (`fast/base/slow/celebrate`, `enter/exit/standard/pop`). Envolvé duraciones con `AppMotion.of(context, d)` y salteá loops/sacudidas si `AppMotion.reduced(context)`. Feedback físico: `AppFeedback.tap/reward/success/partial/fail/delivery/impact/denied`, nunca `HapticFeedback` ni el SFX directo. Texto mínimo 12 pt (lo fuerza `AppTextStyles.fredoka`).

Detalles de tokens y ratios de contraste medidos: `references/tokens.md`.
Patrones de pantalla, jerarquía y animación: `references/patrones.md`.

## Reglas duras

1. **WCAG AA obligatorio.** Todo texto ≥4.5:1 sobre su fondo real; títulos ≥18pt (o ≥14pt bold) ≥3:1. `red` (3.0:1) y `purple` (2.6:1) **no se usan como color de texto** sobre navy: solo bordes, fills e íconos grandes.
2. **Sin emojis.** Íconos Material, tamaño 11-28, del set ya usado.
3. **Máx. 4 colores por pantalla.** Navy (fondo) + oro (acción) + un acento + rojo solo si hay peligro real.
4. **Un solo botón primario dorado por vista.** Las acciones secundarias son texto o `GameCard` con borde.
5. **Rojo = urgencia real** (evento pendiente, misión atrasada, paquete perdido). Nada más.
6. **Texto sobre imagen siempre lleva scrim** (`GradientScaffold` ya lo aplica; si ponés texto sobre un asset propio, agregá gradiente negro ≥60%).
7. **Sin `opacity` sobre texto.** Bajar opacidad es doble penalización de contraste: usá un token más oscuro/claro.
8. **Target táctil ≥44×44 lógicos.**
9. **Nada de scroll infinito ni pantallas de más de 2 scrolls**: el pilar es sesión de 1-3 min.
10. Toda pantalla nueva se registra en `router.dart` con las transiciones custom ya definidas ahí.

## Checklist antes de dar por terminado

- [ ] Cero `Color(0x…)` y cero `TextStyle(` fuera de `app_theme.dart`.
- [ ] Cada texto nuevo pasa 4.5:1 (ver tabla en `references/tokens.md`).
- [ ] Se reusaron los componentes existentes; los nuevos son genéricos y viven en `widgets/widgets.dart`.
- [ ] Estados cubiertos: cargando, vacío, error, y el caso de "ya lo hiciste hoy".
- [ ] Sin emojis; íconos Material coherentes con los de la tienda.
- [ ] Probado mentalmente en pantalla chica (360 dp): sin overflow, textos que envuelven.
- [ ] `flutter analyze` limpio.
