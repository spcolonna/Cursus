// lib/presentation/widgets/widgets.dart
// Shared widgets NOT already defined in app_theme.dart.
// GameButton, GameCard, GradientScaffold, StatBar, RiskChip,
// DeadlineChip, PackageBadge, SkillIcon → all live in app_theme.dart.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'insignia.dart';

export 'components.dart';
export 'faction_widgets.dart';
export 'progression_widgets.dart';

// ─── Monedas ──────────────────────────────────────────────────────────────────
// Una moneda, un trabajo (GDD §6.1). Ícono y color viven acá y en ningún otro
// lado: antes estaban copiados a mano en home, tienda, misión y perfil.

enum CurrencyType { denarios, aureos, seals }

extension CurrencyTypeX on CurrencyType {
  IconData get icon => switch (this) {
        CurrencyType.denarios => Icons.toll,
        CurrencyType.aureos => Icons.monetization_on,
        CurrencyType.seals => Icons.workspace_premium,
      };

  Color get color => switch (this) {
        CurrencyType.denarios => AppColors.sky,
        CurrencyType.aureos => AppColors.gold,
        CurrencyType.seals => AppColors.purple,
      };

  /// Color legible sobre navy: el púrpura de los Sellos no llega a 4.5:1,
  /// así que el texto usa un tono claro y el púrpura queda para borde e ícono.
  Color get textColor =>
      this == CurrencyType.seals ? AppColors.textPrimary : color;

  String label(int amount) => switch (this) {
        CurrencyType.denarios => amount == 1 ? 'denario' : 'denarios',
        CurrencyType.aureos => amount == 1 ? 'aureo' : 'aureos',
        CurrencyType.seals => amount == 1 ? 'Sello del Gremio' : 'Sellos',
      };
}

/// Contador de moneda. Con [animate], cuenta desde el valor anterior en vez
/// de saltar — así el jugador VE que ganó algo.
class CurrencyChip extends StatefulWidget {
  final CurrencyType type;
  final int value;
  final bool animate;
  final double fontSize;

  const CurrencyChip({
    super.key,
    required this.type,
    required this.value,
    this.animate = true,
    this.fontSize = 14,
  });

  @override
  State<CurrencyChip> createState() => _CurrencyChipState();
}

class _CurrencyChipState extends State<CurrencyChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));

  @override
  void initState() {
    super.initState();
    CoinTargets._register(widget.type, this);
  }

  @override
  void didUpdateWidget(CurrencyChip old) {
    super.didUpdateWidget(old);
    if (old.type != widget.type) {
      CoinTargets._unregister(old.type, this);
      CoinTargets._register(widget.type, this);
    }
  }

  @override
  void dispose() {
    CoinTargets._unregister(widget.type, this);
    _bump.dispose();
    super.dispose();
  }

  /// Una moneda llegó: el chip da un saltito.
  void _hit() {
    if (!mounted) return;
    _bump.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final fontSize = widget.fontSize;
    final value = widget.value;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: type.color.withValues(alpha: 0.7), width: 2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(type.icon, size: fontSize - 1, color: type.color),
        const SizedBox(width: 5),
        if (widget.animate)
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: value, end: value),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text('$v',
                style: AppTextStyles.fredoka(fontSize,
                    color: type.textColor, weight: FontWeight.bold)),
          )
        else
          Text('$value',
              style: AppTextStyles.fredoka(fontSize,
                  color: type.textColor, weight: FontWeight.bold)),
      ]),
    );
    return AnimatedBuilder(
      animation: _bump,
      builder: (_, child) => Transform.scale(
        scale: 1 + 0.14 * math.sin(_bump.value * math.pi),
        child: child,
      ),
      child: chip,
    );
  }
}

/// Dónde están los contadores de cada moneda, para que las monedas de un
/// premio vuelen hasta el que se ve en pantalla.
class CoinTargets {
  CoinTargets._();
  static final Map<CurrencyType, List<_CurrencyChipState>> _chips = {};

