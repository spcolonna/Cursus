part of '../home_screen.dart';

/// Cuántas rutas se muestran en el Home antes de "ver todas".
const _kInlineRoutes = 2;

// ─── Card de un mensajero + su misión/tutorial/rutas ─────────────────────────
class _MessengerSlotCard extends ConsumerWidget {
  final MessengerSlot slot;
  const _MessengerSlotCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = slot.messenger;
    final mission = slot.activeMission;

    // El estado del slot (evento → viaje → tutorial → rutas) cambia sin
    // cortes: cada estado tiene su key y el AnimatedSwitcher los cruza.
    final Widget content;
    if (slot.pendingEvent != null && mission != null) {
      content = _UrgentEventButton(
        key: ValueKey('event-${slot.pendingEvent!.id}'),
        event: slot.pendingEvent!,
        mission: mission,
      );
    } else if (mission != null) {
      content = _ActiveMissionBanner(
          key: ValueKey('mission-${mission.id}'), mission: mission);
    } else if (slot.nextTutorial != null) {
      content = _TutorialCard(
        key: ValueKey('tutorial-${slot.nextTutorial!.origin}'),
        tutorial: slot.nextTutorial!,
        messenger: m,
      );
    } else if (slot.availableRoutes.isNotEmpty) {
      content = _RoutesPreview(
          key: const ValueKey('routes'),
          routes: slot.availableRoutes,
          messenger: m);
    } else {
      content = EmptyState(
        key: const ValueKey('empty'),
        icon: Icons.castle,
        title: AppLocalizations.of(context).slotNoMissionsTitle,
        body: AppLocalizations.of(context).slotNoMissionsBody,
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _MessengerCard(messenger: m),
      const SizedBox(height: AppSpacing.md),
      AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.slow),
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        // Align con heightFactor en vez de SizeTransition: crece igual pero
        // no recorta, así la sombra de la card no queda cortada en las esquinas.
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: AnimatedBuilder(
            animation: anim,
            builder: (_, c) => Align(
                alignment: Alignment.topCenter,
                heightFactor: anim.value,
                child: c),
            child: child,
          ),
        ),
        child: content,
      ),
    ]);
  }
}

// ─── Messenger Card ───────────────────────────────────────────────────────────
class _MessengerCard extends StatelessWidget {
  final Messenger messenger;
  const _MessengerCard({required this.messenger});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.ochreDeep.withValues(alpha: 0.4),
      onTap: () => context.push('/profile'),
      semanticLabel:
          AppLocalizations.of(context).slotViewProfile(messenger.name),
      child: Row(children: [
        MessengerHero(messenger, size: 48),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(messenger.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge),
            // El título que eligió llevar (solo el mensajero principal).
            if (messenger.slotIndex == 0)
              Consumer(builder: (context, ref, _) {
                final title = ref.watch(titlesProvider).valueOrNull?.equipped;
                if (title == null) return const SizedBox.shrink();
                return Text(AppLocalizations.of(context).quotedTitle(title),
                    style: AppTextStyles.ui(12,
                        color: AppColors.ochreDeep, weight: FontWeight.bold));
              }),
            const SizedBox(height: AppSpacing.xs),
            Wrap(spacing: 6, runSpacing: 4, children: [
              GameChip(
                  AppLocalizations.of(context)
                      .slotRank(messenger.rankTitle, messenger.rank),
                  color: AppColors.ochreDeep),
              GameChip(messenger.status.label, color: AppColors.egyptianBlue),
            ]),
            if (!messenger.tutorialComplete) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppLocalizations.of(context).slotTrial(
                    messenger.tutorialMissionIndex + 1,
                    lTutorialMissions.length),
                style: AppTextStyles.ui(12, color: AppColors.sienna),
              ),
            ],
          ]),
        ),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.inkMuted, size: 26),
      ]),
    );
  }
}

// ─── Evento urgente ───────────────────────────────────────────────────────────
// Late suave mientras espera: llama la atención sin sacudir toda la pantalla.
class _UrgentEventButton extends StatelessWidget {
  final MissionEvent event;
  final Mission mission;
  const _UrgentEventButton(
      {super.key, required this.event, required this.mission});

