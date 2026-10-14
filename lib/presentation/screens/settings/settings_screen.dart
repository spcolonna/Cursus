// lib/presentation/screens/settings/settings_screen.dart
//
// Ajustes de avisos + panel de diagnóstico.
//
// El panel existe para responder una pregunta concreta en el dispositivo:
// "¿las notificaciones están llegando?". Muestra el permiso y todo lo que
// hay programado con su hora, y permite disparar una de prueba.

import '../../feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../../../infrastructure/l10n/language_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/sky.dart';
import '../../widgets/cloud_widgets.dart';
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
    final l = AppLocalizations.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: Column(children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                SectionHeader(title: l.settingsAlertsHeader),
                prefsAsync.when(
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(error: e),
                  data: (prefs) => _PrefsCard(prefs: prefs, onChanged: _reload),
                ),
                const SizedBox(height: 20),
                SectionHeader(
                    title: l.settingsLanguage.toUpperCase()),
                const _LanguageCard(),
                const SizedBox(height: 20),
                SectionHeader(title: l.settingsSoundHeader),
                const _SfxToggleCard(),
                const SizedBox(height: 20),
                SectionHeader(title: l.settingsUsageHeader),
                const _UsageDataCard(),
                const SizedBox(height: 20),
                SectionHeader(title: l.settingsAccountHeader),
                const AccountCard(),
                const SizedBox(height: 20),
                if (kDebugMode) ...[
                  SectionHeader(title: l.settingsSkyHeader),
                  const _SkyDebugCard(),
                  const SizedBox(height: 20),
                ],
                SectionHeader(title: l.settingsDiagnosticsHeader),
                FutureBuilder<_Diagnostics>(
                  future: _diagnostics,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.ochreDeep));
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
          border: Border(bottom: BorderSide(color: AppColors.paperLine)),
        ),
        child: Row(children: [
          GameBackButton(onTap: () => context.pop()),
          const SizedBox(width: 12),
          Text(AppLocalizations.of(context).settingsTitle,
              style: AppTextStyles.titleLarge),
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
    final l = AppLocalizations.of(context);
    return GameCard(
      child: Column(children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: prefs.enabled,
          title: Text(l.settingsAlertsToggle, style: AppTextStyles.bodyLarge),
          subtitle: Text(
            l.settingsAlertsToggleHint,
            style: AppTextStyles.bodySmall.copyWith(height: 1.35),
          ),
          onChanged: (v) async {
            await notifier.setEnabled(v);
            onChanged();
          },
        ),
        if (prefs.enabled) ...[
          const Divider(color: AppColors.paperLine),
          for (final kind in NotificationKind.values)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: !prefs.muted.contains(kind),
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
    final l = AppLocalizations.of(context);
    final fmt = DateFormat.Md().add_Hm();
    final (permLabel, permColor) = switch (data.permission) {
      NotificationPermission.granted => (l.permGranted, AppColors.verdigris),
      NotificationPermission.denied => (l.permDenied, AppColors.cinnabar),
      NotificationPermission.notRequested => (
          l.permNotRequested,
          AppColors.sienna
        ),
    };

    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.verified_user_outlined, size: 15, color: permColor),
          const SizedBox(width: 7),
          Text(l.permSystemLabel,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
          Text(permLabel,
              style: AppTextStyles.ui(12,
                  color: permColor, weight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        Text(l.diagScheduled(data.pending.length),
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          l.diagIosLimit,
          style: AppTextStyles.bodySmall.copyWith(height: 1.35),
        ),
        const SizedBox(height: 12),
        if (data.pending.isEmpty)
          Text(l.diagQueueEmpty,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12))
        else
          ...data.pending.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_iconFor(n.kind),
                          size: 14, color: AppColors.inkSoft),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title,
                                  style: AppTextStyles.ui(12,
                                      color: AppColors.ink)),
                              Text(n.body,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(height: 1.3)),
                            ]),
                      ),
                      const SizedBox(width: 8),
                      Text(fmt.format(n.at),
                          style:
                              AppTextStyles.ui(12, color: AppColors.ochreDeep)),
                    ]),
              )),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: GameButton(
              label: l.diagTest,
              icon: Icons.notifications_active_outlined,
              fontSize: 13,
              onTap: () async {
                await scheduler.fireTestNotification();
                if (!context.mounted) return;
                showRewardToast(context, const [],
                    note: l.diagTestNote);
                onReload();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GameButton(
              label: l.diagReload,
              icon: Icons.refresh,
              fontSize: 13,
              variant: GameButtonVariant.info,
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
            child: Text(l.diagCancelAll,
                style: AppTextStyles.ui(12, color: AppColors.inkSoft)),
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

// ─── Cielo: hora fija para QA (solo debug) ────────────────────────────────────
class _SkyDebugCard extends ConsumerWidget {
  const _SkyDebugCard();

  static String _fmt(double h) =>
      '${h.floor().toString().padLeft(2, '0')}:${((h % 1) * 60).round().toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixed = ref.watch(debugSkyHourProvider);
    final sky = ref.watch(skyPaletteProvider);
    final set = ref.read(debugSkyHourProvider.notifier);
    final l = AppLocalizations.of(context);
    final phase = switch (sky.phase) {
      SkyPhase.dawn => l.skyDawn,
      SkyPhase.day => l.skyDay,
      SkyPhase.dusk => l.skyDusk,
      SkyPhase.night => l.skyNight,
    };
    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            fixed == null
                ? l.skyRealClock(_fmt(sky.hour), phase)
                : l.skyFixedHour(_fmt(sky.hour), phase),
            style: AppTextStyles.ui(14, weight: FontWeight.w600)),
        Slider(
          value: sky.hour.clamp(0, 23.99),
          max: 23.99,
          onChanged: (v) => set.state = v,
        ),
        Wrap(spacing: 8, runSpacing: 8, children: [
          // Herramienta de QA: botones de contorno en tinta, sin rol de color.
          for (final h in [6.5, 13.0, 19.25, 23.0])
            OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.ink),
                onPressed: () => set.state = h,
                child: Text(_fmt(h))),
          OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.ink),
              onPressed: () => set.state = null,
              child: Text(l.skyClock)),
        ]),
      ]),
    );
  }
}

