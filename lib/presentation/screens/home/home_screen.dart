import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        body: Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium)),
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
        body: Center(
          child:
              CircularProgressIndicator(color: AppColors.gold, strokeWidth: 3),
        ),
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
    await showDialog(
      context: context,
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
            errorBuilder: (_, __, ___) => Container(color: AppColors.bgDeep)),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xDD060E1A),
                Color(0x22060E1A),
                Color(0xF0060E1A),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xCC060E1A),
        border: Border(
          bottom:
              BorderSide(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
        ),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('THE MESSENGER',
              style: AppTextStyles.fredoka(17,
                  color: AppColors.gold,
                  weight: FontWeight.bold,
                  letterSpacing: 2)),
          Text('Imperio Romano · 50 a.C.',
              style: AppTextStyles.fredoka(9, color: AppColors.textSecondary)),
        ]),
        const Spacer(),
        if (m != null) ...[
          CurrencyChip(type: CurrencyType.denarios, value: m.denarios),
          const SizedBox(width: 8),
          CurrencyChip(type: CurrencyType.aureos, value: m.aureos),
          const SizedBox(width: 8),
          CurrencyChip(type: CurrencyType.seals, value: m.seals),
        ],
      ]),
    );
  }
}


// ─── Body ─────────────────────────────────────────────────────────────────────
class _Body extends ConsumerWidget {
  final HomeState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // ── Lo que pasó mientras no estabas
        if (state.autoResolved.isNotEmpty) ...[
          _AutoResolvedNotice(events: state.autoResolved)
              .animate()
              .fadeIn()
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: 16),
        ],

        // ── Primeros pasos (post-tutorial)
        if (state.tutorialDone) const PrimerosPasosCard(),

        // ── Un slot por mensajero
        ...state.slots.asMap().entries.map((entry) {
          final i = entry.key;
          final slot = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _MessengerSlotCard(slot: slot)
                .animate(delay: Duration(milliseconds: 60 + i * 80))
                .fadeIn()
                .slideY(begin: 0.06, end: 0),
          );
        }),

        // ── Capítulo de historia disponible
        if (state.nextStoryMission != null) ...[
          _StoryChapterCard(config: state.nextStoryMission!)
              .animate(delay: 120.ms)
              .fadeIn()
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: 16),
        ],

        // ── Tablón del gremio (contratos del día)
        if (state.tutorialDone)
          _GuildBoard()
              .animate(delay: 150.ms)
              .fadeIn()
              .slideY(begin: 0.06, end: 0),

        // ── Botón de unlock si aplica
        if (state.canUnlockNextSlot) ...[
          const SizedBox(height: 16),
          _UnlockSlotButton(state: state)
              .animate(delay: 200.ms)
              .fadeIn()
              .slideY(begin: 0.06, end: 0),
        ],
      ],
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.55), width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.history_toggle_off,
              color: AppColors.amber, size: 18),
          const SizedBox(width: 8),
          Text('PASÓ MIENTRAS NO ESTABAS',
              style: AppTextStyles.fredoka(11,
                  color: AppColors.amber,
                  weight: FontWeight.bold,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: 8),
        for (final e in events)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${e.messengerName} no podía esperar en «${e.eventTitle}»: '
              'actuó por instinto y ${e.chosenOptionText.toLowerCase()}.',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontSize: 12, height: 1.4),
            ),
          ),
        const SizedBox(height: 4),
        Text('Responder a tiempo siempre sale mejor.',
            style: AppTextStyles.bodySmall),
      ]),
    );
  }
}

// ─── Card de un mensajero + su misión/tutorial/rutas ─────────────────────────
class _MessengerSlotCard extends ConsumerWidget {
  final MessengerSlot slot;
  const _MessengerSlotCard({required this.slot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = slot.messenger;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Cabecera del mensajero
      _MessengerCard(messenger: m),
      const SizedBox(height: 12),

      // Evento urgente
      if (slot.pendingEvent != null && slot.activeMission != null)
        _UrgentEventButton(
          event: slot.pendingEvent!,
          mission: slot.activeMission!,
        ).animate().shake(hz: 1.5, delay: 400.ms, duration: 600.ms).fadeIn(),

      // Misión activa (sin evento)
      if (slot.activeMission != null && slot.pendingEvent == null)
        _ActiveMissionBanner(mission: slot.activeMission!)
            .animate(delay: 60.ms)
            .fadeIn()
            .slideY(begin: 0.04, end: 0),

      // Tutorial pendiente
      if (slot.activeMission == null && slot.nextTutorial != null)
        _TutorialCard(
          tutorial: slot.nextTutorial!,
          messenger: m,
        ).animate(delay: 60.ms).fadeIn().slideY(begin: 0.04, end: 0),

      // Rutas disponibles
      if (slot.activeMission == null &&
          slot.nextTutorial == null &&
          slot.availableRoutes.isNotEmpty) ...[
        const _SectionLabel('RUTAS DISPONIBLES'),
        const SizedBox(height: 8),
        ...slot.availableRoutes.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RouteCard(route: e.value, messenger: m)
                  .animate(delay: Duration(milliseconds: 60 + e.key * 60))
                  .fadeIn()
                  .slideY(begin: 0.04, end: 0),
            )),
      ],

