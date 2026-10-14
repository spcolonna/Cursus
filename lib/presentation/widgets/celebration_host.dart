import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/entities.dart';
import '../../domain/entities/progression.dart';
import '../../domain/entities/world.dart';
import '../feedback/feedback.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'music_director.dart';
import 'widgets.dart';
import '../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CELEBRACIONES — vive sobre toda la app (MaterialApp.router → builder) y
// muestra de a una lo que encola la progresión:
//   · Rango nuevo: laurel a pantalla completa, se cierra con un toque.
//   · Logro o escalón de facción: cinta que baja desde arriba y se va sola.
// Nunca tapa una decisión: mientras el jugador está en /event, espera.
// ─────────────────────────────────────────────────────────────────────────────
class CelebrationHost extends ConsumerStatefulWidget {
  final GoRouter router;
  final Widget child;
  const CelebrationHost({super.key, required this.router, required this.child});

  @override
  ConsumerState<CelebrationHost> createState() => _CelebrationHostState();
}

class _CelebrationHostState extends ConsumerState<CelebrationHost> {
  bool _blocked = false;

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_recheck);
    rewardToastsVisible.addListener(_recheck);
    _blocked = _isBlocked();
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_recheck);
    rewardToastsVisible.removeListener(_recheck);
    super.dispose();
  }

  bool _isBlocked() {
    // Un aviso de recompensa en pantalla: la celebración espera su turno.
    if (rewardToastsVisible.value > 0) return true;
    final path = visibleRouteUri(widget.router).path;
    // Pantallas donde una celebración estorba: decidir y el arranque.
    return path == '/event' || path == '/' || path == '/login';
  }

  // Cambió la ruta o los avisos en pantalla. El router avisa en medio de un
  // build: el cambio se aplica al frame siguiente para no marcar el árbol
  // como sucio mientras se construye.
  void _recheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final blocked = _isBlocked();
      if (blocked != _blocked) setState(() => _blocked = blocked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(celebrationQueueProvider);
    final current = _blocked || queue.isEmpty ? null : queue.first;
    // Mientras se festeja, la música baja (MusicDirector).
    final showing = current != null;
    if (celebrationVisible.value != showing) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => celebrationVisible.value = showing);
    }

    return Stack(children: [
      widget.child,
      if (current?.rank != null)
        Positioned.fill(
          child: _RankUpOverlay(
            key: ValueKey('rank${current!.rank}'),
            rank: current.rank!,
            onDone: _pop,
          ),
        ),
      if (current?.achievement != null || current?.faction != null)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: current!.achievement != null
              ? _achievementToast(current.achievement!)
              : _factionToast(current.faction!, current.tier!),
        ),
    ]);
  }

  Widget _achievementToast(AchievementDef a) {
    final r = a.reward;
    final l = AppLocalizations.of(context);
    return _Toast(
      key: ValueKey(a.id),
      header: l.celebAchievementHeader,
      title: a.name,
      semanticLabel: l.celebAchievementSemantics(a.name),
      leading: AchievementMedal(kind: a.kind, unlocked: true, size: 52),
      chips: [
        if (r.denarios > 0)
          GameChip(l.rewardDenarii(r.denarios),
              icon: CurrencyType.denarios.icon, color: AppColors.egyptianBlue),
        if (r.seals > 0)
          GameChip(l.rewardSeals(r.seals),
              icon: CurrencyType.seals.icon, color: AppColors.tyrian),
        if (r.title != null)
          GameChip(l.quotedTitle(r.title!),
              icon: Icons.military_tech, color: AppColors.sienna),
      ],
      onDone: _pop,
      onOpen: () {
        _pop();
        widget.router.push('/achievements');
      },
    );
  }

  Widget _factionToast(Faction f, FactionTier tier) {
    final opened = ref
        .read(gameContentProvider)
        .factionUnlocks
        .where((u) => u.faction == f && u.tier == tier);
    final l = AppLocalizations.of(context);
    return _Toast(
      key: ValueKey('faction${f.name}${tier.name}'),
      header: l.celebTierHeader,
      title: '${f.label}: ${tier.label}',
      semanticLabel: l.celebTierSemantics(f.label, tier.label),
      leading: FactionBadge(faction: f, size: 52),
      chips: [
        for (final u in opened)
          GameChip(u.name,
              icon: unlockKindIcon(u.kind), color: factionColor(f)),
      ],
      onDone: _pop,
      onOpen: () {
        _pop();
        widget.router.push('/profile?tab=world');
      },
    );
  }

  void _pop() => ref.read(celebrationQueueProvider.notifier).pop();
}

