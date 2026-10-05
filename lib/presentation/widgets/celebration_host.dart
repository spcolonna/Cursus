import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/entities.dart';
import '../../domain/entities/progression.dart';
import '../feedback/feedback.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CELEBRACIONES — vive sobre toda la app (MaterialApp.router → builder) y
// muestra de a una lo que encola la progresión:
//   · Rango nuevo: laurel a pantalla completa, se cierra con un toque.
//   · Logro: cinta que baja desde arriba y se va sola.
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
    widget.router.routerDelegate.addListener(_onRoute);
    _blocked = _isBlocked();
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRoute);
    super.dispose();
  }

  bool _isBlocked() {
    final path = widget.router.routerDelegate.currentConfiguration.uri.path;
    // Pantallas donde una celebración estorba: decidir y el arranque.
    return path == '/event' || path == '/' || path == '/login';
  }

  // El router avisa en medio de un build: el cambio se aplica al frame
  // siguiente para no marcar el árbol como sucio mientras se construye.
  void _onRoute() {
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
      if (current?.achievement != null)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _AchievementToast(
            key: ValueKey(current!.achievement!.id),
            achievement: current.achievement!,
            onDone: _pop,
            onOpen: () {
              _pop();
              widget.router.push('/achievements');
            },
          ),
        ),
    ]);
  }

  void _pop() => ref.read(celebrationQueueProvider.notifier).pop();
}

// ─── Logro: cinta desde arriba ────────────────────────────────────────────────
class _AchievementToast extends StatefulWidget {
  final AchievementDef achievement;
  final VoidCallback onDone;
  final VoidCallback onOpen;
  const _AchievementToast({
    super.key,
    required this.achievement,
    required this.onDone,
    required this.onOpen,
  });

  @override
  State<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<_AchievementToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this);
    AppFeedback.reward();
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
    final a = widget.achievement;
    final r = a.reward;
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
              label: 'Logro conseguido: ${a.name}. Tocá para ver tus logros.',
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppGradients.card,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.gold, width: 2.5),
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
                      AchievementMedal(kind: a.kind, unlocked: true, size: 52),
                    ]),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('LOGRO CONSEGUIDO',
                            style: AppTextStyles.fredoka(12,
                                color: AppColors.gold,
                                weight: FontWeight.bold,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 2),
                        Text(a.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.fredoka(17,
                                weight: FontWeight.bold)),
                        if (r.denarios > 0 || r.seals > 0 || r.title != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (r.denarios > 0)
                                  GameChip('+${r.denarios} Denarios',
                                      icon: CurrencyType.denarios.icon, color: AppColors.sky),
                                if (r.seals > 0)
                                  GameChip('+${r.seals} Sello',
                                      icon: CurrencyType.seals.icon,
                                      color: AppColors.purple),
                                if (r.title != null)
                                  GameChip('«${r.title}»',
                                      icon: Icons.military_tech,
                                      color: AppColors.amber),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
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
    AppFeedback.impact();
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
        final pop = AppMotion.pop.transform(
            ((_c.value - 0.15) / 0.85).clamp(0.0, 1.0));
        return Opacity(
          opacity: fade,
          child: Material(
            color: AppColors.scrim,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('¡NUEVO RANGO!',
                        style: AppTextStyles.fredoka(16,
                            color: AppColors.gold,
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
                        style: AppTextStyles.fredoka(34,
                            color: AppColors.gold, weight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(_blurb(widget.rank),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.parchment)),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: 220,
                      child: GameButton(
                        label: 'SEGUIR',
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

  static String _blurb(int rank) => switch (rank) {
        2 => 'En el correo ya saben tu nombre.\nSe abren rutas que antes no te daban.',
        3 => 'Te confían lo que no se puede perder.\nYa nadie te manda a llevar recados.',
        4 => 'Los otros mensajeros te piden consejo.\nRoma empieza a notarte.',
        _ => 'Tu nombre se dice en las postas de todo el Imperio.',
      };
}
