import 'package:intl/intl.dart';
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
import '../../../l10n/app_localizations.dart';
import '../../../domain/entities/content_l10n.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PERFIL — tres pestañas cortas en vez de un scroll de seis secciones:
//   Mensajero (quién sos y qué sabés) · Mundo (reputación y diario) ·
//   Historial (tus entregas).
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends ConsumerWidget {
  /// Pestaña inicial: 0 Mensajero, 1 Mundo, 2 Historial.
  final int initialTab;
  const ProfileScreen({super.key, this.initialTab = 0});

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
            return EmptyState(
                icon: Icons.person_off_outlined,
                title: AppLocalizations.of(context).profileNoMessenger);
          }
          return _ProfileBody(messenger: messenger, initialTab: initialTab);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final Messenger messenger;
  final int initialTab;
  const _ProfileBody({required this.messenger, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
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
        border: Border(bottom: BorderSide(color: AppColors.paperLine)),
      ),
      child: Row(children: [
        GameBackButton(
          onTap: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: Text(AppLocalizations.of(context).profileTitle,
                style: AppTextStyles.titleLarge)),
        GameIconButton(
          icon: Icons.settings_outlined,
          semanticLabel: AppLocalizations.of(context).settingsTitle,
          color: AppColors.inkSoft,
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
          color: AppColors.paperDeep,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.paperLine, width: 1.5),
        ),
        child: TabBar(
          onTap: (_) => AppFeedback.tap(),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.transparent,
          indicator: BoxDecoration(
            gradient: AppGradients.ochre,
            borderRadius: BorderRadius.circular(AppRadii.md - 3),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          labelColor: AppColors.ink,
          unselectedLabelColor: AppColors.inkSoft,
          labelStyle: AppTextStyles.ui(13, weight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.ui(13),
          tabs: [
            Tab(text: AppLocalizations.of(context).profileTabMessenger),
            Tab(text: AppLocalizations.of(context).profileTabWorld),
            Tab(text: AppLocalizations.of(context).profileTabHistory),
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
        SectionHeader(title: AppLocalizations.of(context).profileSkills),
        _SkillsGrid(messenger: messenger)
            .animate(delay: AppMotion.stagger)
            .fadeIn(duration: AppMotion.of(context, AppMotion.base)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: AppLocalizations.of(context).profileSeePaths,
            icon: Icons.account_tree_outlined,
            variant: GameButtonVariant.secret,
            fontSize: 14,
            onTap: () => context.push('/skills'),
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(title: AppLocalizations.of(context).achTitle),
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
            child: Text(AppLocalizations.of(context).profileSignOut,
                style: AppTextStyles.ui(13, color: AppColors.inkMuted)),
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
      frieze: true,
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
                  style: AppTextStyles.heading(20)),
              if (title != null)
                Text(AppLocalizations.of(context).quotedTitle(title!),
                    style: AppTextStyles.ui(13,
                        color: AppColors.ochreDeep, weight: FontWeight.bold)),
              const SizedBox(height: 6),
              GameChip(
                  AppLocalizations.of(context)
                      .slotRank(messenger.rankTitle, messenger.rank),
                  icon: Icons.military_tech, color: AppColors.ochreDeep),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)
                    .profileCompleted(messenger.completedMissionIds.length),
                style: AppTextStyles.bodyMedium,
              ),
            ]),
          ),
        ]),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [
          Expanded(
              child: StatBar(
            label: AppLocalizations.of(context).statHealth,
            value: messenger.health,
            maxValue: 100,
            color: messenger.health > 60
                ? AppColors.verdigris
                : messenger.health > 30
                    ? AppColors.sienna
                    : AppColors.cinnabar,
          )),
          const SizedBox(width: 14),
          Expanded(
              child: StatBar(
            label: AppLocalizations.of(context).statFatigue,
            value: messenger.fatigue,
            maxValue: 100,
            color: messenger.fatigue < 40
                ? AppColors.verdigris
                : messenger.fatigue < 70
                    ? AppColors.sienna
                    : AppColors.cinnabar,
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
                  color: AppColors.paperDeep,
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
                            Text(
                                '${skill.label} · '
                                '${AppLocalizations.of(context).skillLevelShort(level)}',
                                style: AppTextStyles.ui(13,
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
                                          ? AppColors.tyrian
                                          : AppColors.ochreDeep)
                                      : AppColors.paperDeep,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: filled
                                          ? (isElite
                                              ? AppColors.tyrian
                                              : AppColors.ochreDeep)
                                          : AppColors.paperLine,
                                      width: 1.5),
                                ),
                              );
                            })),
                          ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(children: [
                          Container(height: 6, color: AppColors.paperShade),
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
                                      ? AppGradients.tyrian
                                      : AppGradients.ochre,
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        level >= 10
                            ? AppLocalizations.of(context).profilePathDone
                            : level >= 5
                                ? AppLocalizations.of(context).profileAscendHint
                                : AppLocalizations.of(context).profileXpToNext(
                                    xp % xpPerLevel, xpPerLevel, level + 1),
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
      borderColor: AppColors.ochreDeep.withValues(alpha: 0.5),
      semanticLabel: AppLocalizations.of(context)
          .profileAchSemantics(unlocked.length, defs.length),
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
            Text(
                AppLocalizations.of(context)
                    .profileAchCount(unlocked.length, defs.length),
                style: AppTextStyles.ui(16, weight: FontWeight.bold)),
            if (next != null)
              Text(AppLocalizations.of(context).profileAchNext(next.goal),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppColors.inkSoft),
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
        SectionHeader(title: AppLocalizations.of(context).profileReputation),
        _ReputationCard(
                world: world,
                unlocks: ref.read(gameContentProvider).factionUnlocks)
            .animate()
            .fadeIn(duration: AppMotion.of(context, AppMotion.base)),
        const SizedBox(height: 20),
        SectionHeader(title: AppLocalizations.of(context).profileJournal),
        if (world.journal.isEmpty)
          GameCard(
            child: EmptyState(
              icon: Icons.menu_book_outlined,
              title: AppLocalizations.of(context).profileJournalEmptyTitle,
              body: AppLocalizations.of(context).profileJournalEmptyBody,
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
  final List<FactionUnlock> unlocks;
  const _ReputationCard({required this.world, required this.unlocks});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final f in Faction.values)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _FactionRow(faction: f, world: world, unlocks: unlocks),
        ),
    ]);
  }
}

