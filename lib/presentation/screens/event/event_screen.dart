import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/skill_tree.dart';
import '../../../domain/entities/world.dart';
import '../../../domain/usecases/forecast.dart';
import '../../../domain/usecases/usecases.dart';
import '../../widgets/primeros_pasos.dart';

class EventScreen extends ConsumerStatefulWidget {
  /// Mensajero cuyo evento se decide; null = el principal.
  final String? messengerId;
  const EventScreen({super.key, this.messengerId});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  EventOption? _selected;
  bool _resolving = false;
  /// Resolución completa: incluye el desglose del score, que es lo que le
  /// permite al jugador entender por qué le fue bien o mal.
  EventResolution? _resolution;
  bool _resolvedTutorial = false;
  static bool _spotlightShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSpotlight());
  }

  Future<void> _maybeSpotlight() async {
    if (_spotlightShown || !mounted) return;
    final progress = ref.read(playerProgressProvider);
    final seen = await progress.eventTooltipSeen;
    if (!mounted || seen) return;
    _spotlightShown = true;
    await maybeShowSpotlight(
      context: context,
      alreadySeen: false,
      onSeen: () => progress.markEventTooltipSeen(),
      title: 'Una decisión en el camino',
      body:
          'Cada opción tiene riesgo, costo de tiempo y a veces pide una habilidad. '
          'El forecast te muestra las chances antes de confirmar.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);
    final world = ref.watch(worldProvider).valueOrNull;

    return homeAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: LoadingState(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: ErrorState(
            error: e, onRetry: () => ref.read(homeProvider.notifier).refresh()),
      ),
      data: (state) {
        // El resultado se muestra aunque la misión ya no tenga eventos
        // pendientes (o haya cambiado tras recargar el Home).
        final slot = state.slotFor(widget.messengerId);
        final event = slot?.pendingEvent;
        final mission = slot?.activeMission;

        final Widget body;
        if (_resolution != null) {
          body = _OutcomeView(
            key: const ValueKey('outcome'),
            resolution: _resolution!,
            isTutorial: _resolvedTutorial,
            onContinue: () => _leaveEventScreen(context),
          );
        } else if (event == null || mission == null) {
          body = SafeArea(
            key: const ValueKey('empty'),
            child: Center(
              child: EmptyState(
                icon: Icons.check_circle_outline,
                title: 'No hay eventos pendientes',
                body: 'El camino está tranquilo por ahora.',
                action: GameButton(
                    label: 'VOLVER', onTap: () => _leaveEventScreen(context)),
              ),
            ),
          );
        } else {
          body = _DecisionView(
            key: ValueKey('decision-${event.id}'),
            event: event,
            mission: mission,
            messenger: slot?.messenger,
            world: world,
            selected: _selected,
            resolving: _resolving,
            onSelect: (opt) => setState(() => _selected = opt),
            onConfirm: () => _confirm(mission, event),
          );
        }

        // Decisión → resultado: la decisión se va y el sello entra. Sin
        // corte en seco.
        return GradientScaffold(
          useEventBg: true,
          body: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.slow),
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                  scale: Tween(begin: 0.97, end: 1.0).animate(anim),
                  child: child),
            ),
            child: body,
          ),
        );
      },
    );
  }

  Future<void> _confirm(Mission mission, MissionEvent event) async {
    if (_selected == null || _resolving) return;
    setState(() => _resolving = true);

    final EventResolution result;
    try {
      result = await ref.read(homeProvider.notifier).resolveEvent(
            mission: mission,
            event: event,
            option: _selected!,
          );
    } catch (e) {
      if (mounted) {
        setState(() => _resolving = false);
        showErrorSnack(context, e);
      }
      return;
    }

    // Feedback físico + SFX: que el resultado se SIENTA.
    switch (result.outcome.type) {
      case OutcomeType.success:
        AppFeedback.success();
      case OutcomeType.partial:
        AppFeedback.partial();
      case OutcomeType.fail:
        AppFeedback.fail();
    }

    if (mounted) {
      setState(() {
        _resolution = result;
        _resolvedTutorial = mission.isTutorial;
        _resolving = false;
      });
    }
  }
}

