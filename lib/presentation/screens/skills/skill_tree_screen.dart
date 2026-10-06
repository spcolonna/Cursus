import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/messenger_avatar.dart';
import '../../widgets/skill_tree_board.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/skill_tree.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../infrastructure/progress/player_progress.dart';

// ─── Caminos del Mensajero ───────────────────────────────────────────────────
// Árbol de habilidades: 5 caminos de 10 niveles con nombre y perk.
// Niveles 1-5 se ganan jugando (XP). Niveles 6-10 se ascienden con Sellos
// del Gremio (contratos diarios, racha, nota S… o comprándolos a futuro).
class SkillTreeScreen extends ConsumerStatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  ConsumerState<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends ConsumerState<SkillTreeScreen> {
  String? _selectedMessengerId;
  final Set<SkillType> _expanded = {};
  bool _ascending = false;
  SkillType _focus = SkillType.speed;

  /// Último nodo lacrado, para animar la caída del sello en el árbol.
  (SkillType, int)? _stamp;

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);

    return GradientScaffold(
      body: homeAsync.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
            error: e, onRetry: () => ref.read(homeProvider.notifier).refresh()),
        data: (state) {
          if (state.slots.isEmpty) {
            return Center(
                child: Text('Sin mensajero', style: AppTextStyles.titleLarge));
          }
          final primary = state.slots.first.messenger;
          final selected = state.slots
                  .where((s) => s.messenger.id == _selectedMessengerId)
                  .firstOrNull
                  ?.messenger ??
              primary;

          return SafeArea(
            child: Column(children: [
              _buildHeader(context, primary),
              if (state.slots.length > 1)
                _MessengerSelector(
                  slots: state.slots.map((s) => s.messenger).toList(),
                  selectedId: selected.id,
                  onSelect: (id) =>
                      setState(() => _selectedMessengerId = id),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  children: [
                    _IntroCard()
                        .animate()
                        .fadeIn()
                        .slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 14),
                    if (skillPicksOf(primary) > 0) ...[
                      _SkillPickCard(
                        picks: skillPicksOf(primary),
                        messenger: selected,
                        busy: _ascending,
                        onPick: (skill) => _usePick(selected, skill),
                      ),
                      const SizedBox(height: 14),
                    ],
                    SkillTreeBoard(
                      messenger: selected,
                      focus: _focus,
                      stamp: _stamp,
                      onFocus: (skill) => setState(() => _focus = skill),
                    )
                        .animate(delay: AppMotion.stagger)
                        .fadeIn(duration: AppMotion.of(context, AppMotion.base))
                        .slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 12),
                    // Detalle del camino elegido: perk, próximo nivel y
                    // ascenso con Sellos.
                    AnimatedSwitcher(
                      duration: AppMotion.of(context, AppMotion.base),
                      switchInCurve: AppMotion.enter,
                      switchOutCurve: AppMotion.exit,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween(
                                  begin: const Offset(0, 0.04),
                                  end: Offset.zero)
                              .animate(anim),
                          child: child,
                        ),
                      ),
                      child: _PathCard(
                        key: ValueKey(_focus),
                        skill: _focus,
                        messenger: selected,
                        seals: primary.seals,
                        expanded: _expanded.contains(_focus),
                        ascending: _ascending,
                        onToggle: () => setState(() {
                          _expanded.contains(_focus)
                              ? _expanded.remove(_focus)
                              : _expanded.add(_focus);
                        }),
                        onAscend: () => _ascend(selected, _focus),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Messenger primary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        gradient: AppGradients.header,
        border: Border(bottom: BorderSide(color: AppColors.paperLine)),
      ),
      child: Row(children: [
        GameBackButton(
          onTap: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Text('Caminos del Mensajero', style: AppTextStyles.titleLarge)),
        // Sellos del Gremio
        CurrencyChip(type: CurrencyType.seals, value: primary.seals),
      ]),
    );
  }

  Future<void> _usePick(Messenger messenger, SkillType skill) async {
    if (_ascending) return;
    setState(() => _ascending = true);
    try {
      await ref.read(homeProvider.notifier).useSkillPick(
            messengerId: messenger.id,
            skill: skill,
          );
      await ref
          .read(primerosPasosProvider.notifier)
          .markTask(PlayerProgress.taskLevelSkill);
      AppFeedback.levelUp();
      if (mounted) {
        final node = skillNode(skill, messenger.skillLevel(skill) + 1);
        setState(() {
          _focus = skill;
          _stamp = (skill, messenger.skillLevel(skill) + 1);
        });
        await showGameDialog(
          context,
          builder: (_) => _AscendedDialog(skill: skill, node: node),
        );
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _ascending = false);
    }
  }

  Future<void> _ascend(Messenger messenger, SkillType skill) async {
    if (_ascending) return;
    setState(() => _ascending = true);
    try {
      await ref.read(homeProvider.notifier).ascendSkill(
            messengerId: messenger.id,
            skill: skill,
          );
      await ref
          .read(primerosPasosProvider.notifier)
          .markTask(PlayerProgress.taskLevelSkill);
      AppFeedback.seal();
      if (mounted) {
        final node = skillNode(skill, messenger.skillLevel(skill) + 1);
        setState(() => _stamp = (skill, messenger.skillLevel(skill) + 1));
        await showGameDialog(
          context,
          builder: (_) => _AscendedDialog(skill: skill, node: node),
        );
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _ascending = false);
    }
  }
}

