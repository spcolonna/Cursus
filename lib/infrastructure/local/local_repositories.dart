import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/entities.dart';
import '../../domain/entities/guild.dart';
import '../../domain/entities/notifications.dart';
import '../../domain/entities/world.dart';
import '../../domain/repositories/repositories.dart';
import '../../data/game_content.dart';
import '../../data/game_content_expansion.dart';
import '../../data/story_content.dart';

const _uuid = Uuid();

/// Cola de escrituras: SharedPreferences no tiene transacciones y los
/// read-modify-write (`saveMessenger`, `saveMission`…) pisan cambios si dos
/// corren a la vez. Todo lo que lee una lista y la vuelve a escribir pasa por
/// acá, de a uno.
class _WriteQueue {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }
}

final _writes = _WriteQueue();

/// Índice de enum tolerante: un valor fuera de rango (dato viejo o
/// corrupto) cae en [fallback] en vez de romper la carga.
T _enumAt<T>(List<T> values, Object? index, T fallback) {
  if (index is! int || index < 0 || index >= values.length) return fallback;
  return values[index];
}

// ─── Auth ─────────────────────────────────────────────────────────────────────
class LocalAuthRepository implements AuthRepository {
  static const _kId   = 'user_id';
  static const _kName = 'user_name';
  static const _kOnb  = 'onboarding_done';

  @override
  Future<User?> getCurrentUser() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString(_kId);
    if (id == null) return null;
    return User(id: id, name: p.getString(_kName) ?? 'Mensajero',
        isFirstLogin: !(p.getBool(_kOnb) ?? false));
  }

  @override
  Future<User> signIn({required String name}) async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString(_kId) ?? _uuid.v4();
    await p.setString(_kId, id);
    await p.setString(_kName, name);
    return User(id: id, name: name, isFirstLogin: !(p.getBool(_kOnb) ?? false));
  }

  @override
  Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kId);
    await p.remove(_kName);
  }

  @override
  Future<bool> isFirstLogin() async {
    final p = await SharedPreferences.getInstance();
    return !(p.getBool(_kOnb) ?? false);
  }

  @override
  Future<void> markOnboardingDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnb, true);
  }
}

// ─── Messenger ────────────────────────────────────────────────────────────────
class LocalMessengerRepository implements MessengerRepository {
  // Nueva clave: lista de mensajeros
  static const _kMessengers = 'messengers_v2';
  // Clave legacy para migración
  static const _kLegacy     = 'messenger_data';

