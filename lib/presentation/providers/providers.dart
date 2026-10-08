import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/static_game_content.dart';
import '../../data/story_content.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/entities/entities.dart';
import '../../domain/entities/guild.dart';
import '../../domain/entities/progression.dart';
import '../../domain/entities/weekly.dart';
import '../../domain/entities/world.dart';
import '../../domain/repositories/content_catalog.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/usecases.dart';
import '../../domain/usecases/progression_usecases.dart';
import '../../domain/usecases/weekly_usecases.dart';
import '../../domain/usecases/analytics_usecases.dart';
import '../../domain/entities/notifications.dart';
import '../../infrastructure/analytics/analytics_service.dart';
import '../../infrastructure/local/local_repositories.dart';
import '../../infrastructure/notifications/notification_service.dart';
import '../../infrastructure/audio/sfx_service.dart';
import '../../infrastructure/audio/music_service.dart';
import '../../infrastructure/progress/player_progress.dart';
import '../../infrastructure/monetization/iap_service.dart';
import '../../infrastructure/monetization/rewarded_ads_service.dart';
import '../theme/sky.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────
final authRepositoryProvider    = Provider<AuthRepository>((_) => LocalAuthRepository());
final messengerRepositoryProvider = Provider<MessengerRepository>((_) => LocalMessengerRepository());
final missionRepositoryProvider = Provider<MissionRepository>((_) => LocalMissionRepository());
final guildRepositoryProvider   = Provider<GuildRepository>((_) => LocalGuildRepository());
final worldRepositoryProvider   = Provider<WorldRepository>((_) => LocalWorldRepository());
final weeklyRepositoryProvider  = Provider<WeeklyRepository>((_) => LocalWeeklyRepository());
final progressionRepositoryProvider =
    Provider<ProgressionRepository>((_) => LocalProgressionRepository());
final notificationSchedulerProvider =
    Provider<NotificationScheduler>((_) => LocalNotificationService());
final playerProgressProvider = Provider<PlayerProgress>((_) => PlayerProgress());
final sfxServiceProvider = Provider<SfxService>((_) => SfxService());
final musicServiceProvider = Provider<MusicService>((_) => MusicService());

// ─── Analytics (ver docs/ANALYTICS.md) ────────────────────────────────────────
final retentionRepositoryProvider =
    Provider<RetentionRepository>((_) => LocalRetentionRepository());
final analyticsBufferProvider =
    Provider<LocalBufferAnalyticsSink>((_) => LocalBufferAnalyticsSink());
/// Para sumar Firebase: agregar su sink a esta lista.
final analyticsProvider = Provider<AnalyticsService>((ref) => AnalyticsService([
      ConsoleAnalyticsSink(),
      ref.read(analyticsBufferProvider),
    ]));
final trackSessionUseCaseProvider = Provider((ref) => TrackSessionUseCase(
    ref.read(retentionRepositoryProvider), ref.read(analyticsProvider)));
final iapServiceProvider = Provider<IapService>((ref) => IapService(
      onPurchased: (productId) async {
        final itemId = IapProducts.shopItemIdForProduct(productId);
        if (itemId == null) return;
        await ref.read(creditPurchaseUseCaseProvider).execute(itemId);
        ref.invalidate(homeProvider);
      },
    ));
final rewardedAdsServiceProvider =
    Provider<RewardedAdsService>((_) => RewardedAdsService());

/// Ruta a abrir porque el jugador tocó un aviso. La escribe `main.dart` y la
/// consume el Home cuando ya está montado (así no la pisa el Splash).
final pendingNotificationRouteProvider = StateProvider<String?>((_) => null);

// ─── Cielo vivo (theme/sky.dart) ──────────────────────────────────────────────
/// Hora fija para QA y tests (Ajustes > Cielo, solo en debug). Null = reloj.
final debugSkyHourProvider = StateProvider<double?>((_) => null);

/// La hora real, una vez por minuto.
final skyClockProvider = StreamProvider<double>((_) async* {
  yield SkyPalette.hourOf(DateTime.now());
  yield* Stream.periodic(
      const Duration(minutes: 1), (_) => SkyPalette.hourOf(DateTime.now()));
});

final skyHourProvider = Provider<double>((ref) =>
    ref.watch(debugSkyHourProvider) ??
    ref.watch(skyClockProvider).valueOrNull ??
    SkyPalette.hourOf(DateTime.now()));

final skyPaletteProvider =
    Provider<SkyPalette>((ref) => SkyPalette.at(ref.watch(skyHourProvider)));