// ─── Niveles a elección (Pack del Guerrero) ───────────────────────────────────
class _SkillPickCard extends StatelessWidget {
  final int picks;
  final Messenger messenger;
  final bool busy;
  final ValueChanged<SkillType> onPick;
  const _SkillPickCard({
    required this.picks,
    required this.messenger,
    required this.busy,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.military_tech, color: AppColors.sienna, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                picks == 1
                    ? 'Tenés 1 nivel para elegir'
                    : 'Tenés $picks niveles para elegir',
                style: AppTextStyles.ui(15,
                    color: AppColors.sienna, weight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 4),
        Text('Se aplica a ${messenger.name}. Hasta nivel $kMaxSkillLevel.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.inkSoft, fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final skill in SkillType.values)
            if (messenger.skillLevel(skill) < kMaxSkillLevel)
              ActionChip(
                label: Text(
                    '${skill.label} ${messenger.skillLevel(skill)} → ${messenger.skillLevel(skill) + 1}'),
                onPressed: busy ? null : () => onPick(skill),
              ),
        ]),
      ]),
    );
  }
}

// ─── Intro compacta ───────────────────────────────────────────────────────────
class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: paperTint(AppColors.tyrian),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.tyrian.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(children: [
          const Icon(Icons.workspace_premium,
              color: AppColors.tyrian, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Niveles 1-5 se ganan jugando. Los niveles 6-10 se ascienden '
              'con Sellos del Gremio: contratos del día, rachas y notas S. '
              'Los Sellos son de la cuenta: los comparten todos tus mensajeros.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.ink, height: 1.4),
            ),
          ),
        ]),
      );
}

// ─── Selector de mensajero (si hay más de uno) ────────────────────────────────
class _MessengerSelector extends StatelessWidget {
  final List<Messenger> slots;
  final String selectedId;
  final ValueChanged<String> onSelect;
  const _MessengerSelector(
      {required this.slots, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        children: slots.map((m) {
          final selected = m.id == selectedId;
          final accent = messengerAccent(m.slotIndex);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(m.id),
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(6, 4, 14, 4),
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withValues(alpha: 0.18)
                      : AppColors.paperDeep,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? accent : AppColors.paperLine, width: 2),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  MessengerAvatar.from(m, size: 30),
                  const SizedBox(width: 8),
                  Text(m.name,
                      style: AppTextStyles.ui(13,
                          color: selected
                              ? AppColors.ink
                              : AppColors.inkSoft,
                          weight: FontWeight.bold)),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Card de un camino ────────────────────────────────────────────────────────
class _PathCard extends StatelessWidget {
  final SkillType skill;
  final Messenger messenger;
  final int seals; // sellos de la cuenta (mensajero principal)
  final bool expanded;
  final bool ascending;
  final VoidCallback onToggle;
  final VoidCallback onAscend;

  const _PathCard({
    super.key,
    required this.skill,
    required this.messenger,
    required this.seals,
    required this.expanded,
    required this.ascending,
    required this.onToggle,
    required this.onAscend,
  });

  Color get _color => switch (skill) {
        SkillType.speed => AppColors.egyptianBlue,
        SkillType.stealth => AppColors.tyrian,
        SkillType.combat => AppColors.cinnabar,
        SkillType.survival => AppColors.verdigris,
        SkillType.contacts => AppColors.ochreDeep,
      };

  IconData get _icon => switch (skill) {
        SkillType.speed => Icons.bolt,
        SkillType.stealth => Icons.visibility_off,
        SkillType.combat => Icons.shield,
        SkillType.survival => Icons.eco,
        SkillType.contacts => Icons.people,
      };

  @override
  Widget build(BuildContext context) {
    final level = messenger.skillLevel(skill);
    final node = skillNode(skill, level);
    final isMax = level >= kMaxSkillLevelElite;

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: level >= 6 ? AppColors.tyrian.withValues(alpha: 0.7) : _color.withValues(alpha: 0.5),
            width: 2),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowSoft, offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: Column(children: [
        // Cabecera (tap = expandir)
        GestureDetector(
          onTap: () {
            AppFeedback.tap();
            onToggle();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _color, width: 2),
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(skill.label,
                            style: AppTextStyles.ui(15,
                                color: AppColors.ink,
                                weight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        GameChip('Nv.$level/10',
                            color: level >= 6 ? AppColors.tyrian : _color),
                      ]),
                      const SizedBox(height: 3),
                      Text('«${node.name}»',
                          style: AppTextStyles.proseItalic(size: 13)),
                    ]),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: AppMotion.of(context, AppMotion.base),
                child: const Icon(Icons.expand_more,
                    color: AppColors.inkMuted, size: 24),
              ),
            ]),
          ),
        ),

