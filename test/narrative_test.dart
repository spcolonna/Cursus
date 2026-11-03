// Fase 5: motor de eventos, historia multi-arco, arco de Lucius y premios
// de los finales.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_messenger/data/consequence_content.dart';
import 'package:the_messenger/data/faction_content.dart';
import 'package:the_messenger/data/game_content_expansion.dart';
import 'package:the_messenger/data/geo_content.dart';
import 'package:the_messenger/data/static_game_content.dart';
import 'package:the_messenger/data/story_content.dart';
import 'package:the_messenger/data/story_rewards.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/world.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/domain/usecases/event_selection.dart';
import 'package:the_messenger/domain/usecases/usecases.dart';
import 'package:the_messenger/infrastructure/local/local_repositories.dart';
import 'package:the_messenger/presentation/screens/shop/shop_screen.dart';

const _content = StaticGameContent();

RealEventConfig _evt(String id,
        {String? requiredFlag,
        String? forbiddenFlag,
        Map<Faction, int>? minReputation,
        bool once = false,
        int weight = 1}) =>
    RealEventConfig(
      id: id,
      title: id,
      description: id,
      options: const [],
      requiredFlag: requiredFlag,
      forbiddenFlag: forbiddenFlag,
      minReputation: minReputation,
      once: once,
      weight: weight,
    );

WorldState _world({
  Set<String> flags = const {},
  Map<Faction, int>? rep,
  List<String> recent = const [],
  Set<String> seen = const {},
  Map<String, int> arcProgress = const {},
  Set<String> completedArcs = const {},
}) =>
    WorldState.initial().copyWith(
      flags: flags,
      reputation: rep == null
          ? null
          : {...WorldState.initial().reputation, ...rep},
      recentEvents: recent,
      seenEvents: seen,
      arcProgress: arcProgress,
      completedArcs: completedArcs,
    );

