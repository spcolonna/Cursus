import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/save_snapshot.dart';
import '../../domain/repositories/repositories.dart';
import '../../infrastructure/cloud/cloud_sync_service.dart';
import '../../infrastructure/cloud/firebase_cloud.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'components.dart';
import '../../l10n/app_localizations.dart';

// ─── Elegir partida ───────────────────────────────────────────────────────────

/// Pregunta qué partida queda y la aplica. Si gana la de la nube, recarga el
/// juego desde el splash.
Future<void> resolveSaveConflict(
    BuildContext context, WidgetRef ref, SaveConflict conflict) async {
  final keepRemote = await showGameDialog<bool>(
    context,
    barrierDismissible: false,
    builder: (_) => _ConflictDialog(conflict),
  );
  if (keepRemote == null) return;
  await ref.read(cloudSyncProvider).resolve(conflict, keepRemote: keepRemote);
  if (keepRemote && context.mounted) {
    reloadGameState(ref);
    context.go('/');
  }
}

class _ConflictDialog extends StatelessWidget {
  final SaveConflict conflict;
  const _ConflictDialog(this.conflict);

  @override
  Widget build(BuildContext context) => GameDialog(
        icon: Icons.cloud_sync_outlined,
        title: AppLocalizations.of(context).cloudConflictTitle,
        actions: [
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: AppLocalizations.of(context).cloudUseRemote,
              icon: Icons.cloud_download_outlined,
              fontSize: 15,
              onTap: () => Navigator.pop(context, true),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: AppLocalizations.of(context).cloudUseLocal,
              fontSize: 14,
              variant: GameButtonVariant.secondary,
              onTap: () => Navigator.pop(context, false),
            ),
          ),
        ],
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            AppLocalizations.of(context).cloudConflictBody,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          _SaveRow(
              icon: Icons.cloud_outlined,
              label: AppLocalizations.of(context).cloudLabel,
              summary: conflict.remote.summary),
          const SizedBox(height: AppSpacing.sm),
          _SaveRow(
              icon: Icons.smartphone,
              label: AppLocalizations.of(context).cloudThisPhone,
              summary: conflict.local.summary),
        ]),
      );
}

class _SaveRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final SaveSummary summary;
  const _SaveRow(
      {required this.icon, required this.label, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final when =
        summary.savedAt == null ? '' : ' · ${timeAgo(l, summary.savedAt!)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.inkMuted, width: 1.5),
      ),
      child: Row(children: [
        Icon(icon, size: 22, color: AppColors.ink),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$label$when', style: AppTextStyles.ui(12, color: AppColors.inkSoft)),
            Text(summary.name, style: AppTextStyles.titleSmall),
            Text(l.cloudDeliveries(summary.completedMissions),
                style: AppTextStyles.ui(13, color: AppColors.inkSoft)),
          ]),
        ),
      ]),
    );
  }
}

String timeAgo(AppLocalizations l, DateTime t, {DateTime? now}) {
  final d = (now ?? DateTime.now()).difference(t);
  if (d.inMinutes < 1) return l.agoNow;
  if (d.inHours < 1) return l.agoMinutes(d.inMinutes);
  if (d.inDays < 1) return l.agoHours(d.inHours);
  if (d.inDays == 1) return l.agoYesterday;
  return l.agoDays(d.inDays);
}

// ─── Botones de proveedor ─────────────────────────────────────────────────────

String providerLabel(AppLocalizations l, AccountProvider p) => switch (p) {
      AccountProvider.apple => l.continueWithApple,
      AccountProvider.google => l.continueWithGoogle,
    };

IconData providerIcon(AccountProvider p) => switch (p) {
      AccountProvider.apple => Icons.apple,
      AccountProvider.google => Icons.g_mobiledata_rounded,
    };

// ─── Ajustes: cuenta ──────────────────────────────────────────────────────────

/// Estado del guardado, vincular la cuenta y borrar todo.
class AccountCard extends ConsumerStatefulWidget {
  const AccountCard({super.key});

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard> {
  bool _busy = false;

  Future<void> _link(AccountProvider provider) async {
    final sync = ref.read(cloudSyncProvider);
    setState(() => _busy = true);
    try {
      final (outcome, conflict) = await sync.link(provider);
      if (!mounted) return;
      if (conflict != null) {
        await resolveSaveConflict(context, ref, conflict);
      } else if (outcome == LinkOutcome.switchedAccount) {
        // Se bajó la partida de esa cuenta.
        reloadGameState(ref);
        context.go('/');
      } else if (outcome == LinkOutcome.linked) {
        showGameSnack(context, AppLocalizations.of(context).cloudLinked);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnack(context, AppLocalizations.of(context).cloudLinkFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showGameDialog<bool>(
      context,
      builder: (_) => const _DeleteDialog(),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(cloudSyncProvider).deleteEverything();
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;
      reloadGameState(ref);
      context.go('/login');
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, AppLocalizations.of(context).cloudDeleteFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(cloudSyncProvider);
    final account = sync.account;
    final linked = account?.linkedProviders ?? const <AccountProvider>{};
    final toLink = availableProviders().difference(linked);
    final l = AppLocalizations.of(context);
    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ValueListenableBuilder<CloudStatus>(
          valueListenable: sync.status,
          builder: (_, status, __) => FutureBuilder<DateTime?>(
            future: sync.store.syncedAt(),
            builder: (_, snap) => _StatusLine(status: status, at: snap.data),
          ),
        ),
        if (linked.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.cloudLinkedWith(linked
                .map((p) => p == AccountProvider.apple ? 'Apple' : 'Google')
                .join(l.listAnd)),
            style: AppTextStyles.ui(13, color: AppColors.inkSoft),
          ),
        ] else if (toLink.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.cloudLinkPrompt,
            style: AppTextStyles.ui(13, color: AppColors.inkSoft),
          ),
          for (final p in toLink) ...[
            const SizedBox(height: AppSpacing.sm),
            GameButton(
              label: providerLabel(l, p),
              icon: providerIcon(p),
              fontSize: 14,
              variant: GameButtonVariant.secondary,
              onTap: _busy ? null : () => _link(p),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.md),
        GameButton(
          label: l.cloudDeleteAccount,
          icon: Icons.delete_forever_outlined,
          fontSize: 14,
          variant: GameButtonVariant.ghost,
          isLoading: _busy,
          onTap: _busy ? null : _delete,
        ),
      ]),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final CloudStatus status;
  final DateTime? at;
  const _StatusLine({required this.status, this.at});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (icon, text) = switch (status) {
      CloudStatus.unavailable => (Icons.smartphone, l.cloudStatusLocal),
      CloudStatus.syncing => (Icons.cloud_upload_outlined, l.cloudStatusSyncing),
      CloudStatus.synced => (
          Icons.cloud_done_outlined,
          at == null
              ? l.cloudStatusSynced
              : l.cloudStatusSyncedAgo(timeAgo(l, at!))
        ),
      CloudStatus.offline => (Icons.cloud_off_outlined, l.cloudStatusOffline),
    };
    return Row(children: [
      Icon(icon, size: 22, color: AppColors.ink),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
    ]);
  }
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog();

  @override
  Widget build(BuildContext context) => GameDialog(
        icon: Icons.delete_forever_outlined,
        accent: AppColors.cinnabar,
        title: AppLocalizations.of(context).cloudDeleteTitle,
        actions: [
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: AppLocalizations.of(context).cloudDeleteConfirm,
              variant: GameButtonVariant.danger,
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
        child: Text(
          AppLocalizations.of(context).cloudDeleteBody,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
}