  @override
  Widget build(BuildContext context) {
    final card = GameCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppSpacing.lg),
      gradient: AppGradients.event,
      borderColor: AppColors.cinnabar,
      onTap: () => context.push('/event?m=${mission.messengerId}'),
      semanticLabel: AppLocalizations.of(context).slotEventSemantics(event.title),
      child: Row(children: [
        const Icon(Icons.warning_rounded, color: AppColors.cinnabar, size: 26),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context).slotEventPending,
                style: AppTextStyles.ui(13,
                    color: AppColors.cinnabar,
                    weight: FontWeight.bold,
                    letterSpacing: 1)),
            Text(event.title,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            PeriodicBuilder(
              period: const Duration(seconds: 30),
              builder: (_) {
                final left = event.deadlineAt.difference(GameClock.now());
                return Text(
                  left.isNegative
                      ? AppLocalizations.of(context).slotDecidesAlone
                      : AppLocalizations.of(context)
                          .slotDecidesIn(left.inMinutes),
                  style: AppTextStyles.bodySmall,
                );
              },
            ),
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppGradients.ochre,
            borderRadius: BorderRadius.circular(AppRadii.sm + 2),
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.ink, offset: Offset(0, 3), blurRadius: 0)
            ],
          ),
          child: Text(AppLocalizations.of(context).slotDecide,
              style: AppTextStyles.ui(13,
                  color: AppColors.ink, weight: FontWeight.bold)),
        ),
      ]),
    );

    if (AppMotion.reduced(context)) return card;
    return card
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
            begin: 1.0,
            end: 1.02,
            duration: 900.ms,
            curve: AppMotion.standard);
  }
}

// ─── Misión activa ────────────────────────────────────────────────────────────
// La barra avanza sola a 60 fps; solo el texto se refresca cada segundo.
class _ActiveMissionBanner extends StatelessWidget {
  final Mission mission;
  const _ActiveMissionBanner({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final isTut = mission.isTutorial;
    final accentColor = isTut ? AppColors.sienna : AppColors.ochreDeep;

    return GameCard(
      padding: const EdgeInsets.all(14),
      borderColor: accentColor.withValues(alpha: 0.5),
      onTap: () => context.push('/mission?m=${mission.messengerId}'),
      semanticLabel:
          AppLocalizations.of(context).slotMissionSemantics(
              ContentL10n.place(mission.origin),
              ContentL10n.place(mission.destination)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(isTut ? Icons.assignment : Icons.map,
              color: accentColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${ContentL10n.place(mission.origin)} → '
              '${ContentL10n.place(mission.destination)}',
              style: AppTextStyles.ui(15,
                  color: accentColor, weight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PeriodicBuilder(builder: (_) => DeadlineChip(mission: mission)),
        ]),
        const SizedBox(height: 10),
        LiveProgressBar(
          height: 10,
          progressAt: mission.progressAt,
          gradient: isTut ? AppGradients.sienna : AppGradients.ochre,
          marks: _eventMarksFor(mission),
        ),
        const SizedBox(height: 6),
        // Al llegar, la línea de estado se vuelve la llamada a la acción.
        PeriodicBuilder(builder: (context) {
          final now = GameClock.now();
          if (mission.readyToDeliverAt(now)) {
            return Row(children: [
              const Icon(Icons.flag_rounded, color: AppColors.ochreDeep, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    AppLocalizations.of(context)
                        .slotArrived(ContentL10n.place(mission.destination)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.ui(13,
                        color: AppColors.ochreDeep, weight: FontWeight.bold)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.ochreDeep, size: 22),
            ])
                .animate(
                    onPlay: (c) => AppMotion.reduced(context)
                        ? null
                        : c.repeat(reverse: true))
                .fade(begin: 0.75, end: 1, duration: 700.ms);
          }
          final pct = (mission.progressAt(now) * 100).round();
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context).slotProgress(pct),
                    style: AppTextStyles.bodySmall),
                PackageBadge(state: mission.packageState),
              ]);
        }),
      ]),
    );
  }
}

