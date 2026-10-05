import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/progression.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LOGROS Y TÍTULOS — qué conseguiste, qué te falta y cuánto. Arriba, el
// selector de títulos (lo que se ve bajo tu nombre); abajo, los logros por
// familia, con barra de progreso y premio a la vista.
// ─────────────────────────────────────────────────────────────────────────────
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionProvider);
    final defs = ref.watch(gameContentProvider).achievements;

    return GradientScaffold(
      body: SafeArea(
        child: Column(children: [
          _Header(onBack: () =>
              context.canPop() ? context.pop() : context.go('/home')),
          Expanded(
            child: progression.when(
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(
                  error: e,
                  onRetry: () => ref.invalidate(progressionProvider)),
              data: (state) => _Body(state: state, defs: defs),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      decoration: const BoxDecoration(
        gradient: AppGradients.header,
        border: Border(bottom: BorderSide(color: AppColors.bgLine)),
      ),
      child: Row(children: [
        GameBackButton(onTap: onBack),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: Text('Logros y títulos', style: AppTextStyles.titleLarge)),
      ]),
    );
  }
}

class _Body extends ConsumerWidget {
  final ProgressionState state;
  final List<AchievementDef> defs;
  const _Body({required this.state, required this.defs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = defs.where((d) => state.unlocked.contains(d.id)).length;
    final kinds = AchievementKind.values
        .where((k) => defs.any((d) => d.kind == k))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
      children: [
        _Summary(done: done, total: defs.length)
            .animate()
            .fadeIn(duration: AppMotion.of(context, AppMotion.base))
            .slideY(begin: 0.06, end: 0),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: 'Tu título'),
        GameCard(
          child: state.titles.isEmpty
              ? Text(
                  'Todavía no ganaste ninguno. Los títulos salen de los logros '
                  'y de los finales de la historia.',
                  style: AppTextStyles.bodyMedium)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tocá uno para llevarlo bajo tu nombre.',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    TitlePicker(
                      titles: state.titles,
                      equipped: state.equippedTitle,
                      onToggle: (t) => ref
                          .read(progressionProvider.notifier)
                          .toggleTitle(t),
                    ),
                  ],
                ),
        ),
        for (final kind in kinds) ...[
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: achievementKindLabel(kind)),
          for (final (i, d) in defs.where((d) => d.kind == kind).indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _AchievementRow(
                def: d,
                unlocked: state.unlocked.contains(d.id),
                progress: d.progressOf(state.stats),
              )
                  .animate(delay: AppMotion.stagger * i)
                  .fadeIn(duration: AppMotion.of(context, AppMotion.base)),
            ),
        ],
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final int done;
  final int total;
  const _Summary({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : done / total;
    return GameCard(
      borderColor: AppColors.gold,
      child: Row(children: [
        const Icon(Icons.emoji_events, color: AppColors.gold, size: 40),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic, children: [
              CountUpText(done,
                  style: AppTextStyles.fredoka(28,
                      color: AppColors.gold, weight: FontWeight.bold)),
              Text(' / $total',
                  style: AppTextStyles.fredoka(16,
                      color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            _Bar(value: ratio, height: 10),
          ]),
        ),
      ]),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final AchievementDef def;
  final bool unlocked;
  final int progress;
  const _AchievementRow({
    required this.def,
    required this.unlocked,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final hidden = def.secret && !unlocked;
    final r = def.reward;
    return Semantics(
      label: hidden
          ? 'Logro secreto'
          : '${def.name}. ${def.goal} '
              '${unlocked ? 'Conseguido' : 'Progreso $progress de ${def.target}'}',
      excludeSemantics: true,
      child: GameCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderColor:
            unlocked ? AppColors.gold.withValues(alpha: 0.6) : AppColors.bgLine,
        child: Row(children: [
          AchievementMedal(kind: def.kind, unlocked: unlocked, size: 46),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hidden ? 'Logro secreto' : def.name,
                  style: AppTextStyles.fredoka(15,
                      color: unlocked ? AppColors.gold : AppColors.textPrimary,
                      weight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(hidden ? 'Seguí la historia para descubrirlo.' : def.goal,
                  style: AppTextStyles.bodyMedium),
              if (!unlocked && !hidden && def.target > 1) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: _Bar(value: progress / def.target, height: 6)),
                  const SizedBox(width: AppSpacing.sm),
                  Text('$progress/${def.target}',
                      style: AppTextStyles.bodySmall),
                ]),
              ],
              if (!hidden && (r.denarios > 0 || r.seals > 0 || r.title != null))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(spacing: 6, runSpacing: 4, children: [
                    if (r.denarios > 0)
                      GameChip('${r.denarios}',
                          icon: CurrencyType.denarios.icon,
                          color: unlocked
                              ? AppColors.textMuted
                              : AppColors.sky),
                    if (r.seals > 0)
                      GameChip('${r.seals} Sello',
                          icon: CurrencyType.seals.icon,
                          color: unlocked
                              ? AppColors.textMuted
                              : AppColors.purple),
                    if (r.title != null)
                      GameChip('«${r.title}»',
                          icon: Icons.military_tech,
                          color: unlocked
                              ? AppColors.textMuted
                              : AppColors.amber),
                  ]),
                ),
            ]),
          ),
          if (unlocked)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: Icon(Icons.check_circle, color: AppColors.gold, size: 22),
            ),
        ]),
      ),
    );
  }
}

/// Barra fija y animada al aparecer (no es tiempo real: no necesita ticker).
class _Bar extends StatelessWidget {
  final double value;
  final double height;
  const _Bar({required this.value, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: AppColors.trackDark,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
          duration: AppMotion.of(context, AppMotion.celebrate),
          curve: AppMotion.enter,
          builder: (_, v, __) => FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