/// Sonido, música, vibración y movimiento: lo sensorial del juego, en una card.
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
        title: Text(title, style: AppTextStyles.ui(14)),
        subtitle: Text(subtitle, style: AppTextStyles.bodyMedium),
        value: value,
        onChanged: onChanged,
      );

  @override
  Widget build(BuildContext context) {
    final progress = ref.read(playerProgressProvider);
    // La música lee su estado del servicio: main.dart ya lo cargó de prefs.
    final music = ref.read(musicServiceProvider);
    final l = AppLocalizations.of(context);
    return GameCard(
      child: Column(children: [
        _toggle(
          title: l.settingsMusic,
          subtitle: l.settingsMusicHint,
          value: music.enabled,
          onChanged: (v) async {
            music.setEnabled(v);
            setState(() {});
            await progress.setMusicEnabled(v);
          },
        ),
        if (music.enabled)
          Row(children: [
            const Icon(Icons.volume_down, color: AppColors.inkSoft, size: 22),
            Expanded(
              child: Slider(
                value: music.volume,
                semanticFormatterCallback: (v) =>
                    l.settingsMusicVolume((v * 100).round()),
                onChanged: (v) => setState(() => music.setVolume(v)),
                onChangeEnd: progress.setMusicVolume,
              ),
            ),
            const Icon(Icons.volume_up, color: AppColors.inkSoft, size: 22),
          ]),
        _toggle(
          title: l.settingsSfx,
          subtitle: l.settingsSfxHint,
          value: _sfx,
          onChanged: (v) async {
            await progress.setSfxEnabled(v);
            ref.read(sfxServiceProvider).setEnabled(v);
            setState(() => _sfx = v);
            if (v) AppFeedback.toggle();
          },
        ),
        _toggle(
          title: l.settingsHaptics,
          subtitle: l.settingsHapticsHint,
          value: _haptics,
          onChanged: (v) async {
            await progress.setHapticsEnabled(v);
            AppFeedback.hapticsEnabled = v;
            setState(() => _haptics = v);
            if (v) AppFeedback.toggle();
          },
        ),
        _toggle(
          title: l.settingsReduceMotion,
          subtitle: l.settingsReduceMotionHint,
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
  bool _adsPrivacy = false;
  RetentionLog? _log;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await ref.read(playerProgressProvider).isAnalyticsEnabled();
    final log = await ref.read(retentionRepositoryProvider).load();
    var adsPrivacy = false;
    try {
      adsPrivacy =
          await ref.read(rewardedAdsServiceProvider).privacyOptionsRequired;
    } catch (_) {
      // Sin SDK de anuncios (tests, escritorio).
    }
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _adsPrivacy = adsPrivacy;
      _log = log;
    });
  }

  Future<void> _copy() async {
    final json = await ref.read(analyticsBufferProvider).export(_log);
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    showGameSnack(context, AppLocalizations.of(context).usageCopied);
  }

  @override
  Widget build(BuildContext context) {
    final log = _log;
    final day = log?.dayIndex(DateTime.now()) ?? 0;
    final l = AppLocalizations.of(context);
    return GameCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.usageShare, style: AppTextStyles.ui(14)),
          subtitle: Text(
              l.usageShareHint,
              style: AppTextStyles.bodyMedium),
          value: _enabled,
          onChanged: (v) async {
            await ref.read(playerProgressProvider).setAnalyticsEnabled(v);
            ref.read(analyticsProvider).enabled = v;
            setState(() => _enabled = v);
          },
        ),
        if (log != null) ...[
          const SizedBox(height: 8),
          Text(
            l.usageSummary(day + 1, log.daysActive, log.totalSessions),
            style: AppTextStyles.bodySmall,
          ),
        ],
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded,
                size: 16, color: AppColors.inkSoft),
            label: Text(l.usageCopy,
                style: AppTextStyles.ui(12, color: AppColors.inkSoft)),
          ),
        ),
        // GDPR: quien dio (o negó) el consentimiento puede cambiarlo.
        if (_adsPrivacy)
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  ref.read(rewardedAdsServiceProvider).showPrivacyOptions(),
              icon: const Icon(Icons.privacy_tip_outlined,
                  size: 16, color: AppColors.inkSoft),
              label: Text(l.usageAdsPrivacy,
                  style: AppTextStyles.ui(12, color: AppColors.inkSoft)),
            ),
          ),
      ]),
    );
  }
}

