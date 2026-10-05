import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/messenger_avatar.dart';
import '../../widgets/primeros_pasos.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/guild.dart';
import '../../../domain/entities/notifications.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../data/game_content.dart';
import '../../../infrastructure/progress/player_progress.dart';

part 'parts/slot.dart';
part 'parts/guild.dart';
part 'parts/hire.dart';
part 'parts/story.dart';
part 'parts/nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME — "lo que requiere tu atención ahora" (regla 9: ≤2 scrolls).
// Con varios mensajeros, una tira de retratos arriba elige cuál se ve; el
// resto avisa con un punto si tiene un evento esperando. Las listas largas
// (todas las rutas, el tablón completo) viven en paneles inferiores.
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    return homeAsync.when(
      loading: () => const _LoadingHome(),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: ErrorState(
            error: e, onRetry: () => ref.read(homeProvider.notifier).refresh()),
      ),
      data: (state) {
        if (state.messenger == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/character');
          });
          return const _LoadingHome();
        }
        return _HomeScaffold(state: state);
      },
    );
  }
}

class _LoadingHome extends StatelessWidget {
  const _LoadingHome();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: LoadingState(),
      );
}

// ─── Main Scaffold ────────────────────────────────────────────────────────────
class _HomeScaffold extends ConsumerStatefulWidget {
  final HomeState state;
  const _HomeScaffold({required this.state});

  @override
  ConsumerState<_HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends ConsumerState<_HomeScaffold> {
  static bool _payDialogShownThisSession = false;

  HomeState get state => widget.state;

  @override
  void initState() {
    super.initState();
    // Avisos tocados con la app abierta: el Home queda montado debajo de
    // cualquier pantalla, así que escucha acá.
    ref.listenManual(pendingNotificationRouteProvider, (_, route) {
      if (route != null) _openPendingRoute();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Mirar el juego reinicia el recordatorio de mensajero ocioso.
      ref.read(homeProvider.notifier).syncAllNotifications();
      if (_openPendingRoute()) return;
      await _maybeShowDailyPay();
      await _maybeShowHomeSpotlight();
    });
  }

  /// Abre la pantalla del aviso que tocó el jugador, si hay uno pendiente.
  bool _openPendingRoute() {
    final pending = ref.read(pendingNotificationRouteProvider.notifier);
    final route = pending.state;
    if (route == null || !mounted) return false;
    pending.state = null;
    if (route == '/home') return false;
    context.push(route);
    return true;
  }

  Future<void> _maybeShowHomeSpotlight() async {
    if (!mounted || !state.tutorialDone) return;
    final progress = ref.read(playerProgressProvider);
    final seen = await progress.homeTooltipSeen;
    if (!mounted) return;
    await maybeShowSpotlight(
      context: context,
      alreadySeen: seen,
      onSeen: () => progress.markHomeTooltipSeen(),
      title: 'Tu puesto de correo',
      body:
          'Acá ves a tus mensajeros, el progreso de cada misión y el tablón del gremio. '
          'Las rutas cortas caben en una tarde; las largas siguen mientras dormís.',
    );
  }

  Future<void> _maybeShowDailyPay() async {
    if (_payDialogShownThisSession || !mounted) return;
    // Recién tiene sentido cuando ya pasó el onboarding inicial.
    if (state.messenger == null) return;
    final guild = await ref.read(guildProvider.future);
    if (!mounted || !guild.canClaimDailyPay) return;
    _payDialogShownThisSession = true;
    await showGameDialog(
      context,
      barrierDismissible: false,
      builder: (_) => const _DailyPayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgAsset = isDay
        ? 'assets/images/bg_home_day.jpg'
        : 'assets/images/bg_home_night.jpg';

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(fit: StackFit.expand, children: [
        Image.asset(bgAsset,
            fit: BoxFit.cover,
            cacheWidth: 1080,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: AppColors.bgDeep)),
        const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.homeOverlay)),
        Column(children: [
          SafeArea(
            bottom: false,
            child: _TopBar(state: state),
          ),
          Expanded(child: _Body(state: state)),
          _BottomNav(state: state),
        ]),
      ]),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final HomeState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final m = state.messenger;
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
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('THE MESSENGER',
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: AppTextStyles.fredoka(17,
                    color: AppColors.gold,
                    weight: FontWeight.bold,
                    letterSpacing: 2)),
            Text('Roma · 50 a.C.',
                style:
                    AppTextStyles.fredoka(12, color: AppColors.textSecondary)),
          ]),
        ),
        if (m != null) ...[
          CurrencyChip(type: CurrencyType.denarios, value: m.denarios),
          const SizedBox(width: 6),
          CurrencyChip(type: CurrencyType.aureos, value: m.aureos),
          const SizedBox(width: 6),
          CurrencyChip(type: CurrencyType.seals, value: m.seals),
        ],
      ]),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _Body extends ConsumerStatefulWidget {
  final HomeState state;
  const _Body({required this.state});

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  String? _selectedId;

  HomeState get state => widget.state;

  /// Mensajero visible: el elegido, o el primero que tenga un evento
  /// esperando (lo urgente primero), o el principal.
  MessengerSlot get _selected {
    final chosen =
        state.slots.where((s) => s.messenger.id == _selectedId).firstOrNull;
    if (chosen != null) return chosen;
    return state.slots.where((s) => s.pendingEvent != null).firstOrNull ??
        state.slots.first;
  }

  @override
  Widget build(BuildContext context) {
    final slot = _selected;
    var i = 0;
    Duration next() => AppMotion.stagger * (i++);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
      children: [
        // ── Lo que pasó mientras no estabas
        if (state.autoResolved.isNotEmpty) ...[
          _AutoResolvedNotice(events: state.autoResolved)
              .animate(delay: next())
              .fadeIn(duration: AppMotion.of(context, AppMotion.base))
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ── Primeros pasos (post-tutorial)
        if (state.tutorialDone) const PrimerosPasosCard(),

        // ── Tira de mensajeros (solo si hay más de uno)
        if (state.slots.length > 1) ...[
          _Roster(
            slots: state.slots,
            selectedId: slot.messenger.id,
            onSelect: (id) => setState(() => _selectedId = id),
          ).animate(delay: next()).fadeIn(
              duration: AppMotion.of(context, AppMotion.base)),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── El mensajero elegido: al cambiar, cruza en vez de saltar.
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.base),
          switchInCurve: AppMotion.enter,
          switchOutCurve: AppMotion.exit,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            children: [...previous, if (current != null) current],
          ),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.04, 0), end: Offset.zero)
                  .animate(anim),
              child: child,
            ),
          ),
          child: _MessengerSlotCard(
            key: ValueKey('slot-${slot.messenger.id}'),
            slot: slot,
          ),
        ).animate(delay: next()).fadeIn(
            duration: AppMotion.of(context, AppMotion.base)),

        const SizedBox(height: AppSpacing.lg),

        // ── Capítulo de historia disponible
        if (state.nextStoryMission != null) ...[
          _StoryChapterCard(config: state.nextStoryMission!)
              .animate(delay: next())
              .fadeIn(duration: AppMotion.of(context, AppMotion.base))
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ── Tablón del gremio (resumen; el detalle abre un panel)
        if (state.tutorialDone) ...[
          const _GuildSummaryCard()
              .animate(delay: next())
              .fadeIn(duration: AppMotion.of(context, AppMotion.base))
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ── Contratar otro mensajero
        if (state.canUnlockNextSlot)
          _UnlockSlotButton(state: state)
              .animate(delay: next())
              .fadeIn(duration: AppMotion.of(context, AppMotion.base))
              .slideY(begin: 0.06, end: 0),
      ],
    );
  }
}

