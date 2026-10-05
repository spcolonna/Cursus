import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/messenger_avatar.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/world.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../data/story_content.dart';

class MissionResultScreen extends ConsumerStatefulWidget {
  final Mission mission;

  /// Todo lo que dejó la entrega: nota, paga, XP, fatiga y las consecuencias
  /// narrativas del capítulo (reputación, diario, flags, título).
  final MissionCompletion? completion;

  const MissionResultScreen({
    super.key,
    required this.mission,
    required this.completion,
  });

  @override
  ConsumerState<MissionResultScreen> createState() =>
      _MissionResultScreenState();
}

class _MissionResultScreenState extends ConsumerState<MissionResultScreen> {
  Mission get mission => widget.mission;
  MissionCompletion? get completion => widget.completion;
  MissionResult? get result => widget.completion?.result;

  @override
  void initState() {
    super.initState();
    final grade = result?.grade ?? 'B';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sfx = ref.read(sfxServiceProvider);
      switch (grade) {
        case 'S' || 'A':
          HapticFeedback.heavyImpact();
          sfx.playDelivery();
        case 'B' || 'C':
          HapticFeedback.mediumImpact();
          sfx.playSuccess();
        default:
          HapticFeedback.vibrate();
          sfx.playPartial();
      }
    });
  }

  static const _gradeColors = {
    'S': Color(0xFFFFD700),
    'A': Color(0xFF44BB66),
    'B': Color(0xFF4A9EBF),
    'C': Color(0xFFCC8800),
    'F': Color(0xFFCC2200),
  };

  static const _gradeLabels = {
    'S': '¡LEGENDARIO!',
    'A': '¡EXCELENTE!',
    'B': 'BIEN HECHO',
    'C': 'PASABLE',
    'F': 'FALLIDO',
  };

  static const _denarioReward = {
    'S': 150, 'A': 100, 'B': 60, 'C': 30, 'F': 10,
  };

  static const _gradeBg = {
    'S': Color(0xFF1A1400),
    'A': Color(0xFF0A1A0E),
    'B': Color(0xFF0A1220),
    'C': Color(0xFF1A1000),
    'F': Color(0xFF1A0808),
  };

  @override
  Widget build(BuildContext context) {
    final grade      = result?.grade ?? 'B';
    final gradeColor = _gradeColors[grade] ?? AppColors.gold;
    final gradeLabel = _gradeLabels[grade] ?? '';
    // La recompensa real viene del resultado (incluye bonus de perks);
    // el mapa es solo fallback para resultados guardados con el schema viejo.
    final reward = (result?.denarios ?? 0) > 0
        ? result!.denarios
        : (_denarioReward[grade] ?? 30);
    final bgColor    = _gradeBg[grade] ?? const Color(0xFF0A1220);

    final timeScore     = result?.timeScore ?? 0;
    final packageScore  = result?.packageScore ?? 0;
    final decisionScore = result?.decisionScore ?? 0;
    final total         = timeScore * 0.30 + packageScore * 0.35 + decisionScore * 0.35;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(children: [
          // ── Cabecera
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              // Quién hizo el viaje: el retrato ancla el resultado a TU mensajero.
              Consumer(builder: (context, ref, _) {
                final m = ref
                    .watch(homeProvider)
                    .valueOrNull
                    ?.slots
                    .where((s) => s.messenger.id == mission.messengerId)
                    .firstOrNull
                    ?.messenger;
                if (m == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: MessengerAvatar.from(m, size: 30),
                );
              }),
              Text(
                '${mission.origin} → ${mission.destination}',
                style: AppTextStyles.fredoka(13, color: AppColors.textSecondary),
              ),
              const Spacer(),
              if (mission.isTutorial)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColors.amber, width: 1.5),
                  ),
                  child: Text('PRUEBA DE VARUS',
                      style: AppTextStyles.fredoka(10,
                          color: AppColors.amber, weight: FontWeight.bold)),
                ),
            ]),
          ),

          // ── Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(children: [
                const SizedBox(height: 12),

                // Grade grande — cae como un sello; brilla si es S/A,
                // tiembla si es F.
                grade == 'F'
                    ? _GradeBig(grade: grade, color: gradeColor)
                        .animate()
                        .scale(
                            begin: const Offset(2.2, 2.2),
                            duration: 380.ms,
                            curve: Curves.easeInCubic)
                        .fade(duration: 250.ms)
                        .then()
                        .shake(hz: 5, duration: 500.ms)
                    : _GradeBig(grade: grade, color: gradeColor)
                        .animate()
                        .scale(
                            begin: const Offset(0.3, 0.3),
                            duration: 700.ms,
                            curve: Curves.elasticOut)
                        .fade(duration: 300.ms)
                        .then()
                        .shimmer(
                            duration: 900.ms,
                            color: grade == 'S' || grade == 'A'
                                ? Colors.white70
                                : Colors.white24),

                const SizedBox(height: 8),

                Text(gradeLabel,
                  style: AppTextStyles.fredoka(22,
                      color: gradeColor,
                      weight: FontWeight.bold,
                      letterSpacing: 2),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),

                const SizedBox(height: 6),

                Text(
                  '${total.round()}% de eficacia',
                  style: AppTextStyles.fredoka(14,
                      color: gradeColor.withValues(alpha: 0.7)),
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: 28),

                // Epílogo narrativo — el cierre del capítulo de historia.
                if (mission.epilogue != null) ...[
                  _EpilogueCard(text: mission.epilogue!)
                      .animate(delay: 450.ms).fadeIn().slideY(begin: 0.08),
                  const SizedBox(height: 16),
                ],

                _ScoreCard(
                  timeScore: timeScore,
                  packageScore: packageScore,
                  decisionScore: decisionScore,
                  gradeColor: gradeColor,
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.08),

                const SizedBox(height: 16),

                _RewardCard(
                  denarios: reward,
                  gradeColor: gradeColor,
                ).animate(delay: 650.ms).fadeIn().slideY(begin: 0.08),

                const SizedBox(height: 16),

                if (mission.events.isNotEmpty)
                  _EventsSummary(mission: mission)
                      .animate(delay: 750.ms).fadeIn().slideY(begin: 0.08),

                // ── Lo que cambió ─────────────────────────────────────────
                // Antes esto se aplicaba en silencio: reputación, diario,
                // flags y título quedaban invisibles para el jugador.
                if (completion != null) ...[
                  const SizedBox(height: 16),
                  _WhatChanged(completion: completion!)
                      .animate(delay: 850.ms).fadeIn().slideY(begin: 0.08),
                ],
              ]),
            ),
          ),

          // ── Botón — la misión ya se completó al entregar, acá solo se vuelve
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 8, 24, MediaQuery.of(context).padding.bottom + 16),
            child: GameButton(
              label: 'VOLVER AL CUARTEL',
              icon: Icons.home_rounded,
              gradient: LinearGradient(
                colors: [gradeColor, gradeColor.withValues(alpha: 0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shadowColor: Color.from(
                alpha: gradeColor.a,
                red: gradeColor.r * 0.4,
                green: gradeColor.g * 0.4,
                blue: gradeColor.b * 0.4,
              ),
              onTap: () => context.go('/home'),
            ).animate(delay: 950.ms).fadeIn(),
          ),
        ]),
      ),
    );
  }
}