// ─── Decision View ────────────────────────────────────────────────────────────
class _DecisionView extends StatelessWidget {
  final MissionEvent event;
  final Mission mission;
  final Messenger? messenger;
  final WorldState? world;
  final EventOption? selected;
  final bool resolving;
  final ValueChanged<EventOption> onSelect;
  final VoidCallback onConfirm;

  const _DecisionView({
    super.key,
    required this.event,
    required this.mission,
    required this.messenger,
    required this.world,
    required this.selected,
    required this.resolving,
    required this.onSelect,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    // Las opciones con requiredFlag son callbacks secretos: si la historia
    // no las habilitó, no existen para este jugador.
    final visibleOptions =
        event.options.where((o) => optionVisible(o, world)).toList();

    return SafeArea(
      child: Column(children: [
        _buildTopRow(context),
        Expanded(
          // La narrativa scrollea junto con las opciones: con textos largos
          // en pantallas chicas, antes el encabezado se comía las opciones.
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              Text('¿QUÉ HACÉS?',
                  style: AppTextStyles.fredoka(13,
                      color: AppColors.textSecondary,
                      weight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(height: 10),
              ...visibleOptions.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OptionCard(
                        option: e.value,
                        isSelected: selected?.id == e.value.id,
                        messenger: messenger,
                        world: world,
                        // Callback secreto: se nota que es especial.
                        isSecret: e.value.requiredFlag != null,
                        onTap: () => onSelect(e.value),
                      )
                          .animate(
                              delay: AppMotion.stagger * (2 + e.key))
                          .fadeIn(
                              duration: AppMotion.of(context, AppMotion.base))
                          .slideX(begin: 0.06, end: 0, curve: AppMotion.enter),
                    ),
                  ),
            ],
          ),
        ),
        _buildConfirmArea(),
      ]),
    );
  }

  Widget _buildTopRow(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
        child: Row(children: [
          GameBackButton(onTap: () => _leaveEventScreen(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GameChip(
                mission.isTutorial ? 'PRUEBA DE VARUS' : 'EVENTO CRÍTICO',
                icon: Icons.warning_amber_rounded,
                color: AppColors.amber,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PeriodicBuilder(
              builder: (_) => _DecisionCountdown(deadline: event.deadlineAt)),
        ]),
      );

  Widget _buildHeader(BuildContext context) {
    return Hero(
      tag: eventHeroTag(event.id),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: AppGradients.event,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.red, width: 2.5),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadowSoft,
                  offset: Offset(0, 4),
                  blurRadius: 8),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event.title,
                style: AppTextStyles.fredoka(22,
                    color: AppColors.parchment, weight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            // La narrativa es el corazón del juego: texto grande y claro.
            Text(event.description,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 15,
                  height: 1.55,
                  color: AppColors.parchment,
                )),
          ]),
        ),
      ),
    );
  }

  Widget _buildConfirmArea() {
    final canConfirm = selected != null && !resolving;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.bgLine)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: GameButton(
          label: resolving
              ? 'Resolviendo...'
              : selected == null
                  ? 'ELEGÍ UNA OPCIÓN'
                  : 'CONFIRMAR DECISIÓN',
          fontSize: 18,
          isLoading: resolving,
          onTap: canConfirm ? onConfirm : null,
        ),
      ),
    );
  }
}

