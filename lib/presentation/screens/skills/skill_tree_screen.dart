import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/messenger_avatar.dart';
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

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);

    return GradientScaffold(
      body: homeAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
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
                    ...SkillType.values.toList().asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PathCard(
                          skill: e.value,
                          messenger: selected,
                          seals: primary.seals,
                          expanded: _expanded.contains(e.value),
                          ascending: _ascending,
                          onToggle: () => setState(() {
                            _expanded.contains(e.value)
                                ? _expanded.remove(e.value)
                                : _expanded.add(e.value);
                          }),
                          onAscend: () => _ascend(selected, e.value),
                        )
                            .animate(
                                delay: Duration(milliseconds: 80 + e.key * 60))
                            .fadeIn()
                            .slideY(begin: 0.05, end: 0),
                      );
                    }),
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
        border: Border(bottom: BorderSide(color: AppColors.bgLine)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.go('/home'),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 16),
          ),
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
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
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
      HapticFeedback.heavyImpact();
      if (mounted) {
        final node = skillNode(skill, messenger.skillLevel(skill) + 1);
        await showDialog(
          context: context,
          builder: (_) => _AscendedDialog(skill: skill, node: node),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))));
      }
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
          const Icon(Icons.military_tech, color: AppColors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                picks == 1
                    ? 'Tenés 1 nivel para elegir'
                    : 'Tenés $picks niveles para elegir',
                style: AppTextStyles.fredoka(15,
                    color: AppColors.amber, weight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 4),
        Text('Se aplica a ${messenger.name}. Hasta nivel $kMaxSkillLevel.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, fontSize: 12)),
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
          color: AppColors.purple.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.purple.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(children: [
          const Icon(Icons.workspace_premium,
              color: AppColors.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Niveles 1-5 se ganan jugando. Los niveles 6-10 se ascienden '
              'con Sellos del Gremio: contratos del día, rachas y notas S. '
              'Los Sellos son de la cuenta: los comparten todos tus mensajeros.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary, height: 1.4),
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
                      : AppColors.bgCard2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? accent : AppColors.bgLine, width: 2),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  MessengerAvatar.from(m, size: 30),
                  const SizedBox(width: 8),
                  Text(m.name,
                      style: AppTextStyles.fredoka(13,
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
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
    required this.skill,
    required this.messenger,
    required this.seals,
    required this.expanded,
    required this.ascending,
    required this.onToggle,
    required this.onAscend,
  });

  Color get _color => switch (skill) {
        SkillType.speed => AppColors.skillSpeed,
        SkillType.stealth => AppColors.skillStealth,
        SkillType.combat => AppColors.skillCombat,
        SkillType.survival => AppColors.skillSurvival,
        SkillType.contacts => AppColors.skillContacts,
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
        color: const Color(0xDD0D1830),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: level >= 6 ? AppColors.purple.withValues(alpha: 0.6) : _color.withValues(alpha: 0.4),
            width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x44000000), offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: Column(children: [
        // Cabecera (tap = expandir)
        GestureDetector(
          onTap: onToggle,
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
                            style: AppTextStyles.fredoka(15,
                                color: AppColors.textPrimary,
                                weight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (level >= 6
                                    ? AppColors.purple
                                    : _color)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color:
                                    level >= 6 ? AppColors.purple : _color,
                                width: 1.5),
                          ),
                          child: Text('Nv.$level/10',
                              style: AppTextStyles.fredoka(11,
                                  color: level >= 6
                                      ? AppColors.purple
                                      : _color,
                                  weight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 3),
                      Text('«${node.name}»',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic)),
                    ]),
              ),
              Icon(expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMuted, size: 22),
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
                gradient: AppGradients.purple,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black38, width: 2),
              ),
              child: Center(
                child: Text('CAMINO COMPLETADO',
                    style: AppTextStyles.fredoka(13,
                        color: Colors.white,
                        weight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ),
          ),

        // Lista completa de nodos
        if (expanded)
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.bgLine)),
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
                .copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        _LevelDelta(skill: skill, level: level, color: color),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(children: [
                Container(height: 8, color: AppColors.outline),
                FractionallySizedBox(
                  widthFactor: (xp / kXpPerSkillLevel).clamp(0.0, 1.0),
                  child: Container(height: 8, color: color),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Text('$xp/$kXpPerSkillLevel XP',
              style: AppTextStyles.fredoka(11, color: color)),
        ]),
      ]);
    }

    // Niveles 6-10: ascenso con Sellos.
    final cost = sealCostForLevel[level + 1] ?? 999;
    final canAfford = seals >= cost;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Ascenso: «${next.name}»',
          style: AppTextStyles.fredoka(13,
              color: AppColors.purple, weight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(next.perk,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      _LevelDelta(skill: skill, level: level, color: AppColors.purple),
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
          gradient: canAfford
              ? AppGradients.purple
              : const LinearGradient(
                  colors: [Color(0xFF334455), Color(0xFF223344)]),
          shadowColor:
              canAfford ? const Color(0xFF2A0E55) : const Color(0xFF111822),
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
        color: AppColors.bgCard2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('QUÉ GANÁS',
            style: AppTextStyles.fredoka(9,
                color: AppColors.textSecondary, letterSpacing: 1.2)),
        const SizedBox(height: 5),
        for (final d in deltas)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(children: [
              Expanded(
                child: Text(d.label,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ),
              Text(d.before,
                  style: AppTextStyles.fredoka(11,
                      color: AppColors.textMuted)),
              const Icon(Icons.arrow_right_alt,
                  size: 14, color: AppColors.textMuted),
              Text(d.after,
                  style: AppTextStyles.fredoka(11,
                      color: color, weight: FontWeight.bold)),
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
    final accent = isElite ? AppColors.purple : color;
    final (circleColor, textColor) = switch (state) {
      _NodeState.unlocked => (accent, AppColors.textPrimary),
      _NodeState.next => (AppColors.gold, AppColors.textPrimary),
      _NodeState.locked => (AppColors.bgLine, AppColors.textMuted),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: state == _NodeState.unlocked
                ? circleColor.withValues(alpha: 0.2)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2),
          ),
          child: Center(
            child: state == _NodeState.unlocked
                ? Icon(Icons.check, size: 13, color: circleColor)
                : Text('${node.level}',
                    style: AppTextStyles.fredoka(11,
                        color: circleColor, weight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(node.name,
                    style: AppTextStyles.fredoka(12,
                        color: textColor, weight: FontWeight.bold)),
              ),
              // Cuánto cuesta cada nodo élite, no solo el próximo: así el
              // jugador puede planificar hacia dónde ahorra sus Sellos.
              if (isElite && state != _NodeState.unlocked) ...[
                const SizedBox(width: 6),
                Icon(Icons.workspace_premium,
                    size: 12,
                    color: state == _NodeState.locked
                        ? AppColors.textMuted
                        : AppColors.purple),
                const SizedBox(width: 3),
                Text('${sealCostForLevel[node.level] ?? '?'}',
                    style: AppTextStyles.fredoka(11,
                        color: state == _NodeState.locked
                            ? AppColors.textMuted
                            : AppColors.purple,
                        weight: FontWeight.bold)),
              ] else if (isElite) ...[
                const SizedBox(width: 6),
                const Icon(Icons.workspace_premium,
                    size: 12, color: AppColors.purple),
              ],
            ]),
            Text(node.perk,
                style: AppTextStyles.bodySmall.copyWith(
                    color: state == _NodeState.locked
                        ? AppColors.textMuted
                        : AppColors.textSecondary)),
          ]),
        ),
      ]),
    );
  }
}

// ─── Dialog de ascenso ────────────────────────────────────────────────────────
class _AscendedDialog extends StatelessWidget {
  final SkillType skill;
  final SkillNodeDef node;
  const _AscendedDialog({required this.skill, required this.node});

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: const Color(0xFF160A28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.purple, width: 2.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                gradient: AppGradients.purple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black38, width: 3),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 4),
                ],
              ),
              child: const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 38),
            )
                .animate()
                .scale(
                    begin: const Offset(0.3, 0.3),
                    duration: 500.ms,
                    curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 700.ms),
            const SizedBox(height: 16),
            Text('¡ASCENDISTE!',
                style: AppTextStyles.fredoka(22,
                    color: AppColors.purple,
                    weight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Text('${skill.label} Nv.${node.level} — «${node.name}»',
                style: AppTextStyles.fredoka(14, color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(node.perk,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GameButton(
                label: 'CONTINUAR',
                gradient: AppGradients.purple,
                shadowColor: const Color(0xFF2A0E55),
                fontSize: 15,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ]),
        ),
      );
}