// ── Epílogo narrativo ─────────────────────────────────────────────────────────
class _EpilogueCard extends StatelessWidget {
  final String text;
  const _EpilogueCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF241A38), Color(0xFF16101F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_stories, color: AppColors.purple, size: 16),
          const SizedBox(width: 8),
          Text('LA HISTORIA CONTINÚA',
              style: AppTextStyles.fredoka(11,
                  color: AppColors.purple,
                  weight: FontWeight.bold,
                  letterSpacing: 1.5)),
        ]),
        const SizedBox(height: 10),
        Text(text,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 14,
              height: 1.6,
              color: const Color(0xFFF3EEDC),
            )),
      ]),
    );
  }
}

class _GradeBig extends StatelessWidget {
  final String grade;
  final Color color;
  const _GradeBig({required this.grade, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(alignment: Alignment.center, children: [
        Transform.translate(
          offset: const Offset(6, 8),
          child: Text(grade,
              style: AppTextStyles.fredoka(120,
                  color: Colors.black.withValues(alpha: 0.4),
                  weight: FontWeight.bold)),
        ),
        Text(grade,
            style: AppTextStyles.fredoka(120,
                color: color, weight: FontWeight.bold)),
      ]),
    );
  }
}

// ── Desglose de scores ────────────────────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  final double timeScore;
  final double packageScore;
  final double decisionScore;
  final Color gradeColor;
  const _ScoreCard({
    required this.timeScore,
    required this.packageScore,
    required this.decisionScore,
    required this.gradeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradeColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(children: [
        Text('DESGLOSE',
            style: AppTextStyles.fredoka(11,
                color: AppColors.textMuted,
                weight: FontWeight.bold,
                letterSpacing: 1.5)),
        const SizedBox(height: 14),
        _ScoreRow(
          icon: Icons.schedule,
          label: 'Puntualidad',
          sublabel: timeScore >= 80 ? 'A tiempo' : 'Con retraso',
          score: timeScore,
          weight: 30,
        ),
        const SizedBox(height: 12),
        _ScoreRow(
          icon: Icons.inventory_2,
          label: 'Estado del paquete',
          sublabel: _packageLabel(packageScore),
          score: packageScore,
          weight: 35,
        ),
        const SizedBox(height: 12),
        _ScoreRow(
          icon: Icons.psychology,
          label: 'Decisiones',
          sublabel: _decisionLabel(decisionScore),
          score: decisionScore,
          weight: 35,
        ),
      ]),
    );
  }

  String _packageLabel(double s) {
    if (s >= 100) return 'Intacto';
    if (s >= 75)  return 'Humedad leve';
    if (s >= 50)  return 'Dañado';
    if (s >= 25)  return 'Comprometido';
    return 'Perdido';
  }

  String _decisionLabel(double s) {
    if (s >= 90) return 'Decisiones perfectas';
    if (s >= 70) return 'Buenas decisiones';
    if (s >= 50) return 'Decisiones regulares';
    return 'Malas decisiones';
  }
}