// ─── Cuenta regresiva de la decisión ──────────────────────────────────────────
// Antes decía '45m' fijo, sin relación con el evento real.
class _DecisionCountdown extends StatelessWidget {
  final DateTime deadline;
  const _DecisionCountdown({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final left = deadline.difference(DateTime.now());
    final label = left.isNegative
        ? 'SE TE PASÓ'
        : left.inHours > 0
            ? '${left.inHours}h ${left.inMinutes % 60}m'
            : left.inMinutes > 0
                ? '${left.inMinutes}m ${left.inSeconds % 60}s'
                : '${left.inSeconds}s';
    final urgent = left.inMinutes < 10;
    return Semantics(
      label: 'Tiempo para decidir: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppGradients.gold,
          borderRadius: BorderRadius.circular(AppRadii.sm + 2),
          border: Border.all(color: AppColors.outline, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 3))
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(urgent ? Icons.alarm : Icons.timer_outlined,
              color: AppColors.outline, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(label,
              style: AppTextStyles.fredoka(13,
                  color: AppColors.outline, weight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

// ─── Option Card ──────────────────────────────────────────────────────────────
class _OptionCard extends StatelessWidget {
  final EventOption option;
  final bool isSelected;
  final Messenger? messenger;
  final WorldState? world;
  final bool isSecret;
  final VoidCallback onTap;
  const _OptionCard(
      {required this.option,
      required this.isSelected,
      required this.messenger,
      required this.world,
      this.isSecret = false,
      required this.onTap});

  // Única fuente de verdad del gating (skills + reputación).
  bool _meetsRequirements() =>
      meetsOptionRequirements(option, messenger, world: world);

  static IconData _forecastIcon(ForecastBand band) => switch (band) {
        ForecastBand.assured => Icons.verified_outlined,
        ForecastBand.favourable => Icons.trending_up,
        ForecastBand.uncertain => Icons.help_outline,
        ForecastBand.risky => Icons.warning_amber_rounded,
        ForecastBand.reckless => Icons.dangerous_outlined,
      };

  static Color _forecastColor(ForecastBand band) => switch (band) {
        ForecastBand.assured => AppColors.riskLow,
        ForecastBand.favourable => AppColors.riskLow,
        ForecastBand.uncertain => AppColors.textSecondary,
        ForecastBand.risky => AppColors.riskMed,
        ForecastBand.reckless => AppColors.amber,
      };

  @override
  Widget build(BuildContext context) {
    final meetsReqs = _meetsRequirements();
    final forecast = forecastFor(option, messenger);

    final textColor = meetsReqs ? AppColors.textPrimary : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: meetsReqs,
      child: GestureDetector(
        onTap: () {
          if (!meetsReqs) {
            showGameSnack(
                context, option.lockedHint ?? 'Te falta habilidad para esto.',
                isError: true);
            return;
          }
          AppFeedback.tap();
          onTap();
        },
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.985,
          duration: AppMotion.of(context, AppMotion.base),
          curve: AppMotion.pop,
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.base),
            curve: AppMotion.enter,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: !meetsReqs
                  ? AppGradients.disabled
                  : isSelected
                      ? AppGradients.optionSelected
                      : isSecret
                          ? AppGradients.optionSecret
                          : AppGradients.option,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.gold
                    : isSecret
                        ? AppColors.purple
                        : AppColors.bgLine,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.25),
                          blurRadius: 16)
                    ]
                  : const [],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AnimatedContainer(
                  duration: AppMotion.of(context, AppMotion.base),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.gold : AppColors.outline,
                    border: Border.all(
                        color: isSelected
                            ? AppColors.gold
                            : meetsReqs
                                ? AppColors.textMuted
                                : AppColors.bgLine,
                        width: 2.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          color: AppColors.outline, size: 15)
                      : meetsReqs
                          ? null
                          : const Icon(Icons.lock,
                              color: AppColors.textMuted, size: 12),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(option.text,
                        style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: 14, height: 1.45, color: textColor))),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                // El riesgo existía en el dominio pero nunca se mostraba:
                // sin esto el jugador elige a ciegas.
                RiskChip(level: forecast.effectiveRisk),
                if (option.timeCostMinutes > 0)
                  GameChip(_timeLabel(option.timeCostMinutes),
                      icon: Icons.schedule, color: AppColors.amber),
                ...option.requiredSkills.entries.map((e) {
                  final met = messenger != null &&
                      messenger!.skillLevel(e.key) >=
                          e.value - SkillPerks.gatingDiscount(e.key, messenger!);
                  return GameChip('${e.key.label} Nv.${e.value}',
                      icon: skillIconData(e.key),
                      trailingIcon: met ? Icons.check : null,
                      color: met ? AppColors.green : AppColors.purple);
                }),
              ]),
              if (meetsReqs) ...[
                const SizedBox(height: AppSpacing.sm),
                // Pronóstico: traduce la fórmula a algo que se pueda leer.
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(_forecastIcon(forecast.band),
                      size: 14, color: _forecastColor(forecast.band)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(forecast.reason,
                        style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.35,
                            color: _forecastColor(forecast.band))),
                  ),
                ]),
              ],
              if (isSecret && meetsReqs) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.purple, size: 14),
                  const SizedBox(width: 6),
                  Text('Tu historia abrió este camino',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary)),
                ]),
              ],
              if (!meetsReqs) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                    // Candado narrativo si es por reputación.
                    option.lockedHint ?? 'Te falta habilidad para esto.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  static String _timeLabel(int minutes) {
    if (minutes < 60) return '+${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '+${h}h' : '+${h}h${m}m';
  }
}

