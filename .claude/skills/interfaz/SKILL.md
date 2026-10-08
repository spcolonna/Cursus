---
name: interfaz
description: Diseñar o modificar UI de Cursus — pantallas, widgets, colores, tipografía, layout, animaciones, diálogos, estados vacíos y de carga. Usar siempre que se toque lib/presentation/ (theme, widgets, screens) o cuando se pida "una pantalla nueva", "que se vea mejor", "arreglar el contraste", "un botón/card/chip".
---

# Interfaz de Cursus

Identidad **"Fresco al atardecer"**: papel y tinta sobre un cielo que sigue la hora real. La interfaz es papel (`paper`/`paperDeep`) con texto en tinta, así el contraste no depende de la hora; lo que cambia con el reloj es el cielo. Marcellus (títulos) · Figtree (interfaz) · Literata (prosa narrativa). Botones de estampa: relleno plano, contorno de tinta y sombra dura corta.

## Lo primero: no inventes componentes

El design system vive en `lib/presentation/theme/app_theme.dart`. Antes de escribir un widget, buscá si ya existe:

- `app_theme.dart`: `GradientScaffold` (la página de papel, que de noche baja a `paperNight`; `background:` para una escena) · `PaperPage` (solo el fondo de papel) · `GameButton` (variantes primary/secondary/ghost/danger/info/success/secret; se hunde, suena y vibra solo) · `GameCard` (tocable con `onTap`, `frieze: true` para la guarda pompeyana) · `PompeianFrieze` · `StatBar` · `RiskChip` · `DeadlineChip` · `PackageBadge` · `paperTint(color)` (fondo teñido opaco).
- `widgets/components.dart`: `GameChip` (toda etiqueta) · `GameIconButton` / `GameBackButton` (44 px) · `showGameDialog` + `GameDialog` · `showGameSheet` · `LoadingState` / `EmptyState` / `ErrorState` · `showGameSnack` / `showErrorSnack` (nunca `Text('$e')`) · `LiveProgressBar` (progreso por tiempo, 60 fps sin rebuilds) · `PeriodicBuilder` (relojes) · `CountUpText` · `ParticleBurst`.
- Cielo vivo: `theme/sky.dart` (`SkyPalette.at(hora)`: colores, astro, estrellas, `titleColor`, `titleHalo`, `statusBar`) · `widgets/living_sky.dart` (`LivingSkyBackground`: el paisaje de la hora real) · `skyPaletteProvider` (con `debugSkyHourProvider` para QA, en Ajustes solo en debug). Nunca leas `DateTime.now()` para decidir día/noche: usá el provider.
- `widgets/widgets.dart`: `CurrencyChip` · `RewardAmount` · `showRewardToast` · `GradeBadge` · `SectionHeader`. `MessengerHero` (retrato con Hero) en `messenger_avatar.dart`.

Fuentes: Marcellus, Figtree y Literata van empaquetadas en `assets/fonts/` (instancias estáticas, OFL registrada en `main.dart`); se usan solo vía `AppTextStyles` (`heading`, `ui`, `prose`, `proseItalic`). No vuelvas a `google_fonts`: descargaba en runtime.

Celebraciones (logros, rango nuevo): no las muestres a mano; encolá un `ProgressionUpdate` vía `progressionProvider.notifier.record(...)` y las pinta `CelebrationHost`.

Tokens: `AppColors`, `AppGradients`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppMotion`. **Nunca escribas un `Color(0x…)`, un `Colors.xxx` ni un `TextStyle` crudo en una pantalla** (lo verifica `test/design_system_test.dart`). Si falta un token, agregalo al theme.

Movimiento: duraciones y curvas de `AppMotion` (`fast/base/slow/celebrate`, `enter/exit/standard/pop`). Envolvé duraciones con `AppMotion.of(context, d)` y salteá loops/sacudidas si `AppMotion.reduced(context)`. Feedback físico: `AppFeedback.tap/reward/success/partial/fail/delivery/impact/denied`, nunca `HapticFeedback` ni el SFX directo. Texto mínimo 12 pt (lo fuerzan los helpers de `AppTextStyles`).

Detalles de tokens y ratios de contraste medidos: `references/tokens.md`.
Patrones de pantalla, jerarquía y animación: `references/patrones.md`.

## Reglas duras

1. **WCAG AA obligatorio.** Todo par texto/fondo nuevo se agrega a `kTextPairs` (`app_theme.dart`) y lo valida `test/contrast_test.dart`. Los pigmentos `*Light` y `ochre` son solo rellenos: como texto van `ochreDeep`, `cinnabar`, etc.
2. **Sin emojis.** Íconos Material, tamaño 11-28, del set ya usado.
3. **Un pigmento, un rol.** Ocre = acción principal · cinabrio = marca y peligro (siempre con ícono) · azul egipcio = información · verdigrís = éxito · púrpura de Tiro = sigilo y secreto · siena = atención. Máx. 4 por pantalla además de papel y tinta.
4. **Un solo `GameButton` primario (ocre) por vista.** Lo demás: `secondary`, `ghost` o una `GameCard`.
5. **Texto chico siempre sobre papel.** Sobre el cielo o una escena pintada solo van títulos grandes: en `sky.titleColor` con `sky.titleHalo` (tinta o cal según la hora), o en `onSky` con `scrimSky`. Rótulos, monedas y chips van opacos (`GameChip`, `CurrencyChip`). El cielo se muestra como ventana (banda del home, splash, login, escenas), nunca detrás de párrafos.
   La barra de estado sigue al fondo: pantallas de papel en tinta (default en `main.dart`); con cielo, `AnnotatedRegion(sky.statusBar)`; `GradientScaffold` con escena ya la pone clara.
6. **Nada translúcido sobre papel para dar color**: `withValues(alpha:)` encima del papel se ve barroso. Usá `paperTint(color)` o un gradiente `*Tint`.
7. **Sin `opacity` sobre texto.** Bajar opacidad es doble penalización de contraste: usá un token más oscuro/claro.
8. **Target táctil ≥44×44 lógicos.**
9. **Nada de scroll infinito ni pantallas de más de 2 scrolls**: el pilar es sesión de 1-3 min.
10. Toda pantalla nueva se registra en `router.dart` con las transiciones custom ya definidas ahí.

## Checklist antes de dar por terminado

- [ ] Cero `Color(0x…)` y cero `TextStyle(` fuera de `app_theme.dart`.
- [ ] Cada par texto/fondo nuevo está en `kTextPairs` y `flutter test test/contrast_test.dart` pasa.
- [ ] Se reusaron los componentes existentes; los nuevos son genéricos y viven en `widgets/widgets.dart`.
- [ ] Estados cubiertos: cargando, vacío, error, y el caso de "ya lo hiciste hoy".
- [ ] Sin emojis; íconos Material coherentes con los de la tienda.
- [ ] Probado mentalmente en pantalla chica (360 dp): sin overflow, textos que envuelven.
- [ ] `flutter analyze` limpio.
