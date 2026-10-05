// lib/presentation/widgets/widgets.dart
// Shared widgets NOT already defined in app_theme.dart.
// GameButton, GameCard, GradientScaffold, StatBar, RiskChip,
// DeadlineChip, PackageBadge, SkillIcon → all live in app_theme.dart.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

export 'components.dart';

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
class CurrencyChip extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: type.color.withValues(alpha: 0.7), width: 2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(type.icon, size: fontSize - 1, color: type.color),
        const SizedBox(width: 5),
        if (animate)
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
  Future.delayed(const Duration(milliseconds: 2200), () {
    if (entry.mounted) entry.remove();
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
class GradeBadge extends StatelessWidget {
  final String grade;
  final double size;

  const GradeBadge({super.key, required this.grade, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = gradeColor(grade);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2.5),
      ),
      child: Center(
        child: Text(
          grade,
          style: AppTextStyles.fredoka(
            size * 0.5,
            color: color,
            weight: FontWeight.bold,
          ),
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