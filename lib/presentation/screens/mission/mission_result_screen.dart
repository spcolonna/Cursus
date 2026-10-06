import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/art_image.dart';
import '../../widgets/messenger_avatar.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/progression.dart';
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
      switch (grade) {
        case 'S' || 'A':
          AppFeedback.success();
        case 'B' || 'C':
          AppFeedback.partial();
        default:
          AppFeedback.fail();
      }
    });
  }

  static const _gradeLabels = {
    'S': '¡LEGENDARIO!',
    'A': '¡EXCELENTE!',
    'B': 'BIEN HECHO',
    'C': 'PASABLE',
    'F': 'FALLIDO',
  };

  static const _denarioReward = {
    'S': 150,
    'A': 100,
    'B': 60,
    'C': 30,
    'F': 10,
  };

  @override
  Widget build(BuildContext context) {
    final grade = result?.grade ?? 'B';
    final color = gradeColor(grade);
    final gradeLabel = _gradeLabels[grade] ?? '';
    // La recompensa real viene del resultado (incluye bonus de perks);
    // el mapa es solo fallback para resultados guardados con el schema viejo.
    final reward = (result?.denarios ?? 0) > 0
        ? result!.denarios
        : (_denarioReward[grade] ?? 30);
    final bgColor = gradeBackground(grade);
    final reduced = AppMotion.reduced(context);
    Duration at(int ms) => reduced ? Duration.zero : Duration(milliseconds: ms);
    Duration d(int ms) => AppMotion.of(context, Duration(milliseconds: ms));
    final celebrate = grade == 'S' || grade == 'A';

    final timeScore = result?.timeScore ?? 0;
    final packageScore = result?.packageScore ?? 0;
    final decisionScore = result?.decisionScore ?? 0;
    final total = timeScore * 0.30 + packageScore * 0.35 + decisionScore * 0.35;

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
              Expanded(
                child: Text(
                  '${mission.origin} → ${mission.destination}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.fredoka(13, color: AppColors.textSecondary),
                ),
              ),
              if (mission.isTutorial)
                const GameChip('PRUEBA DE VARUS', color: AppColors.amber),
            ]),
          ),

          // ── Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(children: [
                const SizedBox(height: 12),

                // La nota cae como un sello de cera; con S/A estalla polvo
                // dorado, con F tiembla.
                SizedBox(
                  height: 170,
                  child: Stack(alignment: Alignment.center, children: [
                    if (celebrate)
                      Positioned.fill(
                        child: ParticleBurst(
                          delay: const Duration(milliseconds: 380),
                          spread: grade == 'S' ? 200 : 150,
                          count: grade == 'S' ? 48 : 30,
                        ),
                      ),
                    reduced
                        ? _GradeSeal(grade: grade, color: color)
                            .animate()
                            .fadeIn(duration: d(200))
                        : grade == 'F'
                            ? _GradeSeal(grade: grade, color: color)
                                .animate(
                                    onComplete: (_) => AppFeedback.seal())
                                .scale(
                                    begin: const Offset(2.2, 2.2),
                                    duration: 380.ms,
                                    curve: AppMotion.exit)
                                .fade(duration: 250.ms)
                                .then()
                                .shake(hz: 5, duration: 500.ms)
                            : _GradeSeal(grade: grade, color: color)
                                .animate()
                                .scale(
                                    begin: const Offset(2.4, 2.4),
                                    duration: 380.ms,
                                    curve: AppMotion.exit)
                                .fade(duration: 200.ms)
                                .callback(callback: (_) => AppFeedback.seal())
                                .then()
                                .shimmer(
                                    duration: 900.ms,
                                    color: celebrate
                                        ? AppColors.parchment
                                        : AppColors.textMuted),
                  ]),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  gradeLabel,
                  style: AppTextStyles.fredoka(22,
                      color: GameChip.legibleText(color),
                      weight: FontWeight.bold,
                      letterSpacing: 2),
                )
                    .animate(delay: at(300))
                    .fadeIn(duration: d(250))
                    .slideY(begin: 0.1),

                const SizedBox(height: 6),

                CountUpText(
                  total.round(),
                  suffix: '% de eficacia',
                  duration: const Duration(milliseconds: 900),
                  style:
                      AppTextStyles.fredoka(14, color: AppColors.textSecondary),
                ).animate(delay: at(400)).fadeIn(duration: d(250)),

                const SizedBox(height: 28),

                // Epílogo narrativo — el cierre del capítulo de historia.
                if (mission.epilogue != null) ...[
                  _EpilogueCard(text: mission.epilogue!)
                      .animate(delay: at(450))
                      .fadeIn(duration: d(300))
                      .slideY(begin: 0.08),
                  const SizedBox(height: 16),
                ],

                _ScoreCard(
                  timeScore: timeScore,
                  packageScore: packageScore,
                  decisionScore: decisionScore,
                  gradeColor: color,
                )
                    .animate(delay: at(500))
                    .fadeIn(duration: d(300))
                    .slideY(begin: 0.08),

                const SizedBox(height: 16),

                _RewardCard(
                  denarios: reward,
                  gradeColor: color,
                  grade: grade,
                  payFactor: mission.payFactor,
                )
                    .animate(delay: at(650))
                    .fadeIn(duration: d(300))
                    .slideY(begin: 0.08),

                const SizedBox(height: 16),

                if (mission.events.isNotEmpty)
                  _EventsSummary(mission: mission)
                      .animate(delay: at(750))
                      .fadeIn(duration: d(300))
                      .slideY(begin: 0.08),

                // ── Lo que cambió ─────────────────────────────────────────
                // Antes esto se aplicaba en silencio: reputación, diario,
                // flags y título quedaban invisibles para el jugador.
                if (completion != null) ...[
                  const SizedBox(height: 16),
                  _WhatChanged(completion: completion!)
                      .animate(delay: at(850))
                      .fadeIn(duration: d(300))
                      .slideY(begin: 0.08),
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
              onTap: () => context.go('/home'),
            ).animate(delay: at(950)).fadeIn(duration: d(300)),
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
        gradient: AppGradients.story,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple, width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_stories, color: AppColors.purple, size: 16),
          const SizedBox(width: 8),
          Text('LA HISTORIA CONTINÚA',
              style: AppTextStyles.fredoka(12,
                  color: AppColors.textPrimary,
                  weight: FontWeight.bold,
                  letterSpacing: 1.5)),
        ]),
        const SizedBox(height: 10),
        Text(text,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 14,
              height: 1.6,
              color: AppColors.parchment,
            )),
      ]),
    );
  }
}