/// Pantalla que corresponde a un aviso tocado; null si no lleva a ningún lado.
String? routeForNotification(String? payload) {
  final target = NotificationTarget.parse(payload);
  if (target == null) return null;
  final m = target.messengerId == null ? '' : '?m=${target.messengerId}';
  return switch (target.kind) {
    NotificationKind.event => '/event$m',
    NotificationKind.delivery => '/mission$m',
    NotificationKind.idle || NotificationKind.contracts => '/home',
  };
}

/// Preferencias de avisos (pantalla de ajustes).
final notificationPrefsProvider =
    AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
        NotificationPrefsNotifier.new);

class NotificationPrefsNotifier extends AsyncNotifier<NotificationPrefs> {
  @override
  Future<NotificationPrefs> build() =>
      ref.read(notificationSchedulerProvider).getPrefs();

  Future<void> toggleKind(NotificationKind kind) async {
    final current = state.valueOrNull ?? const NotificationPrefs();
    await _save(current.toggle(kind));
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationPrefs();
    await _save(current.copyWith(enabled: enabled));
  }

  Future<void> _save(NotificationPrefs next) async {
    await ref.read(notificationSchedulerProvider).savePrefs(next);
    state = AsyncData(next);
    // Reprogramar con las nuevas reglas.
    await ref.read(homeProvider.notifier).syncAllNotifications();
  }
}

// ─── Contenido ────────────────────────────────────────────────────────────────
final gameContentProvider =
    Provider<GameContentCatalog>((_) => const StaticGameContent());

// ─── Use cases ────────────────────────────────────────────────────────────────
final signInUseCaseProvider = Provider((ref) => SignInUseCase(
  ref.read(authRepositoryProvider),
));
final getHomeStateUseCaseProvider = Provider((ref) => GetHomeStateUseCase(
  ref.read(messengerRepositoryProvider),
  ref.read(missionRepositoryProvider),
  ref.read(worldRepositoryProvider),
  ref.read(gameContentProvider),
));
final repairArcStateUseCaseProvider = Provider((ref) => RepairArcStateUseCase(
      ref.read(worldRepositoryProvider),
      ref.read(gameContentProvider),
    ));