      // Sin nada
      if (slot.activeMission == null &&
          slot.nextTutorial == null &&
          slot.availableRoutes.isEmpty)
        _EmptyState().animate(delay: 60.ms).fadeIn(),
    ]);
  }
}

// ─── Messenger Card ───────────────────────────────────────────────────────────
class _MessengerCard extends StatelessWidget {
  final Messenger messenger;
  const _MessengerCard({required this.messenger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xDD0D1830),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x55000000), offset: Offset(0, 4), blurRadius: 10),
        ],
      ),
      child: Column(children: [
        Row(children: [
          MessengerAvatar.from(messenger, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(messenger.name, style: AppTextStyles.titleLarge),
              const SizedBox(height: 3),
              Row(children: [
                _Tag('${messenger.rankTitle} · Rank ${messenger.rank}',
                    AppColors.gold),
                const SizedBox(width: 6),
                _Tag(messenger.status.label, AppColors.sky),
              ]),
              if (!messenger.tutorialComplete) ...[
                const SizedBox(height: 4),
                Text(
                  'Prueba ${messenger.tutorialMissionIndex + 1}/${tutorialMissions.length} de Varus',
                  style: AppTextStyles.fredoka(10, color: AppColors.amber),
                ),
              ],
            ]),
          ),
          // Botón 3D → stats del mensajero
          _Button3D(
            icon: Icons.person,
            color: AppColors.sky,
            onTap: () => context.push('/profile'),
          ),
        ]),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Text(text,
            style: AppTextStyles.fredoka(10,
                color: color, weight: FontWeight.bold)),
      );
}

// ─── Botón 3D pequeño ─────────────────────────────────────────────────────────
// Simula profundidad con un bloque inferior desplazado
class _Button3D extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Button3D(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const size = 38.0;
    const depth = 4.0;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size + depth,
        child: Stack(children: [
          // Fondo (sombra del botón)
          Positioned(
            bottom: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: _darken(color),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline, width: 2),
              ),
            ),
          ),
          // Cara del botón (desplazada hacia arriba)
          Positioned(
            top: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline, width: 2),
              ),
              child:
                  Center(child: Icon(icon, size: 20, color: AppColors.outline)),
            ),
          ),
        ]),
      ),
    );
  }

  Color _darken(Color c) => Color.from(
      alpha: c.a, red: c.r * 0.5, green: c.g * 0.5, blue: c.b * 0.5);
}

// ─── Evento urgente ───────────────────────────────────────────────────────────
class _UrgentEventButton extends StatelessWidget {
  final MissionEvent event;
  final Mission mission;
  const _UrgentEventButton({required this.event, required this.mission});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/event?m=${mission.messengerId}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppGradients.red,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline, width: 3),
          boxShadow: const [
            BoxShadow(
                color: AppColors.redShadow,
                offset: Offset(0, 5),
                blurRadius: 0),
          ],
        ),
        child: Row(children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('¡EVENTO PENDIENTE!',
                  style: AppTextStyles.fredoka(13,
                      color: Colors.white,
                      weight: FontWeight.bold,
                      letterSpacing: 1)),
              Text(event.title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline, width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black45, offset: Offset(0, 3), blurRadius: 0)
              ],
            ),
            child: Text('DECIDIR',
                style: AppTextStyles.fredoka(12,
                    color: AppColors.redDark, weight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }
}

// ─── Misión activa ────────────────────────────────────────────────────────────
class _ActiveMissionBanner extends StatefulWidget {
  final Mission mission;
  const _ActiveMissionBanner({required this.mission});

  @override
  State<_ActiveMissionBanner> createState() => _ActiveMissionBannerState();
}

