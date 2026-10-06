// lib/presentation/widgets/skill_tree_board.dart
//
// El árbol de los cinco caminos de un vistazo: cinco columnas que crecen
// hacia arriba, del nivel 1 al 10. Los niveles 1-5 son hitos de bronce que se
// ganan jugando; los 6-10 son sellos de cera que se lacran con Sellos del
// Gremio. Tocar una columna la elige y abre su detalle debajo.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';
import '../../domain/entities/skill_tree.dart';
import '../feedback/feedback.dart';
import '../theme/app_theme.dart';
import '../theme/art_palette.dart';
import 'insignia.dart';

class SkillTreeBoard extends StatefulWidget {
  final Messenger messenger;
  final SkillType focus;
  final ValueChanged<SkillType> onFocus;

  /// Nodo recién lacrado: se anima la caída del sello.
  final (SkillType, int)? stamp;

  const SkillTreeBoard({
    super.key,
    required this.messenger,
    required this.focus,
    required this.onFocus,
    this.stamp,
  });

  @override
  State<SkillTreeBoard> createState() => _SkillTreeBoardState();
}

class _SkillTreeBoardState extends State<SkillTreeBoard>
    with TickerProviderStateMixin {
  static const _nodesHeight = 330.0;

  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final AnimationController _stamp =
      AnimationController(vsync: this, duration: AppMotion.celebrate);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void didUpdateWidget(SkillTreeBoard old) {
    super.didUpdateWidget(old);
    if (widget.stamp != null && widget.stamp != old.stamp) {
      if (AppMotion.reduced(context)) {
        _stamp.value = 1;
      } else {
        _stamp.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _stamp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.messenger;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.bgLine, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.outline, offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Column(children: [
        // El árbol: los nodos y los conectores en un solo pintor.
        SizedBox(
          height: _nodesHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final skill in SkillType.values)
                Expanded(
                  child: _Column(
                    skill: skill,
                    level: m.skillLevel(skill),
                    focused: skill == widget.focus,
                    pulse: _pulse,
                    stamp: widget.stamp?.$1 == skill ? (widget.stamp!.$2, _stamp) : null,
                    onTap: () {
                      AppFeedback.tap();
                      widget.onFocus(skill);
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Pie: el ícono y el nivel de cada camino.
        Row(children: [
          for (final skill in SkillType.values)
            Expanded(
              child: _Foot(
                skill: skill,
                level: m.skillLevel(skill),
                focused: skill == widget.focus,
                onTap: () {
                  AppFeedback.tap();
                  widget.onFocus(skill);
                },
              ),
            ),
        ]),
      ]),
    );
  }
}

class _Column extends StatelessWidget {
  final SkillType skill;
  final int level;
  final bool focused;
  final Animation<double> pulse;
  final (int, Animation<double>)? stamp;
  final VoidCallback onTap;

  const _Column({
    required this.skill,
    required this.level,
    required this.focused,
    required this.pulse,
    required this.stamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: focused,
        label: '${skill.label}, nivel $level de $kMaxSkillLevelElite',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.base),
            curve: AppMotion.standard,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: focused
                  ? skillColor(skill).withValues(alpha: 0.14)
                  : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                  color: focused ? skillColor(skill) : AppColors.transparent,
                  width: 2),
            ),
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: _PathPainter(
                  color: skillColor(skill),
                  level: level,
                  pulse: pulse,
                  stamp: stamp,
                ),
              ),
            ),
          ),
        ),
      );
}

