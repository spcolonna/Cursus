import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/messenger_avatar.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/world.dart';
import '../../../domain/entities/progression.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PERFIL — tres pestañas cortas en vez de un scroll de seis secciones:
//   Mensajero (quién sos y qué sabés) · Mundo (reputación y diario) ·
//   Historial (tus entregas).
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return GradientScaffold(
      body: homeAsync.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
            error: e, onRetry: () => ref.read(homeProvider.notifier).refresh()),
        data: (state) {
          final messenger = state.messenger;
          if (messenger == null) {
            return const EmptyState(
                icon: Icons.person_off_outlined, title: 'Sin mensajero');
          }
          return _ProfileBody(messenger: messenger);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final Messenger messenger;
  const _ProfileBody({required this.messenger});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(children: [
          _Header(),
          const _Tabs(),
          Expanded(
            child: TabBarView(children: [
              _MessengerTab(messenger: messenger),
              const _WorldTab(),
              const _HistoryTab(),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      decoration: const BoxDecoration(
        gradient: AppGradients.header,
        border: Border(bottom: BorderSide(color: AppColors.bgLine)),
      ),
      child: Row(children: [
        GameBackButton(
          onTap: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text('Mi Mensajero', style: AppTextStyles.titleLarge)),
        GameIconButton(
          icon: Icons.settings_outlined,
          semanticLabel: 'Ajustes',
          color: AppColors.textSecondary,
          onTap: () => context.push('/settings'),
        ),
      ]),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.bgCard2,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.bgLine, width: 1.5),
        ),
        child: TabBar(
          onTap: (_) => AppFeedback.tap(),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.transparent,
          indicator: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: BorderRadius.circular(AppRadii.md - 3),
            border: Border.all(color: AppColors.outline, width: 2),
          ),
          labelColor: AppColors.outline,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.fredoka(13, weight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.fredoka(13),
          tabs: const [
            Tab(text: 'Mensajero'),
            Tab(text: 'Mundo'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PESTAÑA: MENSAJERO
// ═══════════════════════════════════════════════════════════════
class _MessengerTab extends ConsumerWidget {
  final Messenger messenger;
  const _MessengerTab({required this.messenger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titles = ref.watch(titlesProvider).valueOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
      children: [
        _HeroCard(messenger: messenger, title: titles?.equipped)
            .animate()
            .fadeIn(duration: AppMotion.of(context, AppMotion.base))
            .slideY(begin: 0.06, end: 0),
        const SizedBox(height: 20),
        SectionHeader(title: 'Habilidades'),
        _SkillsGrid(messenger: messenger)
            .animate(delay: AppMotion.stagger)
            .fadeIn(duration: AppMotion.of(context, AppMotion.base)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: 'VER CAMINOS DEL MENSAJERO',
            icon: Icons.account_tree_outlined,
            gradient: AppGradients.purple,
            shadowColor: AppColors.purpleShadow,
            fontSize: 14,
            onTap: () => context.push('/skills'),
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(title: 'Logros y títulos'),
        const _AchievementsCard(),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: TextButton(
            onPressed: () async {
              final confirmed = await showGameDialog<bool>(
                context,
                builder: (_) => const _SignOutDialog(),
              );
              if (confirmed == true && context.mounted) {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              }
            },
            child: Text('Cerrar sesión',
                style: AppTextStyles.fredoka(13, color: AppColors.textMuted)),
          ),
        ),
      ],
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Messenger messenger;
  final String? title;
  const _HeroCard({required this.messenger, this.title});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      gradient: AppGradients.blue,
      borderColor: AppColors.gold.withValues(alpha: 0.35),
      child: Column(children: [
        Row(children: [
          // Retrato: vuela desde el Home.
          MessengerHero(messenger, size: 64, highlighted: true),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(messenger.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.fredoka(20, weight: FontWeight.bold)),
              if (title != null)
                Text('«$title»',
                    style: AppTextStyles.fredoka(13,
                        color: AppColors.gold, weight: FontWeight.bold)),
              const SizedBox(height: 6),
              GameChip('${messenger.rankTitle} · Rango ${messenger.rank}',
                  icon: Icons.military_tech, color: AppColors.gold),
              const SizedBox(height: 6),
              Text(
                '${messenger.completedMissionIds.length} misiones completadas',
                style: AppTextStyles.bodyMedium,
              ),
            ]),
          ),
        ]),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [
          Expanded(
              child: StatBar(
            label: 'Salud',
            value: messenger.health,
            maxValue: 100,
            color: messenger.health > 60
                ? AppColors.green
                : messenger.health > 30
                    ? AppColors.riskMed
                    : AppColors.red,
          )),
          const SizedBox(width: 14),
          Expanded(
              child: StatBar(
            label: 'Fatiga',
            value: messenger.fatigue,
            maxValue: 100,
            color: messenger.fatigue < 40
                ? AppColors.green
                : messenger.fatigue < 70
                    ? AppColors.riskMed
                    : AppColors.red,
          )),
        ]),
      ]),
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
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GameCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgCard2,
                  borderRadius: BorderRadius.circular(AppRadii.sm + 2),
                  border: Border.all(color: skillColor(skill), width: 1.5),
                ),
                child: Icon(skillIconData(skill),
                    color: skillColor(skill), size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${skill.label} · Nv.$level',
                                style: AppTextStyles.fredoka(13,
                                    weight: FontWeight.bold)),
                            // 10 niveles: 1-5 dorados, 6-10 sellos de élite.
                            Row(
                                children: List.generate(10, (i) {
                              final isElite = i >= 5;
                              final filled = i < level;
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 3),
                                decoration: BoxDecoration(
                                  color: filled
                                      ? (isElite
                                          ? AppColors.purple
                                          : AppColors.gold)
                                      : AppColors.bgCard2,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: filled
                                          ? (isElite
                                              ? AppColors.purple
                                              : AppColors.goldDark)
                                          : AppColors.bgLine,
                                      width: 1.5),
                                ),
                              );
                            })),
                          ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(children: [
                          Container(height: 6, color: AppColors.outline),
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                                begin: 0, end: level >= 5 ? 1.0 : xpProgress),
                            duration: AppMotion.of(context, AppMotion.slow * 2),
                            curve: AppMotion.enter,
                            builder: (_, v, __) => FractionallySizedBox(
                              widthFactor: v,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: level >= 5
                                      ? AppGradients.purple
                                      : AppGradients.gold,
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        level >= 10
                            ? 'Camino completado'
                            : level >= 5
                                ? 'Ascendé en los Caminos con Sellos'
                                : '${xp % xpPerLevel}/$xpPerLevel XP para Nv.${level + 1}',
                        style: AppTextStyles.bodySmall,
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

// ─── Títulos ──────────────────────────────────────────────────────────────────
// Tocá un título para llevarlo puesto: se ve bajo tu nombre.
/// Resumen de logros: cuántos van, los últimos ganados y la puerta a la
/// pantalla completa (donde también se elige el título).
class _AchievementsCard extends ConsumerWidget {
  const _AchievementsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressionProvider).valueOrNull;
    final defs = ref.watch(gameContentProvider).achievements;
    final unlocked =
        defs.where((d) => state?.unlocked.contains(d.id) ?? false).toList();
    final next = defs
        .where((d) => !(state?.unlocked.contains(d.id) ?? true) && !d.secret)
        .firstOrNull;

    return GameCard(
      borderColor: AppColors.gold.withValues(alpha: 0.5),
      semanticLabel: 'Logros: ${unlocked.length} de ${defs.length}. '
          'Tocá para verlos y elegir tu título.',
      onTap: () => context.push('/achievements'),
      child: Row(children: [
        SizedBox(
          // Las medallas se enciman: cada una más corre 20 px.
          width: 46 + 20.0 * (unlocked.length.clamp(1, 3) - 1),
          height: 46,
          child: Stack(children: [
            for (final (i, d) in unlocked.reversed.take(3).indexed)
              Positioned(
                left: i * 20.0,
                child: AchievementMedal(kind: d.kind, unlocked: true, size: 46),
              ),
            if (unlocked.isEmpty)
              const AchievementMedal(
                  kind: AchievementKind.road, unlocked: false, size: 46),
          ]),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${unlocked.length} de ${defs.length} logros',
                style: AppTextStyles.fredoka(16, weight: FontWeight.bold)),
            if (next != null)
              Text('Próximo: ${next.goal}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PESTAÑA: MUNDO
// ═══════════════════════════════════════════════════════════════
class _WorldTab extends ConsumerWidget {
  const _WorldTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldProvider).valueOrNull;
    if (world == null) return const LoadingState();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
      children: [
        SectionHeader(title: 'Reputación'),
        _ReputationCard(world: world)
            .animate()
            .fadeIn(duration: AppMotion.of(context, AppMotion.base)),
        const SizedBox(height: 20),
        SectionHeader(title: 'Diario del mensajero'),
        if (world.journal.isEmpty)
          const GameCard(
            child: EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'El diario está en blanco',
              body: 'Lo que decidas en el camino va a quedar escrito acá.',
            ),
          )
        else
          _JournalCard(world: world)
              .animate(delay: AppMotion.stagger)
              .fadeIn(duration: AppMotion.of(context, AppMotion.base)),
      ],
    );
  }
}

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
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(f.label,
                      style:
                          AppTextStyles.fredoka(13, weight: FontWeight.bold)),
                ),
                GameChip('${reputationTitle(v)} · $v', color: color),
              ]),
              const SizedBox(height: AppSpacing.xs),
              Text(f.lore, style: AppTextStyles.bodySmall),
              const SizedBox(height: 6),
              Stack(alignment: Alignment.center, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(children: [
                    Container(height: 8, color: AppColors.outline),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: fill),
                      duration: AppMotion.of(context, AppMotion.slow * 2),
                      curve: AppMotion.enter,
                      builder: (_, w, __) => FractionallySizedBox(
                        widthFactor: w,
                        child: Container(height: 8, color: color),
                      ),
                    ),
                  ]),
                ),
                // Marca del neutro.
                Container(width: 2, height: 12, color: AppColors.textMuted),
              ]),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final WorldState world;
  const _JournalCard({required this.world});

  @override
  Widget build(BuildContext context) {
    // Últimas entradas primero.
    final entries = world.journal.reversed.take(15).toList();
    return GameCard(
      gradient: AppGradients.story,
      borderColor: AppColors.purple.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, j) in entries.indexed)
            Padding(
              padding:
                  EdgeInsets.only(bottom: i == entries.length - 1 ? 0 : 14),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle,
                          size: 8, color: AppColors.purple),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${j.date.day}/${j.date.month}',
                                style: AppTextStyles.fredoka(12,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text(j.text,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.parchment,
                                  height: 1.45,
                                  fontStyle: FontStyle.italic,
                                )),
                          ]),
                    ),
                  ]),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PESTAÑA: HISTORIAL