final autoResolveExpiredEventsUseCaseProvider =
    Provider((ref) => AutoResolveExpiredEventsUseCase(
  ref.read(messengerRepositoryProvider),
  ref.read(missionRepositoryProvider),
  ref.read(worldRepositoryProvider),
));
final claimChecklistRewardUseCaseProvider =
    Provider((ref) => ClaimChecklistRewardUseCase(
  ref.read(messengerRepositoryProvider),
));
final acceptMissionUseCaseProvider = Provider((ref) => AcceptMissionUseCase(
  ref.read(missionRepositoryProvider),
  ref.read(messengerRepositoryProvider),
  world: ref.read(worldRepositoryProvider),
  content: ref.read(gameContentProvider),
));
final acceptTutorialMissionUseCaseProvider = Provider((ref) => AcceptTutorialUseCase(
  ref.read(missionRepositoryProvider),
  ref.read(messengerRepositoryProvider),
));
final resolveEventUseCaseProvider = Provider((ref) => ResolveEventUseCase(
  ref.read(missionRepositoryProvider),
  ref.read(messengerRepositoryProvider),
  ref.read(worldRepositoryProvider),
  ref.read(gameContentProvider),
));
final acceptStoryMissionUseCaseProvider = Provider((ref) => AcceptStoryMissionUseCase(
  ref.read(missionRepositoryProvider),
  ref.read(messengerRepositoryProvider),
  ref.read(gameContentProvider),
));
final advanceMissionUseCaseProvider = Provider((ref) => AdvanceMissionUseCase(
  ref.read(missionRepositoryProvider),
));
final skipToNextEventUseCaseProvider = Provider((ref) => SkipToNextEventUseCase(
  ref.read(missionRepositoryProvider),
  ref.read(messengerRepositoryProvider),
));
final unlockMessengerSlotUseCaseProvider = Provider((ref) => UnlockMessengerSlotUseCase(
  ref.read(messengerRepositoryProvider),
));
final applyShopItemUseCaseProvider = Provider((ref) => ApplyShopItemUseCase(
  ref.read(messengerRepositoryProvider),
));
final completeMissionUseCaseProvider = Provider((ref) => CompleteMissionUseCase(
  ref.read(missionRepositoryProvider),
  ref.read(messengerRepositoryProvider),
  ref.read(worldRepositoryProvider),
  ref.read(gameContentProvider),
));
final ascendSkillUseCaseProvider = Provider((ref) => AscendSkillUseCase(
  ref.read(messengerRepositoryProvider),
));
final creditPurchaseUseCaseProvider = Provider((ref) => CreditPurchaseUseCase(
  ref.read(messengerRepositoryProvider),
));
final useSkillPickUseCaseProvider = Provider((ref) => UseSkillPickUseCase(
  ref.read(messengerRepositoryProvider),
));
final getGuildStateUseCaseProvider = Provider((ref) => GetGuildStateUseCase(
  ref.read(guildRepositoryProvider),
));
final claimDailyPayUseCaseProvider = Provider((ref) => ClaimDailyPayUseCase(
  ref.read(guildRepositoryProvider),
  ref.read(messengerRepositoryProvider),
));
final recordContractProgressUseCaseProvider =
    Provider((ref) => RecordContractProgressUseCase(
  ref.read(guildRepositoryProvider),
));
final getProgressionUseCaseProvider = Provider((ref) => GetProgressionUseCase(
  ref.read(progressionRepositoryProvider),
  ref.read(messengerRepositoryProvider),
  ref.read(missionRepositoryProvider),
  ref.read(worldRepositoryProvider),
  ref.read(gameContentProvider),
));
final recordProgressUseCaseProvider = Provider((ref) => RecordProgressUseCase(
  ref.read(getProgressionUseCaseProvider),
  ref.read(progressionRepositoryProvider),
  ref.read(messengerRepositoryProvider),
  ref.read(worldRepositoryProvider),
  ref.read(gameContentProvider),
));
final equipTitleUseCaseProvider = Provider((ref) => EquipTitleUseCase(
  ref.read(getProgressionUseCaseProvider),
  ref.read(progressionRepositoryProvider),
));
final rerollContractUseCaseProvider = Provider((ref) => RerollContractUseCase(
  ref.read(guildRepositoryProvider),
  ref.read(worldRepositoryProvider),
  ref.read(gameContentProvider),
));
final getWeeklyUseCaseProvider = Provider((ref) => GetWeeklyUseCase(
  ref.read(weeklyRepositoryProvider),
  ref.read(gameContentProvider),
));
final recordWeeklyProgressUseCaseProvider =
    Provider((ref) => RecordWeeklyProgressUseCase(
          ref.read(getWeeklyUseCaseProvider),
          ref.read(weeklyRepositoryProvider),
          ref.read(gameContentProvider),
        ));
final claimWeeklyUseCaseProvider = Provider((ref) => ClaimWeeklyCommissionUseCase(
  ref.read(getWeeklyUseCaseProvider),
  ref.read(weeklyRepositoryProvider),
  ref.read(messengerRepositoryProvider),
  ref.read(worldRepositoryProvider),
  ref.read(gameContentProvider),
));
final claimContractUseCaseProvider = Provider((ref) => ClaimContractUseCase(
  ref.read(guildRepositoryProvider),
  ref.read(messengerRepositoryProvider),
));

// ─── Auth ─────────────────────────────────────────────────────────────────────
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() => ref.read(authRepositoryProvider).getCurrentUser();

  Future<({bool isFirstLogin})> signInAsGuest({
    String displayName = 'Mensajero',
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signInUseCaseProvider)
        .executeAsGuest(displayName: displayName);
    state = AsyncData(result.user);
    return (isFirstLogin: result.isFirstLogin);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  Future<void> markOnboardingDone() async {
    await ref.read(authRepositoryProvider).markOnboardingDone();
  }
}
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

