import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/messenger_avatar.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/world.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    final completedAsync = ref.watch(completedMissionsProvider);

    return GradientScaffold(
      body: homeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final messenger = state.messenger;
          if (messenger == null) {
            return Center(child: Text('Sin mensajero', style: AppTextStyles.titleLarge));
          }
          return _ProfileBody(
            messenger: messenger,
            completedAsync: completedAsync,
            ref: ref,
          );
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final Messenger messenger;
  final AsyncValue<List<Mission>> completedAsync;
  final WidgetRef ref;

  const _ProfileBody({required this.messenger, required this.completedAsync, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader(context)),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Hero card
                _HeroCard(messenger: messenger)
                .animate().fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Skills
                SectionHeader(title: 'Habilidades'),
                _SkillsGrid(messenger: messenger)
                .animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: GameButton(
                    label: 'VER CAMINOS DEL MENSAJERO',
                    icon: Icons.account_tree_outlined,
                    gradient: AppGradients.purple,
                    shadowColor: const Color(0xFF2A0E55),
                    fontSize: 14,
                    onTap: () => context.push('/skills'),
                  ),
                ).animate(delay: 150.ms).fadeIn(),

                const SizedBox(height: 20),

                // Títulos / cosmética de finales de arco
                FutureBuilder<List<String>>(
                  future: ref.read(playerProgressProvider).getUnlockedTitles(),
                  builder: (context, snap) {
                    final titles = snap.data ?? [];
                    if (titles.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: 'Títulos ganados'),
                        _TitlesCard(titles: titles),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),

                // Reputación con las facciones de Roma
                SectionHeader(title: 'Reputación'),
                Consumer(builder: (context, ref, _) {
                  final world = ref.watch(worldProvider).valueOrNull;
                  if (world == null) return const SizedBox.shrink();
                  return _ReputationCard(world: world)
                      .animate(delay: 120.ms).fadeIn().slideY(begin: 0.1, end: 0);
                }),

                const SizedBox(height: 20),

                // Diario del mensajero
                Consumer(builder: (context, ref, _) {
                  final world = ref.watch(worldProvider).valueOrNull;
                  if (world == null || world.journal.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Diario del mensajero'),
                      _JournalCard(world: world)
                          .animate(delay: 140.ms).fadeIn().slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 20),
                    ],
                  );
                }),

                // Mission history
                SectionHeader(title: 'Historial de misiones'),
                completedAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                  error: (e, _) => Text('Error: $e'),
                  data: (missions) => missions.isEmpty
                    ? _EmptyHistory()
                    : Column(
                        children: missions.take(10).toList().asMap().entries.map((e) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _MissionHistoryCard(mission: e.value)
                            .animate(delay: Duration(milliseconds: 150 + e.key * 60))
                            .fadeIn().slideX(begin: -0.05, end: 0),
                          ),
                        ).toList(),
                      ),
                ),

                const SizedBox(height: 20),

                // Sign out
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => _SignOutDialog(),
                      );
                      if (confirmed == true && context.mounted) {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) context.go('/login');
                      }
                    },
                    child: Text(
                      'Cerrar sesión',
                      style: AppTextStyles.fredoka(13, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text('Mi Mensajero', style: AppTextStyles.titleLarge)),
        GestureDetector(
          onTap: () => context.push('/settings'),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Messenger messenger;
  const _HeroCard({required this.messenger});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A3264), Color(0xFF0D1E40)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderColor: AppColors.gold.withValues(alpha: 0.3),
      child: Column(
        children: [
          Row(
            children: [
              // Retrato del mensajero: género, túnica del slot, rango y estado
              MessengerAvatar.from(messenger, size: 64, highlighted: true),
              const SizedBox(width: 14),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(messenger.name, style: AppTextStyles.fredoka(20, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  // Rank badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black38, width: 2),
                    ),
                    child: Text(
                      '${messenger.rankTitle} · Rango ${messenger.rank}',
                      style: AppTextStyles.fredoka(12, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${messenger.completedMissionIds.length} misiones completadas',
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                  ),
                ]),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats
          Row(children: [
            Expanded(child: StatBar(
              label: 'Salud',
              value: messenger.health,
              maxValue: 100,
              color: messenger.health > 60 ? AppColors.green
                  : messenger.health > 30 ? AppColors.riskMed
                  : AppColors.red,
            )),
            const SizedBox(width: 14),
            Expanded(child: StatBar(
              label: 'Fatiga',
              value: messenger.fatigue,
              maxValue: 100,
              color: messenger.fatigue < 40 ? AppColors.green
                  : messenger.fatigue < 70 ? AppColors.riskMed
                  : AppColors.red,
            )),
          ]),
        ],
      ),
    );
  }
}

