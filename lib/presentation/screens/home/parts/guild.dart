part of '../home_screen.dart';

// ─── Tablón del gremio — resumen en el Home ───────────────────────────────────
// Una línea con el estado del día; tocarla abre el tablón completo. Si hay
// algo para cobrar, se nota desde acá.
class _GuildSummaryCard extends ConsumerWidget {
  const _GuildSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guild = ref.watch(guildProvider).valueOrNull;
    if (guild == null) return const SizedBox.shrink();
    final weekly = ref.watch(weeklyProvider).valueOrNull;
    final defs = _weeklyDefs(ref);

    final total = guild.contracts.length;
    final claimed = guild.contracts.where((c) => c.claimed).length;
    final weeklyReady = weekly == null
        ? 0
        : weekly.entries
            .where((e) =>
                !e.claimed && e.progress >= (defs[e.id]?.target ?? 1 << 30))
            .length;
    final ready =
        guild.contracts.where((c) => c.completed && !c.claimed).length +
            weeklyReady;
    final weeklyClaimed = weekly?.entries.where((e) => e.claimed).length ?? 0;

    return GameCard(
      padding: const EdgeInsets.all(14),
      borderColor: ready > 0
          ? AppColors.gold
          : AppColors.brownBorder.withValues(alpha: 0.6),
      onTap: () => _openGuildBoard(context, ref),
      semanticLabel: 'Tablón del gremio: $claimed de $total cobrados',
      child: Row(children: [
        const Icon(Icons.push_pin, color: AppColors.brownBorder, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TABLÓN DEL GREMIO',
                style: AppTextStyles.fredoka(13,
                    color: AppColors.amber,
                    weight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: AppSpacing.xs),
            // Un punto por contrato: cobrado, listo o en curso.
            Row(children: [
              for (final c in guild.contracts)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.base),
                    width: 22,
                    height: 8,
                    decoration: BoxDecoration(
                      color: c.claimed
                          ? AppColors.green
                          : c.completed
                              ? AppColors.gold
                              : AppColors.outline,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.bgLine),
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                    weekly == null
                        ? '$claimed/$total hoy'
                        : '$claimed/$total hoy · semana $weeklyClaimed/${weekly.entries.length}',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall),
              ),
            ]),
          ]),
        ),
        if (ready > 0)
          GameChip('COBRAR $ready', icon: Icons.savings, color: AppColors.gold)
              .animate(
                  onPlay: (c) => AppMotion.reduced(context)
                      ? null
                      : c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.06, duration: 600.ms)
        else
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 26),
      ]),
    );
  }
}

Map<String, WeeklyCommissionDef> _weeklyDefs(WidgetRef ref) =>
    {for (final d in ref.read(gameContentProvider).weeklyCommissions) d.id: d};

void _openGuildBoard(BuildContext context, WidgetRef ref) {
  // Mirar el tablón es una tarea de "Primeros pasos".
  ref
      .read(primerosPasosProvider.notifier)
      .markTask(PlayerProgress.taskViewGuild);
  showGameSheet(
    context,
    title: 'Tablón del gremio',
    builder: (_) => const _GuildBoard(),
  );
}

