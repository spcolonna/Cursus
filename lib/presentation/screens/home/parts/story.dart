part of '../home_screen.dart';

// ─── Card de capítulo de historia ─────────────────────────────────────────────
// El violeta es el color de lo narrativo. Brilla apenas: la historia es la
// zanahoria de la progresión y tiene que verse distinta de una ruta común.
class _StoryChapterCard extends ConsumerStatefulWidget {
  final StoryMissionConfig config;
  final String? arcTitle;
  const _StoryChapterCard({required this.config, this.arcTitle});

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
        border: Border.all(color: AppColors.tyrian, width: 2.5),
        boxShadow: [
          BoxShadow(
              color: paperTint(AppColors.tyrian),
              offset: const Offset(0, 4),
              blurRadius: 14),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Ilustración del capítulo; sin archivo, el escenario de su primer
        // evento pintado por código.
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: SizedBox(
            height: 112,
            width: double.infinity,
            child: ArtImage(
              asset: ArtPaths.story(c.id),
              fallback: EventScene(category: _chapterScene(ref, c), banner: true),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          const GameChip('HISTORIA',
              icon: Icons.auto_stories, color: AppColors.tyrian),
          const Spacer(),
          GameChip(_durationLabel(c.durationMinutes),
              icon: Icons.schedule, color: AppColors.ochreDeep),
        ]),
        const SizedBox(height: AppSpacing.md),
        if (widget.arcTitle case final arc?)
          Text(arc.toUpperCase(),
              style: AppTextStyles.ui(12,
                  color: AppColors.inkSoft, weight: FontWeight.bold)),
        Text(c.chapterTitle,
            style: AppTextStyles.ui(17, weight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        Text('${c.origin} → ${c.destination}',
            style: AppTextStyles.ui(13, color: AppColors.inkSoft)),
        const SizedBox(height: 10),
        _LoreQuote(text: c.lore, accent: AppColors.tyrian),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: 'COMENZAR CAPÍTULO',
            icon: Icons.play_arrow_rounded,
            variant: GameButtonVariant.secret,
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
            color: AppColors.tyrian.withValues(alpha: 0.25));
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      await ref.read(homeProvider.notifier).acceptStoryMission(widget.config);
      AppFeedback.seal();
      if (mounted) context.push('/mission');
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Capítulo cerrado por rango ───────────────────────────────────────────────
// Sin botón: es una promesa, no una acción. Dice qué capítulo sigue y qué
// rango pide, para que subir de rango tenga un "para qué".
class _LockedStoryCard extends StatelessWidget {
  final StoryStep step;
  const _LockedStoryCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final rank = step.requiredRank.clamp(1, kRankTitles.length - 1);
    return Semantics(
      label: '${step.arc.title}, ${step.chapter.chapterTitle}. '
          'Se abre en rango $rank, ${kRankTitles[rank]}.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.tyrian, width: 2),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: paperTint(AppColors.tyrian),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Icon(Icons.lock_outline,
                color: AppColors.tyrian, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step.arc.title.toUpperCase(),
                  style: AppTextStyles.ui(12,
                      color: AppColors.inkSoft, weight: FontWeight.bold)),
              Text(step.chapter.chapterTitle,
                  style: AppTextStyles.ui(15, weight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('Se abre en rango $rank · ${kRankTitles[rank]}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.inkSoft)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Escenario del capítulo: el de su primer evento.
EventCategory _chapterScene(WidgetRef ref, StoryMissionConfig c) {
  if (c.fixedEventIds.isEmpty) return EventCategory.road;
  return ref.read(gameContentProvider).eventById(c.fixedEventIds.first)?.category ??
      EventCategory.road;
}
