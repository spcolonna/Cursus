import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'widgets.dart';
import '../../infrastructure/progress/player_progress.dart';

/// Checklist post-tutorial (GDD §7): 5 tareas → 3 Aureos + 1 Sello.
class PrimerosPasosCard extends ConsumerWidget {
  const PrimerosPasosCard({super.key});

  static const _labels = {
    PlayerProgress.taskFirstRealRoute: 'Completá tu primera ruta real',
    PlayerProgress.taskBuyItem: 'Comprá un ítem en la tienda',
    PlayerProgress.taskLevelSkill: 'Subí una habilidad',
    PlayerProgress.taskViewGuild: 'Mirá el tablón del gremio',
    PlayerProgress.taskEnableNotifs: 'Activá las notificaciones',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(primerosPasosProvider);

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
            color: AppColors.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.45), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.flag, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('PRIMEROS PASOS',
                      style: AppTextStyles.fredoka(12,
                          color: AppColors.gold,
                          weight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
                Text('${done.length}/${PlayerProgress.allTasks.length}',
                    style: AppTextStyles.fredoka(12, color: AppColors.amber)),
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
                      color: ok ? AppColors.green : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _labels[id] ?? id,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: ok ? AppColors.textSecondary : AppColors.white,
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
                    label: 'RECLAMAR · 3 Aureos + 1 Sello',
                    icon: Icons.card_giftcard,
                    gradient: AppGradients.green,
                    shadowColor: AppColors.greenShadow,
                    fontSize: 14,
                    onTap: () =>
                        ref.read(primerosPasosProvider.notifier).claimReward(),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Completá las 5 tareas y ganás 3 Aureos + 1 Sello.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontSize: 11, color: AppColors.textMuted),
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
            label: 'ENTENDIDO',
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