  @override
  Future<List<Messenger>> getAllMessengers() async {
    final p = await SharedPreferences.getInstance();

    // Migración desde schema viejo (clave legacy)
    if (!p.containsKey(_kMessengers) && p.containsKey(_kLegacy)) {
      final raw = p.getString(_kLegacy);
      if (raw != null) {
        try {
          final m = _fromJson(jsonDecode(raw) as Map<String, dynamic>);
          await saveAllMessengers([m]);
          await p.remove(_kLegacy);
          return [m];
        } catch (_) {
          await p.remove(_kLegacy);
        }
      }
    }

    final raw = p.getString(_kMessengers);
    if (raw == null) return [];
    final List<Messenger> messengers;
    try {
      final list = jsonDecode(raw) as List;
      messengers =
          list.map((j) => _fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      // Nunca tirar la partida en silencio: se guarda una copia para rescate.
      await p.setString('${_kMessengers}_corrupt_backup', raw);
      await p.remove(_kMessengers);
      return [];
    }

    // Hasta la versión 1.0.0+2 cada mensajero cobraba en su propia billetera,
    // que la UI nunca mostraba. Ahora la billetera es una sola: la del
    // principal. Lo que quedó en los secundarios se le pasa a él.
    if (messengers.length > 1 &&
        messengers.skip(1).any((m) => m.denarios > 0 || m.aureos > 0 || m.seals > 0)) {
      var primary = messengers.first;
      for (var i = 1; i < messengers.length; i++) {
        final m = messengers[i];
        primary = primary.copyWith(
          denarios: primary.denarios + m.denarios,
          aureos: primary.aureos + m.aureos,
          seals: primary.seals + m.seals,
        );
        messengers[i] = m.copyWith(denarios: 0, aureos: 0, seals: 0);
      }
      messengers[0] = primary;
      await saveAllMessengers(messengers);
    }
    return messengers;
  }

  @override
  Future<Messenger?> getMessenger() async {
    final all = await getAllMessengers();
    return all.isEmpty ? null : all.first;
  }

  @override
  Future<void> saveMessenger(Messenger m) => _writes.run(() async {
    final all = await getAllMessengers();
    final idx = all.indexWhere((x) => x.id == m.id);
    if (idx >= 0) {
      all[idx] = m;
    } else {
      all.add(m);
    }
    await saveAllMessengers(all);
  });

  @override
  Future<void> saveAllMessengers(List<Messenger> messengers) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kMessengers, jsonEncode(messengers.map(_toJson).toList()));
  }

  @override
  Future<Messenger> createDefaultWithGender(String name, MessengerGender gender) async {
    final m = Messenger(
      id: _uuid.v4(),
      name: name,
      gender: gender,
      health: 100,
      fatigue: 0,
      status: MessengerStatus.idle,
      skills: {for (final s in SkillType.values) s: 1},
      skillXp: {for (final s in SkillType.values) s: 0},
      completedMissionIds: [],
      tutorialPhase: 0,
      tutorialMissionIndex: 0,
      tutorialComplete: false,
      denarios: 200,
      aureos: 5,
      slotIndex: 0,
    );
    await saveMessenger(m);
    return m;
  }

  @override
  Future<Messenger> unlockSlot({
    required Messenger payer,
    required String newName,
    required MessengerGender gender,
    required int slotIndex,
  }) async {
    final cost = messengerSlotCosts[slotIndex] ?? 999;
    if (payer.aureos < cost) {
      throw Exception('Aureos insuficientes (necesitás $cost, tenés ${payer.aureos})');
    }
    // Descontar Aureos del mensajero que paga
    final updatedPayer = payer.copyWith(aureos: payer.aureos - cost);
    await saveMessenger(updatedPayer);

    // Crear nuevo mensajero con tutorial ya completo
    final newMessenger = Messenger(
      id: _uuid.v4(),
      name: newName,
      gender: gender,
      health: 100,
      fatigue: 0,
      status: MessengerStatus.idle,
      skills: {for (final s in SkillType.values) s: 1},
      skillXp: {for (final s in SkillType.values) s: 0},
      completedMissionIds: [],
      tutorialPhase: 1,
      tutorialMissionIndex: tutorialMissions.length,   // ya pasó todas las pruebas
      tutorialComplete: true,
      denarios: 0,
      aureos: 0,
      slotIndex: slotIndex,
    );
    await saveMessenger(newMessenger);
    return newMessenger;
  }

  Map<String, dynamic> _toJson(Messenger m) => {
    'id': m.id, 'name': m.name,
    'gender': m.gender.index,
    'health': m.health, 'fatigue': m.fatigue, 'status': m.status.index,
    'skills': {for (final e in m.skills.entries) e.key.index.toString(): e.value},
    'skillXp': {for (final e in m.skillXp.entries) e.key.index.toString(): e.value},
    'completedMissionIds': m.completedMissionIds,
    'tutorialPhase': m.tutorialPhase,
    'tutorialMissionIndex': m.tutorialMissionIndex,
    'tutorialComplete': m.tutorialComplete,
    'denarios': m.denarios,
    'aureos': m.aureos,
    'seals': m.seals,
    'slotIndex': m.slotIndex,
    'activeBoosts': m.activeBoosts.toList(),
  };

  Messenger _fromJson(Map<String, dynamic> j) => Messenger(
    id: j['id'] as String,
    name: j['name'] as String,
    gender: MessengerGender.values[j['gender'] as int? ?? 0],
    health: j['health'] as int,
    fatigue: j['fatigue'] as int,
    status: _enumAt(MessengerStatus.values, j['status'], MessengerStatus.idle),
    skills: {
      for (final e in (j['skills'] as Map<String, dynamic>).entries)
        SkillType.values[int.parse(e.key)]: e.value as int
    },
    skillXp: {
      for (final e in (j['skillXp'] as Map<String, dynamic>).entries)
        SkillType.values[int.parse(e.key)]: e.value as int
    },
    completedMissionIds: List<String>.from(j['completedMissionIds'] as List),
    tutorialPhase: j['tutorialPhase'] as int? ?? 0,
    tutorialMissionIndex: j['tutorialMissionIndex'] as int? ?? 0,
    tutorialComplete: j['tutorialComplete'] as bool? ?? false,
    denarios: j['denarios'] as int? ?? 0,
    aureos: j['aureos'] as int? ?? 0,
    seals: j['seals'] as int? ?? 0,
    slotIndex: j['slotIndex'] as int? ?? 0,
    activeBoosts: ((j['activeBoosts'] as List?) ?? const [])
        .map((e) => e as String)
        .toSet(),
  );
}

