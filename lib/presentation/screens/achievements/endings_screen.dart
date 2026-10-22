import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/content.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/world.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/art_image.dart';
import '../../widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FINALES — la galería de los 9 finales. Los encontrados muestran su
// ilustración y su título; los que faltan, una pista de la decisión que los
// abre. Un arco terminado se puede volver a recorrer sin tocar la partida.
// ─────────────────────────────────────────────────────────────────────────────
class EndingsScreen extends ConsumerWidget {
  const EndingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldProvider);
    final l = AppLocalizations.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
            decoration: const BoxDecoration(
              gradient: AppGradients.header,
              border: Border(bottom: BorderSide(color: AppColors.paperLine)),
            ),
            child: Row(children: [
              GameBackButton(
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/home')),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                  child: Text(l.endingsTitle, style: AppTextStyles.titleLarge)),
            ]),
          ),
          Expanded(
            child: world.when(
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(
                  error: e, onRetry: () => ref.invalidate(worldProvider)),
              data: (w) => _Body(world: w),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final WorldState world;
  const _Body({required this.world});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(gameContentProvider);
    final missions = <Mission>[
      for (final s
          in ref.watch(homeProvider).valueOrNull?.slots ?? <MessengerSlot>[])
        if (s.activeMission case final m?) m,
    ];
    final total = [for (final a in content.arcs) ...content.endingsOf(a.id)];
    final found = world.endingsFound;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
      children: [
        GameCard(
          borderColor: AppColors.ochreDeep,
          child: Row(children: [
            const Icon(Icons.auto_stories,
                color: AppColors.ochreDeep, size: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.endingsCount(found.length, total.length),
                        style: AppTextStyles.heading(22,
                            color: AppColors.ochreDeep)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l.endingsExplainer, style: AppTextStyles.bodySmall),
                  ]),
            ),
          ]),
        ),
        for (final arc in content.arcs) ...[
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: arc.title),
          if (!world.arcCompleted(arc.id))
            GameCard(
              child: Text(l.endingsArcLocked, style: AppTextStyles.bodyMedium),
            )
          else ...[
            for (final e in content.endingsOf(arc.id))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _EndingRow(
                  chapter: e,
                  found: found.contains('${arc.id}:${e.endingId}'),
                  hint: content.endingHint(e.endingId!),
                ),
              ),
            _ReplayAction(
              arcId: arc.id,
              world: world,
              canStart: canStartArcReplay(world, arc.id, missions),
              chapterOnRoad: missions.any((m) => m.arcId == arc.id),
            ),
          ],
        ],
      ],
    );
  }
}

class _EndingRow extends StatelessWidget {
  final StoryMissionConfig chapter;
  final bool found;
  final String? hint;
  const _EndingRow(
      {required this.chapter, required this.found, required this.hint});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final seal = Container(
      color: found ? AppColors.paperDeep : AppColors.paperLine,
      alignment: Alignment.center,
      child: Icon(found ? Icons.verified : Icons.lock_outline,
          color: found ? AppColors.ochreDeep : AppColors.inkMuted, size: 26),
    );
    return GameCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: found ? AppColors.ochreDeep : AppColors.paperLine,
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: SizedBox(
            width: 56,
            height: 70,
            child: found
                ? ArtImage(
                    asset: ArtPaths.ending(chapter.endingId!), fallback: seal)
                : seal,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(found ? chapter.endingTitle ?? '' : l.endingsUnknown,
                style: AppTextStyles.ui(15,
                    color: found ? AppColors.ochreDeep : AppColors.ink,
                    weight: FontWeight.bold)),
            const SizedBox(height: 2),
            if (found)
              Text(l.endingsFoundLabel, style: AppTextStyles.bodySmall)
            else if (hint != null)
              Text(hint!, style: AppTextStyles.proseItalic(size: 14)),
          ]),
        ),
      ]),
    );
  }
}

class _ReplayAction extends ConsumerStatefulWidget {
  final String arcId;
  final WorldState world;
  final bool canStart;
  final bool chapterOnRoad;
  const _ReplayAction({
    required this.arcId,
    required this.world,
    required this.canStart,
    required this.chapterOnRoad,
  });

  @override
  ConsumerState<_ReplayAction> createState() => _ReplayActionState();
}

class _ReplayActionState extends ConsumerState<_ReplayAction> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      await ref.read(worldProvider.notifier).refresh();
      await ref.read(homeProvider.notifier).refresh();
      if (mounted) showGameSnack(context, done);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final replaying = widget.world.isReplaying(widget.arcId);
    if (replaying) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.endingsReplayActive(widget.world.replay!.stage + 1),
            style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        GameButton(
          label: l.endingsAbandon,
          icon: Icons.close,
          variant: GameButtonVariant.ghost,
          isLoading: _busy,
          onTap: widget.chapterOnRoad
              ? null
              : () => _run(
                  () => ref.read(abandonArcReplayUseCaseProvider).execute(),
                  l.endingsAbandoned),
        ),
      ]);
    }
    // Hay otro recorrido abierto: este arco espera su turno.
    if (widget.world.replay != null) return const SizedBox.shrink();
    return GameButton(
      label: l.endingsReplay,
      icon: Icons.replay,
      variant: GameButtonVariant.secondary,
      isLoading: _busy,
      onTap: widget.canStart
          ? () => _run(
              () =>
                  ref.read(startArcReplayUseCaseProvider).execute(widget.arcId),
              l.endingsReplayStarted)
          : null,
    );
  }
}
