// lib/presentation/widgets/components.dart
//
// Componentes genéricos del design system que antes estaban copiados a mano
// en cada pantalla: chips, botón de ícono, diálogos, sheets, estados de
// carga/vacío/error, barra de progreso continua y contadores.
// Se exportan desde widgets.dart.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../feedback/feedback.dart';
import '../theme/app_theme.dart';
import '../../domain/entities/game_clock.dart';

// ═══════════════════════════════════════════════════════════════
// CHIPS
// ═══════════════════════════════════════════════════════════════

enum GameChipSize { small, medium }

/// Etiqueta con borde de color: riesgo, tiempo, skill, consecuencia, info.
/// Reemplaza las ~9 variantes que había por pantalla.
class GameChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Color de borde, fondo tenue e ícono. Null = neutro (info pasiva).
  final Color? color;
  final GameChipSize size;

  const GameChip(
    this.label, {
    super.key,
    this.icon,
    this.trailingIcon,
    this.color,
    this.size = GameChipSize.small,
  });

  /// Los pigmentos claros son para rellenos: como texto se usa su versión
  /// profunda (todos los demás pasan 4.5:1 sobre papel, ver kTextPairs).
  static Color legibleText(Color c) => switch (c) {
        AppColors.ochre || AppColors.ochreLight => AppColors.ochreDeep,
        AppColors.cinnabarLight => AppColors.cinnabar,
        AppColors.egyptianBlueLight => AppColors.egyptianBlue,
        AppColors.verdigrisLight => AppColors.verdigris,
        AppColors.tyrianLight => AppColors.tyrian,
        _ => c,
      };

  /// Papel apenas teñido y opaco: el chip se lee igual sobre una card que
  /// sobre una escena pintada.
  static Color tint(Color c) => paperTint(c);

  @override
  Widget build(BuildContext context) {
    final neutral = color == null;
    final c = color ?? AppColors.inkSoft;
    final small = size == GameChipSize.small;
    final iconSize = small ? 12.0 : 14.0;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? AppSpacing.sm : AppSpacing.md,
          vertical: small ? 3 : 6),
      decoration: BoxDecoration(
        color: neutral ? AppColors.paperDeep : tint(c),
        borderRadius: BorderRadius.circular(small ? AppRadii.sm : AppRadii.lg),
        border: Border.all(
            color: neutral ? AppColors.paperLine : c.withValues(alpha: 0.6),
            width: small ? 1.5 : 2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: c),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.ui(small ? 12 : 13,
                  color: legibleText(c), weight: FontWeight.bold)),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(trailingIcon, size: iconSize, color: c),
        ],
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BOTONES DE ÍCONO
// ═══════════════════════════════════════════════════════════════

/// Botón cuadrado de ícono con profundidad, 44×44 como mínimo (regla 8).
class GameIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;
  final Color color;
  final double size;

  /// Suena como "volver" en vez de como un toque.
  final bool isBack;

  const GameIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.color = AppColors.ochreDeep,
    this.size = 44,
    this.isBack = false,
  });

  @override
  State<GameIconButton> createState() => _GameIconButtonState();
}

class _GameIconButtonState extends State<GameIconButton> {
  static const _depth = 4.0;
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final down = _pressed && enabled;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: () {
          if (!enabled) return AppFeedback.denied();
          widget.isBack ? AppFeedback.back() : AppFeedback.tap();
          widget.onTap!();
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size + _depth,
          child: AnimatedPadding(
            duration: AppMotion.of(context, AppMotion.fast),
            curve: AppMotion.enter,
            padding: EdgeInsets.only(
                top: down ? _depth - 1 : 0, bottom: down ? 1 : _depth),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.paperDeep,
                borderRadius: BorderRadius.circular(AppRadii.md - 2),
                border: Border.all(
                    color: enabled ? widget.color : AppColors.paperLine,
                    width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(0, down ? 1 : _depth),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(widget.icon,
                  size: widget.size * 0.48,
                  color: enabled ? widget.color : AppColors.inkMuted),
            ),
          ),
        ),
      ),
    );
  }
}