/// Una facción: escalón, avance hasta el siguiente y el próximo favor.
/// Tocarla abre la escalera completa.
class _FactionRow extends StatelessWidget {
  final Faction faction;
  final WorldState world;
  final List<FactionUnlock> unlocks;
  const _FactionRow(
      {required this.faction, required this.world, required this.unlocks});

  @override
  Widget build(BuildContext context) {
    final v = world.repOf(faction);
    final tier = factionTier(v);
    final next = nextTier(tier);
    final color = factionColor(faction);
    final lo = tier.threshold;
    final hi = next?.threshold ?? 100;
    final fill = next == null ? 1.0 : ((v - lo) / (hi - lo)).clamp(0.0, 1.0);
    final nextUnlock = next == null
        ? null
        : unlocks
            .where((u) => u.faction == faction && u.tier == next)
            .firstOrNull;
    final open = unlocks.where((u) => u.faction == faction && u.isOpen(world));

    final l = AppLocalizations.of(context);
    final String hint;
    if (next == null) {
      hint = l.repAllOpen;
    } else if (nextUnlock != null) {
      hint = l.repToNextUnlock(hi - v, next.label, nextUnlock.name);
    } else {
      hint = l.repToNext(hi - v, next.label);
    }

    return GameCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: open.isNotEmpty ? color.withValues(alpha: 0.7) : null,
      semanticLabel: '${faction.label}: ${tier.label}, $v. $hint',
      onTap: () => _openFaction(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          FactionBadge(faction: faction, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(faction.label,
                style: AppTextStyles.ui(15, weight: FontWeight.bold)),
          ),
          GameChip('${tier.label} · $v', color: color),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.inkMuted, size: 24),
        ]),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: [
            Container(height: 8, color: AppColors.paperShade),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fill),
              duration: AppMotion.of(context, AppMotion.slow * 2),
              curve: AppMotion.enter,
              builder: (_, w, __) => FractionallySizedBox(
                widthFactor: w,
                child: Container(height: 8, color: color),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        Text(hint, style: AppTextStyles.bodySmall),
      ]),
    );
  }

  void _openFaction(BuildContext context) {
    AppFeedback.tap();
    showGameSheet(
      context,
      title: faction.label,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(children: [
            FactionBadge(faction: faction, size: 52),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(faction.lore, style: AppTextStyles.bodyMedium),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text(
              AppLocalizations.of(context).repHowToEarn,
              style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          FactionUnlockList(faction: faction, world: world, unlocks: unlocks),
        ],
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
      borderColor: AppColors.tyrian.withValues(alpha: 0.6),
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
                          size: 8, color: AppColors.tyrian),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat.Md().format(j.date),
                                style: AppTextStyles.ui(12,
                                    color: AppColors.inkSoft,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text(j.text,
                                style: AppTextStyles.proseItalic(size: 14)),
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
          return Center(
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: AppLocalizations.of(context).historyEmptyTitle,
              body: AppLocalizations.of(context).historyEmptyBody,
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
              color: AppColors.paperDeep,
              borderRadius: BorderRadius.circular(AppRadii.sm + 2),
            ),
            child: const Icon(Icons.map_outlined,
                color: AppColors.inkMuted, size: 22),
          ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${ContentL10n.place(mission.origin)} → '
              '${ContentL10n.place(mission.destination)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.ui(13,
                  color: AppColors.ochreDeep, weight: FontWeight.bold),
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

  String _formatDate(DateTime d) => DateFormat.yMd().format(d);
}

class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog();

  @override
  Widget build(BuildContext context) => GameDialog(
        icon: Icons.logout_rounded,
        title: AppLocalizations.of(context).signOutTitle,
        actions: [
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: AppLocalizations.of(context).signOutConfirm,
              variant: GameButtonVariant.danger,
              fontSize: 16,
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
        child: Text(
          AppLocalizations.of(context).signOutBody,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
}
