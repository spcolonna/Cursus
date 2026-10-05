import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/messenger_avatar.dart';
import '../../widgets/widgets.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../infrastructure/monetization/rewarded_ads_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
class MissionScreen extends ConsumerStatefulWidget {
  /// Mensajero cuya misión se muestra; null = el principal.
  final String? messengerId;
  const MissionScreen({super.key, this.messengerId});

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> {
  // Guardamos referencia directa al notifier para poder pararlo en dispose()
  // sin depender de ref (que puede no estar disponible al disponer)
  MissionProgressNotifier? _progressNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _progressNotifier = ref.read(missionProgressProvider.notifier);
      final mission = ref
          .read(homeProvider)
          .valueOrNull
          ?.slotFor(widget.messengerId)
          ?.activeMission;
      if (mission != null) {
        _progressNotifier!.start(mission);
      }
    });
  }

  @override
  void dispose() {
    // Parar el timer ANTES de dispose para evitar setState sobre widget muerto
    _progressNotifier?.stop();
    _progressNotifier = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);
    // Solo lo que cambia la estructura de la pantalla: el progreso continuo
    // lo pintan la barra y la ruta por su cuenta, sin rebuilds por segundo.
    final (blockedId, readyToDeliver) = ref.watch(missionProgressProvider
        .select((s) => (s.blockedByEvent?.id, s.readyToDeliver)));

    return homeAsync.when(
      loading: () => const _Loading(),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: ErrorState(
            error: e, onRetry: () => ref.read(homeProvider.notifier).refresh()),
      ),
      data: (state) {
        final slot = state.slotFor(widget.messengerId);
        final mission = slot?.activeMission;
        // Si no hay misión activa, el usuario ya navegó a mission-result o home.
        // NO auto-navegar desde acá — eso causa el flash.
        if (slot == null || mission == null) return const _Loading();

        final blocked = blockedId == null
            ? null
            : ref.read(missionProgressProvider).blockedByEvent;

        return GradientScaffold(
          useEventBg: true,
          body: Column(children: [
            SafeArea(
              bottom: false,
              child: _TopBar(mission: mission, messenger: slot.messenger),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.slow),
                switchInCurve: AppMotion.enter,
                switchOutCurve: AppMotion.exit,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                            begin: const Offset(0, 0.04), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
                child: blocked != null
                    // ── Panel de evento: timer congelado
                    ? _EventPanel(
                        key: ValueKey('event-${blocked.id}'),
                        mission: mission,
                        event: blocked,
                      )
                    // ── Vista de viaje normal
                    : _TravelView(
                        key: const ValueKey('travel'),
                        mission: mission,
                        readyToDeliver: readyToDeliver,
                      ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: LoadingState(),
      );
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final Mission mission;
  final Messenger messenger;
  const _TopBar({required this.mission, required this.messenger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.topBar,
        border: Border(
          bottom: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
        ),
      ),
      child: Row(children: [
        GameBackButton(onTap: () => context.pop()),
        const SizedBox(width: AppSpacing.md),
        MessengerHero(messenger, size: 34),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${mission.origin} → ${mission.destination}',
              style: AppTextStyles.fredoka(15,
                  color: AppColors.gold, weight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              mission.isTutorial
                  ? 'Prueba de Varus · ${messenger.name}'
                  : 'En camino · ${messenger.name}',
              style: AppTextStyles.fredoka(12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        PeriodicBuilder(builder: (_) => DeadlineChip(mission: mission)),
      ]),
    );
  }
}

// ─── Vista de viaje ───────────────────────────────────────────────────────────
class _TravelView extends ConsumerWidget {
  final Mission mission;
  final bool readyToDeliver;
  const _TravelView({
    super.key,
    required this.mission,
    required this.readyToDeliver,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = mission.events
        .where((e) => e.status == EventStatus.resolved)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        // Ruta visual: origen → mensajero → destino, con los eventos marcados
        _RouteVisual(mission: mission),

        const SizedBox(height: AppSpacing.xl),

        // Barra de progreso grande: se mueve sola, a 60 fps
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.outline,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.bgLine, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.outline, offset: Offset(0, 4), blurRadius: 0),
            ],
          ),
          child: LiveProgressBar(
            height: 18,
            track: AppColors.trackDark,
            progressAt: mission.progressAt,
            marks: _eventMarks(mission),
          ),
        ),

        const SizedBox(height: 10),

        PeriodicBuilder(builder: (_) {
          final now = DateTime.now();
          final pct = (mission.progressAt(now) * 100).round();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(readyToDeliver ? '¡Llegaste!' : '$pct% del camino',
                  style: AppTextStyles.fredoka(13,
                      color: readyToDeliver
                          ? AppColors.gold
                          : AppColors.textSecondary,
                      weight: readyToDeliver
                          ? FontWeight.bold
                          : FontWeight.normal)),
              if (!readyToDeliver)
                Text(_timeLeft(mission, now),
                    style: AppTextStyles.fredoka(13,
                        color: AppColors.gold, weight: FontWeight.bold)),
            ],
          );
        }),

        const SizedBox(height: 20),

        // Info del paquete
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgCard2,
            borderRadius: BorderRadius.circular(AppRadii.md - 2),
            border: Border.all(color: AppColors.bgLine, width: 1.5),
          ),
          child: Row(children: [
            const Icon(Icons.inventory_2,
                color: AppColors.textSecondary, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: Text(mission.packageDescription,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            PackageBadge(state: mission.packageState),
          ]),
        ),

        // ── Revelado por "Mapa del explorador"
        if (mission.revealEvents) ...[
          const SizedBox(height: AppSpacing.md),
          PeriodicBuilder(
            period: const Duration(seconds: 30),
            builder: (_) => _RevealedNextEvent(mission: mission),
          ),
        ],

        // ── Botón ENTREGAR — solo cuando llegó al destino. Va arriba de las
        // acciones de pago: es LA acción de la pantalla.
        if (readyToDeliver) ...[
          const SizedBox(height: AppSpacing.lg),
          _DeliverButton(mission: mission)
              .animate()
              .fadeIn(duration: AppMotion.of(context, AppMotion.slow))
              .scale(
                  begin: const Offset(0.94, 0.94),
                  curve: AppMotion.pop,
                  duration: AppMotion.of(context, AppMotion.slow)),
        ] else ...[
          const SizedBox(height: AppSpacing.md),
          // ── Skip al próximo evento
          _SkipButton(mission: mission),
          // ── Rewarded ad: −30 min de viaje (cap 4/día)
          const SizedBox(height: 10),
          _TravelAdButton(mission: mission),
        ],

        // ── Historial de eventos resueltos
        if (resolved.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('EVENTOS RESUELTOS',
              style: AppTextStyles.fredoka(12,
                  color: AppColors.textMuted,
                  weight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 10),
          ...resolved.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ResolvedEventTile(event: entry.value)
                    .animate(delay: AppMotion.stagger * entry.key)
                    .fadeIn(duration: AppMotion.of(context, AppMotion.base))
                    .slideY(begin: 0.04),
              )),
        ],
      ],
    );
  }

  String _timeLeft(Mission mission, DateTime now) {
    final left = mission.deadlineAt.difference(now);
    if (left.isNegative) return '¡Llegaste!';
    if (left.inSeconds < 60) return '${left.inSeconds}s';
    if (left.inMinutes < 60) {
      return '${left.inMinutes}m ${left.inSeconds % 60}s';
    }
    return '${left.inHours}h ${left.inMinutes % 60}m';
  }
}