// ═══════════════════════════════════════════════════════════════
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedMissionsProvider);
    return completedAsync.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(error: e),
      data: (missions) {
        if (missions.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Sin misiones completadas aún',
              body: 'Aceptá tu primera misión desde el Inicio.',
            ),
          );
        }
        // Las últimas 30: el historial no crece sin fin (regla 9).
        final recent = missions.take(30).toList();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
          itemCount: recent.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MissionHistoryCard(mission: recent[i])
                .animate(delay: AppMotion.stagger * (i.clamp(0, 8)))
                .fadeIn(duration: AppMotion.of(context, AppMotion.base))
                .slideX(begin: -0.04, end: 0),
          ),
        );
      },
    );
  }
}

class _MissionHistoryCard extends StatelessWidget {
  final Mission mission;
  const _MissionHistoryCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final result = mission.result;

    return GameCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(children: [
        if (result != null)
          GradeBadge(grade: result.grade, size: 44)
        else
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(AppRadii.sm + 2),
            ),
            child: const Icon(Icons.map_outlined,
                color: AppColors.textMuted, size: 22),
          ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${mission.origin} → ${mission.destination}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.fredoka(13,
                  color: AppColors.gold, weight: FontWeight.bold),
            ),
            Text(
              mission.packageDescription,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (result != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: [
                GameChip('${result.timeScore.toInt()}%', icon: Icons.schedule),
                GameChip('${result.packageScore.toInt()}%',
                    icon: Icons.inventory_2_outlined),
                GameChip('${result.decisionScore.toInt()}%',
                    icon: Icons.psychology_outlined),
              ]),
            ],
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_formatDate(mission.startedAt), style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          PackageBadge(state: mission.packageState),
        ]),
      ]),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog();

  @override
  Widget build(BuildContext context) => GameDialog(
        icon: Icons.logout_rounded,
        title: '¿Cerrar sesión?',
        actions: [
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: 'SALIR',
              variant: GameButtonVariant.danger,
              fontSize: 16,
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
        child: Text(
          'Tu progreso está guardado en el dispositivo.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
}