/// La nota como sello de cera: borde ondulado, letra grabada.
class _GradeSeal extends StatelessWidget {
  final String grade;
  final Color color;
  const _GradeSeal({required this.grade, required this.color});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nota $grade',
      child: SizedBox(
        width: 140,
        height: 140,
        child: CustomPaint(
          painter: _WaxSealPainter(color),
          child: Center(
            child: Text(grade,
                style: AppTextStyles.fredoka(78,
                    color: AppColors.parchment, weight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _WaxSealPainter extends CustomPainter {
  final Color color;
  _WaxSealPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 6;
    // Borde ondulado de cera derramada.
    final blob = Path();
    const lobes = 14;
    for (var i = 0; i <= lobes * 4; i++) {
      final a = i / (lobes * 4) * 6.28318;
      final wobble =
          1 + 0.06 * (i.isEven ? 1 : -1) * ((i ~/ 2).isEven ? 1 : 0.5);
      final p = c + Offset.fromDirection(a, r * wobble);
      i == 0 ? blob.moveTo(p.dx, p.dy) : blob.lineTo(p.dx, p.dy);
    }
    blob.close();
    canvas.drawPath(
        blob.shift(const Offset(0, 6)), Paint()..color = AppColors.shadowHard);
    final dark = Color.lerp(color, AppColors.outline, 0.45)!;
    canvas.drawPath(
        blob,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [color, dark],
          ).createShader(Rect.fromCircle(center: c, radius: r)));
    // Anillo grabado interior.
    canvas.drawCircle(
        c,
        r * 0.72,
        Paint()
          ..color = dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    canvas.drawCircle(
        c,
        r * 0.72 - 3,
        Paint()
          ..color = AppColors.parchment.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(_WaxSealPainter old) => old.color != color;
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
        color: AppColors.bgCard2,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: gradeColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(children: [
        Text('DESGLOSE',
            style: AppTextStyles.fredoka(12,
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
    if (s >= 75) return 'Humedad leve';
    if (s >= 50) return 'Dañado';
    if (s >= 25) return 'Comprometido';
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
          Text(sublabel, style: AppTextStyles.bodySmall),
        ]),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 70,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(children: [
            Container(height: 10, color: AppColors.outline),
            // La barra se llena: el puntaje se "cuenta" frente al jugador.
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (score / 100).clamp(0.0, 1.0)),
              duration:
                  AppMotion.of(context, const Duration(milliseconds: 900)),
              curve: AppMotion.enter,
              builder: (_, v, __) => FractionallySizedBox(
                widthFactor: v,
                child: Container(height: 10, color: _color),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 36,
        child: CountUpText(score.round(),
            style: AppTextStyles.fredoka(13,
                color: GameChip.legibleText(_color), weight: FontWeight.bold)),
      ),
      SizedBox(
        width: 38,
        child: Text('×$weight%',
            style: AppTextStyles.fredoka(12, color: AppColors.textMuted),
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
    final flagLines =
        completion.flagsSet.map(flagDescription).whereType<String>().toList();

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
              style: AppTextStyles.fredoka(12,
                  color: AppColors.textSecondary, letterSpacing: 1.2)),
        ]),
        const SizedBox(height: 12),

        // Ilustración del final, si ya existe (sin archivo no ocupa lugar).
        if (completion.endingId case final id?
            when ArtCatalog.has(ArtPaths.ending(id)))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: ArtImage(
                    asset: ArtPaths.ending(id),
                    fallback: const SizedBox.shrink()),
              ),
            ),
          ),

        // Título de arco: lo más grande que puede pasarte.
        if (completion.endingTitle != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            child: Row(children: [
              const Icon(Icons.military_tech,
                  color: AppColors.outline, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Ganaste el título «${completion.endingTitle}»',
                    style: AppTextStyles.fredoka(14,
                        color: AppColors.outline, weight: FontWeight.bold)),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        // Experiencia por habilidad
        if (completion.xpGained.isNotEmpty) ...[
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in completion.xpGained.entries)
              GameChip(
                '+${e.value} XP ${e.key.label}',
                icon: Icons.school_outlined,
                color: AppColors.sky,
                size: GameChipSize.medium,
              ),
          ]),
          const SizedBox(height: 10),
        ],

        // Cuerpo del mensajero
        if (hasBody) ...[
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (completion.fatigueDelta != 0)
              GameChip(
                '${completion.fatigueDelta} de fatiga al llegar',
                icon: Icons.self_improvement,
                color: AppColors.green,
                size: GameChipSize.medium,
              ),
            if (completion.injured)
              const GameChip(
                'Llegaste herido: descansá antes de salir',
                icon: Icons.medical_services_outlined,
                color: AppColors.red,
                size: GameChipSize.medium,
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
                  e.value > 0 ? Icons.trending_up : Icons.trending_down,
                  size: 15,
                  color: e.value > 0 ? AppColors.riskLow : AppColors.riskMed,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    e.value > 0
                        ? '${e.key.label} te tiene más en cuenta (+${e.value})'
                        : '${e.key.label} desconfía más de vos (${e.value})',
                    style: AppTextStyles.bodyMedium,
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
              const Icon(Icons.key_outlined, size: 15, color: AppColors.purple),
              const SizedBox(width: 7),
              Expanded(
                child: Text(line,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.35)),
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
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.menu_book_outlined,
                  size: 15, color: AppColors.purple),
              const SizedBox(width: 8),
              Expanded(
                child: Text('«${completion.journalEntry}»',
                    style: AppTextStyles.bodyMedium
                        .copyWith(height: 1.4, fontStyle: FontStyle.italic)),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ── Recompensa ────────────────────────────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final int denarios;
  final Color gradeColor;
  final String grade;
  final double payFactor;
  const _RewardCard({
    required this.denarios,
    required this.gradeColor,
    required this.grade,
    required this.payFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.sky.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.sky.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Contador que sube de 0 al total — la recompensa se siente ganada.
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: denarios),
              duration:
                  AppMotion.of(context, const Duration(milliseconds: 900)),
              curve: AppMotion.enter,
              builder: (_, value, __) => RewardAmount(
                  type: CurrencyType.denarios, amount: value, fontSize: 22),
            ),
            const SizedBox(width: 10),
            const GameChip('RECOMPENSA', color: AppColors.sky),
          ],
        ),
        // De dónde sale el número: nota × la ruta que elegiste.
        if (payFactor != 1.0) ...[
          const SizedBox(height: 6),
          Text(
            'Nota $grade: ${gradeBaseReward(grade)} × ruta '
            '${payFactor.toStringAsFixed(1).replaceAll('.', ',')}',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ]),
    );
  }
}

// ── Resumen de eventos ────────────────────────────────────────────────────────
class _EventsSummary extends StatelessWidget {
  final Mission mission;
  const _EventsSummary({required this.mission});

  @override
  Widget build(BuildContext context) {
    final resolved =
        mission.events.where((e) => e.status == EventStatus.resolved).toList();
    if (resolved.isEmpty) return const SizedBox.shrink();

    final successes =
        resolved.where((e) => e.outcome?.type == OutcomeType.success).length;
    final total = resolved.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgLine, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('EVENTOS RESUELTOS',
                style: AppTextStyles.fredoka(12,
                    color: AppColors.textMuted,
                    weight: FontWeight.bold,
                    letterSpacing: 1.5)),
            const Spacer(),
            Text('$successes/$total exitosos',
                style: AppTextStyles.fredoka(12,
                    color: successes == total
                        ? AppColors.green
                        : successes > 0
                            ? AppColors.amber
                            : AppColors.textPrimary,
                    weight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          ...resolved.map((e) {
            final isSuccess = e.outcome?.type == OutcomeType.success;
            final isPartial = e.outcome?.type == OutcomeType.partial;
            final color = isSuccess
                ? AppColors.green
                : isPartial
                    ? AppColors.amber
                    : AppColors.red;
            final icon = isSuccess
                ? Icons.check_circle
                : isPartial
                    ? Icons.warning_rounded
                    : Icons.cancel;
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
                              style: AppTextStyles.bodySmall),
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