class _ActiveMissionBannerState extends State<_ActiveMissionBanner> {
  late Timer _timer;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = _calcProgress();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _progress = _calcProgress());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  double _calcProgress() => widget.mission.progressAt(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    final isTut = mission.isTutorial;
    final accentColor = isTut ? AppColors.amber : AppColors.gold;
    final pct = (_progress * 100).round();
    final hasEvent = mission.blockingEventAt(DateTime.now()) != null;

    return GestureDetector(
      onTap: () => context.push('/mission?m=${mission.messengerId}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xDD0D1830),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasEvent
                  ? AppColors.amber.withValues(alpha: 0.8)
                  : accentColor.withValues(alpha: 0.5),
              width: hasEvent ? 2.5 : 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x44000000), offset: Offset(0, 4), blurRadius: 8),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(
                hasEvent
                    ? Icons.pause_circle
                    : (isTut ? Icons.assignment : Icons.map),
                color: hasEvent ? AppColors.amber : accentColor,
                size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${mission.origin} → ${mission.destination}',
                style: AppTextStyles.fredoka(15,
                    color: hasEvent ? AppColors.amber : accentColor,
                    weight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DeadlineChip(mission: mission),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(children: [
              Container(height: 10, color: AppColors.outline),
              FractionallySizedBox(
                widthFactor: _progress,
                child: Container(
                    height: 10,
                    color: hasEvent ? AppColors.amber : accentColor),
              ),
            ]),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(hasEvent ? 'Evento pendiente' : '$pct% completado',
                style: AppTextStyles.bodySmall
                    .copyWith(color: hasEvent ? AppColors.amber : null)),
            PackageBadge(state: mission.packageState),
          ]),
        ]),
      ),
    );
  }
}

// ─── Tutorial Card ────────────────────────────────────────────────────────────
class _TutorialCard extends ConsumerWidget {
  final TutorialMission tutorial;
  final Messenger messenger;
  const _TutorialCard({required this.tutorial, required this.messenger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = tutorialMissions.indexOf(tutorial);
    final n = idx + 1;
    final total = tutorialMissions.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xDD1E0E00),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber, width: 2.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x55000000), offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AppColors.amber, width: 1.5),
            ),
            child: Text('PRUEBA $n/$total',
                style: AppTextStyles.fredoka(11,
                    color: AppColors.amber,
                    weight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ),
          const Spacer(),
          _DurationChip(minutes: tutorial.durationMinutes),
        ]),
        const SizedBox(height: 12),
        Text('${tutorial.origin} → ${tutorial.destination}',
            style: AppTextStyles.fredoka(18,
                color: AppColors.gold, weight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.brownBorder.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.format_quote,
                size: 14, color: AppColors.amber.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(tutorial.lore,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                    fontSize: 12,
                  )),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: '¡ACEPTAR PRUEBA!',
            fontSize: 17,
            onTap: () async {
              try {
                await ref
                    .read(homeProvider.notifier)
                    .acceptTutorialMission(idx);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          e.toString().replaceFirst('Exception: ', ''))));
                }
                return;
              }
              if (context.mounted) context.push('/mission');
            },
          ),
        ),
      ]),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final int minutes;
  const _DurationChip({required this.minutes});

  String get _label {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgCard2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.bgLine, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.schedule, size: 11, color: AppColors.gold),
          const SizedBox(width: 4),
          Text(_label,
              style: AppTextStyles.fredoka(11,
                  color: AppColors.gold, weight: FontWeight.bold)),
        ]),
      );
}

// ─── Route Card ───────────────────────────────────────────────────────────────
class _RouteCard extends ConsumerWidget {
  final GameRoute route;
  final Messenger messenger;
  const _RouteCard({required this.route, required this.messenger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInjured =
        messenger.status == MessengerStatus.injured || messenger.health <= 0;
    final canAccept = messenger.status == MessengerStatus.idle && !isInjured;
    final busyLabel =
        isInjured ? 'Mensajero herido — curate en la tienda' : 'Mensajero ocupado';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xDD0D1830),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgLine, width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x44000000), offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${route.origin} → ${route.destination}',
            style: AppTextStyles.fredoka(16,
                color: AppColors.gold, weight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(route.lore,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Row(children: [
          _InfoChip('${route.distanceKm} km', Icons.straighten),
          const SizedBox(width: 6),
          _InfoChip(route.durationLabel, Icons.schedule),
          const SizedBox(width: 6),
          RiskChip(level: route.dangerLevel),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: canAccept ? '¡ACEPTAR MISIÓN!' : busyLabel,
            gradient: canAccept
                ? AppGradients.gold
                : const LinearGradient(
                    colors: [Color(0xFF334455), Color(0xFF223344)]),
            shadowColor:
                canAccept ? AppColors.goldShadow : const Color(0xFF111822),
            fontSize: 15,
            onTap: canAccept ? () => _accept(context, ref) : null,
          ),
        ),
      ]),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(route: route),
    );
    if (ok != true || !context.mounted) return;
    await ref
        .read(homeProvider.notifier)
        .acceptMission(route, messengerId: messenger.id);
    if (context.mounted) await maybeAskForNotifications(context, ref);
  }
}

