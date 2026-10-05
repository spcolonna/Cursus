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
      content = const EmptyState(
        key: ValueKey('empty'),
        icon: Icons.castle,
        title: 'Sin misiones disponibles',
        body: 'Completá misiones para desbloquear nuevas rutas.',
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _MessengerCard(messenger: m),
      const SizedBox(height: AppSpacing.md),
      AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.slow),
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SizeTransition(
              sizeFactor: anim, axisAlignment: -1, child: child),
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
      borderColor: AppColors.gold.withValues(alpha: 0.4),
      onTap: () => context.push('/profile'),
      semanticLabel: 'Ver perfil de ${messenger.name}',
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
                return Text('«$title»',
                    style: AppTextStyles.fredoka(12,
                        color: AppColors.gold, weight: FontWeight.bold));
              }),
            const SizedBox(height: AppSpacing.xs),
            Wrap(spacing: 6, runSpacing: 4, children: [
              GameChip('${messenger.rankTitle} · Rank ${messenger.rank}',
                  color: AppColors.gold),
              GameChip(messenger.status.label, color: AppColors.sky),
            ]),
            if (!messenger.tutorialComplete) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Prueba ${messenger.tutorialMissionIndex + 1}/${tutorialMissions.length} de Varus',
                style: AppTextStyles.fredoka(12, color: AppColors.amber),
              ),
            ],
          ]),
        ),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.textMuted, size: 26),
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
      borderColor: AppColors.red,
      onTap: () => context.push('/event?m=${mission.messengerId}'),
      semanticLabel: 'Evento pendiente: ${event.title}. Decidir.',
      child: Row(children: [
        const Icon(Icons.warning_rounded, color: AppColors.parchment, size: 26),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¡EVENTO PENDIENTE!',
                style: AppTextStyles.fredoka(13,
                    color: AppColors.parchment,
                    weight: FontWeight.bold,
                    letterSpacing: 1)),
            Text(event.title,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.parchment),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            PeriodicBuilder(
              period: const Duration(seconds: 30),
              builder: (_) {
                final left = event.deadlineAt.difference(DateTime.now());
                return Text(
                  left.isNegative
                      ? 'Tu mensajero va a decidir solo'
                      : 'Decide solo en ${left.inMinutes} min',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.parchment),
                );
              },
            ),
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: BorderRadius.circular(AppRadii.sm + 2),
            border: Border.all(color: AppColors.outline, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.goldShadow, offset: Offset(0, 3), blurRadius: 0)
            ],
          ),
          child: Text('DECIDIR',
              style: AppTextStyles.fredoka(13,
                  color: AppColors.outline, weight: FontWeight.bold)),
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
    final accentColor = isTut ? AppColors.amber : AppColors.gold;

    return GameCard(
      padding: const EdgeInsets.all(14),
      borderColor: accentColor.withValues(alpha: 0.5),
      onTap: () => context.push('/mission?m=${mission.messengerId}'),
      semanticLabel:
          'Misión ${mission.origin} a ${mission.destination}. Ver viaje.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(isTut ? Icons.assignment : Icons.map,
              color: accentColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${mission.origin} → ${mission.destination}',
              style: AppTextStyles.fredoka(15,
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
          gradient: isTut ? AppGradients.amber : AppGradients.gold,
          marks: _eventMarksFor(mission),
        ),
        const SizedBox(height: 6),
        // Al llegar, la línea de estado se vuelve la llamada a la acción.
        PeriodicBuilder(builder: (context) {
          final now = DateTime.now();
          if (mission.readyToDeliverAt(now)) {
            return Row(children: [
              const Icon(Icons.flag_rounded, color: AppColors.gold, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text('¡Llegó a ${mission.destination}! Tocá para entregar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.fredoka(13,
                        color: AppColors.gold, weight: FontWeight.bold)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.gold, size: 22),
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
                Text('$pct% del camino', style: AppTextStyles.bodySmall),
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
    final idx = tutorialMissions.indexOf(tutorial);
    final n = idx + 1;
    final total = tutorialMissions.length;

    return GameCard(
      gradient: AppGradients.tutorialCard,
      borderColor: AppColors.amber,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GameChip('PRUEBA $n/$total', color: AppColors.amber),
          const Spacer(),
          GameChip(_durationLabel(tutorial.durationMinutes),
              icon: Icons.schedule, color: AppColors.gold),
        ]),
        const SizedBox(height: AppSpacing.md),
        Text('${tutorial.origin} → ${tutorial.destination}',
            style: AppTextStyles.fredoka(18,
                color: AppColors.gold, weight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        _LoreQuote(text: tutorial.lore, accent: AppColors.amber),
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

/// Cita de lore en cursiva, sobre un velo oscuro.
class _LoreQuote extends StatelessWidget {
  final String text;
  final Color accent;
  const _LoreQuote({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard2,
          borderRadius: BorderRadius.circular(AppRadii.sm + 2),
          border: Border.all(color: accent.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.format_quote, size: 16, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary,
                  height: 1.45,
                )),
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
      const _SectionLabel('RUTAS DISPONIBLES'),
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
          label: 'VER LAS ${routes.length} RUTAS',
          icon: Icons.map_outlined,
          fontSize: 14,
          variant: GameButtonVariant.secondary,
          onTap: () => showGameSheet(
            context,
            title: 'Rutas para ${messenger.name}',
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
    final busyLabel =
        isInjured ? 'Herido: curate en la tienda' : 'Mensajero ocupado';

    return GameCard(
      padding: const EdgeInsets.all(14),
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
        Wrap(spacing: 6, runSpacing: 6, children: [
          GameChip('${route.distanceKm} km', icon: Icons.straighten),
          GameChip(route.durationLabel, icon: Icons.schedule),
          RiskChip(level: route.dangerLevel),
          // Lo que paga con nota A: rutas más largas y peligrosas, más paga.
          GameChip(
            'Paga ~${(gradeBaseReward('A') * routePayFactor(route.durationMinutes, route.danger) * route.payBonus).round()}',
            icon: CurrencyType.denarios.icon,
            color: AppColors.sky,
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
            label: canAccept ? '¡ACEPTAR MISIÓN!' : busyLabel,
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
        title: 'Confirmar misión',
        actions: [
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: 'SALIR AL CAMINO',
              icon: Icons.directions_run,
              fontSize: 15,
              onTap: () => Navigator.pop(context, true),
            ),
          ),
          GameButton(
            label: 'Cancelar',
            fontSize: 14,
            variant: GameButtonVariant.secondary,
            onTap: () => Navigator.pop(context, false),
          ),
        ],
        child: Column(children: [
          Text('${route.origin} → ${route.destination}',
              style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('Duración: ${route.durationLabel} en tiempo real.',
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
      title: 'Varus te alcanza en la puerta',
      actions: [
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: 'AVISAME',
            icon: Icons.notifications_active_outlined,
            fontSize: 15,
            onTap: () => Navigator.pop(context, true),
          ),
        ),
        GameButton(
          label: 'Prefiero mirar yo',
          fontSize: 14,
          variant: GameButtonVariant.secondary,
          onTap: () => Navigator.pop(context, false),
        ),
      ],
      child: Column(children: [
        Text(
          '«El camino toma lo que toma. Cerrá los ojos si querés — yo te '
          'aviso si pasa algo.»',
          style: AppTextStyles.bodyLarge.copyWith(height: 1.55),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Te avisamos cuando tu mensajero necesite una decisión o llegue a '
          'destino. Nada entre las 22 y las 8.',
          style: AppTextStyles.bodySmall.copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}