        // Progreso hacia el siguiente nivel
        if (!isMax)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: _NextLevelRow(
              skill: skill,
              messenger: messenger,
              seals: seals,
              color: _color,
              ascending: ascending,
              onAscend: onAscend,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: AppGradients.tyrian,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Center(
                child: Text('CAMINO COMPLETADO',
                    style: AppTextStyles.ui(13,
                        color: AppColors.paper,
                        weight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ),
          ),

        // Lista completa de nodos
        AnimatedSize(
          duration: AppMotion.of(context, AppMotion.base),
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: !expanded
              ? const SizedBox(width: double.infinity)
              : Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.paperLine)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              children: skillTree[skill]!
                  .map((n) => _NodeRow(
                        node: n,
                        state: n.level <= level
                            ? _NodeState.unlocked
                            : n.level == level + 1
                                ? _NodeState.next
                                : _NodeState.locked,
                        color: _color,
                      ))
                  .toList(),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Fila del siguiente nivel (XP o ascenso con Sellos) ───────────────────────
class _NextLevelRow extends StatelessWidget {
  final SkillType skill;
  final Messenger messenger;
  final int seals;
  final Color color;
  final bool ascending;
  final VoidCallback onAscend;

  const _NextLevelRow({
    required this.skill,
    required this.messenger,
    required this.seals,
    required this.color,
    required this.ascending,
    required this.onAscend,
  });

  @override
  Widget build(BuildContext context) {
    final level = messenger.skillLevel(skill);
    final next = skillNode(skill, level + 1);

    // Niveles 2-5: progreso por XP jugando.
    if (level < kMaxSkillLevel) {
      final xp = messenger.skillXp[skill] ?? 0;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Siguiente: «${next.name}» — ${next.perk}',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.ink)),
        const SizedBox(height: 8),
        _LevelDelta(skill: skill, level: level, color: color),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(children: [
                Container(height: 8, color: AppColors.paperShade),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                      begin: 0, end: (xp / kXpPerSkillLevel).clamp(0.0, 1.0)),
                  duration: AppMotion.of(context, AppMotion.slow * 2),
                  curve: AppMotion.enter,
                  builder: (_, v, __) => FractionallySizedBox(
                    widthFactor: v,
                    child: Container(height: 8, color: color),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Text('$xp/$kXpPerSkillLevel XP',
              style: AppTextStyles.ui(12,
                  color: GameChip.legibleText(color))),
        ]),
      ]);
    }

    // Niveles 6-10: ascenso con Sellos.
    final cost = sealCostForLevel[level + 1] ?? 999;
    final canAfford = seals >= cost;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.workspace_premium, color: AppColors.tyrian, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text('Ascenso: «${next.name}»',
              style: AppTextStyles.ui(13, weight: FontWeight.bold)),
        ),
      ]),
      const SizedBox(height: 2),
      Text(next.perk,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.ink)),
      const SizedBox(height: 8),
      _LevelDelta(skill: skill, level: level, color: AppColors.tyrian),
      const SizedBox(height: 4),
      // A partir de Nv.5 la XP deja de subir de nivel, pero se sigue ganando:
      // decirlo evita que el jugador crea que perdió el progreso.
      Text('La experiencia ya no sube este camino: de acá en más van Sellos.',
          style: AppTextStyles.bodySmall),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: GameButton(
          label: canAfford
              ? 'ASCENDER — $cost SELLOS'
              : 'NECESITÁS $cost SELLOS (tenés $seals)',
          variant: GameButtonVariant.secret,
          fontSize: 14,
          isLoading: ascending,
          onTap: canAfford && !ascending ? onAscend : null,
        ),
      ),
    ]);
  }
}

