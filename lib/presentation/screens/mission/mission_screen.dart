import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
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
    final progress = ref.watch(missionProgressProvider);

    return homeAsync.when(
      loading: () => const _Loading(),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Center(child: Text('$e')),
      ),
      data: (state) {
        final mission = state.slotFor(widget.messengerId)?.activeMission;
        // Si no hay misión activa, el usuario ya navegó a mission-result o home.
        // NO auto-navegar desde acá — eso causa el flash.
        if (mission == null) return const _Loading();

        return GradientScaffold(
          useEventBg: true,
          body: Column(children: [
            SafeArea(
              bottom: false,
              child: _TopBar(mission: mission),
            ),
            Expanded(
              child: progress.blockedByEvent != null
              // ── Panel de evento: timer congelado
                  ? _EventPanel(
                mission: mission,
                event: progress.blockedByEvent!,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05)
              // ── Vista de viaje normal
                  : _TravelView(
                mission: mission,
                progress: progress.progress,
                readyToDeliver: progress.readyToDeliver,
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
    body: Center(
      child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 3),
    ),
  );
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final Mission mission;
  const _TopBar({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xCC060E1A),
        border: Border(
          bottom: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
        ),
      ),
      child: Row(children: [
        // Botón atrás
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.bgLine, width: 1.5),
            ),
            child: const Center(
                child: Icon(Icons.arrow_back_ios_new,
                    color: AppColors.gold, size: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${mission.origin} → ${mission.destination}',
              style: AppTextStyles.fredoka(15,
                  color: AppColors.gold, weight: FontWeight.bold),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            Text(
              mission.isTutorial ? 'Prueba de Varus' : 'Misión activa',
              style: AppTextStyles.fredoka(10,
                  color: AppColors.textSecondary),
            ),
          ]),
        ),
        DeadlineChip(mission: mission),
      ]),
    );
  }
}

// ─── Vista de viaje ───────────────────────────────────────────────────────────
class _TravelView extends ConsumerWidget {
  final Mission mission;
  final double progress;
  final bool readyToDeliver;
  const _TravelView({
    required this.mission,
    required this.progress,
    required this.readyToDeliver,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = (progress * 100).round();
    final resolved = mission.events
        .where((e) => e.status == EventStatus.resolved)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        // Ruta visual: origen → mensajero → destino
        _RouteVisual(progress: progress, mission: mission),

        const SizedBox(height: 32),

        // Barra de progreso grande
        _ProgressBar(progress: progress),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(readyToDeliver ? '¡Llegaste!' : '$pct% del camino',
                style: AppTextStyles.fredoka(13,
                    color: readyToDeliver ? AppColors.gold : AppColors.textSecondary,
                    weight: readyToDeliver ? FontWeight.bold : FontWeight.normal)),
            if (!readyToDeliver)
              Text(_timeLeft(mission),
                  style: AppTextStyles.fredoka(13,
                      color: AppColors.gold, weight: FontWeight.bold)),
          ],
        ),

        const SizedBox(height: 20),