/// El botón de volver de todas las pantallas. [onTap] por defecto hace pop.
class GameBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const GameBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) => GameIconButton(
        icon: Icons.arrow_back_rounded,
        semanticLabel: 'Volver',
        isBack: true,
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
      );
}

// ═══════════════════════════════════════════════════════════════
// DIÁLOGOS Y SHEETS
// ═══════════════════════════════════════════════════════════════

/// Abre un diálogo con la entrada del juego (escala + fade) y la barrera de
/// siempre. Usalo con [GameDialog] como contenido.
Future<T?> showGameDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Cerrar',
    barrierColor: AppColors.scrim,
    transitionDuration: AppMotion.of(context, AppMotion.base),
    pageBuilder: (ctx, _, __) => builder(ctx),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
          parent: anim, curve: AppMotion.pop, reverseCurve: AppMotion.exit);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

/// Marco estándar de diálogo: navy, borde de color, ícono opcional arriba.
class GameDialog extends StatelessWidget {
  final IconData? icon;
  final Color accent;
  final String? title;
  final Widget child;
  final List<Widget> actions;

  const GameDialog({
    super.key,
    required this.child,
    this.icon,
    this.title,
    this.accent = AppColors.ochreDeep,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: AppColors.paperDeep.withValues(alpha: 1),
        insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: accent, width: 2.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 40, color: accent),
              const SizedBox(height: AppSpacing.md),
            ],
            if (title != null) ...[
              Text(title!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: GameChip.legibleText(accent))),
              const SizedBox(height: AppSpacing.md),
            ],
            Flexible(child: SingleChildScrollView(child: child)),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              for (final a in actions) ...[
                a,
                if (a != actions.last) const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ]),
        ),
      );
}

/// Panel inferior del juego (rutas, gremio, detalle de un nodo).
Future<T?> showGameSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(
      duration: AppMotion.of(context, AppMotion.slow),
      reverseDuration: AppMotion.of(context, AppMotion.base),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.paperDeep,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.lg + 4)),
          border: Border(
              top: BorderSide(color: AppColors.ochreDeep, width: 2.5)),
        ),
        child: Column(children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.paperLine,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Text(title, style: AppTextStyles.titleLarge),
            ),
          Expanded(
            child: PrimaryScrollController(
                controller: scroll, child: builder(ctx)),
          ),
        ]),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// ESTADOS: CARGANDO · VACÍO · ERROR
// ═══════════════════════════════════════════════════════════════

/// Mensaje legible para el jugador a partir de una excepción. Nunca muestra
/// tipos ni trazas: "Exception: Aureos insuficientes" → "Aureos insuficientes".
String userMessageFor(Object error) {
  var text = error.toString();
  for (final prefix in ['Exception: ', 'StateError: ', 'Bad state: ']) {
    if (text.startsWith(prefix)) text = text.substring(prefix.length);
  }
  final looksTechnical = text.contains('Error') ||
      text.contains('Null check') ||
      text.contains('type \'') ||
      text.contains('RangeError') ||
      text.length > 160 ||
      text.trim().isEmpty;
  return looksTechnical
      ? 'Algo se trabó en el camino. Probá de nuevo en un momento.'
      : text;
}

/// Aviso corto al pie, con el estilo del juego. Reemplaza los SnackBar crudos.
void showGameSnack(BuildContext context, String message,
    {bool isError = false}) {
  if (isError) AppFeedback.denied();
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.paper,
      elevation: 3,
      margin: const EdgeInsets.all(AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(
            color: isError ? AppColors.cinnabar : AppColors.ochreDeep, width: 2),
      ),
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppColors.cinnabar : AppColors.ochreDeep, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(message, style: AppTextStyles.bodyLarge)),
      ]),
    ));
}

/// Error de una operación: [showGameSnack] con el mensaje limpio.
void showErrorSnack(BuildContext context, Object error) =>
    showGameSnack(context, userMessageFor(error), isError: true);