// ─── Cuánto mejora este paso ──────────────────────────────────────────────────
// "Ahora → con el próximo nivel", con los números que devuelve SkillPerks.
// Es la respuesta directa a "¿para qué me sirve subir esto?".
class _LevelDelta extends StatelessWidget {
  final SkillType skill;
  final int level;
  final Color color;
  const _LevelDelta(
      {required this.skill, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    final deltas = skillLevelDelta(skill, level);
    if (deltas.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('QUÉ GANÁS',
            style: AppTextStyles.ui(12,
                color: AppColors.inkSoft, letterSpacing: 1.2)),
        const SizedBox(height: 5),
        for (final d in deltas)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(children: [
              Expanded(
                child: Text(d.label,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.inkSoft)),
              ),
              Text(d.before,
                  style: AppTextStyles.ui(12,
                      color: AppColors.inkMuted)),
              const Icon(Icons.arrow_right_alt,
                  size: 14, color: AppColors.inkMuted),
              Text(d.after,
                  style: AppTextStyles.ui(12,
                      color: GameChip.legibleText(color),
                      weight: FontWeight.bold)),
            ]),
          ),
      ]),
    );
  }
}

// ─── Fila de un nodo del camino ───────────────────────────────────────────────
enum _NodeState { unlocked, next, locked }

class _NodeRow extends StatelessWidget {
  final SkillNodeDef node;
  final _NodeState state;
  final Color color;
  const _NodeRow(
      {required this.node, required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    final isElite = node.level >= 6;
    final accent = isElite ? AppColors.tyrian : color;
    final (circleColor, textColor) = switch (state) {
      _NodeState.unlocked => (accent, AppColors.ink),
      _NodeState.next => (AppColors.ochreDeep, AppColors.ink),
      _NodeState.locked => (AppColors.paperLine, AppColors.inkMuted),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: state == _NodeState.unlocked
                ? circleColor.withValues(alpha: 0.2)
                : AppColors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2),
          ),
          child: Center(
            child: state == _NodeState.unlocked
                ? Icon(Icons.check, size: 13, color: circleColor)
                : Text('${node.level}',
                    style: AppTextStyles.ui(12,
                        color: GameChip.legibleText(circleColor),
                        weight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(node.name,
                    style: AppTextStyles.ui(12,
                        color: textColor, weight: FontWeight.bold)),
              ),
              // Cuánto cuesta cada nodo élite, no solo el próximo: así el
              // jugador puede planificar hacia dónde ahorra sus Sellos.
              if (isElite && state != _NodeState.unlocked) ...[
                const SizedBox(width: 6),
                Icon(Icons.workspace_premium,
                    size: 12,
                    color: state == _NodeState.locked
                        ? AppColors.inkMuted
                        : AppColors.tyrian),
                const SizedBox(width: 3),
                Text('${sealCostForLevel[node.level] ?? '?'}',
                    style: AppTextStyles.ui(12,
                        color: state == _NodeState.locked
                            ? AppColors.inkMuted
                            : AppColors.ink,
                        weight: FontWeight.bold)),
              ] else if (isElite) ...[
                const SizedBox(width: 6),
                const Icon(Icons.workspace_premium,
                    size: 12, color: AppColors.tyrian),
              ],
            ]),
            Text(node.perk,
                style: AppTextStyles.bodySmall.copyWith(
                    color: state == _NodeState.locked
                        ? AppColors.inkMuted
                        : AppColors.inkSoft)),
          ]),
        ),
      ]),
    );
  }
}

// ─── Dialog de ascenso ────────────────────────────────────────────────────────
// El sello se lacra: cae, brilla y suelta polvo dorado.
class _AscendedDialog extends StatelessWidget {
  final SkillType skill;
  final SkillNodeDef node;
  const _AscendedDialog({required this.skill, required this.node});

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return GameDialog(
      accent: AppColors.tyrian,
      actions: [
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: 'CONTINUAR',
            fontSize: 15,
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
      child: Column(children: [
        SizedBox(
          height: 110,
          child: Stack(alignment: Alignment.center, children: [
            const Positioned.fill(
                child: ParticleBurst(
                    delay: Duration(milliseconds: 300), spread: 110)),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppGradients.tyrian,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 3),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.tyrian.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 4),
                ],
              ),
              child: Icon(skillIconData(skill),
                  color: AppColors.paper, size: 38),
            )
                .animate()
                .scale(
                    begin: reduced
                        ? const Offset(1, 1)
                        : const Offset(2.2, 2.2),
                    duration: AppMotion.of(context, 380.ms),
                    curve: AppMotion.exit)
                .fade(duration: AppMotion.of(context, 200.ms))
                .then()
                .shimmer(
                    duration: AppMotion.of(context, 700.ms),
                    color: AppColors.paper),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('¡SUBISTE DE NIVEL!',
            style: AppTextStyles.heading(22,
                color: AppColors.ochreDeep,
                letterSpacing: 1)),
        const SizedBox(height: AppSpacing.sm),
        Text('${skill.label} Nv.${node.level} — «${node.name}»',
            style: AppTextStyles.ui(15, weight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(node.perk,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center),
      ]),
    );
  }
}