// ─── Mission ──────────────────────────────────────────────────────────────────
class LocalMissionRepository implements MissionRepository {
  static const _kActive    = 'active_missions_v2';   // lista de misiones activas
  static const _kCompleted = 'completed_missions';
  /// Tope del historial de misiones entregadas.
  static const kMaxCompletedMissions = 100;
  static const _kLegacyActive = 'active_mission';    // schema viejo

  // ── Leer todas las misiones activas ──────────────────────────────────────────
  @override
  Future<List<Mission>> getAllActiveMissions() async {
    final p = await SharedPreferences.getInstance();

    // Migración desde schema viejo (clave única)
    if (!p.containsKey(_kActive) && p.containsKey(_kLegacyActive)) {
      final raw = p.getString(_kLegacyActive);
      if (raw != null) {
        try {
          final m = _missionFromJson(jsonDecode(raw) as Map<String, dynamic>);
          await _saveAllActive([m], p);
          await p.remove(_kLegacyActive);
          return [m];
        } catch (_) {
          await p.remove(_kLegacyActive);
        }
      }
    }

    final raw = p.getString(_kActive);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      final missions = <Mission>[];
      var dropped = false;
      for (final j in list) {
        try {
          missions.add(_missionFromJson(j as Map<String, dynamic>));
        } catch (_) {
          dropped = true;
        }
      }
      if (dropped) {
        // Se salvan las misiones sanas; la lista original queda de respaldo.
        await p.setString('${_kActive}_corrupt_backup', raw);
        await _saveAllActive(missions, p);
      }
      return _repairInvertedDeadlines(missions);
    } catch (_) {
      // Nunca tirar la partida en silencio: se guarda una copia para rescate.
      await p.setString('${_kActive}_corrupt_backup', raw);
      await p.remove(_kActive);
      return [];
    }
  }

  /// Hasta la versión 1.0.0+2 el costo de tiempo se restaba de la llegada y
  /// podía dejarla antes de la salida: la misión quedaba trabada para siempre.
  /// Esas misiones se dan por llegadas.
  List<Mission> _repairInvertedDeadlines(List<Mission> missions) {
    return missions.map((m) {
      if (m.deadlineAt.isAfter(m.startedAt)) return m;
      return m.copyWith(
          deadlineAt: m.startedAt.add(const Duration(minutes: 1)));
    }).toList();
  }

  Future<void> _saveAllActive(List<Mission> missions, SharedPreferences p) async {
    await p.setString(_kActive, jsonEncode(missions.map(_missionToJson).toList()));
  }

  @override
  Future<Mission?> getActiveMissionFor(String messengerId) async {
    final all = await getAllActiveMissions();
    return all.where((m) => m.messengerId == messengerId).firstOrNull;
  }

  @override
  Future<void> saveMission(Mission m) => _writes.run(() async {
    final p = await SharedPreferences.getInstance();
    final all = await getAllActiveMissions();
    final idx = all.indexWhere((x) => x.id == m.id);
    if (idx >= 0) {
      all[idx] = m;
    } else {
      all.add(m);
    }
    await _saveAllActive(all, p);
  });

  @override
  Future<void> completeMission(String missionId, MissionResult result) =>
      _writes.run(() async {
    final p = await SharedPreferences.getInstance();
    final all = await getAllActiveMissions();
    final idx = all.indexWhere((m) => m.id == missionId);
    if (idx < 0) return;
    final completed = all[idx].copyWith(
        status: MissionStatus.completed, progressPct: 100, result: result);
    all.removeAt(idx);
    await _saveAllActive(all, p);
    // Guardar en completadas (solo las últimas: SharedPreferences no es
    // para historiales infinitos).
    final list = p.getStringList(_kCompleted) ?? [];
    list.add(jsonEncode(_missionToJson(completed)));
    final kept = list.length > kMaxCompletedMissions
        ? list.sublist(list.length - kMaxCompletedMissions)
        : list;
    await p.setStringList(_kCompleted, kept);
  });

  @override
  Future<List<Mission>> getCompletedMissions() async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_kCompleted) ?? [];
    final missions = <Mission>[];
    for (final r in list) {
      // Una entrada corrupta no se lleva puesto todo el historial.
      try {
        missions.add(_missionFromJson(jsonDecode(r) as Map<String, dynamic>));
      } catch (_) {}
    }
    return missions.reversed.toList();
  }

  @override
  Future<List<GameRoute>> getAvailableRoutes(int messengerRank,
      {Set<String> flags = const {}}) async {
    return allRealMissions
        .where((m) =>
            m.requiredRank <= messengerRank &&
            (m.requiredFlag == null || flags.contains(m.requiredFlag)))
        .map((m) => GameRoute(
      id: m.id, origin: m.origin, destination: m.destination,
      distanceKm: m.distanceKm, durationMinutes: m.durationMinutes,
      danger: m.danger, requiredRank: m.requiredRank,
      eventCount: m.minEvents, lore: m.lore,
    ))
        .toList();
  }

  @override
  Future<Mission> createTutorialMission(int index, String messengerId) async {
    final cfg = tutorialMissions[index];
    final now = DateTime.now();
    final deadline = now.add(Duration(minutes: cfg.durationMinutes));
    final totalSec = cfg.durationMinutes * 60;

    final events = <MissionEvent>[];
    for (int i = 0; i < cfg.eventIds.length; i++) {
      final evtCfg = tutorialEvents.firstWhere((e) => e.id == cfg.eventIds[i]);
      final slotSec = totalSec / (cfg.eventIds.length + 1);
      final triggerAt = now.add(Duration(seconds: (slotSec * (i + 1)).round()));
      final deadlineAt = triggerAt.add(Duration(minutes: evtCfg.decisionWindowMinutes));
      events.add(MissionEvent(
        id: _uuid.v4(),
        title: evtCfg.title,
        description: evtCfg.description,
        triggersAt: triggerAt,
        deadlineAt: deadlineAt,
        status: EventStatus.pending,
        options: evtCfg.options.map((o) => EventOption(
          id: o.id,
          text: o.text,
          riskLevel: o.riskLevel,
          timeCostMinutes: o.timeCostMinutes,
          requiredSkills: o.requiredSkills,
          outcomeSuccess: o.outcomeSuccess,
          outcomePartial: o.outcomePartial,
          outcomeFail: o.outcomeFail,
        )).toList(),
      ));
    }

    final mission = Mission(
      id: _uuid.v4(), routeId: cfg.id,
      messengerId: messengerId,
      origin: cfg.origin, destination: cfg.destination,
      packageDescription: cfg.packageDescription, lore: cfg.lore,
      narrativeIntro: cfg.narrativeIntro, isTutorial: true, tutorialIndex: index,
      startedAt: now, deadlineAt: deadline, progressPct: 0,
      status: MissionStatus.active, packageState: PackageState.intact, events: events,
    );
    await saveMission(mission);
    return mission;
  }

  @override
  Future<Mission> createMission(GameRoute route, String messengerId,
      {bool revealEvents = false}) async {
    final now = DateTime.now();
    final deadline = now.add(Duration(minutes: route.durationMinutes));
    final cfg = allRealMissions.firstWhere(
            (m) => m.id == route.id, orElse: () => allRealMissions.first);
    final events = _generateRealEvents(cfg, now, deadline);

    final mission = Mission(
      id: _uuid.v4(), routeId: route.id,
      messengerId: messengerId,
      origin: route.origin, destination: route.destination,
      packageDescription: cfg.packageOptions[Random().nextInt(cfg.packageOptions.length)],
      lore: route.lore, narrativeIntro: null, isTutorial: false, tutorialIndex: -1,
      startedAt: now, deadlineAt: deadline, progressPct: 0,
      status: MissionStatus.active, packageState: PackageState.intact, events: events,
      revealEvents: revealEvents,
    );
    await saveMission(mission);
    return mission;
  }

  @override
  Future<Mission> createStoryMission(
      StoryMissionConfig config, String messengerId) async {
    final now = DateTime.now();
    final deadline = now.add(Duration(minutes: config.durationMinutes));
    final totalSec = config.durationMinutes * 60;

    // Eventos fijos de historia, repartidos en orden a lo largo de la misión.
    final events = <MissionEvent>[];
    for (int i = 0; i < config.fixedEventIds.length; i++) {
      final ec = storyEventById(config.fixedEventIds[i]);
      if (ec == null) continue;
      final slotSec = totalSec / (config.fixedEventIds.length + 1);
      final triggerAt = now.add(Duration(seconds: (slotSec * (i + 1)).round()));
      events.add(MissionEvent(
        id: _uuid.v4(),
        title: ec.title,
        description: ec.description,
        triggersAt: triggerAt,
        // 60 min para decidir (GDD §4.2). Pasada la ventana, el evento se
        // auto-resuelve con la opción más segura a resultado parcial.
        deadlineAt: triggerAt.add(const Duration(minutes: kDecisionWindowMinutes)),
        status: EventStatus.pending,
        options: ec.options.map((o) => o.toEventOption()).toList(),
      ));
    }

    final mission = Mission(
      id: _uuid.v4(),
      routeId: config.id,
      messengerId: messengerId,
      origin: config.origin,
      destination: config.destination,
      packageDescription: config.packageDescription,
      lore: config.lore,
      narrativeIntro: config.narrativeIntro,
      isTutorial: false,
      tutorialIndex: -1,
      startedAt: now,
      deadlineAt: deadline,
      progressPct: 0,
      status: MissionStatus.active,
      packageState: PackageState.intact,
      events: events,
      arcId: config.arcId,
      arcStage: config.stage,
      epilogue: config.epilogue,
    );
    await saveMission(mission);
    return mission;
  }

  List<MissionEvent> _generateRealEvents(
      RealMissionConfig cfg, DateTime start, DateTime end) {
    final rng = Random();
    final count =
        cfg.minEvents + rng.nextInt((cfg.maxEvents - cfg.minEvents + 1).clamp(1, 10));
    final duration = end.difference(start);
    final slot = duration ~/ (count + 1);

    final pool = allRealEvents
        .where((e) => cfg.eventPoolIds.contains(e.id))
        .toList()
      ..shuffle(rng);
    final picked = pool.take(count).toList();

    return picked.asMap().entries.map((entry) {
      final i = entry.key;
      final ec = entry.value;
      final jitter = Duration(minutes: rng.nextInt(6) - 3);
      final triggerAt = start.add(slot * (i + 1) + jitter);
      final deadlineAt =
          triggerAt.add(const Duration(minutes: kDecisionWindowMinutes));
      return MissionEvent(
        id: _uuid.v4(),
        title: ec.title,
        description: ec.description,
        triggersAt: triggerAt,
        deadlineAt: deadlineAt,
        status: EventStatus.pending,
        // Con prosa y efectos narrativos incluidos.
        options: ec.options.map((o) => o.toEventOption()).toList(),
      );
    }).toList();
  }

  // ── JSON ──────────────────────────────────────────────────────────────────
  Map<String, dynamic> _missionToJson(Mission m) => {
    'id': m.id, 'routeId': m.routeId,
    'messengerId': m.messengerId,
    'origin': m.origin, 'destination': m.destination,
    'packageDescription': m.packageDescription, 'lore': m.lore,
    'narrativeIntro': m.narrativeIntro, 'isTutorial': m.isTutorial,
    'tutorialIndex': m.tutorialIndex,
    'startedAt': m.startedAt.toIso8601String(),
    'deadlineAt': m.deadlineAt.toIso8601String(),
    'progressPct': m.progressPct, 'status': m.status.index,
    'packageState': m.packageState.index,
    'events': m.events.map(_eventToJson).toList(),
    'result': m.result != null ? _resultToJson(m.result!) : null,
    'revealEvents': m.revealEvents,
    'arcId': m.arcId,
    'arcStage': m.arcStage,
    'epilogue': m.epilogue,
  };

  Mission _missionFromJson(Map<String, dynamic> j) => Mission(
    id: j['id'] as String, routeId: j['routeId'] as String,
    messengerId: j['messengerId'] as String? ?? '',
    origin: j['origin'] as String, destination: j['destination'] as String,
    packageDescription: j['packageDescription'] as String,
    lore: j['lore'] as String? ?? '',
    narrativeIntro: j['narrativeIntro'] as String?,
    isTutorial: j['isTutorial'] as bool? ?? false,
    tutorialIndex: j['tutorialIndex'] as int? ?? -1,
    startedAt: DateTime.parse(j['startedAt'] as String),
    deadlineAt: DateTime.parse(j['deadlineAt'] as String),
    progressPct: j['progressPct'] as int,
    status: _enumAt(MissionStatus.values, j['status'], MissionStatus.active),
    packageState: _enumAt(PackageState.values, j['packageState'], PackageState.intact),
    events: (j['events'] as List)
        .map((e) => _eventFromJson(e as Map<String, dynamic>))
        .toList(),
    result: j['result'] != null
        ? _resultFromJson(j['result'] as Map<String, dynamic>)
        : null,
    revealEvents: j['revealEvents'] as bool? ?? false,
    arcId: j['arcId'] as String?,
    arcStage: j['arcStage'] as int? ?? 0,
    epilogue: j['epilogue'] as String?,
  );

  Map<String, dynamic> _eventToJson(MissionEvent e) => {
    'id': e.id, 'title': e.title, 'description': e.description,
    'triggersAt': e.triggersAt.toIso8601String(),
    'deadlineAt': e.deadlineAt.toIso8601String(),
    'status': e.status.index,
    'options': e.options.map((o) => {
      'id': o.id, 'text': o.text, 'riskLevel': o.riskLevel,
      'timeCostMinutes': o.timeCostMinutes,
      'requiredSkills': {
        for (final en in o.requiredSkills.entries)
          en.key.index.toString(): en.value
      },
      'isCardOption': o.isCardOption,
      'outcomeSuccess': o.outcomeSuccess,
      'outcomePartial': o.outcomePartial,
      'outcomeFail': o.outcomeFail,
      'repDelta': o.repDelta == null
          ? null
          : {
              for (final en in o.repDelta!.entries)
                en.key.index.toString(): en.value
            },
      'setFlags': o.setFlags,
      'requiredFlag': o.requiredFlag,
      'forbiddenFlag': o.forbiddenFlag,
      'minReputation': o.minReputation == null
          ? null
          : {
              for (final en in o.minReputation!.entries)
                en.key.index.toString(): en.value
            },
      'lockedHint': o.lockedHint,
      'followUpEventId': o.followUpEventId,
      'journalNote': o.journalNote,
    }).toList(),
    'outcome': e.outcome == null ? null : {
      'type': e.outcome!.type.index,
      'narrative': e.outcome!.narrative,
      'healthDelta': e.outcome!.healthDelta,
      'timeDeltaMinutes': e.outcome!.timeDeltaMinutes,
      'packageState': e.outcome!.packageState.index,
      'chosenOptionText': e.outcome!.chosenOptionText,
      'usedSkill': e.outcome!.usedSkill?.index,
      'xpGained': e.outcome!.xpGained,
    },
  };

  MissionEvent _eventFromJson(Map<String, dynamic> j) => MissionEvent(
    id: j['id'] as String, title: j['title'] as String,
    description: j['description'] as String,
    triggersAt: DateTime.parse(j['triggersAt'] as String),
    deadlineAt: DateTime.parse(j['deadlineAt'] as String),
    status: _enumAt(EventStatus.values, j['status'], EventStatus.pending),
    options: (j['options'] as List).map((o) {
      final om = o as Map<String, dynamic>;
      return EventOption(
        id: om['id'] as String, text: om['text'] as String,
        riskLevel: om['riskLevel'] as int,
        timeCostMinutes: om['timeCostMinutes'] as int? ?? 0,
        requiredSkills: {
          for (final e in (om['requiredSkills'] as Map<String, dynamic>).entries)
            SkillType.values[int.parse(e.key)]: e.value as int
        },
        isCardOption: om['isCardOption'] as bool? ?? false,
        outcomeSuccess: om['outcomeSuccess'] as String?,
        outcomePartial: om['outcomePartial'] as String?,
        outcomeFail: om['outcomeFail'] as String?,
        repDelta: om['repDelta'] == null
            ? null
            : {
                for (final e
                    in (om['repDelta'] as Map<String, dynamic>).entries)
                  Faction.values[int.parse(e.key)]: e.value as int
              },
        setFlags: (om['setFlags'] as List?)?.cast<String>(),
        requiredFlag: om['requiredFlag'] as String?,
        forbiddenFlag: om['forbiddenFlag'] as String?,
        minReputation: om['minReputation'] == null
            ? null
            : {
                for (final e
                    in (om['minReputation'] as Map<String, dynamic>).entries)
                  Faction.values[int.parse(e.key)]: e.value as int
              },
        lockedHint: om['lockedHint'] as String?,
        followUpEventId: om['followUpEventId'] as String?,
        journalNote: om['journalNote'] as String?,
      );
    }).toList(),
    outcome: j['outcome'] == null ? null : () {
      final om = j['outcome'] as Map<String, dynamic>;
      return EventOutcome(
        type: _enumAt(OutcomeType.values, om['type'], OutcomeType.partial),
        narrative: om['narrative'] as String,
        healthDelta: om['healthDelta'] as int,
        timeDeltaMinutes: om['timeDeltaMinutes'] as int? ?? 0,
        packageState: _enumAt(PackageState.values, om['packageState'], PackageState.intact),
        chosenOptionText: om['chosenOptionText'] as String?,
        // Misiones guardadas antes de esta versión no traen estos campos.
        usedSkill: om['usedSkill'] == null
            ? null
            : SkillType.values[om['usedSkill'] as int],
        xpGained: om['xpGained'] as int? ?? 0,
      );
    }(),
  );

  Map<String, dynamic> _resultToJson(MissionResult r) => {
    'grade': r.grade, 'timeScore': r.timeScore,
    'packageScore': r.packageScore, 'decisionScore': r.decisionScore,
    'arrivedAt': r.arrivedAt.toIso8601String(),
    'denarios': r.denarios,
  };

  MissionResult _resultFromJson(Map<String, dynamic> j) => MissionResult(
    grade: j['grade'] as String,
    timeScore: (j['timeScore'] as num).toDouble(),
    packageScore: (j['packageScore'] as num).toDouble(),
    decisionScore: (j['decisionScore'] as num).toDouble(),
    arrivedAt: DateTime.parse(j['arrivedAt'] as String),
    denarios: j['denarios'] as int? ?? 0,
  );
}