/// Posición (0..1) de cada evento sobre el camino, para marcarlos.
List<double> _eventMarks(Mission mission) {
  final total =
      mission.deadlineAt.difference(mission.startedAt).inSeconds.toDouble();
  if (total <= 0) return const [];
  return [
    for (final e in mission.events)
      (e.triggersAt.difference(mission.startedAt).inSeconds / total)
          .clamp(0.0, 1.0),
  ];
}

// ─── Próximo evento revelado (Mapa del explorador) ────────────────────────────
class _RevealedNextEvent extends StatelessWidget {
  final Mission mission;
  const _RevealedNextEvent({required this.mission});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final next = mission.nextUpcomingEventAt(now);
    if (next == null) return const SizedBox.shrink();

    final left = next.triggersAt.difference(now);
    final etaLabel = left.inHours > 0
        ? 'en ${left.inHours}h ${left.inMinutes % 60}m'
        : left.inMinutes > 0
            ? 'en ${left.inMinutes}m'
            : 'inminente';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md - 2),
        border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Row(children: [
        const Icon(Icons.map, color: AppColors.gold, size: 16),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PRÓXIMO EVENTO REVELADO',
                style: AppTextStyles.fredoka(12,
                    color: AppColors.gold, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(next.title,
                style: AppTextStyles.fredoka(13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(etaLabel,
            style: AppTextStyles.fredoka(12, color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ─── Botón entregar mensaje ───────────────────────────────────────────────────
class _DeliverButton extends ConsumerStatefulWidget {
  final Mission mission;
  const _DeliverButton({required this.mission});

  @override
  ConsumerState<_DeliverButton> createState() => _DeliverButtonState();
}

class _DeliverButtonState extends ConsumerState<_DeliverButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Comprobante: llegaste, falta el sello
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.green, width: 2),
        ),
        child: Row(children: [
          const Icon(Icons.flag_rounded, color: AppColors.green, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Llegaste a ${widget.mission.destination}',
                  style: AppTextStyles.fredoka(15,
                      color: AppColors.green, weight: FontWeight.bold)),
              Text('Entregá el mensaje para cobrar.',
                  style: AppTextStyles.bodyMedium),
            ]),
          ),
        ]),
      ),

      const SizedBox(height: AppSpacing.md),

      SizedBox(
        width: double.infinity,
        child: GameButton(
          label: 'ENTREGAR MENSAJE',
          icon: Icons.assignment_turned_in,
          fontSize: 17,
          isLoading: _loading,
          onTap: _deliver,
        ),
      ),
    ]);
  }

  Future<void> _deliver() async {
    setState(() => _loading = true);
    try {
      final completion = await ref
          .read(homeProvider.notifier)
          .completeMissionByTime(widget.mission.messengerId);

      if (!mounted) return;
      AppFeedback.delivery();

      context.go('/mission-result', extra: {
        'mission': widget.mission,
        'completion': completion,
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showErrorSnack(context, e);
      }
    }
  }
}