List<double> _eventMarksFor(Mission mission) {
  final total =
      mission.deadlineAt.difference(mission.startedAt).inSeconds.toDouble();
  if (total <= 0) return const [];
  return [
    for (final e in mission.events)
      (e.triggersAt.difference(mission.startedAt).inSeconds / total)
          .clamp(0.0, 1.0),
  ];
}

// ─── Tutorial Card ────────────────────────────────────────────────────────────
class _TutorialCard extends ConsumerWidget {
  final TutorialMission tutorial;
  final Messenger messenger;
  const _TutorialCard(
      {super.key, required this.tutorial, required this.messenger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = lTutorialMissions.indexOf(tutorial);
    final n = idx + 1;
    final total = lTutorialMissions.length;

    return GameCard(
      gradient: AppGradients.ochreTint,
      borderColor: AppColors.sienna,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GameChip(AppLocalizations.of(context).slotTrialChip(n, total),
              color: AppColors.sienna),
          const Spacer(),
          GameChip(_durationLabel(tutorial.durationMinutes),
              icon: Icons.schedule, color: AppColors.ochreDeep),
        ]),
        const SizedBox(height: AppSpacing.md),
        Text(
            '${ContentL10n.place(tutorial.origin)} → '
            '${ContentL10n.place(tutorial.destination)}',
            style: AppTextStyles.heading(18,
                color: AppColors.ochreDeep)),
        const SizedBox(height: AppSpacing.sm),
        _LoreQuote(text: tutorial.lore, accent: AppColors.sienna),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: AppLocalizations.of(context).slotAcceptTrial,
            fontSize: 17,
            onTap: () async {
              try {
                await ref
                    .read(homeProvider.notifier)
                    .acceptTutorialMission(idx, messengerId: messenger.id);
              } catch (e) {
                if (context.mounted) showErrorSnack(context, e);
                return;
              }
              if (context.mounted) {
                context.push('/mission?m=${messenger.id}');
              }
            },
          ),
        ),
      ]),
    );
  }
}

/// Cita de lore en cursiva, sobre un pozo de papel.
class _LoreQuote extends StatelessWidget {
  final String text;
  final Color accent;
  const _LoreQuote({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.paperDeep,
          borderRadius: BorderRadius.circular(AppRadii.sm + 2),
          border: Border.all(color: accent.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.format_quote, size: 16, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: AppTextStyles.proseItalic(size: 15)),
          ),
        ]),
      );
}

// ─── Rutas ────────────────────────────────────────────────────────────────────
/// Las primeras rutas en el Home; el resto, en un panel inferior.
class _RoutesPreview extends StatelessWidget {
  final List<GameRoute> routes;
  final Messenger messenger;
  const _RoutesPreview(
      {super.key, required this.routes, required this.messenger});

  @override
  Widget build(BuildContext context) {
    final inline = routes.take(_kInlineRoutes).toList();
    final rest = routes.length - inline.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel(AppLocalizations.of(context).slotRoutesHeader),
      const SizedBox(height: AppSpacing.sm),
      for (final (i, r) in inline.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RouteCard(route: r, messenger: messenger)
              .animate(delay: AppMotion.stagger * i)
              .fadeIn(duration: AppMotion.of(context, AppMotion.base))
              .slideY(begin: 0.04, end: 0),
        ),
      if (rest > 0)
        GameButton(
          label: AppLocalizations.of(context).slotSeeAllRoutes(routes.length),
          icon: Icons.map_outlined,
          fontSize: 14,
          variant: GameButtonVariant.secondary,
          onTap: () => showGameSheet(
            context,
            title: AppLocalizations.of(context).slotRoutesFor(messenger.name),
            builder: (sheet) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final (i, r) in routes.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RouteCard(
                      route: r,
                      messenger: messenger,
                      onAccepted: () => Navigator.of(sheet).pop(),
                    )
                        .animate(delay: AppMotion.stagger * i)
                        .fadeIn(duration: AppMotion.of(context, AppMotion.base))
                        .slideY(begin: 0.05, end: 0),
                  ),
              ],
            ),
          ),
        ),
    ]);
  }
}

