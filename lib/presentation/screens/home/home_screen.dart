import 'package:flutter/material.dart';
import '../../../data/localized_content.dart';
import '../../../domain/entities/content.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/sky.dart';
import '../../widgets/widgets.dart';
import '../../widgets/messenger_avatar.dart';
import '../../widgets/primeros_pasos.dart';
import '../../widgets/route_map.dart';
import '../../widgets/art_image.dart';
import '../../widgets/brand.dart';
import '../../widgets/event_scene.dart';
import '../../widgets/living_sky.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/guild.dart';
import '../../../domain/entities/notifications.dart';
import '../../../domain/entities/progression.dart';
import '../../../domain/entities/weekly.dart';
import '../../../domain/entities/world.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../infrastructure/progress/player_progress.dart';
import '../../../domain/entities/game_clock.dart';
import '../../../domain/entities/content_l10n.dart';
import '../../../l10n/app_localizations.dart';

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
        backgroundColor: AppColors.paperDeep,
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
        backgroundColor: AppColors.paperDeep,
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
      title: AppLocalizations.of(context).homeSpotlightTitle,
      body: AppLocalizations.of(context).homeSpotlightBody,
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

  /// Alto de la ventana al cielo, debajo de la barra de estado.
  static const _skyBand = 128.0;

  @override
  Widget build(BuildContext context) {
    // Arriba, una ventana al cielo de la hora real; abajo, la página de
    // papel donde vive todo lo que se lee.
    final sky = ref.watch(skyPaletteProvider);
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: sky.statusBar,
      child: Scaffold(
        backgroundColor: AppColors.paperDeep,
        body: Column(children: [
          SizedBox(
            height: top + _skyBand,
            child: Stack(fit: StackFit.expand, children: [
              LivingSkyBackground(
                  horizon: 0.76,
                  topInset: top,
                  celestialSpan: (0.36, 0.46)),
              Padding(
                padding: EdgeInsets.only(top: top),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _TopBar(state: state, sky: sky),
                ),
              ),
            ]),
          ),
          Expanded(
            // Container (no DecoratedBox): así el borde corre al contenido.
            child: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
              ),
              child: Stack(fit: StackFit.expand, children: [
                const PaperPage(),
                Column(children: [
                  Expanded(child: _Body(state: state)),
                  _BottomNav(state: state),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
/// Sobre el cielo: el nombre en grande (tinta o cal según la hora) y las
/// monedas en chips opacos. Nada de texto chico acá (regla de legibilidad).
class _TopBar extends StatelessWidget {
  final HomeState state;
  final SkyPalette sky;
  const _TopBar({required this.state, required this.sky});

  @override
  Widget build(BuildContext context) {
    final m = state.messenger;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: Row(children: [
        Expanded(
          // Con muchas monedas, el nombre se achica en vez de cortarse.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(kGameName.toUpperCase(),
                maxLines: 1,
                softWrap: false,
                style: AppTextStyles.brandWordmark(22, sky.titleColor)
                    .copyWith(shadows: sky.titleHalo)),
          ),
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
          _StoryChapterCard(
                  config: state.nextStoryMission!,
                  arcTitle: state.storyArcTitle,
                  isReplay: state.storyIsReplay)
              .animate(delay: next())
              .fadeIn(duration: AppMotion.of(context, AppMotion.base))
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: AppSpacing.lg),
        ] else if (state.lockedStory != null) ...[
          // La historia sigue, pero pide más rango: que se sepa qué falta.
          _LockedStoryCard(step: state.lockedStory!)
              .animate(delay: next())
              .fadeIn(duration: AppMotion.of(context, AppMotion.base)),
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
    final l = AppLocalizations.of(context);
    final status = hasEvent
        ? l.homeRosterEvent
        : mission != null
            ? l.homeRosterOnRoad
            : m.status == MessengerStatus.injured
                ? l.homeRosterInjured
                : l.homeRosterFree;

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
            color: selected ? AppColors.paper : AppColors.paperDeep,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: hasEvent
                  ? AppColors.cinnabar
                  : selected
                      ? AppColors.ochreDeep
                      : AppColors.paperLine,
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
                      color: AppColors.cinnabar,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 2),
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
                style: AppTextStyles.ui(12,
                    color: selected ? AppColors.ochreDeep : AppColors.inkSoft,
                    weight: FontWeight.bold)),
            if (mission != null && !hasEvent)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
                child: LiveProgressBar(
                    height: 4, progressAt: mission.progressAt),
              )
            else
              Text(status,
                  style: AppTextStyles.ui(12,
                      color: hasEvent ? AppColors.ink : AppColors.inkMuted)),
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
      borderColor: AppColors.sienna.withValues(alpha: 0.6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.history_toggle_off,
              color: AppColors.sienna, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(AppLocalizations.of(context).homeAwayHeader,
              style: AppTextStyles.ui(12,
                  color: AppColors.sienna,
                  weight: FontWeight.bold,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        for (final e in events)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              AppLocalizations.of(context).homeAwayLine(e.messengerName,
                  e.eventTitle, e.chosenOptionText.toLowerCase()),
              style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(AppLocalizations.of(context).homeAwayHint,
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
      style: AppTextStyles.ui(13,
          color: AppColors.inkSoft,
          weight: FontWeight.bold,
          letterSpacing: 1.5));
}