/// El permiso de avisos se pide UNA vez, con contexto narrativo y recién
/// después de aceptar la primera misión real — nunca en frío al abrir la app
/// (GDD §7). Varus explica por qué conviene decir que sí.
Future<void> maybeAskForNotifications(
    BuildContext context, WidgetRef ref) async {
  final scheduler = ref.read(notificationSchedulerProvider);
  if (await scheduler.permissionStatus() !=
      NotificationPermission.notRequested) {
    return;
  }
  if (!context.mounted) return;

  final quiere = await showDialog<bool>(
    context: context,
    builder: (_) => const _VarusNotificationDialog(),
  );
  if (quiere != true) {
    // No insistir: se marca como pedido y queda el toggle en Ajustes.
    await scheduler.savePrefs(
        (await scheduler.getPrefs()).copyWith(enabled: false));
    return;
  }
  await scheduler.requestPermission();
  await ref.read(homeProvider.notifier).syncAllNotifications();
  await ref
      .read(primerosPasosProvider.notifier)
      .markTask(PlayerProgress.taskEnableNotifs);
}

class _VarusNotificationDialog extends StatelessWidget {
  const _VarusNotificationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1830),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.gold, width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.record_voice_over, color: AppColors.gold, size: 40),
          const SizedBox(height: 10),
          Text('Varus te alcanza en la puerta',
              style: AppTextStyles.fredoka(17,
                  color: AppColors.gold, weight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            '«El camino toma lo que toma. Cerrá los ojos si querés — yo te '
            'aviso si pasa algo.»',
            style: AppTextStyles.bodyLarge
                .copyWith(fontSize: 14, height: 1.55),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Te avisamos cuando tu mensajero necesite una decisión o llegue a '
            'destino. Nada entre las 22 y las 8.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: 'AVISAME',
              icon: Icons.notifications_active_outlined,
              fontSize: 15,
              onTap: () => Navigator.pop(context, true),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Prefiero mirar yo',
                style: AppTextStyles.fredoka(13,
                    color: AppColors.textSecondary)),
          ),
        ]),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _InfoChip(this.text, this.icon);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgCard2,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.bgLine, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(text,
              style: AppTextStyles.fredoka(11, color: AppColors.textSecondary)),
        ]),
      );
}

class _ConfirmDialog extends StatelessWidget {
  final GameRoute route;
  const _ConfirmDialog({required this.route});

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: const Color(0xFF0D1830),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.gold, width: 2.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.map, color: AppColors.gold, size: 44),
            const SizedBox(height: 10),
            Text('Confirmar misión',
                style: AppTextStyles.fredoka(18,
                    color: AppColors.gold, weight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${route.origin} → ${route.destination}',
                style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Duración: ${route.durationLabel} en tiempo real.',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.bgLine, width: 2),
                    ),
                    child: Center(
                        child: Text('Cancelar',
                            style: AppTextStyles.fredoka(14,
                                color: AppColors.textMuted))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GameButton(
                  label: 'Aceptar',
                  fontSize: 15,
                  onTap: () => Navigator.pop(context, true),
                ),
              ),
            ]),
          ]),
        ),
      );
}

// ─── Botón de desbloqueo de nuevo slot ───────────────────────────────────────
class _UnlockSlotButton extends ConsumerStatefulWidget {
  final HomeState state;
  const _UnlockSlotButton({required this.state});

  @override
  ConsumerState<_UnlockSlotButton> createState() => _UnlockSlotButtonState();
}