// ─── Home ─────────────────────────────────────────────────────────────────────
class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() => _load();

  Future<void> refresh() async {
    // No usar AsyncLoading — evita flashes en UI y re-triggers innecesarios
    state = AsyncData(await _load());
  }

  /// Primero repara arcos y auto-resuelve eventos vencidos (escribe), después lee.
  Future<HomeState> _load() async {
    await ref.read(repairArcStateUseCaseProvider).execute();
    // Crea (o migra) la progresión antes de que cualquier acción la registre.
    await ref.read(getProgressionUseCaseProvider).execute();
    final autoResolved =
        await ref.read(autoResolveExpiredEventsUseCaseProvider).execute();
    if (autoResolved.isNotEmpty) {
      _track(AnalyticsEvent.eventsAutoResolved(autoResolved.length));
    }
    final home = await ref
        .read(getHomeStateUseCaseProvider)
        .execute(autoResolved: autoResolved);
    final analytics = ref.read(analyticsProvider);
    analytics.setUserProperty('player_rank', '${home.messenger?.rank ?? 1}');
    analytics.setUserProperty('messengers', '${home.slots.length}');
    return home;
  }

  void _track(AnalyticsEvent e) => ref.read(analyticsProvider).track(e);

  Messenger? _messenger(String? id) {
    final slots = state.valueOrNull?.slots ?? const <MessengerSlot>[];
    if (slots.isEmpty) return null;
    return slots
            .where((s) => s.messenger.id == id)
            .firstOrNull
            ?.messenger ??
        slots.first.messenger;
  }

  int get _busy =>
      state.valueOrNull?.slots.where((s) => s.activeMission != null).length ??
      0;

  void _trackAccept(Mission? m, String kind) {
    if (m == null) return;
    _track(AnalyticsEvent.missionAccept(
      routeId: m.routeId,
      kind: kind,
      rank: _messenger(m.messengerId)?.rank ?? 1,
      minutes: m.deadlineAt.difference(m.startedAt).inMinutes,
      busy: _busy,
    ));
  }

  /// Reprograma los avisos de TODAS las misiones activas a partir del estado
  /// actual. Se llama después de cualquier cosa que mueva el reloj de una
  /// misión: aceptar, resolver un evento, adelantar o entregar. Es idempotente
  /// (cada sync borra y vuelve a programar lo de esa misión), así que es
  /// preferible llamarlo de más que de menos.
  Future<void> syncAllNotifications() async {
    final scheduler = ref.read(notificationSchedulerProvider);
    final current = state.valueOrNull;
    if (current == null) return;
    for (final slot in current.slots) {
      final mission = slot.activeMission;
      if (mission == null) continue;
      await scheduler.syncMission(mission, messengerName: slot.messenger.name);
    }
    final idle = current.slots
        .where((s) =>
            s.activeMission == null &&
            s.messenger.status == MessengerStatus.idle)
        .firstOrNull;
    final guild = await ref.read(guildProvider.future);
    await scheduler.syncReminders(
      idleMessengerName: idle?.messenger.name,
      contractsPending: guild.contracts.any((c) => !c.claimed),
    );
  }

  Future<Mission?> acceptTutorialMission(int index, {String? messengerId}) async {
    final mission = await ref.read(acceptTutorialMissionUseCaseProvider)
        .execute(index, messengerId: messengerId);
    await refresh();
    _track(AnalyticsEvent.tutorialStep(index));
    _trackAccept(mission, 'tutorial');
    await syncAllNotifications();
    return mission;
  }

  Future<Mission?> acceptMission(GameRoute route, {String? messengerId}) async {
    final mission = await ref.read(acceptMissionUseCaseProvider)
        .execute(route, messengerId: messengerId);
    await refresh();
    _trackAccept(mission, 'real');
    await syncAllNotifications();
    return mission;
  }

  Future<EventResolution> resolveEvent({
    required Mission mission,
    required MissionEvent event,
    required EventOption option,
  }) async {
    final result = await ref.read(resolveEventUseCaseProvider).execute(
      mission: mission, event: event, option: option,
    );
    // Progreso de contratos del gremio (resolver eventos / éxitos / usar skill).
    await ref.read(guildProvider.notifier).recordEvent(
      outcome: result.outcome.type,
      usedSkill: option.requiredSkills.keys.firstOrNull,
    );
    await ref.read(weeklyProvider.notifier).recordEvent(result.outcome.type);
    await ref.read(worldProvider.notifier).refresh();
    await ref.read(progressionProvider.notifier).record(
        change: (s) => s.copyWith(eventsResolved: s.eventsResolved + 1));
    await refresh();
    _track(AnalyticsEvent.eventResolved(
      event: event.configId ?? event.title,
      category: event.category.name,
      outcome: result.outcome.type.name,
      risk: result.effectiveRisk,
      score: result.score,
    ));
    final m = _messenger(mission.messengerId);
    for (final skill in result.leveledUpSkills) {
      _track(AnalyticsEvent.skillLevel(
          skill: skill.name, level: m?.skillLevel(skill) ?? 0, via: 'xp'));
    }
    // Subir de nivel por XP también cuenta para "Subí una habilidad".
    if (result.leveledUpSkills.isNotEmpty) {
      await ref
          .read(primerosPasosProvider.notifier)
          .markTask(PlayerProgress.taskLevelSkill);
    }
    // Resolver corre el deadline: reprogramar los avisos.
    await syncAllNotifications();
    return result;
  }

  Future<Mission> acceptStoryMission(StoryMissionConfig config) async {
    final mission =
        await ref.read(acceptStoryMissionUseCaseProvider).execute(config);
    await refresh();
    _track(AnalyticsEvent.storyChapter(
        arcId: config.arcId, chapter: config.stage + 1, variant: config.id));
    _trackAccept(mission, 'story');
    await syncAllNotifications();
    return mission;
  }

  Future<Messenger> useSkillPick({
    required String messengerId,
    required SkillType skill,
  }) async {
    final messenger = await ref.read(useSkillPickUseCaseProvider).execute(
      messengerId: messengerId, skill: skill,
    );
    await ref.read(progressionProvider.notifier).record();
    await refresh();
    _track(AnalyticsEvent.skillLevel(
        skill: skill.name, level: messenger.skillLevel(skill), via: 'pick'));
    return messenger;
  }

  Future<Messenger> ascendSkill({
    required String messengerId,
    required SkillType skill,
  }) async {
    final messenger = await ref.read(ascendSkillUseCaseProvider).execute(
      messengerId: messengerId, skill: skill,
    );
    await ref.read(progressionProvider.notifier).record();
    await refresh();
    _track(AnalyticsEvent.skillLevel(
        skill: skill.name, level: messenger.skillLevel(skill), via: 'ascend'));
    return messenger;
  }

  Future<({Mission mission, int cost})> skipToNextEvent({
    required Mission mission,
    required String messengerId,
  }) async {
    final result = await ref.read(skipToNextEventUseCaseProvider).execute(
      mission: mission, messengerId: messengerId,
    );
    await refresh();
    _track(AnalyticsEvent.skipToEvent(result.cost));
    // Adelantar mueve startedAt y deadlineAt: lo programado ya no sirve.
    await syncAllNotifications();
    return result;
  }

  Future<Messenger> unlockMessengerSlot({
    required Messenger payer,
    required String newName,
    required MessengerGender gender,
  }) async {
    final messenger = await ref.read(unlockMessengerSlotUseCaseProvider).execute(
      payer: payer, newName: newName, gender: gender,
    );
    await ref.read(progressionProvider.notifier).record();
    await refresh();
    _track(AnalyticsEvent.slotUnlock(state.valueOrNull?.slots.length ?? 0));
    return messenger;
  }

  Future<MissionCompletion?> completeMissionByTime(String messengerId) async {
    final active =
        await ref.read(missionRepositoryProvider).getActiveMissionFor(messengerId);
    final tutorialWasDone = state.valueOrNull?.tutorialDone ?? true;
    final completion =
        await ref.read(completeMissionUseCaseProvider).execute(messengerId);
    if (completion != null && active != null) {
      _track(AnalyticsEvent.missionComplete(
        routeId: active.routeId,
        kind: active.isTutorial
            ? 'tutorial'
            : active.arcId != null
                ? 'story'
                : 'real',
        grade: completion.result.grade,
        denarios: completion.denariosDelta,
      ));
      if (completion.endingTitle != null) {
        _track(AnalyticsEvent.arcComplete(
            arcId: active.arcId ?? '', ending: completion.endingTitle!));
      }
    }
    if (completion != null) {
      await ref
          .read(guildProvider.notifier)
          .recordDelivery(completion.result.grade);
      if (active != null) {
        await ref
            .read(weeklyProvider.notifier)
            .recordDelivery(active, completion.result.grade);
      }
      await ref.read(worldProvider.notifier).refresh();

      // Checklist: primera ruta real (no tutorial).
      if (active != null && !active.isTutorial) {
        await ref
            .read(primerosPasosProvider.notifier)
            .markTask(PlayerProgress.taskFirstRealRoute);
      }

      // Estadísticas, logros y el título de final de arco.
      if (active != null) {
        await ref.read(progressionProvider.notifier).record(
          change: (s) => statsAfterDelivery(s, active,
              completion.result.grade, completion.denariosDelta),
          titles: [if (completion.endingTitle != null) completion.endingTitle!],
        );
      }
    }
    await refresh();
    if (!tutorialWasDone && (state.valueOrNull?.tutorialDone ?? false)) {
      _track(AnalyticsEvent.tutorialComplete());
    }
    await syncAllNotifications();
    return completion;
  }

  /// Rewarded ad: adelanta [minutes] el reloj de la misión (GDD §6.4).
  Future<void> advanceMissionMinutes(String messengerId, int minutes) async {
    final updated = await ref
        .read(advanceMissionUseCaseProvider)
        .execute(messengerId, minutes);
    if (updated == null) return;
    _track(AnalyticsEvent.rewardedAd('advance_$minutes'));
    await refresh();
    await syncAllNotifications();
    // Reiniciar ticker de progreso
    ref.read(missionProgressProvider.notifier).start(updated);
  }
}
final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