        // Info del paquete
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xBB0D1830),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bgLine, width: 1.5),
          ),
          child: Row(children: [
            const Icon(Icons.inventory_2,
                color: AppColors.textSecondary, size: 15),
            const SizedBox(width: 8),
            Expanded(
                child: Text(mission.packageDescription,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            PackageBadge(state: mission.packageState),
          ]),
        ),

        // ── Revelado por "Mapa del explorador"
        if (mission.revealEvents) ...[
          const SizedBox(height: 12),
          _RevealedNextEvent(mission: mission),
        ],

        const SizedBox(height: 12),

        // ── Skip al próximo evento
        _SkipButton(mission: mission),

        // ── Rewarded ad: −30 min de viaje (cap 4/día)
        const SizedBox(height: 10),
        _TravelAdButton(mission: mission),

        // ── Botón ENTREGAR — solo cuando llegó al destino
        if (readyToDeliver) ...[
          const SizedBox(height: 16),
          _DeliverButton(mission: mission)
              .animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),
        ],

        // ── Historial de eventos resueltos
        if (resolved.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('EVENTOS RESUELTOS',
              style: AppTextStyles.fredoka(11,
                  color: AppColors.textMuted,
                  weight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 10),
          ...resolved.asMap().entries.map((entry) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ResolvedEventTile(event: entry.value)
                    .animate(delay: Duration(milliseconds: entry.key * 60))
                    .fadeIn().slideY(begin: 0.04),
              )),
        ],
      ],
    );
  }

  String _timeLeft(Mission mission) {
    final left = mission.deadlineAt.difference(DateTime.now());
    if (left.isNegative) return '¡Llegaste!';
    if (left.inSeconds < 60) return '${left.inSeconds}s';
    if (left.inMinutes < 60) return '${left.inMinutes}m ${left.inSeconds % 60}s';
    return '${left.inHours}h ${left.inMinutes % 60}m';
  }
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Row(children: [
        const Icon(Icons.map, color: AppColors.gold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PRÓXIMO EVENTO REVELADO',
                    style: AppTextStyles.fredoka(9,
                        color: AppColors.gold, letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(next.title,
                    style: AppTextStyles.fredoka(13, color: AppColors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ]),
        ),
        const SizedBox(width: 8),
        Text(etaLabel,
            style: AppTextStyles.fredoka(11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ─── Tile de evento resuelto ──────────────────────────────────────────────────
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
      // Sello / comprobante visual
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.9), width: 2),
        ),
        child: Row(children: [
          const Icon(Icons.verified, color: AppColors.green, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mensaje entregado',
                  style: AppTextStyles.fredoka(14,
                      color: AppColors.green, weight: FontWeight.bold)),
              Text('${widget.mission.origin} → ${widget.mission.destination}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.green.withValues(alpha: 1.0))),
            ]),
          ),
        ]),
      ),

      const SizedBox(height: 12),

      // Botón principal de entrega
      SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: _loading ? null : _deliver,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: _loading ? const LinearGradient(
                  colors: [Color(0xFF334455), Color(0xFF223344)])
                  : AppGradients.gold,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline, width: 3),
              boxShadow: [
                BoxShadow(
                    color: _loading ? Colors.black45 : AppColors.goldShadow,
                    offset: const Offset(0, 5),
                    blurRadius: 0),
              ],
            ),
            child: Center(
              child: _loading
                  ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.assignment_turned_in,
                    color: AppColors.outline, size: 20),
                const SizedBox(width: 8),
                Text('ENTREGAR MENSAJE',
                    style: AppTextStyles.fredoka(17,
                        color: AppColors.outline,
                        weight: FontWeight.bold)),
              ]),
            ),
          ),
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

      context.go('/mission-result', extra: {
        'mission': widget.mission,
        'completion': completion,
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
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
    final cost = SkipToNextEventUseCase.costFor(widget.mission);
    if (cost == 0) return const SizedBox.shrink();

    final hasNextEvent =
        widget.mission.nextUpcomingEventAt(DateTime.now()) != null;
    final skipLabel = hasNextEvent ? 'Adelantar al próximo evento' : 'Adelantar al final de la misión';

    // Paga la billetera común (la del principal).
    final wallet = ref.watch(homeProvider).valueOrNull?.messenger;
    final canAfford = (wallet?.denarios ?? 0) >= cost;

    return GestureDetector(
      onTap: canAfford && !_loading ? _skip : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        decoration: BoxDecoration(
          color: canAfford
              ? AppColors.sky.withValues(alpha: 0.08)
              : const Color(0xBB0D1830),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: canAfford
                  ? AppColors.sky.withValues(alpha: 0.5)
                  : AppColors.bgLine,
              width: 1.5),
        ),
        child: Row(children: [
          Icon(Icons.fast_forward_rounded,
              color: canAfford ? AppColors.sky : AppColors.textMuted,
              size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
                  canAfford ? skipLabel : 'Sin denarios suficientes para adelantar',
                  style: AppTextStyles.fredoka(13,
                      color: canAfford ? AppColors.sky : AppColors.textMuted))),
          const SizedBox(width: 8),
          if (_loading)
            const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    color: AppColors.sky, strokeWidth: 2))
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.toll,
                  size: 13,
                  color: canAfford ? AppColors.sky : AppColors.textMuted),
              const SizedBox(width: 4),
              Text('$cost',
                  style: AppTextStyles.fredoka(13,
                      color: canAfford ? AppColors.sky : AppColors.textMuted,
                      weight: FontWeight.bold)),
            ]),
        ]),
      ),
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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Adelantaste el tiempo (-${result.cost} denarios)',
            style: AppTextStyles.fredoka(13, color: Colors.white)),
        backgroundColor: AppColors.bgCard,
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.redDark));
      }
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
    final remaining =
        RewardedAdsService.travelSkipCapPerDay - _usedToday;
    if (remaining <= 0) {
      return Text('Ya usaste los 4 adelantos de hoy',
          style: AppTextStyles.bodyMedium
              .copyWith(fontSize: 11, color: AppColors.textMuted),
          textAlign: TextAlign.center);
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _watch,
        icon: const Icon(Icons.play_circle_outline, size: 18),
        label: Text(
          _loading
              ? 'Cargando…'
              : 'Ver anuncio · −30 min ($remaining hoy)',
          style: AppTextStyles.fredoka(13, color: AppColors.sky),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sky,
          side: BorderSide(color: AppColors.sky.withValues(alpha: 0.5), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.bgCard,
          content: Text('Adelantaste 30 minutos de camino',
              style: AppTextStyles.fredoka(13, color: AppColors.sky)),
        ));
      }
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: borderColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title,
                  style: AppTextStyles.fredoka(13,
                      color: AppColors.textPrimary,
                      weight: FontWeight.bold)),
              if (outcome?.chosenOptionText != null) ...[
                const SizedBox(height: 3),
                Text('Decidiste: ${outcome!.chosenOptionText}',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
              if (outcome?.narrative != null) ...[
                const SizedBox(height: 4),
                Text(outcome!.narrative,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: borderColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 11),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}
// ─── Route visual: puntos de origen y destino con ícono del mensajero
class _RouteVisual extends StatelessWidget {
  final double progress;
  final Mission mission;
  const _RouteVisual({required this.progress, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CityDot(label: mission.origin, isOrigin: true),
          _CityDot(label: mission.destination, isOrigin: false),
        ],
      ),
      const SizedBox(height: 8),
      LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        // El mensajero se mueve de izquierda a derecha
        final messengerX = (w * progress).clamp(18.0, w - 18.0);
        return SizedBox(
          height: 44,  // más alto para que el círculo no se corte
          child: Stack(clipBehavior: Clip.none, children: [
            // Línea del camino
            Positioned(
              top: 21, left: 0, right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold,
                      AppColors.gold.withValues(alpha: 0.3),
                    ],
                    stops: [progress, progress],
                  ),
                ),
              ),
            ),
            // Ícono del mensajero
            Positioned(
              left: messengerX - 18,
              top: 3,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outline, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.goldShadow,
                        offset: Offset(0, 3), blurRadius: 0),
                  ],
                ),
                child: const Center(
                    child: Icon(Icons.directions_run,
                        color: AppColors.outline, size: 18)),
              ),
            ),
          ]),
        );
      }),
    ]);
  }
}