class _UnlockSlotButtonState extends ConsumerState<_UnlockSlotButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final cost = widget.state.nextSlotCost;
    final payer = widget.state.messenger!;
    final canAfford = payer.aureos >= cost;

    return GestureDetector(
      onTap: canAfford && !_loading ? () => _showUnlockDialog(context) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xDD0D1830),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                canAfford ? AppColors.gold.withValues(alpha: 0.6) : AppColors.bgLine,
            width: 2,
          ),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: canAfford
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.bgCard2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: canAfford ? AppColors.gold : AppColors.bgLine,
                  width: 2),
            ),
            child: Center(
              child: Icon(Icons.person_add,
                  color: canAfford ? AppColors.gold : AppColors.textMuted,
                  size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Contratar nuevo mensajero',
                  style: AppTextStyles.fredoka(14,
                      color: canAfford ? AppColors.gold : AppColors.textMuted,
                      weight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(
                  canAfford
                      ? 'Salta el tutorial — ya conoce el oficio'
                      : 'Necesitás $cost aureos (tenés ${payer.aureos})',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: canAfford
                          ? AppColors.textSecondary
                          : AppColors.textMuted)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: canAfford
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.bgCard2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: canAfford ? AppColors.gold : AppColors.bgLine,
                  width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.monetization_on,
                  size: 13,
                  color: canAfford ? AppColors.gold : AppColors.textMuted),
              const SizedBox(width: 4),
              Text('$cost',
                  style: AppTextStyles.fredoka(13,
                      color: canAfford ? AppColors.gold : AppColors.textMuted,
                      weight: FontWeight.bold)),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _showUnlockDialog(BuildContext context) async {
    final result = await showDialog<({String name, MessengerGender gender})>(
      context: context,
      builder: (_) => _NewMessengerDialog(slotIndex: widget.state.slots.length),
    );
    if (result == null || !mounted) return;

    setState(() => _loading = true);
    try {
      await ref.read(homeProvider.notifier).unlockMessengerSlot(
            payer: widget.state.messenger!,
            newName: result.name,
            gender: result.gender,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Dialog para nombrar el nuevo mensajero ───────────────────────────────────
class _NewMessengerDialog extends StatefulWidget {
  /// Slot que va a ocupar: define el color de túnica del retrato.
  final int slotIndex;
  const _NewMessengerDialog({required this.slotIndex});

  @override
  State<_NewMessengerDialog> createState() => _NewMessengerDialogState();
}

class _NewMessengerDialogState extends State<_NewMessengerDialog> {
  final _ctrl = TextEditingController();
  MessengerGender _gender = MessengerGender.male;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1830),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.gold, width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          MessengerAvatar(
            gender: _gender,
            slotIndex: widget.slotIndex,
            size: 56,
            highlighted: true,
          ),
          const SizedBox(height: 10),
          Text('Nuevo mensajero',
              style: AppTextStyles.fredoka(18,
                  color: AppColors.gold, weight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Ya conoce el oficio. Varus confía en él.',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Nombre
          TextField(
            controller: _ctrl,
            style: AppTextStyles.fredoka(15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Nombre del mensajero',
              hintStyle: AppTextStyles.fredoka(14, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.bgCard2,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.bgLine)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.bgLine)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.gold, width: 2)),
            ),
          ),
          const SizedBox(height: 12),
          // Género
          Row(children: [
            Expanded(
                child: _GenderOption(
              label: 'Hombre',
              gender: MessengerGender.male,
              slotIndex: widget.slotIndex,
              selected: _gender == MessengerGender.male,
              onTap: () => setState(() => _gender = MessengerGender.male),
            )),
            const SizedBox(width: 10),
            Expanded(
                child: _GenderOption(
              label: 'Mujer',
              gender: MessengerGender.female,
              slotIndex: widget.slotIndex,
              selected: _gender == MessengerGender.female,
              onTap: () => setState(() => _gender = MessengerGender.female),
            )),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.bgLine, width: 2),
                  ),
                  child: Center(
                      child: Text('Cancelar',
                          style: AppTextStyles.fredoka(14,
                              color: AppColors.textMuted))),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GameButton(
                label: 'Contratar',
                fontSize: 15,
                onTap: () {
                  final name = _ctrl.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(context, (name: name, gender: _gender));
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final MessengerGender gender;
  final int slotIndex;
  final bool selected;
  final VoidCallback onTap;
  const _GenderOption(
      {required this.label,
      required this.gender,
      required this.slotIndex,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.gold.withValues(alpha: 0.15) : AppColors.bgCard2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? AppColors.gold : AppColors.bgLine,
                width: selected ? 2 : 1.5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            MessengerAvatar(
                gender: gender, slotIndex: slotIndex, size: 34),
            const SizedBox(height: 6),
            Text(label,
                style: AppTextStyles.fredoka(13,
                    color: selected ? AppColors.gold : AppColors.textMuted,
                    weight: selected ? FontWeight.bold : FontWeight.normal)),
          ]),
        ),
      );
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xBB0D1830),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bgLine, width: 2),
        ),
        child: Column(children: [
          const Icon(Icons.castle, color: AppColors.gold, size: 44),
          const SizedBox(height: 10),
          Text('Sin misiones disponibles',
              style: AppTextStyles.fredoka(15,
                  color: AppColors.textMuted, weight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Completá misiones para desbloquear nuevas rutas.',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ]),
      );
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
// Altura total controlada por un único kNavItemSize — todo es relativo a él
class _BottomNav extends StatelessWidget {
  final HomeState state;
  const _BottomNav({required this.state});

  // Único valor que controla el tamaño de todo el footer
  static const double kItemSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final hasMission = state.activeMission != null;
    final hasEvent = state.pendingEvent != null;

    return Container(
      padding: EdgeInsets.only(
        top: kItemSize * 0.2,
        left: kItemSize * 0.2,
        right: kItemSize * 0.2,
        bottom: bottomPad + kItemSize * 0.15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xEE130A00),
        border:
            const Border(top: BorderSide(color: Color(0xFF8B6000), width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _NavTab(
            icon: Icons.storefront,
            label: 'Tienda',
            itemSize: kItemSize,
            onTap: () => context.push('/shop'),
          ),
          // Botón 3D → stats mensajero
          _NavTab3D(
            icon: Icons.person,
            label: 'Mensajero',
            itemSize: kItemSize,
            color: AppColors.sky,
            onTap: () => context.push('/profile'),
          ),
          // Botón central HOME — más grande
          const _NavTabHome(itemSize: kItemSize),
          // Botón 3D → selección de misiones (solo activo si hay misiones)
          _NavTab3D(
            icon: Icons.map_outlined,
            label: 'Misiones',
            itemSize: kItemSize,
            color:
                hasMission || hasEvent ? AppColors.amber : AppColors.textMuted,
            badge: hasEvent,
            onTap: hasMission ? () => context.push('/mission') : null,
          ),
          _NavTab(
            icon: Icons.account_tree_outlined,
            label: 'Caminos',
            itemSize: kItemSize,
            onTap: () => context.push('/skills'),
          ),
        ],
      ),
    );
  }
}

// Tab normal (sin 3D)
class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final double itemSize;
  final VoidCallback? onTap;
  const _NavTab({
    required this.icon,
    required this.label,
    required this.itemSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    final color =
        active ? AppColors.gold.withValues(alpha: 0.7) : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemSize * 1.2,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: itemSize * 0.55),
          SizedBox(height: itemSize * 0.08),
          Text(label,
              style: AppTextStyles.fredoka(itemSize * 0.22, color: color),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// Tab con efecto 3D (fondo desplazado)
class _NavTab3D extends StatelessWidget {
  final IconData icon;
  final String label;
  final double itemSize;
  final Color color;
  final bool badge;
  final VoidCallback? onTap;
  const _NavTab3D({
    required this.icon,
    required this.label,
    required this.itemSize,
    required this.color,
    this.badge = false,
    required this.onTap,
  });

  Color _darken(Color c) => Color.from(
      alpha: c.a, red: c.r * 0.45, green: c.g * 0.45, blue: c.b * 0.45);

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    final btnSize = itemSize * 0.95;
    const depth = 4.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemSize * 1.2,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: btnSize,
            height: btnSize + depth,
            child: Stack(clipBehavior: Clip.none, children: [
              // Fondo 3D
              Positioned(
                bottom: 0,
                child: Container(
                  width: btnSize,
                  height: btnSize,
                  decoration: BoxDecoration(
                    color: active ? _darken(color) : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(itemSize * 0.25),
                    border: Border.all(color: AppColors.outline, width: 2),
                  ),
                ),
              ),
              // Cara
              Positioned(
                top: 0,
                child: Stack(children: [
                  Container(
                    width: btnSize,
                    height: btnSize,
                    decoration: BoxDecoration(
                      color: active ? color : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(itemSize * 0.25),
                      border: Border.all(color: AppColors.outline, width: 2),
                    ),
                    child: Center(
                      child: Icon(icon,
                          size: btnSize * 0.5,
                          color:
                              active ? AppColors.outline : AppColors.textMuted),
                    ),
                  ),
                  if (badge)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: itemSize * 0.28,
                        height: itemSize * 0.28,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ]),
              ),
            ]),
          ),
          SizedBox(height: itemSize * 0.1),
          Text(label,
              style: AppTextStyles.fredoka(itemSize * 0.22,
                  color: active ? color : AppColors.textMuted),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// Tab HOME central — círculo dorado más grande
class _NavTabHome extends StatelessWidget {
  final double itemSize;
  const _NavTabHome({required this.itemSize});

  @override
  Widget build(BuildContext context) {
    final btnSize = itemSize * 1.25;
    const depth = 5.0;
    return SizedBox(
      width: itemSize * 1.4,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: btnSize,
          height: btnSize + depth,
          child: Stack(children: [
            // Sombra
            Positioned(
              bottom: 0,
              child: Container(
                width: btnSize,
                height: btnSize,
                decoration: BoxDecoration(
                  color: AppColors.goldShadow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outline, width: 2.5),
                ),
              ),
            ),
            // Cara
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: btnSize,
                  height: btnSize,
                  decoration: BoxDecoration(
                    gradient: AppGradients.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outline, width: 2.5),
                  ),
                  child: Center(
                    child: Icon(Icons.home_rounded,
                        size: btnSize * 0.48, color: AppColors.outline),
                  ),
                ),
              ),
            ),
          ]),
        ),
        SizedBox(height: itemSize * 0.1),
        Text('INICIO',
            style: AppTextStyles.fredoka(itemSize * 0.22,
                color: AppColors.gold, weight: FontWeight.bold)),
      ]),
    );
  }
}