class LoadingState extends StatelessWidget {
  final String? message;
  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
                color: AppColors.ochreDeep, strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message!, style: AppTextStyles.bodyMedium),
          ],
        ]),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 44, color: AppColors.inkMuted),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              textAlign: TextAlign.center, style: AppTextStyles.titleMedium),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(body!,
                textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ]),
      );
}

class ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  const ErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: EmptyState(
          icon: Icons.report_gmailerrorred_outlined,
          title: 'No pudimos cargar esto',
          body: userMessageFor(error),
          action: onRetry == null
              ? null
              : GameButton(
                  label: 'REINTENTAR',
                  icon: Icons.refresh,
                  variant: GameButtonVariant.secondary,
                  onTap: onRetry),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// PROGRESO CONTINUO Y CONTADORES
// ═══════════════════════════════════════════════════════════════

/// Barra de progreso que se mueve suave a 60 fps a partir de una función del
/// tiempo, sin reconstruir nada por encima de ella. Ideal para el viaje: se
/// le pasa `(now) => mission.progressAt(now)` y avanza sola.
class LiveProgressBar extends StatefulWidget {
  final double Function(DateTime now) progressAt;
  final double height;
  final Gradient gradient;
  final Color track;

  /// Marcas (0..1) sobre la barra: eventos del camino.
  final List<double> marks;

  const LiveProgressBar({
    super.key,
    required this.progressAt,
    this.height = 10,
    this.gradient = AppGradients.ochre,
    this.track = AppColors.paperShade,
    this.marks = const [],
  });

  @override
  State<LiveProgressBar> createState() => _LiveProgressBarState();
}

class _LiveProgressBarState extends State<LiveProgressBar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _value = ValueNotifier<double>(0);
  Duration _lastPaint = Duration.zero;

  @override
  void initState() {
    super.initState();
    _value.value = widget.progressAt(GameClock.now()).clamp(0.0, 1.0);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    // Con movimiento reducido alcanza con 1 actualización por segundo.
    final step = AppMotion.userPrefersReduced.value
        ? const Duration(seconds: 1)
        : Duration.zero;
    if (elapsed - _lastPaint < step) return;
    _lastPaint = elapsed;
    _value.value = widget.progressAt(GameClock.now()).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: CustomPaint(
            painter: _BarPainter(
              value: _value,
              gradient: widget.gradient,
              track: widget.track,
              marks: widget.marks,
            ),
          ),
        ),
      );
}

class _BarPainter extends CustomPainter {
  final ValueNotifier<double> value;
  final Gradient gradient;
  final Color track;
  final List<double> marks;

  _BarPainter({
    required this.value,
    required this.gradient,
    required this.track,
    required this.marks,
  }) : super(repaint: value);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    final full = RRect.fromRectAndRadius(Offset.zero & size, r);
    canvas.drawRRect(full, Paint()..color = track);

    final w = size.width * value.value;
    if (w > 0) {
      final fill = Rect.fromLTWH(0, 0, w, size.height);
      canvas.save();
      canvas.clipRRect(full);
      canvas.drawRect(
          fill, Paint()..shader = gradient.createShader(Offset.zero & size));
      // Brillo superior: le da volumen sin otro color.
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, size.height * 0.35),
        Paint()..color = AppColors.paperHigh.withValues(alpha: 0.18),
      );
      canvas.restore();
    }

    for (final m in marks) {
      final x = size.width * m.clamp(0.0, 1.0);
      final passed = m <= value.value;
      canvas.drawCircle(
        Offset(x, size.height / 2),
        size.height * 0.42,
        Paint()..color = passed ? AppColors.ink : AppColors.inkSoft,
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.gradient != gradient || old.marks != marks || old.track != track;
}

/// Reconstruye solo su hijo cada [period]: relojes y cuentas regresivas sin
/// tocar el resto de la pantalla.
class PeriodicBuilder extends StatefulWidget {
  final Duration period;
  final WidgetBuilder builder;
  const PeriodicBuilder({
    super.key,
    this.period = const Duration(seconds: 1),
    required this.builder,
  });

  @override
  State<PeriodicBuilder> createState() => _PeriodicBuilderState();
}

class _PeriodicBuilderState extends State<PeriodicBuilder> {
  late final Stream<int> _ticks =
      Stream.periodic(widget.period, (i) => i);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: _ticks,
        builder: (context, _) => widget.builder(context),
      );
}

