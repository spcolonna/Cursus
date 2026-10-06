// lib/presentation/screens/settings/settings_screen.dart
//
// Ajustes de avisos + panel de diagnóstico.
//
// El panel existe para responder una pregunta concreta en el dispositivo:
// "¿las notificaciones están llegando?". Muestra el permiso y todo lo que
// hay programado con su hora, y permite disparar una de prueba.

import '../../feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/entities/notifications.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late Future<_Diagnostics> _diagnostics;

  @override
  void initState() {
    super.initState();
    _diagnostics = _loadDiagnostics();
  }

  Future<_Diagnostics> _loadDiagnostics() async {
    final scheduler = ref.read(notificationSchedulerProvider);
    return _Diagnostics(
      permission: await scheduler.permissionStatus(),
      pending: await scheduler.pending(),
    );
  }

  void _reload() => setState(() => _diagnostics = _loadDiagnostics());

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPrefsProvider);

    return GradientScaffold(
      body: SafeArea(
        child: Column(children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                SectionHeader(title: 'AVISOS DEL CAMINO'),
                prefsAsync.when(
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(error: e),
                  data: (prefs) => _PrefsCard(prefs: prefs, onChanged: _reload),
                ),
                const SizedBox(height: 20),
                SectionHeader(title: 'SONIDO Y MOVIMIENTO'),
                const _SfxToggleCard(),
                const SizedBox(height: 20),
                SectionHeader(title: 'DATOS DE USO'),
                const _UsageDataCard(),
                const SizedBox(height: 20),
                SectionHeader(title: 'DIAGNÓSTICO'),
                FutureBuilder<_Diagnostics>(
                  future: _diagnostics,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: AppColors.gold));
                    }
                    return _DiagnosticsCard(
                      data: snap.data!,
                      onReload: _reload,
                    );
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          gradient: AppGradients.header,
          border: Border(bottom: BorderSide(color: AppColors.bgLine)),
        ),
        child: Row(children: [
          GameBackButton(onTap: () => context.pop()),
          const SizedBox(width: 12),
          Text('Ajustes', style: AppTextStyles.titleLarge),
        ]),
      );
}

class _Diagnostics {
  final NotificationPermission permission;
  final List<ScheduledNotification> pending;
  const _Diagnostics({required this.permission, required this.pending});
}

// ─── Preferencias ─────────────────────────────────────────────────────────────
class _PrefsCard extends ConsumerWidget {
  final NotificationPrefs prefs;
  final VoidCallback onChanged;
  const _PrefsCard({required this.prefs, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationPrefsProvider.notifier);
    return GameCard(
      child: Column(children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: prefs.enabled,
          activeThumbColor: AppColors.gold,
          title: Text('Recibir avisos', style: AppTextStyles.bodyLarge),
          subtitle: Text(
            'Nunca entre las 22 y las 8, salvo un evento de una misión que '
            'ya está en marcha. Máximo 4 por día.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.35),
          ),
          onChanged: (v) async {
            await notifier.setEnabled(v);
            onChanged();
          },
        ),
        if (prefs.enabled) ...[
          const Divider(color: AppColors.bgLine),
          for (final kind in NotificationKind.values)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: !prefs.muted.contains(kind),
              activeThumbColor: AppColors.gold,
              title: Text(kind.label, style: AppTextStyles.bodyLarge),
              subtitle: Text(kind.description,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.35)),
              onChanged: (_) async {
                await notifier.toggleKind(kind);
                onChanged();
              },
            ),
        ],
      ]),
    );
  }
}

// ─── Diagnóstico ──────────────────────────────────────────────────────────────
class _DiagnosticsCard extends ConsumerWidget {
  final _Diagnostics data;
  final VoidCallback onReload;
  const _DiagnosticsCard({required this.data, required this.onReload});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduler = ref.read(notificationSchedulerProvider);
    final fmt = DateFormat('d/MM HH:mm');
    final (permLabel, permColor) = switch (data.permission) {
      NotificationPermission.granted => ('Concedido', AppColors.green),
      NotificationPermission.denied => ('Denegado', AppColors.red),
      NotificationPermission.notRequested => (
          'Todavía no se pidió',
          AppColors.amber
        ),
    };

    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.verified_user_outlined, size: 15, color: permColor),
          const SizedBox(width: 7),
          Text('Permiso del sistema: ',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
          Text(permLabel,
              style: AppTextStyles.fredoka(12,
                  color: permColor, weight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        Text('${data.pending.length} aviso(s) programado(s)',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          'iOS descarta lo que pase de 64 pendientes: por eso se programan '
          'solo los dos próximos eventos de cada misión.',
          style: AppTextStyles.bodySmall.copyWith(height: 1.35),
        ),
        const SizedBox(height: 12),
        if (data.pending.isEmpty)
          Text('Nada en la cola. Aceptá una misión para que se programen.',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12))
        else
          ...data.pending.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_iconFor(n.kind),
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title,
                                  style: AppTextStyles.fredoka(12,
                                      color: AppColors.textPrimary)),
                              Text(n.body,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(height: 1.3)),
                            ]),
                      ),
                      const SizedBox(width: 8),
                      Text(fmt.format(n.at),
                          style:
                              AppTextStyles.fredoka(12, color: AppColors.gold)),
                    ]),
              )),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: GameButton(
              label: 'PROBAR EN 10s',
              icon: Icons.notifications_active_outlined,
              fontSize: 13,
              onTap: () async {
                await scheduler.fireTestNotification();
                if (!context.mounted) return;
                showRewardToast(context, const [],
                    note: 'Cerrá la app: el aviso llega en 10 segundos.');
                onReload();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GameButton(
              label: 'RECARGAR',
              icon: Icons.refresh,
              fontSize: 13,
              gradient: AppGradients.sky,
              shadowColor: AppColors.skyDark,
              onTap: onReload,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () async {
              await scheduler.cancelAll();
              onReload();
            },
            child: Text('Cancelar todos los avisos',
                style:
                    AppTextStyles.fredoka(12, color: AppColors.textSecondary)),
          ),
        ),
      ]),
    ).animate().fadeIn();
  }

  IconData _iconFor(NotificationKind kind) => switch (kind) {
        NotificationKind.event => Icons.warning_amber_rounded,
        NotificationKind.delivery => Icons.inventory_2_outlined,
        NotificationKind.idle => Icons.hotel_outlined,
        NotificationKind.contracts => Icons.assignment_outlined,
      };
}