  static void _register(CurrencyType t, _CurrencyChipState s) =>
      (_chips[t] ??= []).add(s);
  static void _unregister(CurrencyType t, _CurrencyChipState s) =>
      _chips[t]?.remove(s);

  /// El último chip montado y visible de esa moneda.
  static _CurrencyChipState? _visible(CurrencyType t) {
    for (final s in (_chips[t] ?? const <_CurrencyChipState>[]).reversed) {
      final box = s.context.findRenderObject() as RenderBox?;
      if (s.mounted && box != null && box.attached && box.hasSize) return s;
    }
    return null;
  }
}

/// Lanza [count] monedas de [type] desde [from] (coordenadas globales) hasta
/// su contador. Sin contador visible o con movimiento reducido, no hace nada.
void flyCoins(BuildContext context, CurrencyType type,
    {required Offset from, int count = 6}) {
  if (AppMotion.reduced(context)) return;
  final target = CoinTargets._visible(type);
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (target == null || overlay == null) return;
  final box = target.context.findRenderObject() as RenderBox;
  final to = box.localToGlobal(box.size.center(Offset.zero));
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: _CoinFlight(
        type: type,
        from: from,
        to: to,
        count: count,
        onCoinArrived: target._hit,
        onDone: () {
          if (entry.mounted) entry.remove();
        },
      ),
    ),
  );
  overlay.insert(entry);
}

class _CoinFlight extends StatefulWidget {
  final CurrencyType type;
  final Offset from;
  final Offset to;
  final int count;
  final VoidCallback onCoinArrived;
  final VoidCallback onDone;
  const _CoinFlight({
    required this.type,
    required this.from,
    required this.to,
    required this.count,
    required this.onCoinArrived,
    required this.onDone,
  });

  @override
  State<_CoinFlight> createState() => _CoinFlightState();
}

class _CoinFlightState extends State<_CoinFlight>
    with SingleTickerProviderStateMixin {
  static const _flight = 0.62; // fracción del total que vuela cada moneda
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    })
    ..forward();
  final _arrived = <int>{};
  late final _rng = math.Random(widget.from.dx.toInt());
  late final _spread = [
    for (var i = 0; i < widget.count; i++)
      Offset(_rng.nextDouble() * 70 - 35, _rng.nextDouble() * 30 - 15),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final children = <Widget>[];
          final stagger = (1 - _flight) / math.max(1, widget.count - 1);
          for (var i = 0; i < widget.count; i++) {
            final t = ((_c.value - i * stagger) / _flight).clamp(0.0, 1.0);
            if (t <= 0) continue;
            if (t >= 1) {
              // Fuera del build: el saltito del chip es otro widget.
              if (_arrived.add(i)) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => widget.onCoinArrived());
              }
              continue;
            }
            // Salen hacia afuera y después se curvan hasta el contador.
            final e = Curves.easeInCubic.transform(t);
            final start = widget.from + _spread[i];
            final ctrl = Offset.lerp(start, widget.to, 0.3)! + const Offset(0, -90);
            final p = _bezier(start, ctrl, widget.to, e);
            final scale = 1.0 - 0.35 * e;
            children.add(Positioned(
              left: p.dx - 11,
              top: p.dy - 11,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgDark,
                    border: Border.all(color: widget.type.color, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: widget.type.color.withValues(alpha: 0.5),
                          blurRadius: 8),
                    ],
                  ),
                  child: Icon(widget.type.icon,
                      size: 13, color: widget.type.color),
                ),
              ),
            ));
          }
          return Stack(children: children);
        },
      );

  static Offset _bezier(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + c * (t * t);
  }
}

/// "+50 denarios" — para diálogos de recompensa y el resumen de entrega.
class RewardAmount extends StatelessWidget {
  final CurrencyType type;
  final int amount;
  final double fontSize;
  final bool withLabel;

  const RewardAmount({
    super.key,
    required this.type,
    required this.amount,
    this.fontSize = 14,
    this.withLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final sign = amount < 0 ? '−' : '+';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(type.icon, size: fontSize, color: type.color),
      const SizedBox(width: 5),
      Text(
        withLabel
            ? '$sign${amount.abs()} ${type.label(amount.abs())}'
            : '$sign${amount.abs()}',
        style: AppTextStyles.fredoka(fontSize,
            color: type.textColor, weight: FontWeight.bold),
      ),
    ]);
  }
}