// ─── Tablón del gremio — contratos del día ────────────────────────────────────
bool _guildViewMarked = false;

class _GuildBoard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guildAsync = ref.watch(guildProvider);
    final guild = guildAsync.valueOrNull;
    if (guild == null) return const SizedBox.shrink();

    // Marca checklist "mirá el tablón" la primera vez que se renderiza
    // (una sola vez por sesión, no en cada rebuild del Home).
    if (!_guildViewMarked) {
      _guildViewMarked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(primerosPasosProvider.notifier)
            .markTask(PlayerProgress.taskViewGuild);
      });
    }

    final done = guild.contracts.where((c) => c.claimed).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xDD0D1830),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brownBorder.withValues(alpha: 0.6), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.push_pin, color: AppColors.brownBorder, size: 18),
          const SizedBox(width: 8),
          Text('TABLÓN DEL GREMIO',
              style: AppTextStyles.fredoka(13,
                  color: AppColors.brownBorder,
                  weight: FontWeight.bold,
                  letterSpacing: 1)),
          const Spacer(),
          Text('$done/${guild.contracts.length} hoy',
              style: AppTextStyles.fredoka(11,
                  color: done == guild.contracts.length
                      ? AppColors.green
                      : AppColors.textSecondary,
                  weight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        ...guild.contracts.map((c) => _ContractRow(contract: c)),
      ]),
    );
  }
}