// ─── Guild (contratos del día + paga diaria) ──────────────────────────────────
class LocalGuildRepository implements GuildRepository {
  static const _kGuild = 'guild_v1';

  @override
  Future<GuildState> getState() async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final raw = p.getString(_kGuild);

    GuildState state;
    if (raw == null) {
      state = GuildState.freshFor(now);
      await saveState(state);
      return state;
    }
    try {
      state = _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await p.setString('${_kGuild}_corrupt_backup', raw);
      state = GuildState.freshFor(now);
      await saveState(state);
      return state;
    }

    // Cambió el día → tablón nuevo, conservando la racha de paga
    if (state.contractsDate != dateKey(now)) {
      state = GuildState.freshFor(now,
          streakDay: state.streakDay, lastPayDate: state.lastPayDate);
      await saveState(state);
    }
    return state;
  }

  @override
  Future<void> saveState(GuildState state) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kGuild, jsonEncode(_toJson(state)));
  }

  Map<String, dynamic> _toJson(GuildState s) => {
    'contractsDate': s.contractsDate,
    'contracts': s.contracts.map((c) => {
      'templateId': c.templateId,
      'progress': c.progress,
      'claimed': c.claimed,
    }).toList(),
    'streakDay': s.streakDay,
    'lastPayDate': s.lastPayDate,
  };

  GuildState _fromJson(Map<String, dynamic> j) => GuildState(
    contractsDate: j['contractsDate'] as String,
    contracts: (j['contracts'] as List).map((c) {
      final m = c as Map<String, dynamic>;
      return DailyContract(
        templateId: m['templateId'] as String,
        progress: m['progress'] as int? ?? 0,
        claimed: m['claimed'] as bool? ?? false,
      );
    }).toList(),
    streakDay: j['streakDay'] as int? ?? 0,
    lastPayDate: j['lastPayDate'] as String?,
  );
}