void main() {
  // ─── Selección de eventos ──────────────────────────────────────────────────
  group('pickEventsForMission', () {
    final pool = [for (var i = 0; i < 8; i++) _evt('e$i')];

    List<String> pick(List<RealEventConfig> pool, WorldState w,
            {int count = 3, int seed = 1}) =>
        pickEventsForMission(
                pool: pool, count: count, world: w, rng: Random(seed))
            .map((e) => e.id)
            .toList();

    test('es determinista con la misma semilla y no repite', () {
      final a = pick(pool, _world(), seed: 7);
      expect(a, pick(pool, _world(), seed: 7));
      expect(a.toSet().length, a.length);
      expect(a.length, 3);
    });

    test('respeta flags, reputación y eventos de una vez', () {
      final gated = [
        _evt('needs', requiredFlag: 'f'),
        _evt('hates', forbiddenFlag: 'f'),
        _evt('rich', minReputation: {Faction.legions: 30}),
        _evt('once', once: true),
      ];
      expect(pick(gated, _world(), count: 4).toSet(), {'hates', 'once'});
      expect(
          pick(gated, _world(flags: {'f'}, rep: {Faction.legions: 30}),
                  count: 4, seed: 3)
              .toSet(),
          {'needs', 'rich', 'once'});
      expect(pick(gated, _world(seen: {'once'}), count: 4), ['hates']);
    });

    test('evita los recientes mientras haya otros', () {
      final w = _world(recent: ['e0', 'e1', 'e2', 'e3', 'e4']);
      for (var seed = 0; seed < 20; seed++) {
        expect(pick(pool, w, seed: seed).toSet(), {'e5', 'e6', 'e7'});
      }
    });

    test('si no alcanzan, completa con el reciente más viejo', () {
      final small = [_evt('a'), _evt('b'), _evt('c')];
      final w = _world(recent: ['b', 'a']);
      expect(pick(small, w, count: 2), ['c', 'b']);
    });

    test('las consecuencias pesan triple y salen de a una', () {
      final mixed = [
        ...pool,
        _evt('c1', requiredFlag: 'x'),
        _evt('c2', requiredFlag: 'x'),
      ];
      final w = _world(flags: {'x'});
      var withConsequence = 0;
      for (var seed = 0; seed < 400; seed++) {
        final ids = pick(mixed, w, seed: seed);
        final n = ids.where((id) => id.startsWith('c')).length;
        expect(n, lessThanOrEqualTo(kMaxConsequencesPerMission));
        if (n > 0) withConsequence++;
      }
      // 2 consecuencias ×3 contra 8 normales: salen en bastante más de la
      // mitad de las misiones, no en todas.
      expect(withConsequence, greaterThan(200));
      expect(withConsequence, lessThan(400));
    });
  });

  // ─── Aceptar una misión elige con el mundo ─────────────────────────────────
  group('AcceptMissionUseCase con mundo', () {
    test('usa el pool de la ruta y las consecuencias, y lo anota', () async {
      final missions = _Missions();
      final world = _World(_world(flags: {'fled_bandits'}));
      final route = allRealMissions.firstWhere((r) => r.id == 'real_02');
      for (var i = 0; i < 6; i++) {
        await AcceptMissionUseCase(missions, _Messengers(),
                world: world, content: _content, rng: Random(i))
            .execute(_routeOf(route));
        final ids = missions.lastEventIds!;
        expect(ids.length,
            inInclusiveRange(route.minEvents, route.maxEvents));
        for (final id in ids) {
          expect(
              route.eventPoolIds.contains(id) ||
                  consequenceEvents.any((e) => e.id == id),
              isTrue,
              reason: id);
        }
      }
      // La consecuencia de huir de los bandidos sale una sola vez.
      expect(world.state.seenEvents, contains('evt_bandit_grudge'));
      expect(world.state.recentEvents.length, kRecentEventMemory);
    });
  });

  // ─── Varios arcos ──────────────────────────────────────────────────────────
  group('Historia en varios arcos', () {
    test('Lucius espera a que termine Claudius', () {
      final step = nextStoryStep(_content, _world());
      expect(step!.arc.id, kArcClaudius);

      final done = _world(
        flags: {'ending_underworld'},
        completedArcs: {'$kArcClaudius:end_underworld'},
      );
      final next = nextStoryStep(_content, done)!;
      expect(next.arc.id, kArcLucius);
      expect(next.chapter.id, 'lucius_1_underworld');
      expect(next.requiredRank, 3);
    });

    test('el capítulo I de Lucius depende del final del arco 1', () {
      for (final (flag, id) in [
        ('ending_varus', 'lucius_1_varus'),
        ('ending_claudius', 'lucius_1_claudius'),
        ('ending_underworld', 'lucius_1_underworld'),
      ]) {
        expect(storyMissionFor(kArcLucius, 0, {flag})!.id, id);
      }
      expect(storyMissionFor(kArcLucius, 0, {})!.isDefaultVariant, isTrue);
    });

    test('los capítulos IV y V piden rango 4 y siguen el camino', () {
      for (final path in ['lucius_family', 'lucius_legion', 'lucius_book']) {
        for (final stage in [3, 4]) {
          final c = storyMissionFor(kArcLucius, stage, {path})!;
          expect(c.requiredFlag, path, reason: '$stage $path');
          final step = nextStoryStep(
              _content,
              _world(
                flags: {path},
                completedArcs: {'$kArcClaudius:end_varus'},
                arcProgress: {kArcLucius: stage},
              ))!;
          expect(step.requiredRank, 4);
        }
      }
      expect(storyMissionFor(kArcLucius, 3, {})!.isDefaultVariant, isTrue);
    });

    test('tres finales distintos, cada uno con su premio', () {
      final finals = allStoryChapters
          .where((c) => c.arcId == kArcLucius && c.isFinal)
          .toList();
      expect(finals.map((c) => c.endingId).toSet(), {
        'end_lucius_family',
        'end_lucius_legion',
        'end_lucius_book',
      });
      final unlockFlags = {
        ...restStops.map((r) => r.flag),
        ...allRealMissions.map((r) => r.requiredFlag).whereType<String>(),
        ...shopCatalogue.map((i) => i.requiredFlag).whereType<String>(),
      };
      for (final c in finals) {
        expect(c.setFlagsOnComplete!.any(unlockFlags.contains), isTrue,
            reason: '${c.endingId} no abre nada');
      }
    });

    test('cada capítulo de cada arco existe y tiene sus eventos', () {
      for (final arc in storyArcs) {
        for (var stage = 0; stage < arc.stageCount; stage++) {
          final variants = allStoryChapters
              .where((c) => c.arcId == arc.id && c.stage == stage)
              .toList();
          expect(variants, isNotEmpty, reason: '${arc.id} $stage');
          if (variants.length > 1) {
            expect(variants.where((v) => v.isDefaultVariant).length, 1,
                reason: '${arc.id} $stage necesita una variante por defecto');
          }
          for (final v in variants) {
            for (final id in v.fixedEventIds) {
              expect(_content.eventById(id), isNotNull, reason: '${v.id}: $id');
            }
          }
        }
      }
    });

    test('la reparación también endereza el arco de Lucius', () async {
      final world = _World(_world(
        flags: {'ending_varus'},
        completedArcs: {'$kArcClaudius:end_varus'},
        arcProgress: {kArcLucius: 3},
      ));
      expect(await RepairArcStateUseCase(world, _content).execute(), isTrue);
      expect(world.state.hasFlag('lucius_family'), isTrue);
      expect(await RepairArcStateUseCase(world, _content).execute(), isFalse);
    });

    test('el Home anuncia el capítulo cerrado por rango', () async {
      final world = _World(_world(
        flags: {'ending_varus'},
        completedArcs: {'$kArcClaudius:end_varus'},
      ));
      final home = await GetHomeStateUseCase(
              _Messengers(rankSkills: 2), _Missions(), world, _content)
          .execute();
      expect(home.nextStoryMission, isNull);
      expect(home.lockedStory?.arc.id, kArcLucius);
      expect(home.lockedStory?.requiredRank, 3);

      final ready = await GetHomeStateUseCase(
              _Messengers(rankSkills: 3), _Missions(), world, _content)
          .execute();
      expect(ready.nextStoryMission?.id, 'lucius_1_varus');
      expect(ready.storyArcTitle, 'La Taberna del Buey');
    });

    test('la Decimotercera espera a que termine Lucius', () {
      final afterClaudius = _world(
        flags: {'ending_varus'},
        completedArcs: {'$kArcClaudius:end_varus'},
      );
      expect(nextStoryStep(_content, afterClaudius)!.arc.id, kArcLucius);

      final done = _world(
        flags: {'ending_varus', 'ending_lucius_legion'},
        completedArcs: {
          '$kArcClaudius:end_varus',
          '$kArcLucius:end_lucius_legion',
        },
      );
      final next = nextStoryStep(_content, done)!;
      expect(next.arc.id, kArcLegion);
      expect(next.chapter.id, 'legion_1_sexto');
      expect(next.requiredRank, 3);
      expect(storyMissionFor(kArcLegion, 0, {})!.id, 'legion_1');
    });

    test('la Decimotercera sigue el camino y abre un premio por final', () {
      final unlockFlags = {
        ...restStops.map((r) => r.flag),
        ...allRealMissions.map((r) => r.requiredFlag).whereType<String>(),
        ...shopCatalogue.map((i) => i.requiredFlag).whereType<String>(),
      };
      final endings = <String>{};
      for (final path in ['legion_caesar', 'legion_senate', 'legion_guild']) {
        expect(storyMissionFor(kArcLegion, 3, {path})!.requiredFlag, path);
        final last = storyMissionFor(kArcLegion, 4, {path})!;
        expect(last.requiredFlag, path);
        expect(last.isFinal, isTrue);
        endings.add(last.endingId!);
        expect(last.setFlagsOnComplete!.any(unlockFlags.contains), isTrue,
            reason: '${last.endingId} no abre nada');
      }
      expect(endings.length, 3);
      expect(storyMissionFor(kArcLegion, 3, {})!.isDefaultVariant, isTrue);
    });
  });

  // ─── Premios de los finales ────────────────────────────────────────────────
  group('Premios de los finales', () {
    RealMissionConfig route(String id) =>
        allRealMissions.firstWhere((r) => r.id == id);

    test('el final de Varus abre el correo exprés y el cambio de contrato', () {
      final varus = _world(flags: {'ending_varus'});
      expect(route('real_16').isOfferedTo(2, _world()), isFalse);
      expect(route('real_16').isOfferedTo(2, varus), isTrue);
      expect(
          hasFactionPerk(factionUnlocks, varus, FactionPerk.contractReroll),
          isTrue);
    });

    test('Claudius y la legión abren sus rutas', () {
      expect(route('real_20').isOfferedTo(2, _world(flags: {'ending_claudius'})),
          isTrue);
      expect(route('real_20').isOfferedTo(5, _world()), isFalse);
      expect(
          route('real_21')
              .isOfferedTo(4, _world(flags: {'ending_lucius_legion'})),
          isTrue);
      expect(
          route('real_21')
              .isOfferedTo(3, _world(flags: {'ending_lucius_legion'})),
          isFalse);
    });

    test('la Posta del Buey cubre solo rutas de la Appia', () {
      for (final id in restStops.single.routeIds) {
        final via = geoAtlas.routeWaypoints[id];
        expect(via, contains('Forum Appii'), reason: id);
      }
    });

    test('la posta descansa 10 más al llegar por la Appia', () async {
      final world = _World(_world(flags: {'ending_lucius_family'}));
      final missions = _Missions()..active.add(_mission('real_02'));
      final messengers = _Messengers(fatigue: 50);
      final done = await CompleteMissionUseCase(
              missions, messengers, world, _content)
          .execute('m1');
      expect(done!.fatigueDelta, -20);
      expect(done.restStop, 'Posta del Buey');

      final plain = _Missions()..active.add(_mission('real_01'));
      final other = await CompleteMissionUseCase(
              plain, _Messengers(fatigue: 50), world, _content)
          .execute('m1');
      expect(other!.fatigueDelta, -10);
      expect(other.restStop, isNull);
    });

    test('el mapa del mercado negro solo con el final del libro', () {
      final item =
          shopCatalogue.firstWhere((i) => i.id == 'boost_events_black');
      expect(item.requiredFlag, 'ending_lucius_book');
      expect(item.currency, PriceCurrency.denarios);
    });
  });

  // ─── Contenido ─────────────────────────────────────────────────────────────
  group('Flags con consumidor', () {
    test('ningún flag que se otorga queda sin leer', () {
      final set = <String>{};
      final read = <String>{};
      void readFrom(String? f) {
        if (f != null) read.add(f);
      }

      for (final e in [...allRealEvents, ...allStoryEvents]) {
        readFrom(e.requiredFlag);
        readFrom(e.forbiddenFlag);
        for (final o in e.options) {
          set.addAll(o.setFlags ?? const []);
          readFrom(o.requiredFlag);
          readFrom(o.forbiddenFlag);
        }
      }
      for (final c in allStoryChapters) {
        set.addAll(c.setFlagsOnComplete ?? const []);
        readFrom(c.requiredFlag);
        readFrom(c.forbiddenFlag);
      }
      for (final r in allRealMissions) {
        readFrom(r.requiredFlag);
        readFrom(r.openedByFlag);
      }
      for (final u in factionUnlocks) {
        readFrom(u.orFlag);
      }
      for (final s in restStops) {
        readFrom(s.flag);
      }
      for (final i in shopCatalogue) {
        readFrom(i.requiredFlag);
      }
      expect(set.difference(read), isEmpty);
    });

    test('las consecuencias salen una vez y piden un flag que existe', () {
      for (final e in consequenceEvents) {
        expect(e.once, isTrue, reason: e.id);
        expect(e.requiredFlag, isNotNull, reason: e.id);
        expect(flagDescription(e.requiredFlag!), isNotNull, reason: e.id);
        expect(e.options.length, inInclusiveRange(2, 4), reason: e.id);
      }
    });

    test('la prosa nueva respeta los topes de largo', () {
      for (final e in [
        ...consequenceEvents,
        ...luciusEventPool,
        ...legionEventPool,
      ]) {
        expect(e.description.length, lessThanOrEqualTo(240), reason: e.id);
        for (final o in e.options) {
          for (final t in [o.outcomeSuccess, o.outcomePartial, o.outcomeFail]) {
            expect(t, isNotNull, reason: o.id);
            expect(t!.length, lessThanOrEqualTo(320), reason: o.id);
          }
        }
      }
    });

    test('todos los capítulos tienen trazado en el mapa', () {
      for (final c in allStoryChapters) {
        final g = geoAtlas.routeFor(c.id, c.origin, c.destination);
        expect(g, isNotNull, reason: '${c.id}: ${c.origin} → ${c.destination}');
      }
    });
  });

  // ─── Persistencia ──────────────────────────────────────────────────────────
  group('Memoria de eventos', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('se guarda y un guardado viejo arranca vacío', () async {
      final repo = LocalWorldRepository();
      final w = (await repo.getState())
          .recordEvents(['a', 'b'], once: ['b']);
      await repo.saveState(w);
      final back = await repo.getState();
      expect(back.recentEvents, ['a', 'b']);
      expect(back.seenEvents, {'b'});

      SharedPreferences.setMockInitialValues({
        'world_v1': '{"reputation":{"0":10},"flags":[],"journal":[]}',
      });
      final old = await LocalWorldRepository().getState();
      expect(old.recentEvents, isEmpty);
      expect(old.seenEvents, isEmpty);
    });

    test('recuerda solo los últimos eventos', () {
      var w = WorldState.initial();
      const n = kRecentEventMemory + 4;
      for (var i = 0; i < n; i++) {
        w = w.recordEvents(['e$i']);
      }
      expect(w.recentEvents.length, kRecentEventMemory);
      expect(w.recentEvents.first, 'e4');
      expect(w.recentEvents.last, 'e${n - 1}');
    });
  });
}

