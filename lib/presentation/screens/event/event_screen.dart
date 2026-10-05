import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
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
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (state) {
        // El resultado se muestra aunque la misión ya no tenga eventos
        // pendientes (o haya cambiado tras recargar el Home).
        if (_resolution != null) {
          return GradientScaffold(
            useEventBg: true,
            body: _OutcomeView(
              resolution: _resolution!,
              isTutorial: _resolvedTutorial,
              onContinue: () => _leaveEventScreen(context),
            ),
          );
        }

        final slot = state.slotFor(widget.messengerId);
        final event = slot?.pendingEvent;
        final mission = slot?.activeMission;

        if (event == null || mission == null) {
          return Scaffold(
            backgroundColor: AppColors.bgDeep,
            body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.green, size: 56),
                    const SizedBox(height: 12),
                    Text('No hay eventos pendientes',
                        style: AppTextStyles.titleLarge),
                    const SizedBox(height: 20),
                    GameButton(
                        label: 'Volver',
                        onTap: () => _leaveEventScreen(context),
                        fontSize: 16),
                  ]),
            ),
          );
        }

        return GradientScaffold(
          useEventBg: true,
          body: Container(
            color: Colors.transparent,
            child: _DecisionView(
                    event: event,
                    mission: mission,
                    messenger: slot?.messenger,
                    world: world,
                    selected: _selected,
                    resolving: _resolving,
                    onSelect: (opt) => setState(() => _selected = opt),
                    onConfirm: () => _confirm(mission, event),
                  ),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
      return;
    }

    // Feedback físico + SFX: que el resultado se SIENTA.
    final sfx = ref.read(sfxServiceProvider);
    switch (result.outcome.type) {
      case OutcomeType.success:
        HapticFeedback.heavyImpact();
        sfx.playSuccess();
      case OutcomeType.partial:
        HapticFeedback.mediumImpact();
        sfx.playPartial();
      case OutcomeType.fail:
        HapticFeedback.vibrate();
        sfx.playFail();
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
        _buildHeader(context),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            children: [
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
                              delay: Duration(milliseconds: 80 + e.key * 70))
                          .fadeIn()
                          .slideX(begin: 0.08, end: 0),
                    ),
                  ),
            ],
          ),
        ),
        _buildConfirmArea(),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F0000), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border:
            Border(bottom: BorderSide(color: AppColors.red.withValues(alpha: 0.4))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => _leaveEventScreen(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white60, size: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white70, size: 13),
                const SizedBox(width: 4),
                Text(
                  mission.isTutorial ? 'PRUEBA DE VARUS' : 'EVENTO CRÍTICO',
                  style: AppTextStyles.fredoka(10,
                      color: Colors.red[100]!, letterSpacing: 1),
                ),
              ]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black38, width: 2),
              boxShadow: const [
                BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 3))
              ],
            ),
            child: _DecisionCountdown(deadline: event.deadlineAt),
          ),
        ]),
        const SizedBox(height: 12),
        Text(event.title,
            style: AppTextStyles.fredoka(22, color: Colors.white)),
        const SizedBox(height: 6),
        // La narrativa es el corazón del juego: texto grande y claro,
        // siempre casi-blanco sobre el header rojo.
        Text(event.description,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 15,
              height: 1.55,
              color: const Color(0xFFF7EFDC),
            )),
      ]),
    );
  }

  Widget _buildConfirmArea() {
    final canConfirm = selected != null && !resolving;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.bgLine)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: GameButton(
          label: resolving ? 'Resolviendo...' : 'CONFIRMAR DECISIÓN',
          gradient: canConfirm
              ? AppGradients.green
              : const LinearGradient(
                  colors: [Color(0xFF546E7A), Color(0xFF37474F)]),
          shadowColor:
              canConfirm ? AppColors.greenShadow : const Color(0xFF1A2A30),
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
class _DecisionCountdown extends StatefulWidget {
  final DateTime deadline;
  const _DecisionCountdown({required this.deadline});

  @override
  State<_DecisionCountdown> createState() => _DecisionCountdownState();
}

class _DecisionCountdownState extends State<_DecisionCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.deadline.difference(DateTime.now());
    final label = left.isNegative
        ? 'SE TE PASÓ'
        : left.inHours > 0
            ? '${left.inHours}h ${left.inMinutes % 60}m'
            : left.inMinutes > 0
                ? '${left.inMinutes}m ${left.inSeconds % 60}s'
                : '${left.inSeconds}s';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.timer_outlined, color: Colors.black87, size: 13),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.fredoka(13, color: Colors.black87)),
    ]);
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

    return GestureDetector(
      onTap: meetsReqs ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF1A4E9A), Color(0xFF103060)])
              : isSecret
                  ? const LinearGradient(
                      colors: [Color(0xFF2A1A4A), Color(0xFF1A1136)])
                  : const LinearGradient(
                      colors: [Color(0xFF1A2A4A), Color(0xFF111E36)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : isSecret
                    ? AppColors.purple.withValues(alpha: 0.7)
                    : meetsReqs
                        ? AppColors.bgLine
                        : AppColors.bgLine.withValues(alpha: 0.4),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25), blurRadius: 16)
                ]
              : [],
        ),
        child: Opacity(
          opacity: meetsReqs ? 1.0 : 0.5,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.gold : Colors.transparent,
                  border: Border.all(
                      color: isSelected ? AppColors.gold : Colors.white30,
                      width: 2.5),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 13)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(option.text,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontSize: 14, height: 1.45))),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              // El riesgo existía en el dominio pero nunca se mostraba:
              // sin esto el jugador elige a ciegas.
              RiskChip(level: forecast.effectiveRisk),
              if (option.timeCostMinutes > 0)
                _TimeTag(minutes: option.timeCostMinutes),
              ...option.requiredSkills.entries.map((e) => _SkillTag(
                    skill: e.key,
                    level: e.value,
                    met: messenger != null &&
                        messenger!.skillLevel(e.key) >=
                            e.value -
                                SkillPerks.gatingDiscount(e.key, messenger!),
                  )),
            ]),
            if (meetsReqs) ...[
              const SizedBox(height: 8),
              // Pronóstico: traduce la fórmula a algo que se pueda leer.
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(_forecastIcon(forecast.band),
                    size: 13, color: _forecastColor(forecast.band)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(forecast.reason,
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 11.5,
                          height: 1.35,
                          color: _forecastColor(forecast.band))),
                ),
              ]),
            ],
            if (isSecret && meetsReqs) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.purple, size: 13),
                const SizedBox(width: 5),
                Text('Tu historia abrió este camino',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontSize: 11, color: AppColors.purple)),
              ]),
            ],
            if (!meetsReqs) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.lock, color: Colors.white38, size: 13),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                      // Candado narrativo si es por reputación.
                      option.lockedHint ?? 'Habilidad insuficiente',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontSize: 11, color: Colors.white38)),
                ),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

