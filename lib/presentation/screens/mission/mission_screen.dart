import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/messenger_avatar.dart';
import '../../widgets/event_scene.dart';
import '../../widgets/route_map.dart';
import '../../widgets/widgets.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../domain/entities/game_clock.dart';
import '../../../infrastructure/monetization/rewarded_ads_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/entities/content_l10n.dart';

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
    // Un evento que llega mientras el jugador mira el camino se anuncia.
    ref.listen(missionProgressProvider.select((s) => s.blockedByEvent?.id),
        (prev, next) {
      if (prev == null && next != null) AppFeedback.eventArrive();
    });

    return homeAsync.when(
      loading: () => const _Loading(),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.paperDeep,
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
          // Viajando, el camino; con un evento encima, su escenario.
          background: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.slow),
            layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, if (current != null) current]),
            // Viajando, el mapa es el protagonista: el camino queda de fondo,
            // apagado, para que los textos sobre él se lean.
            child: blocked == null
                ? const Stack(
                    key: ValueKey('travel'),
                    fit: StackFit.expand,
                    children: [
                      EventScene(category: EventCategory.road),
                      ColoredBox(color: AppColors.scrim),
                    ],
                  )
                : KeyedSubtree(
                    key: ValueKey(blocked.id),
                    child: EventBackdrop(event: blocked)),
          ),
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
                    position:
                        Tween(begin: const Offset(0, 0.04), end: Offset.zero)
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
        backgroundColor: AppColors.paperDeep,
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
        color: AppColors.paper,
        border: Border(
          bottom: BorderSide(
              color: AppColors.ochreDeep.withValues(alpha: 0.3), width: 1.5),
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
              '${ContentL10n.place(mission.origin)} → '
              '${ContentL10n.place(mission.destination)}',
              style: AppTextStyles.ui(15,
                  color: AppColors.ochreDeep, weight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              mission.isTutorial
                  ? AppLocalizations.of(context).missionTrialOf(messenger.name)
                  : AppLocalizations.of(context).missionOnRoadOf(messenger.name),
              style: AppTextStyles.ui(12, color: AppColors.inkSoft),
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
    final resolved =
        mission.events.where((e) => e.status == EventStatus.resolved).toList();

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
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.paperLine, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(0, 4),
                  blurRadius: 0),
            ],
          ),
          child: LiveProgressBar(
            height: 18,
            track: AppColors.paperShade,
            progressAt: mission.progressAt,
            marks: eventMarks(mission),
          ),
        ),

        const SizedBox(height: 10),

        PeriodicBuilder(builder: (_) {
          final now = GameClock.now();
          final pct = (mission.progressAt(now) * 100).round();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  readyToDeliver
                      ? AppLocalizations.of(context).missionArrived
                      : AppLocalizations.of(context).slotProgress(pct),
                  style: AppTextStyles.ui(13,
                      color: readyToDeliver
                          ? AppColors.ochreDeep
                          : AppColors.inkSoft,
                      weight: readyToDeliver
                          ? FontWeight.bold
                          : FontWeight.normal)),
              if (!readyToDeliver)
                Text(_timeLeft(context, mission, now),
                    style: AppTextStyles.ui(13,
                        color: AppColors.ochreDeep, weight: FontWeight.bold)),
            ],
          );
        }),

        const SizedBox(height: 20),

        // Info del paquete
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.paperDeep,
            borderRadius: BorderRadius.circular(AppRadii.md - 2),
            border: Border.all(color: AppColors.paperLine, width: 1.5),
          ),
          child: Row(children: [
            const Icon(Icons.inventory_2,
                color: AppColors.inkSoft, size: 16),
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
          // QA: probar el ritmo sin esperar el viaje real.
          if (kDebugMode) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.ink),
              icon: const Icon(Icons.fast_forward, size: 18),
              label: Text(AppLocalizations.of(context).missionDebugAdvance),
              onPressed: () => ref
                  .read(homeProvider.notifier)
                  .advanceMissionMinutes(mission.messengerId, 24 * 60),
            ),
          ],
        ],

        // ── Historial de eventos resueltos
        if (resolved.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(AppLocalizations.of(context).missionResolvedHeader,
              style: AppTextStyles.ui(12,
                  color: AppColors.inkMuted,
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

  String _timeLeft(BuildContext context, Mission mission, DateTime now) {
    final left = mission.deadlineAt.difference(now);
    if (left.isNegative) return AppLocalizations.of(context).missionArrived;
    if (left.inSeconds < 60) return '${left.inSeconds}s';
    if (left.inMinutes < 60) {
      return '${left.inMinutes}m ${left.inSeconds % 60}s';
    }
    return '${left.inHours}h ${left.inMinutes % 60}m';
  }
}

// ─── Próximo evento revelado (Mapa del explorador) ────────────────────────────
class _RevealedNextEvent extends StatelessWidget {
  final Mission mission;
  const _RevealedNextEvent({required this.mission});

  @override
  Widget build(BuildContext context) {
    final now = GameClock.now();
    final next = mission.nextUpcomingEventAt(now);
    if (next == null) return const SizedBox.shrink();

    final left = next.triggersAt.difference(now);
    final l = AppLocalizations.of(context);
    final etaLabel = left.inHours > 0
        ? l.missionEtaIn('${left.inHours}h ${left.inMinutes % 60}m')
        : left.inMinutes > 0
            ? l.missionEtaIn('${left.inMinutes}m')
            : l.missionEtaImminent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: paperTint(AppColors.ochreDeep),
        borderRadius: BorderRadius.circular(AppRadii.md - 2),
        border: Border.all(
            color: AppColors.ochreDeep.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Row(children: [
        const Icon(Icons.map, color: AppColors.ochreDeep, size: 16),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.missionNextRevealed,
                style: AppTextStyles.ui(12,
                    color: AppColors.ochreDeep, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(next.title,
                style: AppTextStyles.ui(13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(etaLabel,
            style: AppTextStyles.ui(12, color: AppColors.inkSoft)),
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
          color: paperTint(AppColors.verdigris),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.verdigris, width: 2),
        ),
        child: Row(children: [
          const Icon(Icons.flag_rounded, color: AppColors.verdigris, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  AppLocalizations.of(context).missionArrivedAt(
                      ContentL10n.place(widget.mission.destination)),
                  style: AppTextStyles.ui(15,
                      color: AppColors.verdigris, weight: FontWeight.bold)),
              Text(AppLocalizations.of(context).missionDeliverHint,
                  style: AppTextStyles.bodyMedium),
            ]),
          ),
        ]),
      ),

      const SizedBox(height: AppSpacing.md),

      SizedBox(
        width: double.infinity,
        child: GameButton(
          label: AppLocalizations.of(context).missionDeliver,
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
            widget.mission.nextUpcomingEventAt(GameClock.now()) != null;
        final l = AppLocalizations.of(context);
        final skipLabel =
            hasNextEvent ? l.missionSkipToEvent : l.missionSkipToEnd;

        // Paga la billetera común (la del principal).
        final wallet = ref.watch(homeProvider).valueOrNull?.messenger;
        final canAfford = (wallet?.denarios ?? 0) >= cost;
        final color = canAfford ? AppColors.egyptianBlue : AppColors.inkMuted;

        return GameCard(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          borderColor: canAfford
              ? AppColors.egyptianBlue.withValues(alpha: 0.5)
              : AppColors.paperLine,
          semanticLabel: l.missionSkipSemantics(skipLabel, cost),
          onTap: canAfford && !_loading
              ? _skip
              : () => showGameSnack(
                  context, l.missionSkipNoFunds,
                  isError: true),
          child: Row(children: [
            Icon(Icons.fast_forward_rounded, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: Text(
                    canAfford
                        ? skipLabel
                        : l.missionSkipNoFundsLabel,
                    style: AppTextStyles.ui(13, color: color))),
            const SizedBox(width: AppSpacing.sm),
            if (_loading)
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: AppColors.egyptianBlue, strokeWidth: 2))
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
          context, AppLocalizations.of(context).missionSkipped(result.cost));
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
    final cap = ref.watch(remoteFlagsProvider).travelAdsPerDay;
    final remaining = cap - _usedToday;
    if (cap <= 0) return const SizedBox.shrink();
    if (remaining <= 0) {
      return Text(AppLocalizations.of(context).missionAdsUsed(cap),
          style: AppTextStyles.bodySmall, textAlign: TextAlign.center);
    }

    return GameButton(
      label: _loading
          ? AppLocalizations.of(context).loading
          : AppLocalizations.of(context).missionWatchAd(remaining),
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
      final outcome = await ref.read(rewardedAdsServiceProvider).showRewarded(
            context: context,
            placement: 'travel_skip_30',
          );
      if (!mounted) return;
      if (outcome == AdOutcome.unavailable) {
        showGameSnack(context, AppLocalizations.of(context).adsUnavailable);
        return;
      }
      if (outcome != AdOutcome.rewarded) return;
      await ref.read(playerProgressProvider).recordTravelAd();
      await ref.read(homeProvider.notifier).advanceMissionMinutes(
            widget.mission.messengerId,
            30,
          );
      final used = await ref.read(playerProgressProvider).travelAdsUsedToday();
      if (mounted) {
        setState(() => _usedToday = used);
        showGameSnack(context, AppLocalizations.of(context).missionAdSkipped);
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
        ? (AppColors.verdigris, Icons.check_circle)
        : isPartial
            ? (AppColors.sienna, Icons.warning_rounded)
            : (AppColors.cinnabar, Icons.cancel);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: paperTint(borderColor),
        borderRadius: BorderRadius.circular(AppRadii.md - 2),
        border:
            Border.all(color: borderColor.withValues(alpha: 0.7), width: 1.5),
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
                  style: AppTextStyles.ui(13, weight: FontWeight.bold)),
              if (outcome?.chosenOptionText != null) ...[
                const SizedBox(height: 3),
                Text(
                    AppLocalizations.of(context)
                        .missionYouChose(outcome!.chosenOptionText!),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.inkSoft)),
              ],
              if (outcome?.narrative != null) ...[
                const SizedBox(height: AppSpacing.xs),
                // La prosa va en tinta; el color del resultado queda en el
                // ícono y el borde.
                Text(outcome!.narrative,
                    style: AppTextStyles.proseItalic(size: 14),
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
class _RouteVisual extends StatelessWidget {
  final Mission mission;
  const _RouteVisual({required this.mission});

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CityLabel(
                label: ContentL10n.place(mission.origin), isOrigin: true),
            _CityLabel(
                label: ContentL10n.place(mission.destination), isOrigin: false),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        RouteMapView(mission: mission),
      ]);
}

class _CityLabel extends StatelessWidget {
  final String label;
  final bool isOrigin;
  const _CityLabel({required this.label, required this.isOrigin});

  @override
  // Va sobre la escena: en un rótulo de papel, nunca suelto sobre el cielo.
  Widget build(BuildContext context) => Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(AppRadii.xs),
            border: Border.all(color: AppColors.paperLine),
          ),
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.ui(12,
                  color: isOrigin ? AppColors.inkSoft : AppColors.ochreDeep,
                  weight: FontWeight.bold)),
        ),
      );
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
            flightShuttleBuilder: eventHeroShuttle,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sienna, width: 2.5),
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
                    Row(children: [
                      GameChip(AppLocalizations.of(context).eventChip,
                          color: AppColors.sienna),
                      const Spacer(),
                      GameChip(AppLocalizations.of(context).missionPaused,
                          icon: Icons.pause_circle, color: AppColors.sienna),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    Text(event.title,
                        style: AppTextStyles.heading(20,
                            color: AppColors.ochreDeep)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(event.description, style: AppTextStyles.prose()),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          GameButton(
            label: AppLocalizations.of(context).slotDecide,
            icon: Icons.alt_route,
            onTap: () => context.push('/event?m=${mission.messengerId}'),
          ),
        ],
      ),
    );
  }
}
