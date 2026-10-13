import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de onboarding / engagement (checklist + tooltips + cosmética).
class PlayerProgress {
  static const _kChecklist = 'primeros_pasos_v1';
  static const _kChecklistClaimed = 'primeros_pasos_claimed_v1';
  static const _kTooltipHome = 'tooltip_home_seen_v1';
  static const _kTooltipEvent = 'tooltip_event_seen_v1';
  static const _kTooltipShop = 'tooltip_shop_seen_v1';
  // Los títulos (cosmetic_titles_v1) migraron a progression_v2:
  // ver LocalProgressionRepository.
  static const _kAdsTravelToday = 'ads_travel_day_v1';
  static const _kAdsTravelCount = 'ads_travel_count_v1';
  static const _kAdsDoublePayDay = 'ads_double_pay_day_v1';
  static const _kSfxEnabled = 'sfx_enabled_v1';
  static const _kMusicEnabled = 'music_enabled_v1';
  static const _kMusicVolume = 'music_volume_v1';
  static const _kHapticsEnabled = 'haptics_enabled_v1';
  static const _kReduceMotion = 'reduce_motion_v1';
  static const _kAnalytics = 'analytics_enabled_v1';

  // Checklist task ids (GDD §7)
  static const taskFirstRealRoute = 'first_real_route';
  static const taskBuyItem = 'buy_item';
  static const taskLevelSkill = 'level_skill';
  static const taskViewGuild = 'view_guild';
  static const taskEnableNotifs = 'enable_notifs';

  static const allTasks = [
    taskFirstRealRoute,
    taskBuyItem,
    taskLevelSkill,
    taskViewGuild,
    taskEnableNotifs,
  ];

  Future<Set<String>> getCompletedTasks() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_kChecklist) ?? []).toSet();
  }

  Future<void> completeTask(String taskId) async {
    final p = await SharedPreferences.getInstance();
    final current = (p.getStringList(_kChecklist) ?? []).toSet()..add(taskId);
    await p.setStringList(_kChecklist, current.toList());
  }

  Future<bool> isChecklistClaimed() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kChecklistClaimed) ?? false;
  }

  Future<void> markChecklistClaimed() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kChecklistClaimed, true);
  }

  Future<bool> tooltipSeen(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(key) ?? false;
  }

  Future<void> markTooltipSeen(String key) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, true);
  }

  Future<bool> get homeTooltipSeen => tooltipSeen(_kTooltipHome);
  Future<bool> get eventTooltipSeen => tooltipSeen(_kTooltipEvent);
  Future<bool> get shopTooltipSeen => tooltipSeen(_kTooltipShop);

  Future<void> markHomeTooltipSeen() => markTooltipSeen(_kTooltipHome);
  Future<void> markEventTooltipSeen() => markTooltipSeen(_kTooltipEvent);
  Future<void> markShopTooltipSeen() => markTooltipSeen(_kTooltipShop);

  /// Adelantos −30 min usados hoy; el tope diario es remoto
  /// (`RemoteFlags.travelAdsPerDay`, GDD §6.4).
  Future<int> travelAdsUsedToday() async {
    final p = await SharedPreferences.getInstance();
    final today = _dayKey();
    if (p.getString(_kAdsTravelToday) != today) return 0;
    return p.getInt(_kAdsTravelCount) ?? 0;
  }

  Future<void> recordTravelAd() async {
    final p = await SharedPreferences.getInstance();
    final today = _dayKey();
    if (p.getString(_kAdsTravelToday) != today) {
      await p.setString(_kAdsTravelToday, today);
      await p.setInt(_kAdsTravelCount, 1);
    } else {
      await p.setInt(_kAdsTravelCount, (p.getInt(_kAdsTravelCount) ?? 0) + 1);
    }
  }

  Future<bool> doublePayUsedToday() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAdsDoublePayDay) == _dayKey();
  }

  Future<void> markDoublePayUsed() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAdsDoublePayDay, _dayKey());
  }

  Future<bool> isSfxEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kSfxEnabled) ?? true;
  }

  Future<void> setSfxEnabled(bool enabled) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSfxEnabled, enabled);
  }

  Future<bool> isMusicEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kMusicEnabled) ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kMusicEnabled, enabled);
  }

  /// Volumen de la música (0-1); null si el jugador nunca lo tocó.
  Future<double?> musicVolume() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_kMusicVolume);
  }

  Future<void> setMusicVolume(double volume) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kMusicVolume, volume);
  }

  Future<bool> isHapticsEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kHapticsEnabled) ?? true;
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kHapticsEnabled, enabled);
  }

  Future<bool> isReduceMotion() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kReduceMotion) ?? false;
  }

  Future<void> setReduceMotion(bool reduce) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kReduceMotion, reduce);
  }

  /// Compartir estadísticas de uso anónimas (opt-out, encendido por defecto).
  Future<bool> isAnalyticsEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kAnalytics) ?? true;
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAnalytics, enabled);
  }

  String _dayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