class _ScoreRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final double score;
  final int weight;
  const _ScoreRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.score,
    required this.weight,
  });

  Color get _color {
    if (score >= 80) return AppColors.green;
    if (score >= 50) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: _color),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: AppTextStyles.fredoka(13,
                  color: AppColors.textPrimary, weight: FontWeight.bold)),
          Text(sublabel,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted, fontSize: 11)),
        ]),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 70,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(children: [
            Container(height: 10, color: AppColors.outline),
            FractionallySizedBox(
              widthFactor: (score / 100).clamp(0.0, 1.0),
              child: Container(height: 10, color: _color),
            ),
          ]),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 36,
        child: Text('${score.round()}',
            style: AppTextStyles.fredoka(13,
                color: _color, weight: FontWeight.bold),
            textAlign: TextAlign.right),
      ),
      SizedBox(
        width: 30,
        child: Text('×$weight%',
            style: AppTextStyles.fredoka(9, color: AppColors.textMuted),
            textAlign: TextAlign.right),
      ),
    ]);
  }
}

// ── Lo que cambió ─────────────────────────────────────────────────────────────
// La respuesta a "¿en qué ayudó lo que hice?": XP, cuerpo, reputación,
// diario y las puertas que se abrieron.
class _WhatChanged extends StatelessWidget {
  final MissionCompletion completion;
  const _WhatChanged({required this.completion});