// ─── Skills Grid ──────────────────────────────────────────────────────────────
class _SkillsGrid extends StatelessWidget {
  final Messenger messenger;
  const _SkillsGrid({required this.messenger});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: SkillType.values.map((skill) {
        final level = messenger.skillLevel(skill);
        final xp = messenger.skillXp[skill] ?? 0;
        const xpPerLevel = 100;
        final xpProgress = (xp % xpPerLevel) / xpPerLevel;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GameCard(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              // Icon
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgCard2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.bgLine),
                ),
                child: Center(
                    child: Icon(skillIconData(skill),
                        color: skillColor(skill), size: 20)),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(skill.label, style: AppTextStyles.fredoka(13, color: AppColors.textPrimary)),
                    // Level pips — 10 niveles: 1-5 dorados, 6-10 élite (púrpura)
                    Row(children: List.generate(10, (i) {
                      final isElite = i >= 5;
                      final filled = i < level;
                      final fillColor = filled
                          ? (isElite ? AppColors.purple : AppColors.gold)
                          : AppColors.bgCard2;
                      final borderColor = filled
                          ? (isElite ? AppColors.purple : AppColors.goldDark)
                          : AppColors.bgLine;
                      return Container(
                        width: 9, height: 9,
                        margin: const EdgeInsets.only(left: 3),
                        decoration: BoxDecoration(
                          color: fillColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                      );
                    })),
                  ]),
                  const SizedBox(height: 5),
                  // XP bar
                  Stack(children: [
                    Container(height: 6, decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    )),
                    FractionallySizedBox(
                      widthFactor: level >= 5 ? 1.0 : xpProgress,
                      child: Container(height: 6, decoration: BoxDecoration(
                        gradient: level >= 5 ? AppGradients.purple : AppGradients.gold,
                        borderRadius: BorderRadius.circular(4),
                      )),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    level >= 10
                        ? 'Camino completado'
                        : level >= 5
                            ? 'Ascendé en los Caminos del Mensajero'
                            : '${xp % xpPerLevel}/$xpPerLevel XP para Nv.${level + 1}',
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 10),
                  ),
                ]),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Reputación ───────────────────────────────────────────────────────────────
class _ReputationCard extends StatelessWidget {
  final WorldState world;
  const _ReputationCard({required this.world});