class _Foot extends StatelessWidget {
  final SkillType skill;
  final int level;
  final bool focused;
  final VoidCallback onTap;
  const _Foot(
      {required this.skill,
      required this.level,
      required this.focused,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = skillColor(skill);
    return ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedScale(
              scale: focused ? 1.12 : 1,
              duration: AppMotion.of(context, AppMotion.base),
              curve: AppMotion.pop,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: focused ? 0.3 : 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(skillIconData(skill), color: color, size: 17),
              ),
            ),
            const SizedBox(height: 4),
            Text('$level/10',
                style: AppTextStyles.fredoka(12,
                    color: focused ? AppColors.textPrimary : AppColors.textSecondary,
                    weight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final Color color;
  final int level;
  final Animation<double> pulse;
  final (int, Animation<double>)? stamp;

  _PathPainter({
    required this.color,
    required this.level,
    required this.pulse,
    required this.stamp,
  }) : super(repaint: Listenable.merge([pulse, if (stamp case (_, final a)) a]));

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const pad = 16.0;
    final rowH = (size.height - pad * 2) / (kMaxSkillLevelElite - 1);
    Offset at(int l) => Offset(cx, size.height - pad - (l - 1) * rowH);

    // Tronco: la parte ganada en el color del camino.
    final trunk = Paint()
      ..color = AppColors.bgLine
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(at(1), at(kMaxSkillLevelElite), trunk);
    if (level > 1) {
      canvas.drawLine(at(1), at(level), trunk..color = color);
    }

    // Umbral de los Sellos, entre el 5 y el 6.
    final gateY = (at(5).dy + at(6).dy) / 2;
    final gate = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    for (var x = 4.0; x < size.width - 4; x += 6) {
      canvas.drawLine(Offset(x, gateY), Offset(x + 3, gateY), gate);
    }

    final p = pulse.value;
    for (var l = 1; l <= kMaxSkillLevelElite; l++) {
      final c = at(l);
      final unlocked = l <= level;
      final next = l == level + 1;
      final elite = l > kMaxSkillLevel;
      if (next) {
        // Halo que respira: el próximo paso del camino.
        final ring = 13 + 5 * p;
        canvas.drawCircle(
            c,
            ring,
            Paint()
              ..color = (elite ? AppColors.purple : color)
                  .withValues(alpha: 0.35 * (1 - p))
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5);
      }
      if (elite) {
        _sealNode(canvas, c, l, unlocked: unlocked, next: next);
      } else {
        _bronzeNode(canvas, c, unlocked: unlocked, next: next);
      }
    }
  }

  void _bronzeNode(Canvas canvas, Offset c,
      {required bool unlocked, required bool next}) {
    const r = 8.5;
    canvas.drawCircle(c.translate(0, 2), r, Paint()..color = AppColors.outline);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = unlocked
              ? color
              : next
                  ? AppColors.bgDark
                  : AppColors.bgCard2);
    if (unlocked) {
      canvas.drawCircle(c.translate(-2.5, -2.5), 2.5,
          Paint()..color = AppColors.white.withValues(alpha: 0.5));
    }
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = next ? color : (unlocked ? AppColors.outline : AppColors.bgLine)
          ..style = PaintingStyle.stroke
          ..strokeWidth = next ? 2.5 : 2);
  }

  void _sealNode(Canvas canvas, Offset c, int l,
      {required bool unlocked, required bool next}) {
    const r = 11.0;
    final stamping = stamp != null && stamp!.$1 == l ? stamp!.$2.value : 1.0;
    if (unlocked) {
      // El sello cae: grande y transparente, se aplasta y rebota un poco.
      final t = Curves.easeOutBack.transform(stamping.clamp(0.0, 1.0));
      final scale = 1 + (1 - t) * 1.2;
      if (stamping < 1) {
        canvas.drawCircle(
            c,
            r * (1 + stamping * 1.8),
            Paint()
              ..color = ArtColors.waxLight.withValues(alpha: 0.4 * (1 - stamping))
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3);
      }
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(scale);
      paintWaxSeal(canvas, Offset.zero, r, outline: 2);
      canvas.restore();
      return;
    }
    // Sin lacrar: el hueco donde va la cera.
    canvas.drawPath(
        waxSealPath(c, r),
        Paint()
          ..color = next
              ? ArtColors.wax.withValues(alpha: 0.25)
              : AppColors.bgCard2);
    canvas.drawPath(
        waxSealPath(c, r),
        Paint()
          ..color = next ? AppColors.purple : AppColors.bgLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = next ? 2.5 : 2);
    if (!next) {
      // Candado mínimo: dos trazos.
      final lock = Paint()
        ..color = AppColors.bgLine
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawRect(Rect.fromCenter(center: c.translate(0, 2), width: 8, height: 6), lock);
      canvas.drawArc(Rect.fromCenter(center: c.translate(0, -1.5), width: 6, height: 6),
          math.pi, math.pi, false, lock);
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.level != level || old.color != color || old.stamp != stamp;
}