// ─── Outcome View ─────────────────────────────────────────────────────────────
class _OutcomeView extends StatelessWidget {
  final EventResolution resolution;
  final bool isTutorial;
  final VoidCallback onContinue;

  const _OutcomeView({
    super.key,
    required this.resolution,
    required this.isTutorial,
    required this.onContinue,
  });

  EventOutcome get outcome => resolution.outcome;
  bool get missionComplete => resolution.missionComplete;
  List<SkillType> get leveledUpSkills => resolution.leveledUpSkills;
  Map<Faction, int>? get repDelta => resolution.repDelta;

  @override
  Widget build(BuildContext context) {
    final isFail = outcome.type == OutcomeType.fail;
    final (icon, title, grad, color) = switch (outcome.type) {
      OutcomeType.success => (
          Icons.emoji_events,
          '¡ÉXITO!',
          AppGradients.green,
          AppColors.green
        ),
      OutcomeType.partial => (
          Icons.bolt,
          'ÉXITO PARCIAL',
          AppGradients.gold,
          AppColors.gold
        ),
      OutcomeType.fail => (
          Icons.close_rounded,
          'FALLASTE',
          AppGradients.red,
          AppColors.red
        ),
    };

    final reduced = AppMotion.reduced(context);
    Duration d(int ms) => AppMotion.of(context, Duration(milliseconds: ms));
    // Escalonado de la revelación: sello → título → relato → detalles.
    Duration at(int ms) => reduced ? Duration.zero : Duration(milliseconds: ms);

    // Sello grande — entra con elasticidad; brilla si ganaste, tiembla si no.
    Widget stamp = Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        gradient: grad,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 4),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.55),
              blurRadius: 46,
              spreadRadius: 8)
        ],
      ),
      child: Center(child: Icon(icon, size: 58, color: AppColors.parchment)),
    );
    stamp = reduced
        ? stamp.animate().fadeIn(duration: d(200))
        : isFail
            ? stamp
                .animate(onComplete: (_) => AppFeedback.impact())
                .scale(
                    begin: const Offset(1.6, 1.6),
                    duration: 350.ms,
                    curve: AppMotion.exit)
                .fade(duration: 200.ms)
                .then()
                .shake(hz: 6, duration: 500.ms)
            : stamp
                .animate()
                .scale(
                    begin: const Offset(0.3, 0.3),
                    duration: 600.ms,
                    curve: Curves.elasticOut)
                .fade(duration: 300.ms)
                .then()
                .shimmer(duration: 800.ms, color: AppColors.parchment);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.sm),
            stamp,

            const SizedBox(height: 26),

            Text(title,
                    style: AppTextStyles.fredoka(34,
                        color: color,
                        weight: FontWeight.bold,
                        letterSpacing: 1.5))
                .animate(delay: at(250))
                .fadeIn(duration: d(200))
                .scale(
                    begin: reduced ? const Offset(1, 1) : const Offset(1.5, 1.5),
                    duration: d(350),
                    curve: AppMotion.pop),

            const SizedBox(height: AppSpacing.lg),

            // La narrativa del resultado: texto grande, alto contraste.
            GameCard(
              borderColor: color.withValues(alpha: 0.4),
              child: Text(outcome.narrative,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 15,
                    height: 1.65,
                    color: AppColors.parchment,
                  ),
                  textAlign: TextAlign.center),
            )
                .animate(delay: at(450))
                .fadeIn(duration: d(300))
                .slideY(begin: 0.2, end: 0, curve: AppMotion.enter),

            // Level-up de skills: el momento más festejado de la pantalla.
            if (leveledUpSkills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              ...leveledUpSkills.toSet().map((skill) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _LevelUpBanner(skill: skill)
                        .animate(
                            delay: at(650),
                            onPlay: (_) => AppFeedback.impact())
                        .fadeIn(duration: d(200))
                        .scale(
                            begin: reduced
                                ? const Offset(1, 1)
                                : const Offset(0.6, 0.6),
                            duration: d(450),
                            curve: Curves.elasticOut)
                        .then()
                        .shimmer(
                            duration: d(900), color: AppColors.parchment),
                  )),
            ],

            // Mission complete banner
            if (missionComplete) ...[
              const SizedBox(height: AppSpacing.lg),
              GameCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                gradient: isTutorial ? AppGradients.tutorialCard : AppGradients.blue,
                borderColor: isTutorial
                    ? AppColors.amber.withValues(alpha: 0.5)
                    : AppColors.gold.withValues(alpha: 0.4),
                child: Row(children: [
                  Icon(isTutorial ? Icons.emoji_events : Icons.auto_awesome,
                      color: isTutorial ? AppColors.amber : AppColors.gold,
                      size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                    isTutorial
                        ? '¡Varus está satisfecho! Siguiente prueba desbloqueada.'
                        : '¡Misión completada! Resultado disponible en tu perfil.',
                    style: AppTextStyles.fredoka(13,
                        color: isTutorial ? AppColors.amber : AppColors.gold),
                  )),
                ]),
              )
                  .animate(delay: at(700))
                  .fadeIn(duration: d(300))
                  .slideY(begin: 0.2, end: 0),
            ],

            if (outcome.healthDelta != 0 ||
                outcome.timeDeltaMinutes != 0 ||
                (repDelta?.isNotEmpty ?? false) ||
                (outcome.xpGained > 0 && outcome.usedSkill != null) ||
                resolution.journalNote != null ||
                resolution.flagsSet.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  if (outcome.healthDelta != 0)
                    GameChip(
                      '${outcome.healthDelta > 0 ? '+' : ''}${outcome.healthDelta} salud',
                      icon: Icons.favorite,
                      size: GameChipSize.medium,
                      color: outcome.healthDelta > 0
                          ? AppColors.green
                          : AppColors.red,
                    ),
                  if (outcome.timeDeltaMinutes != 0)
                    GameChip(
                      '+${outcome.timeDeltaMinutes}m de viaje',
                      icon: Icons.timer_outlined,
                      size: GameChipSize.medium,
                      color: AppColors.riskMed,
                    ),
                  // El mundo recuerda: cambios de reputación de la decisión.
                  ...?repDelta?.entries.map((e) => GameChip(
                        '${e.value > 0 ? '+' : ''}${e.value} ${e.key.label}',
                        icon: e.value > 0
                            ? Icons.thumb_up_alt_outlined
                            : Icons.thumb_down_alt_outlined,
                        size: GameChipSize.medium,
                        color: e.value > 0 ? AppColors.sky : AppColors.riskMed,
                      )),
                  // XP ganado (antes solo se veía si justo subías de nivel)
                  if (outcome.xpGained > 0 && outcome.usedSkill != null)
                    GameChip(
                      '+${outcome.xpGained} XP de ${outcome.usedSkill!.label}',
                      icon: Icons.school_outlined,
                      size: GameChipSize.medium,
                      color: AppColors.sky,
                    ),
                  // El mundo tomó nota: flags y diario dejaban de ser invisibles.
                  if (resolution.journalNote != null ||
                      resolution.flagsSet.isNotEmpty)
                    GameChip(
                      resolution.journalNote != null
                          ? 'Quedó anotado en tu diario'
                          : 'Roma no se olvida de esto',
                      icon: Icons.menu_book_outlined,
                      size: GameChipSize.medium,
                      color: AppColors.purple,
                    ),
                ]
                    .animate(interval: AppMotion.stagger, delay: at(700))
                    .fadeIn(duration: d(250))
                    .slideY(begin: 0.3, end: 0, curve: AppMotion.enter),
              ),
            ],

            // ── Por qué pasó ──────────────────────────────────────────────
            // El desglose de la tirada. Es lo que le enseña al jugador qué
            // mirar la próxima vez: la habilidad suma, el riesgo resta,
            // la fatiga castiga y el camino siempre mete la cola.
            const SizedBox(height: AppSpacing.lg),
            _WhyItHappened(resolution: resolution)
                .animate(delay: at(850))
                .fadeIn(duration: d(300))
                .slideY(begin: 0.15, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: GameButton(
                label: missionComplete ? 'IR AL HOME' : 'CONTINUAR',
                fontSize: 20,
                onTap: onContinue,
              ),
            )
                .animate(delay: at(950))
                .fadeIn(duration: d(300))
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