/// Sonido, vibración y movimiento: lo sensorial del juego, en una card.
class _SfxToggleCard extends ConsumerStatefulWidget {
  const _SfxToggleCard();

  @override
  ConsumerState<_SfxToggleCard> createState() => _SfxToggleCardState();
}

class _SfxToggleCardState extends ConsumerState<_SfxToggleCard> {
  bool _sfx = true;
  bool _haptics = true;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = ref.read(playerProgressProvider);
    final sfx = await progress.isSfxEnabled();
    final haptics = await progress.isHapticsEnabled();
    final reduce = await progress.isReduceMotion();
    if (!mounted) return;
    setState(() {
      _sfx = sfx;
      _haptics = haptics;
      _reduceMotion = reduce;
    });
  }

  Widget _toggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: AppTextStyles.fredoka(14)),
        subtitle: Text(subtitle, style: AppTextStyles.bodyMedium),
        value: value,
        activeThumbColor: AppColors.gold,
        onChanged: onChanged,
      );

  @override
  Widget build(BuildContext context) {
    final progress = ref.read(playerProgressProvider);
    return GameCard(
      child: Column(children: [
        _toggle(
          title: 'Efectos de sonido',
          subtitle: 'Botones, resultados, entregas y cobros',
          value: _sfx,
          onChanged: (v) async {
            await progress.setSfxEnabled(v);
            ref.read(sfxServiceProvider).setEnabled(v);
            setState(() => _sfx = v);
            if (v) AppFeedback.toggle();
          },
        ),
        _toggle(
          title: 'Vibración',
          subtitle: 'Un golpe suave al tocar y al cobrar',
          value: _haptics,
          onChanged: (v) async {
            await progress.setHapticsEnabled(v);
            AppFeedback.hapticsEnabled = v;
            setState(() => _haptics = v);
            if (v) AppFeedback.toggle();
          },
        ),
        _toggle(
          title: 'Animaciones reducidas',
          subtitle: 'Menos movimiento: transiciones cortas y sin sacudidas',
          value: _reduceMotion,
          onChanged: (v) async {
            await progress.setReduceMotion(v);
            AppMotion.userPrefersReduced.value = v;
            setState(() => _reduceMotion = v);
          },
        ),
      ]),
    );
  }
}

// ─── Datos de uso ─────────────────────────────────────────────────────────────
/// Opt-out de estadísticas y, para la beta, lo que el dispositivo sabe de
/// sus propias sesiones, con un botón para copiarlo y mandarlo.
class _UsageDataCard extends ConsumerStatefulWidget {
  const _UsageDataCard();

  @override
  ConsumerState<_UsageDataCard> createState() => _UsageDataCardState();
}

class _UsageDataCardState extends ConsumerState<_UsageDataCard> {
  bool _enabled = true;
  RetentionLog? _log;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await ref.read(playerProgressProvider).isAnalyticsEnabled();
    final log = await ref.read(retentionRepositoryProvider).load();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _log = log;
    });
  }

  Future<void> _copy() async {
    final json = await ref.read(analyticsBufferProvider).export(_log);
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    showGameSnack(context, 'Datos copiados. Pegalos en un mensaje.');
  }

  @override
  Widget build(BuildContext context) {
    final log = _log;
    final day = log?.dayIndex(DateTime.now()) ?? 0;
    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title:
              Text('Compartir estadísticas', style: AppTextStyles.fredoka(14)),
          subtitle: Text(
              'Qué rutas jugás y cuándo volvés. Anónimo: sin tu nombre '
              'ni nada que te identifique.',
              style: AppTextStyles.bodyMedium),
          value: _enabled,
          activeThumbColor: AppColors.gold,
          onChanged: (v) async {
            await ref.read(playerProgressProvider).setAnalyticsEnabled(v);
            ref.read(analyticsProvider).enabled = v;
            setState(() => _enabled = v);
          },
        ),
        if (log != null) ...[
          const SizedBox(height: 8),
          Text(
            'Día ${day + 1} desde que empezaste · '
            '${log.daysActive} '
            '${log.daysActive == 1 ? 'día jugado' : 'días jugados'} · '
            '${log.totalSessions} '
            '${log.totalSessions == 1 ? 'sesión' : 'sesiones'}',
            style: AppTextStyles.bodySmall,
          ),
        ],
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded,
                size: 16, color: AppColors.textSecondary),
            label: Text('Copiar datos para el equipo',
                style:
                    AppTextStyles.fredoka(12, color: AppColors.textSecondary)),
          ),
        ),
      ]),
    );
  }
}
