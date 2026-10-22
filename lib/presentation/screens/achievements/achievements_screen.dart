import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/progression.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../../l10n/app_localizations.dart';

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
        border: Border(bottom: BorderSide(color: AppColors.paperLine)),
      ),
      child: Row(children: [
        GameBackButton(onTap: onBack),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: Text(AppLocalizations.of(context).achTitle,
                style: AppTextStyles.titleLarge)),
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
        const SizedBox(height: AppSpacing.md),
        GameButton(
          label: AppLocalizations.of(context).achSeeEndings,
          icon: Icons.auto_stories,
          variant: GameButtonVariant.secondary,
          onTap: () => context.push('/endings'),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: AppLocalizations.of(context).achYourTitle),
        GameCard(
          child: state.titles.isEmpty
              ? Text(
                  AppLocalizations.of(context).achNoTitles,
                  style: AppTextStyles.bodyMedium)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).achPickTitle,
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
          SectionHeader(title: achievementKindLabel(AppLocalizations.of(context), kind)),
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
      borderColor: AppColors.ochreDeep,
      child: Row(children: [
        const Icon(Icons.emoji_events, color: AppColors.ochreDeep, size: 40),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic, children: [
              CountUpText(done,
                  style: AppTextStyles.heading(28,
                      color: AppColors.ochreDeep)),
              Text(' / $total',
                  style: AppTextStyles.ui(16,
                      color: AppColors.inkSoft)),
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
    final l = AppLocalizations.of(context);
    return Semantics(
      label: hidden
          ? l.achSecret
          : '${def.name}. ${def.goal} '
              '${unlocked ? l.achDone : l.achProgress(progress, def.target)}',
      excludeSemantics: true,
      child: GameCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderColor:
            unlocked ? AppColors.ochreDeep.withValues(alpha: 0.6) : AppColors.paperLine,
        child: Row(children: [
          AchievementMedal(kind: def.kind, unlocked: unlocked, size: 46),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hidden ? l.achSecret : def.name,
                  style: AppTextStyles.ui(15,
                      color: unlocked ? AppColors.ochreDeep : AppColors.ink,
                      weight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(hidden ? l.achSecretHint : def.goal,
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
                              ? AppColors.inkMuted
                              : AppColors.egyptianBlue),
                    if (r.seals > 0)
                      GameChip(l.sealsCount(r.seals),
                          icon: CurrencyType.seals.icon,
                          color: unlocked
                              ? AppColors.inkMuted
                              : AppColors.tyrian),
                    if (r.title != null)
                      GameChip(l.quotedTitle(r.title!),
                          icon: Icons.military_tech,
                          color: unlocked
                              ? AppColors.inkMuted
                              : AppColors.sienna),
                  ]),
                ),
            ]),
          ),
          if (unlocked)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: Icon(Icons.check_circle, color: AppColors.ochreDeep, size: 22),
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
        color: AppColors.paperShade,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
          duration: AppMotion.of(context, AppMotion.celebrate),
          curve: AppMotion.enter,
          builder: (_, v, __) => FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.ochre,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