/// "¡Velocidad subió de nivel!" — un sello dorado con el ícono de la skill.
class _LevelUpBanner extends StatelessWidget {
  final SkillType skill;
  const _LevelUpBanner({required this.skill});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppGradients.gold,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.outline, width: 2.5),
          boxShadow: const [
            BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 4)),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                color: AppColors.outline, shape: BoxShape.circle),
            child: Icon(skillIconData(skill), color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¡SUBISTE DE NIVEL!',
                style: AppTextStyles.fredoka(12,
                    color: AppColors.outline,
                    weight: FontWeight.bold,
                    letterSpacing: 1)),
            Text(skill.label,
                style: AppTextStyles.fredoka(17,
                    color: AppColors.outline, weight: FontWeight.bold)),
          ]),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.arrow_upward_rounded,
              color: AppColors.outline, size: 22),
        ]),
      );
}

// ─── Por qué pasó ─────────────────────────────────────────────────────────────
// Traduce la tirada a una lista legible. No es la fórmula desnuda: es el
// relato de qué pesó a favor y qué en contra.
class _WhyItHappened extends StatelessWidget {
  final EventResolution resolution;
  const _WhyItHappened({required this.resolution});

  @override
  Widget build(BuildContext context) {
    final factors = resolution.scoreFactors;
    if (factors.isEmpty) return const SizedBox.shrink();

    return GameCard(
      borderColor: AppColors.bgLine,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.balance, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Text('POR QUÉ PASÓ',
              style: AppTextStyles.fredoka(12,
                  color: AppColors.textSecondary, letterSpacing: 1.2)),
        ]),
        const SizedBox(height: 10),
        ...factors.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(children: [
                Expanded(
                  child: Text(f.label,
                      style: AppTextStyles.bodyMedium),
                ),
                Text(
                  f.value >= 0 ? '+${f.value}' : '−${f.value.abs()}',
                  style: AppTextStyles.fredoka(13,
                      color: f.value >= 0
                          ? AppColors.riskLow
                          : AppColors.riskMed,
                      weight: FontWeight.bold),
                ),
              ]),
            )),
        const Divider(color: AppColors.bgLine, height: 16),
        Row(children: [
          Expanded(
            child: Text('Tu tirada',
                style: AppTextStyles.fredoka(12,
                    color: AppColors.textPrimary, weight: FontWeight.bold)),
          ),
          Text('${resolution.score}',
              style: AppTextStyles.fredoka(15,
                  color: AppColors.gold, weight: FontWeight.bold)),
        ]),
        const SizedBox(height: 4),
        Text(
          _threshold(resolution.score),
          style: AppTextStyles.bodySmall.copyWith(height: 1.35),
        ),
      ]),
    );
  }

  /// Qué habría hecho falta: la lección concreta que se lleva el jugador.
  String _threshold(int score) {
    if (score >= 55) return 'Con 55 alcanzaba para salir bien parado.';
    if (score >= 30) {
      return 'Con 55 salía redondo: te faltaron ${55 - score}.';
    }
    return 'Desde 30 era un éxito parcial: te faltaron ${30 - score}.';
  }
}

/// Vuelve a donde estaba el jugador (Home o la pantalla de misión).
void _leaveEventScreen(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}