/// Número que cuenta desde su valor anterior hasta el nuevo.
class CountUpText extends StatelessWidget {
  final int value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const CountUpText(
    this.value, {
    super.key,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: value.toDouble()),
        duration: AppMotion.of(context, duration),
        curve: AppMotion.enter,
        builder: (_, v, __) =>
            Text('$prefix${v.round()}$suffix', style: style),
      );
}

/// Tag del Hero de la cabecera de un evento (panel de misión → decisión).
String eventHeroTag(String eventId) => 'event-$eventId';

/// Durante el vuelo la card cambia de alto: el contenido se dibuja con su
/// alto natural y se recorta, en vez de desbordar mientras se achica.
Widget eventHeroShuttle(BuildContext _, Animation<double> __,
        HeroFlightDirection direction, BuildContext from, BuildContext to) {
  final hero = (direction == HeroFlightDirection.push ? to : from).widget as Hero;
  return ClipRect(
    child: OverflowBox(
      alignment: Alignment.topCenter,
      maxHeight: double.infinity,
      child: hero.child,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// CELEBRACIÓN
// ═══════════════════════════════════════════════════════════════

/// Estallido de polvo dorado, una sola vez. Se superpone (Stack) detrás o
/// delante de lo que se festeja. Con movimiento reducido no dibuja nada.
class ParticleBurst extends StatefulWidget {
  final int count;
  final List<Color> colors;
  final Duration duration;
  final Duration delay;
  final double spread;

  const ParticleBurst({
    super.key,
    this.count = 36,
    this.colors = const [AppColors.ochreDeep, AppColors.paper, AppColors.sienna],
    this.duration = const Duration(milliseconds: 1400),
    this.delay = Duration.zero,
    this.spread = 160,
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration);
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = _Rng(widget.count * 7919);
    _particles = List.generate(widget.count, (i) {
      final angle = rnd.next() * 6.2832;
      final speed = 0.45 + rnd.next() * 0.55;
      return _Particle(
        dx: speed * _cos(angle),
        dy: speed * _sin(angle) - 0.35,
        size: 2.5 + rnd.next() * 3.5,
        spin: rnd.next() * 6,
        color: widget.colors[i % widget.colors.length],
      );
    });
    Future.delayed(widget.delay, () {
      if (mounted && !AppMotion.userPrefersReduced.value) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _BurstPainter(_ctrl, _particles, widget.spread),
        ),
      ),
    );
  }
}

class _Particle {
  final double dx, dy, size, spin;
  final Color color;
  const _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.spin,
    required this.color,
  });
}

class _BurstPainter extends CustomPainter {
  final Animation<double> t;
  final List<_Particle> particles;
  final double spread;
  _BurstPainter(this.t, this.particles, this.spread) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    if (v == 0 || v == 1) return;
    final center = size.center(Offset.zero);
    final ease = 1 - (1 - v) * (1 - v); // easeOut
    final fade = v < 0.7 ? 1.0 : (1 - v) / 0.3;
    for (final p in particles) {
      final pos = center +
          Offset(p.dx * spread * ease, p.dy * spread * ease + 120 * v * v);
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * v * 3);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 1.6),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => false;
}

/// Pseudoaleatorio determinístico (las partículas no cambian entre rebuilds).
class _Rng {
  int _s;
  _Rng(this._s);
  double next() {
    _s = (_s * 1103515245 + 12345) & 0x7fffffff;
    return _s / 0x7fffffff;
  }
}

double _sin(double x) => math.sin(x);
double _cos(double x) => math.cos(x);