  @override
  Widget build(BuildContext context) {
    final flagLines = completion.flagsSet
        .map(flagDescription)
        .whereType<String>()
        .toList();

    final hasBody = completion.fatigueDelta != 0 || completion.injured;
    final hasAnything = completion.xpGained.isNotEmpty ||
        hasBody ||
        completion.repDelta.isNotEmpty ||
        completion.journalEntry != null ||
        flagLines.isNotEmpty ||
        completion.endingTitle != null;
    if (!hasAnything) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgLine, width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.change_history,
              size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Text('LO QUE CAMBIÓ',
              style: AppTextStyles.fredoka(11,
                  color: AppColors.textSecondary, letterSpacing: 1.2)),
        ]),
        const SizedBox(height: 12),

        // Título de arco: lo más grande que puede pasarte.
        if (completion.endingTitle != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black38, width: 2),
            ),
            child: Row(children: [
              const Icon(Icons.military_tech, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Ganaste el título «${completion.endingTitle}»',
                    style:
                        AppTextStyles.fredoka(13, color: Colors.black87)),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        // Experiencia por habilidad
        if (completion.xpGained.isNotEmpty) ...[
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in completion.xpGained.entries)
              _ChangeChip(
                icon: Icons.school_outlined,
                label: '+${e.value} XP ${e.key.label}',
                color: AppColors.sky,
              ),
          ]),
          const SizedBox(height: 10),
        ],

        // Cuerpo del mensajero
        if (hasBody) ...[
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (completion.fatigueDelta != 0)
              _ChangeChip(
                icon: Icons.self_improvement,
                label: '${completion.fatigueDelta} de fatiga al llegar',
                color: AppColors.green,
              ),
            if (completion.injured)
              const _ChangeChip(
                icon: Icons.medical_services_outlined,
                label: 'Llegaste herido: descansá antes de salir',
                color: AppColors.red,
              ),
          ]),
          const SizedBox(height: 10),
        ],

        // Reputación con las facciones
        if (completion.repDelta.isNotEmpty) ...[
          for (final e in completion.repDelta.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Icon(
                  e.value > 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  size: 15,
                  color: e.value > 0 ? AppColors.riskLow : AppColors.riskMed,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    e.value > 0
                        ? '${e.key.label} te tiene más en cuenta (+${e.value})'
                        : '${e.key.label} desconfía más de vos (${e.value})',
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                  ),
                ),
              ]),
            ),
          const SizedBox(height: 4),
        ],

        // Puertas que abrió (o cerró) la decisión
        for (final line in flagLines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.key_outlined,
                  size: 15, color: AppColors.purple),
              const SizedBox(width: 7),
              Expanded(
                child: Text(line,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontSize: 12, height: 1.35)),
              ),
            ]),
          ),

        // Entrada de diario
        if (completion.journalEntry != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.45), width: 1.5),
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 15, color: AppColors.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('«${completion.journalEntry}»',
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            height: 1.4,
                            fontStyle: FontStyle.italic)),
                  ),
                ]),
          ),
        ],
      ]),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ChangeChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.fredoka(11.5, color: color)),
        ]),
      );
}

// ── Recompensa ────────────────────────────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final int denarios;
  final Color gradeColor;
  const _RewardCard({required this.denarios, required this.gradeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.sky.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sky.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Contador que sube de 0 al total — la recompensa se siente ganada.
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: denarios),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => RewardAmount(
                type: CurrencyType.denarios, amount: value, fontSize: 22),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.sky.withValues(alpha: 0.4)),
            ),
            child: Text('RECOMPENSA',
                style: AppTextStyles.fredoka(9,
                    color: AppColors.sky, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

// ── Resumen de eventos ────────────────────────────────────────────────────────
class _EventsSummary extends StatelessWidget {
  final Mission mission;
  const _EventsSummary({required this.mission});

  @override
  Widget build(BuildContext context) {
    final resolved = mission.events
        .where((e) => e.status == EventStatus.resolved)
        .toList();
    if (resolved.isEmpty) return const SizedBox.shrink();

    final successes = resolved
        .where((e) => e.outcome?.type == OutcomeType.success).length;
    final total = resolved.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgLine, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('EVENTOS RESUELTOS',
                style: AppTextStyles.fredoka(11,
                    color: AppColors.textMuted,
                    weight: FontWeight.bold,
                    letterSpacing: 1.5)),
            const Spacer(),
            Text('$successes/$total exitosos',
                style: AppTextStyles.fredoka(11,
                    color: successes == total
                        ? AppColors.green
                        : successes > 0 ? AppColors.amber : AppColors.red,
                    weight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          ...resolved.map((e) {
            final isSuccess = e.outcome?.type == OutcomeType.success;
            final isPartial = e.outcome?.type == OutcomeType.partial;
            final color = isSuccess
                ? AppColors.green
                : isPartial ? AppColors.amber : AppColors.red;
            final icon = isSuccess
                ? Icons.check_circle
                : isPartial ? Icons.warning_rounded : Icons.cancel;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style: AppTextStyles.fredoka(12,
                                color: AppColors.textPrimary,
                                weight: FontWeight.bold)),
                        if (e.outcome?.chosenOptionText != null)
                          Text('Decidiste: ${e.outcome!.chosenOptionText}',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}