// ─── Botón de cobro (contratos y encargos) ────────────────────────────────────
class _ClaimButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _ClaimButton({super.key, required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cobrar',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: busy ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 88),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: BorderRadius.circular(AppRadii.sm + 2),
            border: Border.all(color: AppColors.outline, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 3)),
            ],
          ),
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.outline))
              : Text('COBRAR',
                  style: AppTextStyles.fredoka(13,
                      color: AppColors.outline, weight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ─── Encargo semanal ──────────────────────────────────────────────────────────
// Quién lo pide, qué dice, cuánto falta y qué paga (incluida la reputación).
class _WeeklyCard extends ConsumerStatefulWidget {
  final WeeklyEntry entry;
  final WeeklyCommissionDef def;
  const _WeeklyCard({required this.entry, required this.def});

  @override
  ConsumerState<_WeeklyCard> createState() => _WeeklyCardState();
}

class _WeeklyCardState extends ConsumerState<_WeeklyCard> {
  bool _claiming = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final d = widget.def;
    final progress = e.progress.clamp(0, d.target);
    final done = progress >= d.target;
    final accent =
        d.npcFaction == null ? AppColors.gold : factionColor(d.npcFaction!);

    final Widget trailing = e.claimed
        ? const GameChip('COBRADO',
            key: ValueKey('claimed'), icon: Icons.check, color: AppColors.green)
        : done
            ? _ClaimButton(
                key: const ValueKey('claim'), busy: _claiming, onTap: _claim)
            : Text('$progress/${d.target}',
                key: const ValueKey('progress'),
                style: AppTextStyles.fredoka(14,
                    color: AppColors.textSecondary, weight: FontWeight.bold));

    return GameCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor:
          done && !e.claimed ? AppColors.gold : accent.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          NpcPortrait(name: d.npcName, faction: d.npcFaction, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.npcName,
                  style: AppTextStyles.fredoka(15, weight: FontWeight.bold)),
              Text(d.npcRole, style: AppTextStyles.bodySmall),
            ]),
          ),
          AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.base),
            transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: AppMotion.pop),
                child: FadeTransition(opacity: anim, child: child)),
            child: trailing,
          ),
        ]),
        if (!e.claimed) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('«${d.intro}»',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.parchment, fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(d.goalText,
            style: AppTextStyles.fredoka(13,
                color: e.claimed ? AppColors.textMuted : AppColors.textPrimary,
                weight: FontWeight.bold)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: [
            Container(height: 6, color: AppColors.outline),
            TweenAnimationBuilder<double>(
              tween: Tween(end: (progress / d.target).clamp(0.0, 1.0)),
              duration: AppMotion.of(context, AppMotion.slow),
              curve: AppMotion.enter,
              builder: (_, v, __) => FractionallySizedBox(
                widthFactor: v,
                child: Container(
                    height: 6, color: e.claimed ? AppColors.green : accent),
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(spacing: 6, runSpacing: 4, children: [
          if (d.denarios > 0)
            GameChip('+${d.denarios}',
                icon: CurrencyType.denarios.icon, color: AppColors.sky),
          if (d.seals > 0)
            GameChip('+${d.seals} Sello',
                icon: CurrencyType.seals.icon, color: AppColors.purple),
          for (final r in d.rep.entries)
            GameChip('+${r.value} ${r.key.label}',
                icon: factionIcon(r.key), color: factionColor(r.key)),
        ]),
      ]),
    );
  }

  Future<void> _claim() async {
    setState(() => _claiming = true);
    try {
      final def =
          await ref.read(weeklyProvider.notifier).claim(widget.entry.id);
      AppFeedback.reward();
      if (mounted) {
        showRewardToast(
          context,
          [
            (type: CurrencyType.denarios, amount: def.denarios),
            (type: CurrencyType.seals, amount: def.seals),
          ],
          note: 'Encargo de ${def.npcName} cumplido',
        );
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }
}

// ─── Tablón completo (dentro del panel) ───────────────────────────────────────
class _GuildBoard extends ConsumerWidget {
  const _GuildBoard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guild = ref.watch(guildProvider).valueOrNull;
    if (guild == null) return const LoadingState();
    final weekly = ref.watch(weeklyProvider).valueOrNull;
    final defs = _weeklyDefs(ref);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (weekly != null) ...[
          SectionHeader(title: 'Encargos de la semana'),
          Text('Gente que confía en vos. Se renuevan el lunes.',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          for (final (i, e) in weekly.entries.indexed)
            if (defs[e.id] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _WeeklyCard(entry: e, def: defs[e.id]!)
                    .animate(delay: AppMotion.stagger * i)
                    .fadeIn(duration: AppMotion.of(context, AppMotion.base))
                    .slideX(begin: 0.05, end: 0),
              ),
          const SizedBox(height: AppSpacing.md),
        ],
        SectionHeader(title: 'Contratos del día'),
        Text('Se renuevan a medianoche.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        for (final (i, c) in guild.contracts.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ContractRow(contract: c)
                .animate(delay: AppMotion.stagger * i)
                .fadeIn(duration: AppMotion.of(context, AppMotion.base))
                .slideX(begin: 0.05, end: 0),
          ),
      ],
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

    final Widget trailing;
    if (c.claimed) {
      trailing = const GameChip('COBRADO',
          key: ValueKey('claimed'), icon: Icons.check, color: AppColors.green);
    } else if (c.completed) {
      final button = _ClaimButton(
          key: const ValueKey('claim'), busy: _claiming, onTap: _claim);
      trailing = AppMotion.reduced(context)
          ? button
          : button
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.06, duration: 600.ms);
    } else {
      trailing = RewardAmount(
        key: const ValueKey('reward'),
        type: isSeal ? CurrencyType.seals : CurrencyType.denarios,
        amount: isSeal ? t.reward.seals : t.reward.denarios,
        fontSize: 13,
        withLabel: false,
      );
    }

    // Favor del Gremio: cambiar un contrato por día.
    final guild = ref.watch(guildProvider).valueOrNull;
    final world = ref.watch(worldProvider).valueOrNull;
    final canReroll = guild != null &&
        world != null &&
        !c.completed &&
        RerollContractUseCase.canReroll(
            guild, world, ref.read(gameContentProvider).factionUnlocks, c);

    return GameCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: c.completed && !c.claimed ? AppColors.gold : null,
      child: Row(children: [
        // Estado
        AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.base),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: c.claimed
                ? AppColors.green.withValues(alpha: 0.15)
                : AppColors.outline,
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
              ? const Icon(Icons.check, size: 16, color: AppColors.green)
              : c.completed
                  ? const Icon(Icons.priority_high,
                      size: 16, color: AppColors.gold)
                  : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.description,
                style: AppTextStyles.fredoka(13,
                    color:
                        c.claimed ? AppColors.textMuted : AppColors.textPrimary,
                    weight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(children: [
                    Container(height: 6, color: AppColors.outline),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: (progress / t.target).clamp(0.0, 1.0)),
                      duration: AppMotion.of(context, AppMotion.slow),
                      curve: AppMotion.enter,
                      builder: (_, v, __) => FractionallySizedBox(
                        widthFactor: v,
                        child: Container(
                            height: 6,
                            color: c.claimed
                                ? AppColors.green
                                : AppColors.brownBorder),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('$progress/${t.target}', style: AppTextStyles.bodySmall),
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        if (canReroll)
          GameIconButton(
            icon: Icons.autorenew,
            semanticLabel: 'Cambiar este contrato por otro',
            color: AppColors.textSecondary,
            onTap: _reroll,
          ),
        // Recompensa → botón de cobro → cobrado, sin saltos.
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.base),
          transitionBuilder: (child, anim) => ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: AppMotion.pop),
              child: FadeTransition(opacity: anim, child: child)),
          child: trailing,
        ),
      ]),
    );
  }

  Future<void> _reroll() async {
    AppFeedback.tap();
    try {
      await ref.read(guildProvider.notifier).reroll(widget.contract.templateId);
      if (mounted) {
        showGameSnack(context, 'Contrato cambiado. Mañana podés de nuevo.');
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }

  Future<void> _claim() async {
    setState(() => _claiming = true);
    try {
      final reward = await ref
          .read(guildProvider.notifier)
          .claimContract(widget.contract.templateId);
      AppFeedback.reward();
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
      if (mounted) showErrorSnack(context, e);
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

    return GameDialog(
      title: 'PAGA DEL GREMIO',
      actions: [
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: 'COBRAR PAGA — DÍA $day',
            fontSize: 16,
            isLoading: _claiming,
            onTap: _claiming ? null : _claim,
          ),
        ),
      ],
      child: Column(children: [
        Stack(alignment: Alignment.center, children: [
          const SizedBox(
              width: 160,
              height: 90,
              child: ParticleBurst(count: 24, spread: 90)),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline, width: 3),
              boxShadow: [
                BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 26,
                    spreadRadius: 3),
              ],
            ),
            child:
                const Icon(Icons.savings, color: AppColors.outline, size: 34),
          ).animate().scale(
              begin: AppMotion.reduced(context)
                  ? const Offset(1, 1)
                  : const Offset(0.3, 0.3),
              duration: AppMotion.of(context, 500.ms),
              curve: Curves.elasticOut),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text('Varus premia tu constancia.',
            style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        // Racha de 7 días: se llena día por día.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final d = i + 1;
            final isToday = d == day;
            final isPast = d < day;
            return Container(
              width: 30,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.gold.withValues(alpha: 0.2)
                    : isPast
                        ? AppColors.green.withValues(alpha: 0.12)
                        : AppColors.bgCard2,
                borderRadius: BorderRadius.circular(AppRadii.sm),
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
                    ? const Icon(Icons.check, size: 14, color: AppColors.green)
                    : Text('$d',
                        style: AppTextStyles.fredoka(13,
                            color:
                                isToday ? AppColors.gold : AppColors.textMuted,
                            weight: FontWeight.bold)),
              ),
            )
                .animate(delay: AppMotion.stagger * i)
                .fadeIn(duration: AppMotion.of(context, AppMotion.base))
                .slideY(begin: 0.4, end: 0, curve: AppMotion.pop);
          }),
        ),
        const SizedBox(height: 14),
        _PayRewardChips(reward: guild.nextPayReward),
      ]),
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
      AppFeedback.reward();
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
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      if (rootContext.mounted) showErrorSnack(rootContext, e);
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
            borderRadius: BorderRadius.circular(AppRadii.sm + 2),
            border: Border.all(color: type.color, width: 2),
          ),
          child: RewardAmount(
              type: type, amount: amount, fontSize: 14, withLabel: false),
        );

    return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.center,
        children: [
          if (reward.denarios > 0) chip(CurrencyType.denarios, reward.denarios),
          if (reward.aureos > 0) chip(CurrencyType.aureos, reward.aureos),
          if (reward.seals > 0) chip(CurrencyType.seals, reward.seals),
        ]);
  }
}