// ─── Botón skip al próximo evento ─────────────────────────────────────────────
class _SkipButton extends ConsumerStatefulWidget {
  final Mission mission;
  const _SkipButton({required this.mission});

  @override
  ConsumerState<_SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends ConsumerState<_SkipButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    // El costo baja con el tiempo: se recalcula cada 30 s, no en cada frame.
    return PeriodicBuilder(
      period: const Duration(seconds: 30),
      builder: (context) {
        final cost = SkipToNextEventUseCase.costFor(widget.mission);
        if (cost == 0) return const SizedBox.shrink();

        final hasNextEvent =
            widget.mission.nextUpcomingEventAt(DateTime.now()) != null;
        final skipLabel = hasNextEvent
            ? 'Adelantar al próximo evento'
            : 'Adelantar al final de la misión';

        // Paga la billetera común (la del principal).
        final wallet = ref.watch(homeProvider).valueOrNull?.messenger;
        final canAfford = (wallet?.denarios ?? 0) >= cost;
        final color = canAfford ? AppColors.sky : AppColors.textMuted;

        return GameCard(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          borderColor:
              canAfford ? AppColors.sky.withValues(alpha: 0.5) : AppColors.bgLine,
          semanticLabel: '$skipLabel por $cost denarios',
          onTap: canAfford && !_loading
              ? _skip
              : () => showGameSnack(
                  context, 'Te faltan denarios para adelantar.',
                  isError: true),
          child: Row(children: [
            Icon(Icons.fast_forward_rounded, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: Text(
                    canAfford
                        ? skipLabel
                        : 'Sin denarios suficientes para adelantar',
                    style: AppTextStyles.fredoka(13, color: color))),
            const SizedBox(width: AppSpacing.sm),
            if (_loading)
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: AppColors.sky, strokeWidth: 2))
            else
              RewardAmount(
                  type: CurrencyType.denarios,
                  amount: -cost,
                  fontSize: 13,
                  withLabel: false),
          ]),
        );
      },
    );
  }

  Future<void> _skip() async {
    setState(() => _loading = true);
    try {
      final result = await ref.read(homeProvider.notifier).skipToNextEvent(
            mission: widget.mission,
            messengerId: widget.mission.messengerId,
          );
      if (!mounted) return;
      // Reiniciar el timer con la misión actualizada
      ref.read(missionProgressProvider.notifier).start(result.mission);

      // Si el adelanto trajo un evento, llevar al jugador a decidirlo.
      final pending = result.mission.pendingEvent;
      if (pending != null) {
        context.push('/event?m=${widget.mission.messengerId}');
        return;
      }

      showGameSnack(
          context, 'Adelantaste el tiempo (−${result.cost} denarios)');
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

/// Rewarded: −30 min de viaje (cap 4/día). Simulado hasta AdMob real.
class _TravelAdButton extends ConsumerStatefulWidget {
  final Mission mission;
  const _TravelAdButton({required this.mission});

  @override
  ConsumerState<_TravelAdButton> createState() => _TravelAdButtonState();
}

class _TravelAdButtonState extends ConsumerState<_TravelAdButton> {
  bool _loading = false;
  int _usedToday = 0;

  @override
  void initState() {
    super.initState();
    ref.read(playerProgressProvider).travelAdsUsedToday().then((n) {
      if (mounted) setState(() => _usedToday = n);
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = RewardedAdsService.travelSkipCapPerDay - _usedToday;
    if (remaining <= 0) {
      return Text('Ya usaste los 4 adelantos de hoy',
          style: AppTextStyles.bodySmall, textAlign: TextAlign.center);
    }

    return GameButton(
      label: _loading ? 'Cargando…' : 'Ver anuncio · −30 min ($remaining hoy)',
      icon: Icons.play_circle_outline,
      fontSize: 13,
      variant: GameButtonVariant.secondary,
      isLoading: _loading,
      onTap: _watch,
    );
  }

  Future<void> _watch() async {
    setState(() => _loading = true);
    try {
      final ok = await ref.read(rewardedAdsServiceProvider).showRewarded(
            context: context,
            placement: 'travel_skip_30',
          );
      if (!ok || !mounted) return;
      await ref.read(playerProgressProvider).recordTravelAd();
      await ref.read(homeProvider.notifier).advanceMissionMinutes(
            widget.mission.messengerId,
            30,
          );
      final used = await ref.read(playerProgressProvider).travelAdsUsedToday();
      if (mounted) {
        setState(() => _usedToday = used);
        showGameSnack(context, 'Adelantaste 30 minutos de camino');
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _ResolvedEventTile extends StatelessWidget {
  final MissionEvent event;
  const _ResolvedEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final outcome = event.outcome;
    final isSuccess = outcome?.type == OutcomeType.success;
    final isPartial = outcome?.type == OutcomeType.partial;

    final (borderColor, icon) = isSuccess
        ? (AppColors.green, Icons.check_circle)
        : isPartial
            ? (AppColors.amber, Icons.warning_rounded)
            : (AppColors.red, Icons.cancel);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md - 2),
        border: Border.all(color: borderColor.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: borderColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title,
                  style: AppTextStyles.fredoka(13, weight: FontWeight.bold)),
              if (outcome?.chosenOptionText != null) ...[
                const SizedBox(height: 3),
                Text('Decidiste: ${outcome!.chosenOptionText}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
              if (outcome?.narrative != null) ...[
                const SizedBox(height: AppSpacing.xs),
                // El rojo no es legible como texto: la prosa va en pergamino
                // y el color del resultado queda en el ícono y el borde.
                Text(outcome!.narrative,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: GameChip.legibleText(borderColor),
                        fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Ruta visual ──────────────────────────────────────────────────────────────
// Un camino serpenteante de origen a destino: lo recorrido en oro, lo que
// falta punteado, los eventos como hitos y el mensajero avanzando suave.
class _RouteVisual extends StatefulWidget {
  final Mission mission;
  const _RouteVisual({required this.mission});

  @override
  State<_RouteVisual> createState() => _RouteVisualState();
}

class _RouteVisualState extends State<_RouteVisual>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _clock = ValueNotifier<double>(0); // segundos desde que se abrió

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (AppMotion.userPrefersReduced.value &&
          (elapsed.inMilliseconds - _clock.value * 1000).abs() < 1000) {
        return;
      }
      _clock.value = elapsed.inMilliseconds / 1000;
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CityLabel(label: mission.origin, isOrigin: true),
          _CityLabel(label: mission.destination, isOrigin: false),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      RepaintBoundary(
        child: SizedBox(
          height: 96,
          width: double.infinity,
          child: CustomPaint(
            painter: _RoadPainter(
              mission: mission,
              clock: _clock,
              animate: !AppMotion.reduced(context),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _CityLabel extends StatelessWidget {
  final String label;
  final bool isOrigin;
  const _CityLabel({required this.label, required this.isOrigin});

  @override
  Widget build(BuildContext context) => Flexible(
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isOrigin ? TextAlign.left : TextAlign.right,
            style: AppTextStyles.fredoka(12,
                color: isOrigin ? AppColors.textMuted : AppColors.gold,
                weight: FontWeight.bold)),
      );
}

class _RoadPainter extends CustomPainter {
  final Mission mission;
  final ValueNotifier<double> clock;
  final bool animate;

  _RoadPainter({
    required this.mission,
    required this.clock,
    required this.animate,
  }) : super(repaint: clock);

  Path _road(Size size) {
    final h = size.height;
    final w = size.width;
    const pad = 14.0;
    return Path()
      ..moveTo(pad, h * 0.62)
      ..cubicTo(w * 0.25, h * 0.05, w * 0.42, h * 0.95, w * 0.6, h * 0.5)
      ..cubicTo(w * 0.72, h * 0.2, w * 0.86, h * 0.25, w - pad, h * 0.4);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final progress = mission.progressAt(now).clamp(0.0, 1.0);
    final path = _road(size);
    final metric = path.computeMetrics().first;
    final len = metric.length;

    // Base del camino: tierra oscura con borde.
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);

    // Lo que falta: punteado tenue.
    final dash = Paint()
      ..color = AppColors.bgLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var d = len * progress; d < len; d += 12) {
      canvas.drawPath(metric.extractPath(d, math.min(d + 6, len)), dash);
    }

    // Lo recorrido: oro.
    if (progress > 0) {
      canvas.drawPath(
          metric.extractPath(0, len * progress),
          Paint()
            ..color = AppColors.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round);
    }

    // Origen y destino.
    final start = metric.getTangentForOffset(0)!.position;
    final end = metric.getTangentForOffset(len)!.position;
    _dot(canvas, start, 7, AppColors.textMuted, AppColors.bgLine);
    _flag(canvas, end, progress >= 1);

    // Eventos: hitos sobre el camino.
    for (final (i, m) in _eventMarks(mission).indexed) {
      final e = mission.events[i];
      final pos = metric.getTangentForOffset(len * m)!.position;
      final resolved = e.status == EventStatus.resolved;
      final blocking = e.isUnresolved && !now.isBefore(e.triggersAt);
      final pulse = animate && blocking
          ? 1 + 0.18 * math.sin(clock.value * 5)
          : 1.0;
      _dot(
        canvas,
        pos,
        6.5 * pulse,
        resolved
            ? AppColors.green
            : blocking
                ? AppColors.amber
                : AppColors.bgCard2,
        resolved ? AppColors.greenDark : AppColors.outline,
      );
    }

    // El mensajero: un medallón dorado que avanza y "trota" levemente.
    final tangent = metric.getTangentForOffset(len * progress)!;
    final bob = animate && progress < 1 ? math.sin(clock.value * 7) * 1.6 : 0.0;
    final c = tangent.position.translate(0, -14 + bob);
    canvas.drawCircle(
        c.translate(0, 3), 15, Paint()..color = AppColors.goldShadow);
    canvas.drawCircle(c, 15, Paint()..color = AppColors.gold);
    canvas.drawCircle(
        c,
        15,
        Paint()
          ..color = AppColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    _icon(canvas, c, Icons.directions_run, 18, AppColors.outline);
  }

  void _dot(Canvas canvas, Offset c, double r, Color fill, Color border) {
    canvas.drawCircle(c, r, Paint()..color = fill);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  void _flag(Canvas canvas, Offset base, bool reached) {
    final pole = Paint()
      ..color = AppColors.goldDark
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final top = base.translate(0, -26);
    canvas.drawLine(base, top, pole);
    final cloth = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(top.dx + 16, top.dy + 5)
      ..lineTo(top.dx, top.dy + 11)
      ..close();
    canvas.drawPath(
        cloth, Paint()..color = reached ? AppColors.gold : AppColors.amber);
    _dot(canvas, base, 5, AppColors.gold, AppColors.goldDark);
  }

  void _icon(Canvas canvas, Offset c, IconData icon, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: size,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_RoadPainter old) =>
      old.mission != mission || old.animate != animate;
}

// ─── Panel de evento bloqueante ───────────────────────────────────────────────
class _EventPanel extends StatelessWidget {
  final Mission mission;
  final MissionEvent event;
  const _EventPanel({super.key, required this.mission, required this.event});

  @override
  Widget build(BuildContext context) {
    // Las opciones se deciden siempre en EventScreen: un solo flujo con
    // pronóstico, confirmación y explicación del resultado.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del evento: vuela hasta la pantalla de decisión.
          Hero(
            tag: eventHeroTag(event.id),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.amberCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.amber, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.shadowSoft,
                        offset: Offset(0, 4),
                        blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      GameChip('EVENTO', color: AppColors.amber),
                      Spacer(),
                      GameChip('Progreso pausado',
                          icon: Icons.pause_circle, color: AppColors.amber),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    Text(event.title,
                        style: AppTextStyles.fredoka(20,
                            color: AppColors.gold, weight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(event.description, style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          GameButton(
            label: 'DECIDIR',
            icon: Icons.alt_route,
            onTap: () => context.push('/event?m=${mission.messengerId}'),
          ),
        ],
      ),
    );
  }
}