// ─── Guild (tablón de contratos + paga diaria) ────────────────────────────────
class GuildNotifier extends AsyncNotifier<GuildState> {
  @override
  Future<GuildState> build() => ref.read(getGuildStateUseCaseProvider).execute();

  Future<void> refresh() async {
    final newState = await ref.read(getGuildStateUseCaseProvider).execute();
    state = AsyncData(newState);
  }

  Future<({DailyPayReward reward, int day})> claimDailyPay() async {
    final result = await ref.read(claimDailyPayUseCaseProvider).execute();
    ref.read(analyticsProvider).track(AnalyticsEvent.dailyPay(result.day));
    await ref.read(progressionProvider.notifier).record(
        change: (s) => s.recordDailyPay(DateTime.now()));
    await refresh();
    await ref.read(homeProvider.notifier).refresh(); // monedas del mensajero
    return result;
  }

  Future<ContractReward> claimContract(String templateId) async {
    final result =
        await ref.read(claimContractUseCaseProvider).execute(templateId);
    state = AsyncData(result.state);
    ref.read(analyticsProvider).track(AnalyticsEvent.contractClaim(templateId));
    await ref.read(progressionProvider.notifier).record(
        change: (s) => s.copyWith(
              contractsClaimed: s.contractsClaimed + 1,
              denariosEarned: s.denariosEarned + result.reward.denarios,
            ));
    await ref.read(homeProvider.notifier).refresh();
    return result.reward;
  }