class _ContractRow extends ConsumerStatefulWidget {
  final DailyContract contract;
  const _ContractRow({required this.contract});

  @override
  ConsumerState<_ContractRow> createState() => _ContractRowState();
}

class _ContractRowState extends ConsumerState<_ContractRow> {
  bool _claiming = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contract;
    final t = c.template;
    final progress = c.progress.clamp(0, t.target);
    final isSeal = t.reward.seals > 0;
    final rewardColor = isSeal ? AppColors.purple : AppColors.sky;
    final rewardLabel =
        isSeal ? '${t.reward.seals} Sello' : '${t.reward.denarios} den.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        // Estado
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: c.claimed
                ? AppColors.green.withValues(alpha: 0.15)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
                color: c.claimed
                    ? AppColors.green
                    : c.completed
                        ? AppColors.gold
                        : AppColors.bgLine,
                width: 2),
          ),
          child: c.claimed
              ? const Icon(Icons.check, size: 14, color: AppColors.green)
              : c.completed
                  ? const Icon(Icons.priority_high,
                      size: 14, color: AppColors.gold)
                  : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.description,
                style: AppTextStyles.fredoka(12,
                    color: c.claimed
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    weight: FontWeight.bold)),
            const SizedBox(height: 3),
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(children: [
                    Container(height: 6, color: AppColors.outline),
                    FractionallySizedBox(
                      widthFactor: (progress / t.target).clamp(0.0, 1.0),
                      child: Container(
                          height: 6,
                          color: c.claimed
                              ? AppColors.green
                              : AppColors.brownBorder),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              Text('$progress/${t.target}',
                  style: AppTextStyles.fredoka(10,
                      color: AppColors.textSecondary)),
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        // Recompensa / botón de cobro
        if (c.claimed)
          Text('COBRADO',
              style: AppTextStyles.fredoka(10,
                  color: AppColors.green, weight: FontWeight.bold))
        else if (c.completed)
          GestureDetector(
            onTap: _claiming ? null : _claim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.outline, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 3)),
                ],
              ),
              child: Text(_claiming ? '...' : 'COBRAR',
                  style: AppTextStyles.fredoka(11,
                      color: AppColors.outline, weight: FontWeight.bold)),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.06, duration: 600.ms)
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rewardColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: rewardColor.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isSeal ? Icons.workspace_premium : Icons.toll,
                  size: 11, color: rewardColor),
              const SizedBox(width: 3),
              Text(rewardLabel,
                  style: AppTextStyles.fredoka(10, color: rewardColor)),
            ]),
          ),
      ]),
    );
  }

  Future<void> _claim() async {
    setState(() => _claiming = true);
    try {
      final reward = await ref
          .read(guildProvider.notifier)
          .claimContract(widget.contract.templateId);
      HapticFeedback.mediumImpact();
      if (mounted) {
        showRewardToast(
          context,
          [
            (type: CurrencyType.denarios, amount: reward.denarios),
            (type: CurrencyType.seals, amount: reward.seals),
          ],
          note: 'Contrato cobrado',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }
}

// ─── Paga del gremio — login diario con racha ─────────────────────────────────
class _DailyPayDialog extends ConsumerStatefulWidget {
  const _DailyPayDialog();

  @override
  ConsumerState<_DailyPayDialog> createState() => _DailyPayDialogState();
}

class _DailyPayDialogState extends ConsumerState<_DailyPayDialog> {
  bool _claiming = false;

  @override
  Widget build(BuildContext context) {
    final guild = ref.watch(guildProvider).valueOrNull;
    if (guild == null) return const SizedBox.shrink();
    final day = guild.nextPayDay;

    return Dialog(
      backgroundColor: const Color(0xFF16100A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.gold, width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black38, width: 3),
              boxShadow: [
                BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 26, spreadRadius: 3),
              ],
            ),
            child: const Icon(Icons.savings, color: Colors.black87, size: 34),
          )
              .animate()
              .scale(
                  begin: const Offset(0.3, 0.3),
                  duration: 500.ms,
                  curve: Curves.elasticOut),
          const SizedBox(height: 14),
          Text('PAGA DEL GREMIO',
              style: AppTextStyles.fredoka(19,
                  color: AppColors.gold,
                  weight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('Varus premia tu constancia.',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          // Racha de 7 días
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (i) {
              final d = i + 1;
              final isToday = d == day;
              final isPast = d < day;
              return Container(
                width: 30, height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.gold.withValues(alpha: 0.2)
                      : isPast
                          ? AppColors.green.withValues(alpha: 0.12)
                          : AppColors.bgCard2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isToday
                          ? AppColors.gold
                          : isPast
                              ? AppColors.green
                              : AppColors.bgLine,
                      width: isToday ? 2 : 1.5),
                ),
                child: Center(
                  child: isPast
                      ? const Icon(Icons.check,
                          size: 13, color: AppColors.green)
                      : Text('$d',
                          style: AppTextStyles.fredoka(12,
                              color: isToday
                                  ? AppColors.gold
                                  : AppColors.textMuted,
                              weight: FontWeight.bold)),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          _PayRewardChips(reward: guild.nextPayReward),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: 'COBRAR PAGA — DÍA $day',
              fontSize: 16,
              isLoading: _claiming,
              onTap: _claiming ? null : _claim,
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _claim() async {
    setState(() => _claiming = true);
    // El diálogo se cierra al cobrar: el toast tiene que quedar sobre el Home,
    // que es donde el jugador ve subir los contadores.
    final navigator = Navigator.of(context);
    final rootContext = navigator.context;
    try {
      final claimed = await ref.read(guildProvider.notifier).claimDailyPay();
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      navigator.pop();
      if (!rootContext.mounted) return;
      showRewardToast(
        rootContext,
        [
          (type: CurrencyType.denarios, amount: claimed.reward.denarios),
          (type: CurrencyType.aureos, amount: claimed.reward.aureos),
          (type: CurrencyType.seals, amount: claimed.reward.seals),
        ],
        note: 'Paga del gremio · día ${claimed.day} de racha',
      );
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }
}

class _PayRewardChips extends StatelessWidget {
  final DailyPayReward reward;
  const _PayRewardChips({required this.reward});

  @override
  Widget build(BuildContext context) {
    Widget chip(CurrencyType type, int amount) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: type.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: type.color, width: 2),
          ),
          child: RewardAmount(
              type: type, amount: amount, fontSize: 14, withLabel: false),
        );

    return Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
      if (reward.denarios > 0) chip(CurrencyType.denarios, reward.denarios),
      if (reward.aureos > 0) chip(CurrencyType.aureos, reward.aureos),
      if (reward.seals > 0) chip(CurrencyType.seals, reward.seals),
    ]);
  }
}

// ─── Card de capítulo de historia ─────────────────────────────────────────────
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1A48), Color(0xFF17102A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AppColors.purple, width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.auto_stories, size: 12, color: AppColors.purple),
              const SizedBox(width: 5),
              Text('HISTORIA',
                  style: AppTextStyles.fredoka(10,
                      color: AppColors.purple,
                      weight: FontWeight.bold,
                      letterSpacing: 1)),
            ]),
          ),
          const Spacer(),
          _DurationChip(minutes: c.durationMinutes),
        ]),
        const SizedBox(height: 12),
        Text(c.chapterTitle,
            style: AppTextStyles.fredoka(17,
                color: AppColors.textPrimary, weight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${c.origin} → ${c.destination}',
            style: AppTextStyles.fredoka(12, color: AppColors.purple)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
          ),
          child: Text(c.lore,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.85),
                height: 1.45,
                fontStyle: FontStyle.italic,
              )),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: 'COMENZAR CAPÍTULO',
            icon: Icons.play_arrow_rounded,
            gradient: AppGradients.purple,
            shadowColor: const Color(0xFF2A0E55),
            fontSize: 16,
            isLoading: _loading,
            onTap: _loading ? null : _start,
          ),
        ),
      ]),
    );
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      await ref.read(homeProvider.notifier).acceptStoryMission(widget.config);
      HapticFeedback.mediumImpact();
      if (mounted) context.push('/mission');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