// ─── Cinta desde arriba (logros, facciones) ───────────────────────────────────
class _Toast extends StatefulWidget {
  final String header;
  final String title;
  final String semanticLabel;
  final Widget leading;
  final List<Widget> chips;
  final VoidCallback onDone;
  final VoidCallback onOpen;
  const _Toast({
    super.key,
    required this.header,
    required this.title,
    required this.semanticLabel,
    required this.leading,
    required this.chips,
    required this.onDone,
    required this.onOpen,
  });

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this);
    AppFeedback.achievement();
    _timer = Timer(const Duration(milliseconds: 3800), _leave);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_c.isAnimating && _c.value == 0 && !_leaving) {
      _c.duration = AppMotion.of(context, AppMotion.slow);
      _c.forward();
    }
  }

  Future<void> _leave() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    _timer?.cancel();
    _c.duration = AppMotion.of(context, AppMotion.base);
    await _c.reverse();
    if (mounted) widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = AppMotion.pop.transform(_c.value);
        return Transform.translate(
          offset: Offset(0, (1 - t) * -140),
          child: Opacity(opacity: _c.value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.md, top + AppSpacing.sm, AppSpacing.md, 0),
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: widget.onOpen,
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) < 0) _leave();
            },
            child: Semantics(
              liveRegion: true,
              button: true,
              label: widget.semanticLabel,
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppGradients.paper,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.ochreDeep, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.shadowHard,
                        blurRadius: 18,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: Row(children: [
                  SizedBox.square(
                    dimension: 52,
                    child: Stack(clipBehavior: Clip.none, children: [
                      const Positioned.fill(
                          child: ParticleBurst(count: 18, spread: 70)),
                      widget.leading,
                    ]),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.header,
                            style: AppTextStyles.ui(12,
                                color: AppColors.ochreDeep,
                                weight: FontWeight.bold,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 2),
                        Text(widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTextStyles.ui(17, weight: FontWeight.bold)),
                        if (widget.chips.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: widget.chips,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.inkSoft),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Rango nuevo: laurel a pantalla completa ──────────────────────────────────
class _RankUpOverlay extends StatefulWidget {
  final int rank;
  final VoidCallback onDone;
  const _RankUpOverlay({super.key, required this.rank, required this.onDone});

  @override
  State<_RankUpOverlay> createState() => _RankUpOverlayState();
}

class _RankUpOverlayState extends State<_RankUpOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this);
    AppFeedback.rankUp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.value == 0 && !_c.isAnimating) {
      _c.duration = AppMotion.of(context, AppMotion.celebrate);
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    AppFeedback.tap();
    _c.duration = AppMotion.of(context, AppMotion.base);
    await _c.reverse();
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final title = kRankTitles[widget.rank.clamp(1, 5)];
    final reduced = AppMotion.reduced(context);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final fade = Curves.easeOut.transform((_c.value * 2).clamp(0.0, 1.0));
        final pop =
            AppMotion.pop.transform(((_c.value - 0.15) / 0.85).clamp(0.0, 1.0));
        return Opacity(
          opacity: fade,
          child: Material(
            // Noche de tinta: el laurel y el rango brillan en ocre.
            color: AppColors.ink.withValues(alpha: 0.92),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(AppLocalizations.of(context).celebRankHeader,
                        style: AppTextStyles.ui(16,
                            color: AppColors.ochreLight,
                            weight: FontWeight.bold,
                            letterSpacing: 2)),
                    const SizedBox(height: AppSpacing.lg),
                    Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          if (!reduced)
                            const Positioned.fill(
                              child: ParticleBurst(
                                  count: 48,
                                  spread: 220,
                                  delay: Duration(milliseconds: 250)),
                            ),
                          Transform.scale(
                            scale: 0.6 + 0.4 * pop,
                            child: Transform.rotate(
                              angle: (1 - pop) * -0.25,
                              child: RankLaurel(rank: widget.rank, size: 200),
                            ),
                          ),
                        ]),
                    const SizedBox(height: AppSpacing.lg),
                    Text(title,
                        style: AppTextStyles.heading(34,
                            color: AppColors.ochreLight)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(_blurb(AppLocalizations.of(context), widget.rank),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.paper)),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: 220,
                      child: GameButton(
                        label: AppLocalizations.of(context).celebContinue,
                        icon: Icons.arrow_forward,
                        onTap: _close,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _blurb(AppLocalizations l, int rank) => switch (rank) {
        2 => l.rankBlurb2,
        3 => l.rankBlurb3,
        4 => l.rankBlurb4,
        _ => l.rankBlurb5,
      };
}