  /// Cambia un contrato del tablón por otro (favor del Gremio, 1 por día).
  Future<void> reroll(String templateId) async {
    state = AsyncData(
        await ref.read(rerollContractUseCaseProvider).execute(templateId));
    ref.read(analyticsProvider).track(AnalyticsEvent.contractReroll());
  }

  Future<void> recordDelivery(String grade) async {
    final newState = await ref
        .read(recordContractProgressUseCaseProvider)
        .recordDelivery(grade);
    state = AsyncData(newState);
  }

  Future<void> recordEvent({
    required OutcomeType outcome,
    SkillType? usedSkill,
  }) async {
    final newState = await ref
        .read(recordContractProgressUseCaseProvider)
        .recordEvent(outcome: outcome, usedSkill: usedSkill);
    state = AsyncData(newState);
  }
}
final guildProvider =
    AsyncNotifierProvider<GuildNotifier, GuildState>(GuildNotifier.new);

// ─── World (reputación, flags, diario, arcos) ─────────────────────────────────
class WorldNotifier extends AsyncNotifier<WorldState> {
  @override
  Future<WorldState> build() => ref.read(worldRepositoryProvider).getState();

  /// Relee el mundo. Si una facción subió de escalón desde la última
  /// lectura, lo celebra (vale para eventos, entregas y encargos).
  Future<void> refresh() async {
    final before = state.valueOrNull;
    final newState = await ref.read(worldRepositoryProvider).getState();
    state = AsyncData(newState);
    if (before != null) {
      ref
          .read(celebrationQueueProvider.notifier)
          .enqueueFactions(newState.tierUpsSince(before));
    }
  }
}
final worldProvider =
    AsyncNotifierProvider<WorldNotifier, WorldState>(WorldNotifier.new);

// ─── Encargos semanales ───────────────────────────────────────────────────────
class WeeklyNotifier extends AsyncNotifier<WeeklyState> {
  @override
  Future<WeeklyState> build() => ref.read(getWeeklyUseCaseProvider).execute();

  Future<void> refresh() async {
    state = AsyncData(await ref.read(getWeeklyUseCaseProvider).execute());
  }

  Future<void> recordDelivery(Mission mission, String grade) async {
    try {
      state = AsyncData(await ref
          .read(recordWeeklyProgressUseCaseProvider)
          .recordDelivery(mission, grade));
    } catch (_) {
      // El avance semanal nunca rompe la entrega.
    }
  }

  Future<void> recordEvent(OutcomeType outcome) async {
    try {
      state = AsyncData(await ref
          .read(recordWeeklyProgressUseCaseProvider)
          .recordEvent(outcome));
    } catch (_) {}
  }