  Color _colorFor(int v) {
    if (v >= 10) return AppColors.green;
    if (v > -10) return AppColors.sky;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        children: Faction.values.map((f) {
          final v = world.repOf(f);
          final color = _colorFor(v);
          // Barra centrada en 0: -100..100 mapeado a 0..1.
          final fill = ((v + 100) / 200).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(f.label,
                      style: AppTextStyles.fredoka(13,
                          color: AppColors.textPrimary,
                          weight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Text(reputationTitle(v),
                      style: AppTextStyles.fredoka(10,
                          color: color, weight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 4),
              Text(f.lore,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
              const SizedBox(height: 5),
              // Barra con marca de neutro en el centro.
              Stack(alignment: Alignment.center, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(children: [
                    Container(height: 7, color: AppColors.outline),
                    FractionallySizedBox(
                      widthFactor: fill,
                      child: Container(height: 7, color: color),
                    ),
                  ]),
                ),
                Container(width: 2, height: 11, color: AppColors.textMuted),
              ]),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Diario del mensajero ─────────────────────────────────────────────────────
class _JournalCard extends StatelessWidget {
  final WorldState world;
  const _JournalCard({required this.world});

  @override
  Widget build(BuildContext context) {
    // Últimas entradas primero.
    final entries = world.journal.reversed.take(15).toList();
    return GameCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF241A38), Color(0xFF16101F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.purple.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.asMap().entries.map((e) {
          final j = e.value;
          final isLast = e.key == entries.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(Icons.circle,
                    size: 7, color: AppColors.purple.withValues(alpha: 0.8)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${j.date.day}/${j.date.month}',
                          style: AppTextStyles.fredoka(9,
                              color: AppColors.purple, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text(j.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xFFE8E0CC),
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          )),
                    ]),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Mission History Card ─────────────────────────────────────────────────────
class _MissionHistoryCard extends StatelessWidget {
  final Mission mission;
  const _MissionHistoryCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final result = mission.result;

    return GameCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        if (result != null)
          GradeBadge(grade: result.grade, size: 44)
        else
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
                child: Icon(Icons.map_outlined,
                    color: AppColors.textMuted, size: 22)),
          ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${mission.origin} → ${mission.destination}',
              style: AppTextStyles.fredoka(13, color: AppColors.gold),
            ),
            Text(
              mission.packageDescription,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            if (result != null) ...[
              const SizedBox(height: 3),
              Row(children: [
                _ScorePill(Icons.schedule, '${result.timeScore.toInt()}%'),
                const SizedBox(width: 4),
                _ScorePill(Icons.inventory_2_outlined, '${result.packageScore.toInt()}%'),
                const SizedBox(width: 4),
                _ScorePill(Icons.psychology_outlined, '${result.decisionScore.toInt()}%'),
              ]),
            ],
          ]),
        ),

        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            _formatDate(mission.startedAt),
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 4),
          PackageBadge(state: mission.packageState),
        ]),
      ]),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _ScorePill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ScorePill(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.bgCard2,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: AppColors.textMuted),
      const SizedBox(width: 2),
      Text(text, style: AppTextStyles.fredoka(9, color: AppColors.textMuted)),
    ]),
  );
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GameCard(
    child: Column(children: [
      const Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 36),
      const SizedBox(height: 8),
      Text('Sin misiones completadas aún', style: AppTextStyles.titleSmall),
      const SizedBox(height: 4),
      Text('Aceptá tu primera misión desde el Home.', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
    ]),
  );
}

class _TitlesCard extends StatelessWidget {
  final List<String> titles;
  const _TitlesCard({required this.titles});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35), width: 2),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: titles
            .map((t) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.military_tech,
                        color: AppColors.gold, size: 14),
                    const SizedBox(width: 6),
                    Text(t,
                        style: AppTextStyles.fredoka(12, color: AppColors.gold)),
                  ]),
                ))
            .toList(),
      ),
    );
  }
}

class _SignOutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.bgCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.bgLine, width: 2),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.logout_rounded, color: AppColors.gold, size: 40),
        const SizedBox(height: 12),
        Text('¿Cerrar sesión?', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Tu progreso está guardado en el dispositivo.',
          style: AppTextStyles.bodyMedium, textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
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
                child: Center(child: Text('Cancelar', style: AppTextStyles.fredoka(14, color: AppColors.textMuted))),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GameButton(
              label: 'Salir',
              gradient: AppGradients.red,
              shadowColor: AppColors.redShadow,
              fontSize: 16,
              onTap: () => Navigator.pop(context, true),
            ),
          ),
        ]),
      ]),
    ),
  );
}
