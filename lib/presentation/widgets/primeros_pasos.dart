import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'widgets.dart';
import '../../infrastructure/progress/player_progress.dart';
import '../../l10n/app_localizations.dart';

/// Checklist post-tutorial (GDD §7): 5 tareas → 3 Aureos + 1 Sello.
class PrimerosPasosCard extends ConsumerWidget {
  const PrimerosPasosCard({super.key});

  static Map<String, String> _labels(AppLocalizations l) => {
        PlayerProgress.taskFirstRealRoute: l.firstStepsRoute,
        PlayerProgress.taskBuyItem: l.firstStepsBuy,
        PlayerProgress.taskLevelSkill: l.firstStepsSkill,
        PlayerProgress.taskViewGuild: l.firstStepsGuild,
        PlayerProgress.taskEnableNotifs: l.firstStepsNotifs,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(primerosPasosProvider);
    final l = AppLocalizations.of(context);
    final labels = _labels(l);

    return progress.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) {
        if (state.claimed || !state.tutorialDone) return const SizedBox.shrink();
        final done = state.completed;
        final allDone = PlayerProgress.allTasks.every(done.contains);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: paperTint(AppColors.ochreDeep),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ochreDeep.withValues(alpha: 0.45), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.flag, color: AppColors.ochreDeep, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.firstStepsTitle,
                      style: AppTextStyles.ui(12,
                          color: AppColors.ochreDeep,
                          weight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
                Text('${done.length}/${PlayerProgress.allTasks.length}',
                    style: AppTextStyles.ui(12, color: AppColors.sienna)),
              ]),
              const SizedBox(height: 10),
              ...PlayerProgress.allTasks.map((id) {
                final ok = done.contains(id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Icon(
                      ok ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                      color: ok ? AppColors.verdigris : AppColors.inkMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        labels[id] ?? id,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: ok ? AppColors.inkSoft : AppColors.paperHigh,
                          decoration:
                              ok ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ]),
                );
              }),
              if (allDone) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: GameButton(
                    label: l.firstStepsClaim,
                    icon: Icons.card_giftcard,
                    variant: GameButtonVariant.success,
                    fontSize: 14,
                    onTap: () =>
                        ref.read(primerosPasosProvider.notifier).claimReward(),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l.firstStepsHint,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontSize: 11, color: AppColors.inkMuted),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Consejo de primera vez: una vez por pantalla, con el estilo del juego.
Future<void> maybeShowSpotlight({
  required BuildContext context,
  required bool alreadySeen,
  required VoidCallback onSeen,
  required String title,
  required String body,
}) async {
  if (alreadySeen || !context.mounted) return;
  await showGameDialog<void>(
    context,
    builder: (ctx) => GameDialog(
      icon: Icons.lightbulb_outline,
      title: title,
      actions: [
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: AppLocalizations.of(ctx).gotIt,
            fontSize: 15,
            onTap: () => Navigator.pop(ctx),
          ),
        ),
      ],
      child: Text(body,
          style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
    ),
  );
  onSeen();
}