  Future<WeeklyCommissionDef> claim(String id) async {
    final result = await ref.read(claimWeeklyUseCaseProvider).execute(id);
    state = AsyncData(result.state);
    ref.read(analyticsProvider).track(AnalyticsEvent.weeklyClaim(id));
    await ref.read(worldProvider.notifier).refresh();
    await ref.read(progressionProvider.notifier).record(
        change: (s) =>
            s.copyWith(denariosEarned: s.denariosEarned + result.def.denarios));
    await ref.read(homeProvider.notifier).refresh();
    return result.def;
  }
}
final weeklyProvider =
    AsyncNotifierProvider<WeeklyNotifier, WeeklyState>(WeeklyNotifier.new);

// ─── Mission Progress (timer para la mission screen) ──────────────────────────
class MissionProgressState {
  final double progress;
  final MissionEvent? blockedByEvent;
  final bool completed;       // timer llegó a 100% sin eventos bloqueantes
  final bool readyToDeliver;  // listo para que el jugador apriete "Entregar"

  const MissionProgressState({
    required this.progress,
    this.blockedByEvent,
    this.completed = false,
    this.readyToDeliver = false,
  });

  MissionProgressState copyWith({
    double? progress,
    MissionEvent? blockedByEvent,
    bool clearEvent = false,
    bool? completed,
    bool? readyToDeliver,
  }) => MissionProgressState(
    progress: progress ?? this.progress,
    blockedByEvent: clearEvent ? null : (blockedByEvent ?? this.blockedByEvent),
    completed: completed ?? this.completed,
    readyToDeliver: readyToDeliver ?? this.readyToDeliver,
  );
}

class MissionProgressNotifier extends Notifier<MissionProgressState> {
  Timer? _timer;
  bool _disposed = false;