// ─── Dobles de prueba ──────────────────────────────────────────────────────────
GameRoute _routeOf(RealMissionConfig c) => GameRoute(
      id: c.id,
      origin: c.origin,
      destination: c.destination,
      distanceKm: c.distanceKm,
      durationMinutes: c.durationMinutes,
      danger: c.danger,
      requiredRank: c.requiredRank,
      eventCount: c.minEvents,
      lore: c.lore,
    );

Mission _mission(String routeId) {
  final now = DateTime.now();
  return Mission(
    id: 'mission_$routeId',
    routeId: routeId,
    messengerId: 'm1',
    origin: 'Roma',
    destination: 'Capua',
    packageDescription: 'p',
    lore: 'l',
    narrativeIntro: null,
    isTutorial: false,
    tutorialIndex: -1,
    startedAt: now.subtract(const Duration(hours: 2)),
    deadlineAt: now,
    progressPct: 1,
    status: MissionStatus.active,
    packageState: PackageState.intact,
    events: const [],
  );
}

class _Missions extends Fake implements MissionRepository {
  final active = <Mission>[];
  List<String>? lastEventIds;

  @override
  Future<List<Mission>> getAllActiveMissions() async => active;
  @override
  Future<Mission?> getActiveMissionFor(String messengerId) async =>
      active.where((m) => m.messengerId == messengerId).firstOrNull;
  @override
  Future<void> completeMission(String missionId, MissionResult result) async =>
      active.removeWhere((m) => m.id == missionId);
  @override
  Future<List<GameRoute>> getAvailableRoutes(
          int messengerRank, WorldState world) async =>
      const [];
  @override
  Future<Mission> createMission(GameRoute route, String messengerId,
      {bool revealEvents = false,
      double payFactor = 1.0,
      List<String>? eventIds}) async {
    lastEventIds = eventIds;
    return _mission(route.id);
  }
}

class _Messengers extends Fake implements MessengerRepository {
  Messenger m;
  _Messengers({int rankSkills = 1, int fatigue = 0})
      : m = Messenger(
          id: 'm1',
          name: 'Test',
          gender: MessengerGender.male,
          health: 100,
          fatigue: fatigue,
          status: MessengerStatus.idle,
          skills: {for (final s in SkillType.values) s: rankSkills},
          skillXp: const {},
          completedMissionIds: const [],
          tutorialPhase: 1,
          tutorialMissionIndex: 0,
          tutorialComplete: true,
        );

  @override
  Future<List<Messenger>> getAllMessengers() async => [m];
  @override
  Future<void> saveMessenger(Messenger messenger) async => m = messenger;
}

class _World implements WorldRepository {
  WorldState state;
  _World(this.state);
  @override
  Future<WorldState> getState() async => state;
  @override
  Future<void> saveState(WorldState s) async => state = s;
}
