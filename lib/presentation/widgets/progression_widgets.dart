import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../domain/entities/progression.dart';
import '../feedback/feedback.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Piezas de progresión: medallas de logro, laurel de rango y selector de
// títulos. Las usan la pantalla de logros, el perfil y las celebraciones.
// ─────────────────────────────────────────────────────────────────────────────

IconData achievementIcon(AchievementKind kind) => switch (kind) {
      AchievementKind.road => Icons.route,
      AchievementKind.grade => Icons.stars,
      AchievementKind.guild => Icons.account_balance,
      AchievementKind.skill => Icons.military_tech,
      AchievementKind.story => Icons.auto_stories,
      AchievementKind.empire => Icons.savings,
    };

String achievementKindLabel(AchievementKind kind) => switch (kind) {
      AchievementKind.road => 'El camino',
      AchievementKind.grade => 'Entregas perfectas',
      AchievementKind.guild => 'El gremio',
      AchievementKind.skill => 'Oficio',
      AchievementKind.story => 'Historia',
      AchievementKind.empire => 'Fortuna',
    };

const _romanRanks = ['', 'I', 'II', 'III', 'IV', 'V'];

// ─── Medalla ──────────────────────────────────────────────────────────────────
/// Moneda dorada si está ganada; hueco apagado con candado si no.
class AchievementMedal extends StatelessWidget {
  final AchievementKind kind;
  final bool unlocked;
  final double size;
  const AchievementMedal({
    super.key,
    required this.kind,
    required this.unlocked,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: unlocked ? AppGradients.gold : null,
        color: unlocked ? null : AppColors.bgCard2,
        border: Border.all(
            color: unlocked ? AppColors.outline : AppColors.bgLine,
            width: size > 40 ? 2.5 : 2),
        boxShadow: unlocked
            ? const [
                BoxShadow(
                    color: AppColors.goldShadow,
                    offset: Offset(0, 3),
                    blurRadius: 0),
              ]
            : null,
      ),
      child: Icon(
        unlocked ? achievementIcon(kind) : Icons.lock_outline,
        size: size * 0.5,
        color: unlocked ? AppColors.outline : AppColors.textMuted,
      ),
    );
  }
}

// ─── Laurel de rango ──────────────────────────────────────────────────────────
/// Corona de laurel alrededor de un medallón con el número romano del rango.
class RankLaurel extends StatelessWidget {
  final int rank;
  final double size;
  const RankLaurel({super.key, required this.rank, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LaurelPainter(),
        child: Center(
          child: Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.gold,
              border: Border.all(color: AppColors.outline, width: 3),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.goldShadow,
                    offset: Offset(0, 5),
                    blurRadius: 0),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _romanRanks[rank.clamp(1, 5)],
              style: AppTextStyles.fredoka(size * 0.2,
                  color: AppColors.outline, weight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _LaurelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.38;
    final leaf = Paint()..color = AppColors.gold;
    final edge = Paint()
      ..color = AppColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final stem = Paint()
      ..color = AppColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Dos ramas: de abajo hacia arriba, una por lado, sin cerrarse arriba.
    for (final side in [-1.0, 1.0]) {
      const start = math.pi * 0.62; // abajo
      const sweep = math.pi * 0.78; // hasta casi arriba
      final path = Path();
      for (var i = 0; i <= 20; i++) {
        final a = start + sweep * i / 20;
        final p = c + Offset(side * math.cos(a) * -r, math.sin(a) * r);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, stem);

      const leaves = 7;
      for (var i = 0; i < leaves; i++) {
        final a = start + sweep * (i + 0.5) / leaves;
        final p = c + Offset(side * math.cos(a) * -r, math.sin(a) * r);
        // Dirección de la rama en ese punto: la hoja apunta hacia donde crece.
        final tangent = math.atan2(side * math.sin(a), -math.cos(a));
        for (final out in [-1.0, 1.0]) {
          canvas.save();
          canvas.translate(p.dx, p.dy);
          canvas.rotate(tangent + out * 0.7 * side);
          final len = size.width * (0.11 - i * 0.004);
          final rect = Rect.fromCenter(
              center: Offset(0, -len / 2), width: len * 0.42, height: len);
          canvas.drawOval(rect, leaf);
          canvas.drawOval(rect, edge);
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Selector de títulos ──────────────────────────────────────────────────────
class TitlePicker extends StatelessWidget {
  final List<String> titles;
  final String? equipped;
  final ValueChanged<String> onToggle;
  const TitlePicker({
    super.key,
    required this.titles,
    required this.equipped,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final t in titles)
          Semantics(
            button: true,
            selected: t == equipped,
            label: t == equipped ? '$t, equipado' : t,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () {
                AppFeedback.tap();
                onToggle(t);
              },
              child: AnimatedContainer(
                duration: AppMotion.of(context, AppMotion.base),
                curve: AppMotion.standard,
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: t == equipped ? AppGradients.gold : null,
                  color: t == equipped
                      ? null
                      : AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                      color: t == equipped
                          ? AppColors.outline
                          : AppColors.gold.withValues(alpha: 0.45),
                      width: 2),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(t == equipped ? Icons.check : Icons.military_tech,
                      color:
                          t == equipped ? AppColors.outline : AppColors.gold,
                      size: 16),
                  const SizedBox(width: 6),
                  Text(t,
                      style: AppTextStyles.fredoka(13,
                          color: t == equipped
                              ? AppColors.outline
                              : AppColors.gold,
                          weight: FontWeight.bold)),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}