class _CityDot extends StatelessWidget {
  final String label;
  final bool isOrigin;
  const _CityDot({required this.label, required this.isOrigin});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(
          color: isOrigin
              ? AppColors.textMuted
              : AppColors.gold,
          shape: BoxShape.circle,
          border: Border.all(
              color: isOrigin ? AppColors.bgLine : AppColors.goldDark,
              width: 2),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: AppTextStyles.fredoka(10,
              color: isOrigin ? AppColors.textMuted : AppColors.gold,
              weight: FontWeight.bold)),
    ],
  );
}

// ─── Barra de progreso grande con efecto 3D
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.outline,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgLine, width: 2),
        // Sombra inferior → efecto caja 3D
        boxShadow: const [
          BoxShadow(
              color: Color(0xFF000000),
              offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(children: [
          // Fondo oscuro
          Container(color: const Color(0xFF0A1020)),
          // Barra dorada animada
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE066),
                    Color(0xFFCC8800),
                  ],
                ),
              ),
            ),
          ),
          // Brillo interior (línea top)
          Positioned(
            top: 3, left: 0, right: 0,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 4,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Panel de evento bloqueante ───────────────────────────────────────────────
class _EventPanel extends StatelessWidget {
  final Mission mission;
  final MissionEvent event;
  const _EventPanel({required this.mission, required this.event});

  @override
  Widget build(BuildContext context) {
    // Las opciones se deciden siempre en EventScreen: un solo flujo con
    // pronóstico, confirmación y explicación del resultado.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del evento
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xDD1A0800),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.amber, width: 2.5),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x55000000),
                    offset: Offset(0, 4), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          color: AppColors.amber, width: 1.5),
                    ),
                    child: Text('EVENTO',
                        style: AppTextStyles.fredoka(11,
                            color: AppColors.amber,
                            weight: FontWeight.bold,
                            letterSpacing: 0.5)),
                  ),
                  const Spacer(),
                  // Ícono de pausa — el progreso está congelado
                  Row(children: [
                    const Icon(Icons.pause_circle,
                        color: AppColors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('Progreso pausado',
                        style: AppTextStyles.fredoka(10,
                            color: AppColors.amber)),
                  ]),
                ]),
                const SizedBox(height: 12),
                Text(event.title,
                    style: AppTextStyles.fredoka(20,
                        color: AppColors.gold, weight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(event.description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.85),
                      height: 1.5,
                    )),
              ],
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