// ─── Tira de mensajeros ───────────────────────────────────────────────────────
class _Roster extends StatelessWidget {
  final List<MessengerSlot> slots;
  final String selectedId;
  final ValueChanged<String> onSelect;
  const _Roster({
    required this.slots,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final s in slots)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _RosterChip(
              slot: s,
              selected: s.messenger.id == selectedId,
              onTap: () => onSelect(s.messenger.id),
            ),
          ),
        ),
    ]);
  }
}

class _RosterChip extends StatelessWidget {
  final MessengerSlot slot;
  final bool selected;
  final VoidCallback onTap;
  const _RosterChip({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final m = slot.messenger;
    final hasEvent = slot.pendingEvent != null;
    final mission = slot.activeMission;
    final status = hasEvent
        ? 'Evento'
        : mission != null
            ? 'En camino'
            : m.status == MessengerStatus.injured
                ? 'Herido'
                : 'Libre';

    return Semantics(
      button: true,
      selected: selected,
      label: '${m.name}, $status',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          AppFeedback.tap();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.base),
          curve: AppMotion.enter,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.bgCard : AppColors.bgCard2,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: hasEvent
                  ? AppColors.red
                  : selected
                      ? AppColors.gold
                      : AppColors.bgLine,
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(clipBehavior: Clip.none, children: [
              MessengerAvatar.from(m, size: 34, highlighted: selected),
              if (hasEvent)
                Positioned(
                  top: -3,
                  right: -6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outline, width: 2),
                    ),
                  )
                      .animate(
                          onPlay: (c) => AppMotion.reduced(context)
                              ? null
                              : c.repeat(reverse: true))
                      .scaleXY(begin: 0.85, end: 1.15, duration: 600.ms),
                ),
            ]),
            const SizedBox(height: AppSpacing.xs),
            Text(m.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.fredoka(12,
                    color: selected ? AppColors.gold : AppColors.textSecondary,
                    weight: FontWeight.bold)),
            if (mission != null && !hasEvent)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
                child: LiveProgressBar(
                    height: 4, progressAt: mission.progressAt),
              )
            else
              Text(status,
                  style: AppTextStyles.fredoka(12,
                      color: hasEvent ? AppColors.textPrimary : AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }
}

// ─── Lo que pasó mientras no estabas ─────────────────────────────────────────
// Si el jugador no responde un evento en 60 minutos, el mensajero actúa por
// instinto: opción más segura, resultado parcial. Nunca destruye la misión,
// pero tiene que enterarse — si no, la decisión desaparece sin explicación.
class _AutoResolvedNotice extends StatelessWidget {
  final List<AutoResolvedEvent> events;
  const _AutoResolvedNotice({required this.events});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.amber.withValues(alpha: 0.6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.history_toggle_off,
              color: AppColors.amber, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text('PASÓ MIENTRAS NO ESTABAS',
              style: AppTextStyles.fredoka(12,
                  color: AppColors.amber,
                  weight: FontWeight.bold,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        for (final e in events)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '${e.messengerName} no podía esperar en «${e.eventTitle}»: '
              'actuó por instinto y ${e.chosenOptionText.toLowerCase()}.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text('Responder a tiempo siempre sale mejor.',
            style: AppTextStyles.bodySmall),
      ]),
    );
  }
}

// ─── Utilidades compartidas por las partes del Home ──────────────────────────
String _durationLabel(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.fredoka(13,
          color: AppColors.textSecondary,
          weight: FontWeight.bold,
          letterSpacing: 1.5));
}