// ─── Idioma ───────────────────────────────────────────────────────────────────

class _LanguageCard extends ConsumerStatefulWidget {
  const _LanguageCard();

  @override
  ConsumerState<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends ConsumerState<_LanguageCard> {
  /// null = el del teléfono.
  String? _chosen;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    ref.read(playerProgressProvider).language().then((l) {
      if (!mounted) return;
      setState(() {
        _chosen = l;
        _loaded = true;
      });
    });
  }

  Future<void> _pick(String? lang) async {
    if (lang == _chosen) return;
    setState(() => _chosen = lang);
    await ref.read(playerProgressProvider).setLanguage(lang);
    final effective =
        resolveLanguage(lang, WidgetsBinding.instance.platformDispatcher.locale);
    await applyLanguage(effective);
    ref.read(languageProvider.notifier).state = effective;
    // Lo que ya estaba cargado se vuelve a leer en el idioma nuevo.
    reloadGameState(ref);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final options = <(String?, String)>[
      (null, l.languageSystem),
      ('es', l.languageSpanish),
      ('en', l.languageEnglish),
    ];
    return GameCard(
      child: RadioGroup<String?>(
        groupValue: _chosen,
        onChanged: (v) {
          if (_loaded) _pick(v);
        },
        child: Column(children: [
          for (final (code, label) in options)
            RadioListTile<String?>(
              contentPadding: EdgeInsets.zero,
              value: code,
              activeColor: AppColors.ochreDeep,
              title: Text(label, style: AppTextStyles.ui(14)),
            ),
        ]),
      ),
    );
  }
}
