part of '../home_screen.dart';

// ─── Card de capítulo de historia ─────────────────────────────────────────────
// El violeta es el color de lo narrativo. Brilla apenas: la historia es la
// zanahoria de la progresión y tiene que verse distinta de una ruta común.
class _StoryChapterCard extends ConsumerStatefulWidget {
  final StoryMissionConfig config;
  const _StoryChapterCard({required this.config});

  @override
  ConsumerState<_StoryChapterCard> createState() => _StoryChapterCardState();
}

class _StoryChapterCardState extends ConsumerState<_StoryChapterCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.story,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple, width: 2.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.25),
              offset: const Offset(0, 4),
              blurRadius: 14),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const GameChip('HISTORIA',
              icon: Icons.auto_stories, color: AppColors.purple),
          const Spacer(),
          GameChip(_durationLabel(c.durationMinutes),
              icon: Icons.schedule, color: AppColors.gold),
        ]),
        const SizedBox(height: AppSpacing.md),
        Text(c.chapterTitle,
            style: AppTextStyles.fredoka(17, weight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        Text('${c.origin} → ${c.destination}',
            style: AppTextStyles.fredoka(13, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        _LoreQuote(text: c.lore, accent: AppColors.purple),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: 'COMENZAR CAPÍTULO',
            icon: Icons.play_arrow_rounded,
            gradient: AppGradients.purple,
            shadowColor: AppColors.purpleShadow,
            fontSize: 16,
            isLoading: _loading,
            onTap: _loading ? null : _start,
          ),
        ),
      ]),
    );

    if (AppMotion.reduced(context)) return card;
    return card
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
            delay: 3.seconds,
            duration: 1400.ms,
            color: AppColors.purple.withValues(alpha: 0.25));
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      await ref.read(homeProvider.notifier).acceptStoryMission(widget.config);
      AppFeedback.impact();
      if (mounted) context.push('/mission');
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