// ─── Reward Toast ─────────────────────────────────────────────────────────────
// Aviso efímero de recompensa: sube y se desvanece sobre la pantalla actual.
// No bloquea: el jugador sigue jugando (pilar de sesiones de 1-3 min).

/// Una línea de recompensa: moneda + cantidad.
typedef RewardLine = ({CurrencyType type, int amount});

/// Cuántos avisos de recompensa hay en pantalla. Las celebraciones esperan
/// a que llegue a 0 para no encimarse con ellos.
final ValueNotifier<int> rewardToastsVisible = ValueNotifier(0);

void showRewardToast(
  BuildContext context,
  List<RewardLine> rewards, {
  String? note,
}) {
  final lines = rewards.where((r) => r.amount != 0).toList();
  if (lines.isEmpty && note == null) return;
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      top: MediaQuery.of(ctx).padding.top + 64,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: _RewardToastBody(rewards: lines, note: note),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  rewardToastsVisible.value++;
  // Las monedas salen del aviso y vuelan a su contador.
  final media = MediaQuery.of(context);
  final origin = Offset(media.size.width / 2, media.padding.top + 90);
  for (final (i, r) in lines.where((r) => r.amount > 0).indexed) {
    Future.delayed(Duration(milliseconds: 250 + i * 180), () {
      if (!context.mounted) return;
      flyCoins(context, r.type,
          from: origin, count: r.type == CurrencyType.denarios ? 7 : 3);
    });
  }
  Future.delayed(const Duration(milliseconds: 2200), () {
    if (entry.mounted) entry.remove();
    rewardToastsVisible.value--;
  });
}

class _RewardToastBody extends StatelessWidget {
  final List<RewardLine> rewards;
  final String? note;
  const _RewardToastBody({required this.rewards, this.note});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppGradients.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowHard, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final r in rewards) ...[
                RewardAmount(type: r.type, amount: r.amount, fontSize: 15),
                if (r != rewards.last) const SizedBox(width: 14),
              ],
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(note!,
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ]),
      ),
    )
        .animate()
        .fadeIn(duration: 180.ms)
        .slideY(begin: 0.4, end: 0, duration: 260.ms, curve: Curves.easeOut)
        .then(delay: 1500.ms)
        .fadeOut(duration: 320.ms)
        .slideY(begin: 0, end: -0.3, duration: 320.ms);
  }
}

// ─── Grade Badge ──────────────────────────────────────────────────────────────
/// La nota como sello de cera del color de la nota.
class GradeBadge extends StatelessWidget {
  final String grade;
  final double size;

  const GradeBadge({super.key, required this.grade, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = gradeColor(grade);
    // Letra oscura sobre las ceras claras y clara sobre las oscuras: así
    // pasa 4.5:1 en todas.
    final ink = color.computeLuminance() > 0.2
        ? AppColors.outline
        : AppColors.parchment;
    return Semantics(
      label: 'Nota $grade',
      excludeSemantics: true,
      child: WaxSeal(
        size: size,
        color: color,
        shade: Color.lerp(color, AppColors.outline, 0.5)!,
        light: Color.lerp(color, AppColors.white, 0.22)!,
        child: Text(
          grade,
          style: AppTextStyles.fredoka(size * 0.42,
              color: ink, weight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ─── Pulsing Dot (used in mission timeline) ───────────────────────────────────
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulsingDot({super.key, required this.color, this.size = 12});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: _anim.value),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _anim.value * 0.5),
              blurRadius: widget.size * 0.8,
              spreadRadius: widget.size * 0.2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
// NOT const — uses dynamic strings that may contain emoji/icons.
// Remove the 'const' keyword wherever SectionHeader is constructed.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  // ignore: prefer_const_constructors_in_immutables
  SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(
          child: Text(title, style: AppTextStyles.titleMedium),
        ),
        if (trailing != null) trailing!,
      ]),
    );
  }
}