class _TimeTag extends StatelessWidget {
  final int minutes;
  const _TimeTag({required this.minutes});

  String get _label {
    if (minutes < 60) return '+${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '+${h}h' : '+${h}h${m}m';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.5), width: 2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.schedule, size: 11, color: AppColors.amber),
          const SizedBox(width: 3),
          Text(_label,
              style: AppTextStyles.fredoka(10, color: AppColors.amber)),
        ]),
      );
}

class _SkillTag extends StatelessWidget {
  final SkillType skill;
  final int level;
  final bool met;
  const _SkillTag(
      {required this.skill, required this.level, required this.met});

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.green : AppColors.purple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('${skill.label} Nv.$level',
            style: AppTextStyles.fredoka(10, color: color)),
        if (met) ...[
          const SizedBox(width: 3),
          Icon(Icons.check, size: 11, color: color),
        ],
      ]),
    );
  }
}

// ─── Outcome View ─────────────────────────────────────────────────────────────
class _OutcomeView extends StatelessWidget {
  final EventResolution resolution;
  final bool isTutorial;
  final VoidCallback onContinue;

  const _OutcomeView({
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

    // Sello grande — entra con elasticidad; brilla si ganaste, tiembla si no.
    Widget stamp = Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        gradient: grad,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black38, width: 4),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.55),
              blurRadius: 46,
              spreadRadius: 8)
        ],
      ),
      child: Center(child: Icon(icon, size: 58, color: Colors.white)),
    );
    stamp = isFail
        ? stamp
            .animate()
            .scale(
                begin: const Offset(1.6, 1.6),
                duration: 350.ms,
                curve: Curves.easeInCubic)
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
            .shimmer(duration: 800.ms, color: Colors.white54);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            stamp,

            const SizedBox(height: 26),

            Text(title,
                    style: AppTextStyles.fredoka(34,
                        color: color,
                        weight: FontWeight.bold,
                        letterSpacing: 1.5))
                .animate(delay: 250.ms)
                .fadeIn()
                .scale(
                    begin: const Offset(1.5, 1.5),
                    duration: 350.ms,
                    curve: Curves.easeOutBack),

            const SizedBox(height: 16),

            // La narrativa del resultado: texto grande, alto contraste.
            GameCard(
              borderColor: color.withValues(alpha: 0.4),
              child: Text(outcome.narrative,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 15,
                    height: 1.65,
                    color: const Color(0xFFF7EFDC),
                  ),
                  textAlign: TextAlign.center),
            ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.2, end: 0),

            // Mission complete banner
            if (missionComplete) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isTutorial
                      ? const LinearGradient(
                          colors: [Color(0xFF2E1E00), Color(0xFF1E1400)])
                      : AppGradients.blue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTutorial
                        ? AppColors.amber.withValues(alpha: 0.4)
                        : AppColors.gold.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
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
              ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2, end: 0),
            ],

            if (outcome.healthDelta != 0 ||
                outcome.timeDeltaMinutes != 0 ||
                (repDelta?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (outcome.healthDelta != 0)
                    _ConsequenceChip(
                      icon: Icons.favorite,
                      label:
                          '${outcome.healthDelta > 0 ? '+' : ''}${outcome.healthDelta} salud',
                      color: outcome.healthDelta > 0
                          ? AppColors.green
                          : AppColors.red,
                    ),
                  if (outcome.timeDeltaMinutes != 0)
                    _ConsequenceChip(
                      icon: Icons.timer_outlined,
                      label: '-${outcome.timeDeltaMinutes}m del plazo',
                      color: AppColors.riskMed,
                    ),
                  // El mundo recuerda: cambios de reputación de la decisión.
                  ...?repDelta?.entries.map((e) => _ConsequenceChip(
                        icon: e.value > 0
                            ? Icons.thumb_up_alt_outlined
                            : Icons.thumb_down_alt_outlined,
                        label:
                            '${e.value > 0 ? '+' : ''}${e.value} ${e.key.label}',
                        color:
                            e.value > 0 ? AppColors.sky : AppColors.riskMed,
                      )),
                ],
              ).animate(delay: 700.ms).fadeIn(),
            ],

            // ── Por qué pasó ──────────────────────────────────────────────
            // El desglose de la tirada. Es lo que le enseña al jugador qué
            // mirar la próxima vez: la habilidad suma, el riesgo resta,
            // la fatiga castiga y el camino siempre mete la cola.
            const SizedBox(height: 16),
            _WhyItHappened(resolution: resolution)
                .animate(delay: 750.ms)
                .fadeIn()
                .slideY(begin: 0.15, end: 0),

            // XP ganado (antes solo se veía si justo subías de nivel)
            if (outcome.xpGained > 0 && outcome.usedSkill != null) ...[
              const SizedBox(height: 12),
              _ConsequenceChip(
                icon: Icons.school_outlined,
                label:
                    '+${outcome.xpGained} XP de ${outcome.usedSkill!.label}',
                color: AppColors.sky,
              ).animate(delay: 780.ms).fadeIn(),
            ],

            // El mundo tomó nota: flags y diario dejaban de ser invisibles.
            if (resolution.journalNote != null ||
                resolution.flagsSet.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ConsequenceChip(
                icon: Icons.menu_book_outlined,
                label: resolution.journalNote != null
                    ? 'Quedó anotado en tu diario'
                    : 'Roma no se olvida de esto',
                color: AppColors.purple,
              ).animate(delay: 800.ms).fadeIn(),
            ],

            // Level-up de skills
            if (leveledUpSkills.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...leveledUpSkills.toSet().map((skill) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black38, width: 2),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.goldShadow, offset: Offset(0, 3))
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.arrow_upward_rounded,
                          color: Colors.black87, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '¡${skill.label} subió de nivel!',
                        style: AppTextStyles.fredoka(15, color: Colors.black87),
                      ),
                    ]),
                  ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2, end: 0)),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: GameButton(
                label: missionComplete ? 'IR AL HOME' : 'CONTINUAR',
                gradient: grad,
                shadowColor: color.withValues(alpha: 0.5),
                fontSize: 20,
                onTap: onContinue,
              ),
            ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
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
              style: AppTextStyles.fredoka(11,
                  color: AppColors.textSecondary, letterSpacing: 1.2)),
        ]),
        const SizedBox(height: 10),
        ...factors.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(children: [
                Expanded(
                  child: Text(f.label,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
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

class _ConsequenceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ConsequenceChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.fredoka(13, color: color)),
        ]),
      );
}

/// Vuelve a donde estaba el jugador (Home o la pantalla de misión).
void _leaveEventScreen(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}