  @override
  MissionProgressState build() {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
      _timer = null;
    });
    _disposed = false;
    return const MissionProgressState(progress: 0.0);
  }

  void start(Mission mission) {
    _timer?.cancel();
    _timer = null;
    _notifiedEvents.clear(); // resetear para la nueva misión
    if (_disposed) return;
    _tick(mission);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      final current = ref.read(homeProvider).valueOrNull
          ?.slots
          .where((s) => s.messenger.id == mission.messengerId)
          .firstOrNull
          ?.activeMission;
      if (current != null) {
        _tick(current);
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  // Rastreamos eventos ya notificados para no invalidar en cada tick
  final Set<String> _notifiedEvents = {};

  void _tick(Mission mission) {
    if (_disposed) return;
    final now = DateTime.now();

    // Solo invalidar homeProvider la PRIMERA vez que cada evento llega
    for (final e in mission.events) {
      if (e.isUnresolved &&
          !now.isBefore(e.triggersAt) &&
          !_notifiedEvents.contains(e.id)) {
        _notifiedEvents.add(e.id);
        ref.invalidate(homeProvider);
        break;
      }
    }
    final blocking = mission.blockingEventAt(now);
    final readyToDeliver = mission.readyToDeliverAt(now);

    state = MissionProgressState(
      progress: readyToDeliver ? 1.0 : mission.progressAt(now),
      blockedByEvent: blocking,
      completed: false,         // nunca auto-completa
      readyToDeliver: readyToDeliver,
    );

    // Si llegó a 100%, parar el timer — el jugador entrega manualmente
    if (readyToDeliver) {
      _timer?.cancel();
      _timer = null;
    }
  }
}

final missionProgressProvider =
NotifierProvider<MissionProgressNotifier, MissionProgressState>(
  MissionProgressNotifier.new,
);

// ─── Progresión: logros, títulos y celebraciones ──────────────────────────────
class ProgressionNotifier extends AsyncNotifier<ProgressionState> {
  @override
  Future<ProgressionState> build() =>
      ref.read(getProgressionUseCaseProvider).execute();

  /// Registra un avance y encola lo que haya para celebrar. Nunca rompe la
  /// acción que lo disparó: si algo falla, la progresión se pone al día en
  /// el próximo registro (lo que se lee del estado no se pierde).
  Future<ProgressionUpdate?> record({
    PlayerStats Function(PlayerStats)? change,
    Iterable<String> titles = const [],
  }) async {
    try {
      final update = await ref
          .read(recordProgressUseCaseProvider)
          .execute(change: change, titles: titles);
      state = AsyncData(update.state);
      ref.read(celebrationQueueProvider.notifier).enqueue(update);
      return update;
    } catch (_) {
      return null;
    }
  }

  /// Equipa [title] (o lo saca, si es null o ya estaba puesto).
  Future<void> toggleTitle(String? title) async {
    state = AsyncData(await ref.read(equipTitleUseCaseProvider).execute(title));
  }
}

final progressionProvider =
    AsyncNotifierProvider<ProgressionNotifier, ProgressionState>(
        ProgressionNotifier.new);

/// Títulos ganados y el que el jugador lleva puesto (se ve bajo su nombre).
typedef TitlesState = ({List<String> unlocked, String? equipped});

final titlesProvider = Provider<AsyncValue<TitlesState>>((ref) =>
    ref.watch(progressionProvider).whenData(
        (p) => (unlocked: p.titles, equipped: p.equippedTitle)));

/// Algo para festejar: un logro, un rango nuevo o un escalón de facción.
/// Se muestran de a uno.
class Celebration {
  final AchievementDef? achievement;
  final int? rank;
  final Faction? faction;
  final FactionTier? tier;
  const Celebration.achievement(AchievementDef this.achievement)
      : rank = null,
        faction = null,
        tier = null;
  const Celebration.rank(int this.rank)
      : achievement = null,
        faction = null,
        tier = null;
  const Celebration.faction(Faction this.faction, FactionTier this.tier)
      : achievement = null,
        rank = null;
}

class CelebrationQueue extends Notifier<List<Celebration>> {
  @override
  List<Celebration> build() => const [];

  void enqueue(ProgressionUpdate update) {
    if (update.isEmpty) return;
    final analytics = ref.read(analyticsProvider);
    if (update.rankReached != null) {
      analytics.track(AnalyticsEvent.rankUp(update.rankReached!));
    }
    for (final a in update.unlocked) {
      analytics.track(AnalyticsEvent.achievement(a.id));
    }
    state = [
      ...state,
      // El rango primero: es el momento grande; los logros, después.
      if (update.rankReached != null) Celebration.rank(update.rankReached!),
      ...update.unlocked.map(Celebration.achievement),
    ];
  }

  void enqueueFactions(Map<Faction, FactionTier> ups) {
    if (ups.isEmpty) return;
    for (final e in ups.entries) {
      ref.read(analyticsProvider).track(AnalyticsEvent.factionTier(
          faction: e.key.name, tier: e.value.name));
    }
    state = [
      ...state,
      for (final e in ups.entries) Celebration.faction(e.key, e.value),
    ];
  }

  void pop() {
    if (state.isNotEmpty) state = state.sublist(1);
  }
}

final celebrationQueueProvider =
    NotifierProvider<CelebrationQueue, List<Celebration>>(CelebrationQueue.new);

// ─── Completed missions ───────────────────────────────────────────────────────
final completedMissionsProvider = FutureProvider<List<Mission>>((ref) {
  return ref.read(missionRepositoryProvider).getCompletedMissions();
});

// ─── Primeros pasos (checklist post-tutorial) ─────────────────────────────────
class PrimerosPasosState {
  final Set<String> completed;
  final bool claimed;
  final bool tutorialDone;

  const PrimerosPasosState({
    required this.completed,
    required this.claimed,
    required this.tutorialDone,
  });
}

class PrimerosPasosNotifier extends AsyncNotifier<PrimerosPasosState> {
  @override
  Future<PrimerosPasosState> build() async {
    final progress = ref.read(playerProgressProvider);
    final home = await ref.watch(homeProvider.future);
    return PrimerosPasosState(
      completed: await progress.getCompletedTasks(),
      claimed: await progress.isChecklistClaimed(),
      tutorialDone: home.tutorialDone,
    );
  }

  Future<void> markTask(String taskId) async {
    final progress = ref.read(playerProgressProvider);
    final current = await progress.getCompletedTasks();
    if (current.contains(taskId)) return;
    await progress.completeTask(taskId);
    ref.invalidateSelf();
  }

  Future<void> claimReward() async {
    final current = state.valueOrNull;
    if (current == null || current.claimed) return;
    if (!PlayerProgress.allTasks.every(current.completed.contains)) return;

    final credited =
        await ref.read(claimChecklistRewardUseCaseProvider).execute();
    if (!credited) return;
    await ref.read(playerProgressProvider).markChecklistClaimed();
    ref.invalidate(homeProvider);
    ref.invalidateSelf();
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

final primerosPasosProvider =
    AsyncNotifierProvider<PrimerosPasosNotifier, PrimerosPasosState>(
        PrimerosPasosNotifier.new);