// ─── World (reputación, flags, diario, arcos) ─────────────────────────────────
class LocalWorldRepository implements WorldRepository {
  static const _kWorld = 'world_v1';

  @override
  Future<WorldState> getState() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kWorld);
    if (raw == null) {
      final state = WorldState.initial();
      await saveState(state);
      return state;
    }
    try {
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Reputación, flags y diario no se pierden en silencio.
      await p.setString('${_kWorld}_corrupt_backup', raw);
      final state = WorldState.initial();
      await saveState(state);
      return state;
    }
  }

  @override
  Future<void> saveState(WorldState state) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kWorld, jsonEncode(_toJson(state)));
  }

  Map<String, dynamic> _toJson(WorldState s) => {
    'reputation': {
      for (final e in s.reputation.entries) e.key.index.toString(): e.value
    },
    'flags': s.flags.toList(),
    'journal': s.journal
        .map((j) => {'date': j.date.toIso8601String(), 'text': j.text})
        .toList(),
    'arcProgress': s.arcProgress,
    'completedArcs': s.completedArcs.toList(),
  };

  WorldState _fromJson(Map<String, dynamic> j) => WorldState(
    reputation: {
      for (final e in (j['reputation'] as Map<String, dynamic>).entries)
        Faction.values[int.parse(e.key)]: e.value as int
    },
    flags: ((j['flags'] as List?) ?? const []).cast<String>().toSet(),
    journal: ((j['journal'] as List?) ?? const []).map((e) {
      final m = e as Map<String, dynamic>;
      return JournalEntry(
        date: DateTime.parse(m['date'] as String),
        text: m['text'] as String,
      );
    }).toList(),
    arcProgress: ((j['arcProgress'] as Map<String, dynamic>?) ?? const {})
        .map((k, v) => MapEntry(k, v as int)),
    completedArcs:
        ((j['completedArcs'] as List?) ?? const []).cast<String>().toSet(),
  );
}