class _RouteCard extends ConsumerWidget {
  final GameRoute route;
  final Messenger messenger;

  /// Se llama después de aceptar (p. ej. para cerrar el panel de rutas).
  final VoidCallback? onAccepted;
  const _RouteCard(
      {required this.route, required this.messenger, this.onAccepted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInjured =
        messenger.status == MessengerStatus.injured || messenger.health <= 0;
    final canAccept = messenger.status == MessengerStatus.idle && !isInjured;
    final l = AppLocalizations.of(context);
    final busyLabel = isInjured ? l.slotInjuredHeal : l.slotBusy;

    return GameCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RouteMapThumbnail(
            routeId: route.id,
            origin: route.origin,
            destination: route.destination,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${ContentL10n.place(route.origin)} → '
                    '${ContentL10n.place(route.destination)}',
                    style: AppTextStyles.ui(16,
                        color: AppColors.ochreDeep, weight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(route.lore,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          GameChip('${route.distanceKm} km', icon: Icons.straighten),
          GameChip(route.durationLabel, icon: Icons.schedule),
          RiskChip(level: route.dangerLevel),
          // Lo que paga con nota A: rutas más largas y peligrosas, más paga.
          GameChip(
            l.slotPay((gradeBaseReward('A') *
                    routePayFactor(route.durationMinutes, route.danger) *
                    route.payBonus)
                .round()),
            icon: CurrencyType.denarios.icon,
            color: AppColors.egyptianBlue,
            trailingIcon: route.payBonus > 1 ? Icons.arrow_upward : null,
          ),
          // Quién la encarga: entregarle bien suma reputación con esa facción.
          if (route.patron != null)
            GameChip(route.patron!.label,
                icon: factionIcon(route.patron!),
                color: factionColor(route.patron!)),
        ]),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: canAccept ? l.slotAcceptMission : busyLabel,
            fontSize: 15,
            onTap: canAccept ? () => _accept(context, ref) : null,
          ),
        ),
      ]),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final ok = await showGameDialog<bool>(
      context,
      builder: (_) => _ConfirmDialog(route: route),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref
          .read(homeProvider.notifier)
          .acceptMission(route, messengerId: messenger.id);
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
      return;
    }
    onAccepted?.call();
    if (context.mounted) await maybeAskForNotifications(context, ref);
  }
}

class _ConfirmDialog extends StatelessWidget {
  final GameRoute route;
  const _ConfirmDialog({required this.route});

  @override
  Widget build(BuildContext context) => GameDialog(
        icon: Icons.map,
        title: AppLocalizations.of(context).slotConfirmTitle,
        actions: [
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: AppLocalizations.of(context).slotSetOut,
              icon: Icons.directions_run,
              fontSize: 15,
              onTap: () => Navigator.pop(context, true),
            ),
          ),
          GameButton(
            label: AppLocalizations.of(context).cancel,
            fontSize: 14,
            variant: GameButtonVariant.secondary,
            onTap: () => Navigator.pop(context, false),
          ),
        ],
        child: Column(children: [
          Text(
              '${ContentL10n.place(route.origin)} → '
              '${ContentL10n.place(route.destination)}',
              style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context).slotDuration(route.durationLabel),
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ]),
      );
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

  final quiere = await showGameDialog<bool>(
    context,
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
    return GameDialog(
      icon: Icons.record_voice_over,
      title: AppLocalizations.of(context).slotNotifTitle,
      actions: [
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: AppLocalizations.of(context).slotNotifYes,
            icon: Icons.notifications_active_outlined,
            fontSize: 15,
            onTap: () => Navigator.pop(context, true),
          ),
        ),
        GameButton(
          label: AppLocalizations.of(context).slotNotifNo,
          fontSize: 14,
          variant: GameButtonVariant.secondary,
          onTap: () => Navigator.pop(context, false),
        ),
      ],
      child: Column(children: [
        Text(
          AppLocalizations.of(context).slotNotifQuote,
          style: AppTextStyles.bodyLarge.copyWith(height: 1.55),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context).slotNotifBody,
          style: AppTextStyles.bodySmall.copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}
