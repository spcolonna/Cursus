// Fase 2: paga por ruta, presupuesto diario, logros, títulos y migración.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_messenger/data/faction_content.dart';
import 'package:the_messenger/data/game_content_expansion.dart';
import 'package:the_messenger/data/static_game_content.dart';
import 'package:the_messenger/domain/entities/content.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/guild.dart';
import 'package:the_messenger/domain/entities/progression.dart';
import 'package:the_messenger/domain/entities/weekly.dart';
import 'package:the_messenger/domain/entities/world.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/domain/usecases/progression_usecases.dart';
import 'package:the_messenger/domain/usecases/usecases.dart';
import 'package:the_messenger/infrastructure/local/local_repositories.dart';

const kContent = StaticGameContent();

// ─── Fakes en memoria ─────────────────────────────────────────────────────────
class _Messengers implements MessengerRepository {
  final List<Messenger> list;
  _Messengers(this.list);
  @override
  Future<List<Messenger>> getAllMessengers() async => List.of(list);
  @override
  Future<Messenger?> getMessenger() async => list.firstOrNull;
  @override
  Future<void> saveMessenger(Messenger m) async {
    final i = list.indexWhere((x) => x.id == m.id);
    i == -1 ? list.add(m) : list[i] = m;
  }

  @override
  Future<void> saveAllMessengers(List<Messenger> ms) async => list
    ..clear()
    ..addAll(ms);
  @override
  Future<Messenger> createDefaultWithGender(String n, MessengerGender g) =>
      throw UnimplementedError();
  @override
  Future<Messenger> unlockSlot(
          {required Messenger payer,
          required String newName,
          required MessengerGender gender,
          required int slotIndex}) =>
      throw UnimplementedError();
}

class _Missions implements MissionRepository {
  final List<Mission> completed;
  GameRoute? createdRoute;
  double? createdPayFactor;
  _Missions([this.completed = const []]);

  @override
  Future<List<Mission>> getCompletedMissions() async => completed;
  @override
  Future<Mission> createMission(GameRoute r, String id,
      {bool revealEvents = false,
      double payFactor = 1.0,
      List<String>? eventIds}) async {
    createdRoute = r;
    createdPayFactor = payFactor;
    return _mission(routeId: r.id, minutes: r.durationMinutes);
  }

  @override
  Future<void> saveMission(Mission mission) async {}
  @override
  Future<Mission?> getActiveMissionFor(String id) async => null;
  @override
  Future<List<Mission>> getAllActiveMissions() async => [];
  @override
  Future<void> completeMission(String id, MissionResult r) async {}
  @override
  Future<List<GameRoute>> getAvailableRoutes(int rank, WorldState world) async =>
      [];
  @override
  Future<Mission> createTutorialMission(int i, String id) =>
      throw UnimplementedError();
  @override
  Future<Mission> createStoryMission(
          StoryMissionConfig c, String id, List<RealEventConfig> events) =>
      throw UnimplementedError();
}

class _World implements WorldRepository {
  WorldState state = WorldState.initial();
  @override
  Future<WorldState> getState() async => state;
  @override
  Future<void> saveState(WorldState s) async => state = s;
}

class _Progression implements ProgressionRepository {
  ProgressionState? saved;
  List<String> legacy;
  String? legacyEquipped;
  _Progression({this.legacy = const [], this.legacyEquipped});
  @override
  Future<ProgressionState?> load() async => saved;
  @override
  Future<void> save(ProgressionState s) async => saved = s;
  @override
  Future<({List<String> titles, String? equipped})> legacyTitles() async =>
      (titles: legacy, equipped: legacyEquipped);
}

// ─── Datos de prueba ──────────────────────────────────────────────────────────
Messenger _messenger({
  String id = 'm1',
  Map<SkillType, int>? skills,
  Set<String> boosts = const {},
}) =>
    Messenger(
      id: id,
      name: 'Marcus',
      gender: MessengerGender.male,
      health: 100,
      fatigue: 0,
      status: MessengerStatus.idle,
      skills: skills ?? {for (final s in SkillType.values) s: 1},
      skillXp: const {},
      completedMissionIds: const [],
      tutorialPhase: 1,
      tutorialMissionIndex: 0,
      tutorialComplete: true,
      activeBoosts: boosts,
    );

Mission _mission({
  String routeId = 'real_01',
  int minutes = 120,
  String? grade,
  bool tutorial = false,
}) {
  final start = DateTime(2026, 1, 1, 8);
  return Mission(
    id: 'mis_$routeId$grade',
    routeId: routeId,
    messengerId: 'm1',
    origin: 'Roma',
    destination: 'Ostia',
    packageDescription: 'Carta',
    lore: '',
    isTutorial: tutorial,
    tutorialIndex: tutorial ? 0 : -1,
    startedAt: start,
    deadlineAt: start.add(Duration(minutes: minutes)),
    progressPct: 100,
    status: MissionStatus.completed,
    packageState: PackageState.intact,
    events: const [],
    result: grade == null
        ? null
        : MissionResult(
            grade: grade,
            timeScore: 100,
            packageScore: 100,
            decisionScore: 100,
            arrivedAt: start,
            denarios: 50,
          ),
  );
}

({
  RecordProgressUseCase record,
  GetProgressionUseCase get,
  _Messengers messengers,
  _Progression progression,
}) _wire({
  List<Messenger>? messengers,
  List<Mission> completed = const [],
  _Progression? progression,
}) {
  final m = _Messengers(messengers ?? [_messenger()]);
  final p = progression ?? _Progression();
  final w = _World();
  final get = GetProgressionUseCase(p, m, _Missions(completed), w, kContent);
  return (
    record: RecordProgressUseCase(get, p, m, w, kContent),
    get: get,
    messengers: m,
    progression: p,
  );
}

void main() {
  // ─── Paga por ruta ──────────────────────────────────────────────────────────
  group('Paga por ruta', () {
    test('crece con la duración y el peligro, dentro del tope', () {
      double f(int min, [double d = 0.3]) => routePayFactor(min, d);
      expect(f(120), lessThan(f(480)));
      expect(f(480), lessThan(f(1440)));
      expect(f(480, 0.2), lessThan(f(480, 0.6)));
      expect(f(0, 0), kMinPayFactor);
      expect(f(100000, 1), kMaxPayFactor);
    });

    test('una ruta larga paga menos por hora que una corta', () {
      final short = routePayFactor(120, 0.2) / 2;
      final long = routePayFactor(72 * 60, 0.6) / 72;
      expect(long, lessThan(short));
    });

    test('el boost de velocidad acorta el viaje pero no la paga', () async {
      final route = allRealMissions.firstWhere((r) => r.id == 'real_02');
      final gameRoute = GameRoute(
        id: route.id, origin: route.origin, destination: route.destination,
        distanceKm: route.distanceKm, durationMinutes: route.durationMinutes,
        danger: route.danger, requiredRank: route.requiredRank,
        eventCount: route.minEvents, lore: route.lore,
      );
      Future<_Missions> accept(Set<String> boosts) async {
        final missions = _Missions();
        await AcceptMissionUseCase(
                missions, _Messengers([_messenger(boosts: boosts)]))
            .execute(gameRoute);
        return missions;
      }

      final plain = await accept({});
      final fast = await accept({'boost_speed'});
      expect(fast.createdRoute!.durationMinutes,
          lessThan(plain.createdRoute!.durationMinutes));
      expect(fast.createdPayFactor, plain.createdPayFactor);
      expect(plain.createdPayFactor,
          routePayFactor(route.durationMinutes, route.danger));
    });
  });

  // ─── Presupuesto diario (GDD §6.2) ──────────────────────────────────────────
  group('Presupuesto diario', () {
    // Jugador activo: 3 sesiones, una ruta corta y una larga, nota A/B.
    int missionsPerDay() {
      final short = allRealMissions.firstWhere((r) => r.id == 'real_01');
      final long = allRealMissions.firstWhere((r) => r.id == 'real_02');
      final avgAB = (gradeBaseReward('A') + gradeBaseReward('B')) / 2;
      return (avgAB *
              (routePayFactor(short.durationMinutes, short.danger) +
                  routePayFactor(long.durationMinutes, long.danger)))
          .round();
    }

    test('un día típico da ~435 Denarios (±10%)', () {
      // Contratos: promedio real del tablón a lo largo de 10 semanas.
      var contractSum = 0;
      for (var d = 0; d < 70; d++) {
        for (final id in contractIdsForDate(DateTime(2026, 3, 1 + d))) {
          contractSum += contractTemplateById(id).reward.denarios;
        }
      }
      final contracts = contractSum / 70;
      final dailyPay = dailyPaySchedule.fold<int>(0, (a, r) => a + r.denarios) /
          dailyPaySchedule.length;
      // Encargos semanales: dos de Denarios por semana (el tercero es el Sello).
      final paid = weeklyCommissionPool.where((d) => d.id != kWeeklySealId);
      final weekly =
          2 * paid.fold<int>(0, (a, d) => a + d.denarios) / paid.length / 7;
      const ads = 60; // rewarded ads, GDD §6.4
      final total = missionsPerDay() + contracts + dailyPay + weekly + ads;
      expect(total, inInclusiveRange(435 * 0.9, 435 * 1.1),
          reason: 'misiones ${missionsPerDay()} · contratos $contracts · '
              'paga ${dailyPay.round()} · semanales ${weekly.round()} · '
              'total ${total.round()}');
    });

    test('adelantar una ruta corta cuesta más de lo que paga', () {
      final short = allRealMissions.firstWhere((r) => r.id == 'real_01');
      final payA = gradeBaseReward('A') *
          routePayFactor(short.durationMinutes, short.danger);
      // 1 Denario por minuto adelantado (SkipToNextEventUseCase).
      expect(short.durationMinutes, greaterThan(payA));
    });
  });

  // ─── Logros ─────────────────────────────────────────────────────────────────
  group('Contenido de logros', () {
    final defs = kContent.achievements;

    test('ids únicos, metas positivas y textos presentes', () {
      expect(defs.map((d) => d.id).toSet(), hasLength(defs.length));
      for (final d in defs) {
        expect(d.target, greaterThan(0), reason: d.id);
        expect(d.name, isNotEmpty);
        expect(d.goal, isNotEmpty);
      }
    });

    test('Sellos: como mucho 1 por logro y 8 en toda la partida', () {
      for (final d in defs) {
        expect(d.reward.seals, lessThanOrEqualTo(1), reason: d.id);
      }
      expect(defs.fold<int>(0, (a, d) => a + d.reward.seals),
          lessThanOrEqualTo(8));
    });

    test('los títulos de logros no repiten los de los finales', () {
      final titles = defs.map((d) => d.reward.title).whereType<String>();
      expect(titles.toSet(), hasLength(titles.length));
      for (final t in ['El hombre de Varus', 'El protegido del Senador',
          'El que sabe demasiado']) {
        expect(titles, isNot(contains(t)));
      }
    });
  });

  group('Registro de progreso', () {
    test('desbloquea, paga una sola vez y es idempotente', () async {
      final w = _wire();
      await w.get.execute();

      final first = await w.record.execute(
          change: (s) => statsAfterDelivery(s, _mission(), 'S', 80));
      final ids = first.unlocked.map((a) => a.id);
      expect(ids, containsAll(['ach_first_delivery', 'ach_grade_s_1']));
      final paid = w.messengers.list.first.denarios;
      expect(paid, first.denarios);
      expect(paid, greaterThan(0));

      final again = await w.record.execute();
      expect(again.unlocked, isEmpty);
      expect(w.messengers.list.first.denarios, paid);
    });

    test('subir de rango se avisa una vez', () async {
      final w = _wire();
      await w.get.execute();
      w.messengers.list[0] = _messenger(
          skills: {for (final s in SkillType.values) s: 2}); // total 10 → rango 2
      final up = await w.record.execute();
      expect(up.rankReached, 2);
      expect((await w.record.execute()).rankReached, isNull);
    });

    test('el título de un final se suma y se puede equipar', () async {
      final w = _wire();
      await w.get.execute();
      final up = await w.record.execute(titles: ['El hombre de Varus']);
      expect(up.newTitles, ['El hombre de Varus']);
      final equip = EquipTitleUseCase(w.get, w.progression);
      expect((await equip.execute('El hombre de Varus')).equippedTitle,
          'El hombre de Varus');
      // Tocar de nuevo lo saca; un título que no tenés no se equipa.
      expect((await equip.execute('El hombre de Varus')).equippedTitle, isNull);
      expect((await equip.execute('Inventado')).equippedTitle, isNull);
    });

    test('la racha de paga cuenta días seguidos y se corta', () {
      var s = const PlayerStats();
      s = s.recordDailyPay(DateTime(2026, 2, 27));
      s = s.recordDailyPay(DateTime(2026, 2, 28));
      s = s.recordDailyPay(DateTime(2026, 3, 1)); // cruza el mes
      s = s.recordDailyPay(DateTime(2026, 3, 1)); // mismo día: no suma
      expect(s.payStreak, 3);
      s = s.recordDailyPay(DateTime(2026, 3, 5));
      expect(s.payStreak, 1);
      expect(s.bestPayStreak, 3);
    });
  });

  // ─── Migración v1 → v2 ──────────────────────────────────────────────────────
  group('Migración', () {
    test('reconstruye estadísticas y trae los títulos v1', () async {
      final w = _wire(
        completed: [
          _mission(grade: 'S'),
          _mission(routeId: 'real_03', minutes: 72 * 60, grade: 'B'),
          _mission(routeId: 'tut_01', grade: 'A', tutorial: true),
        ],
        progression: _Progression(
            legacy: ['El hombre de Varus'],
            legacyEquipped: 'El hombre de Varus'),
      );
      final state = await w.get.execute();
      expect(state.stats.missions, 3);
      expect(state.stats.gradeS, 1);
      expect(state.stats.routes, {'real_01', 'real_03'});
      expect(state.stats.longMissions, 1);
      expect(state.titles, contains('El hombre de Varus'));
      expect(state.equippedTitle, 'El hombre de Varus');
      // Logros retroactivos: desbloqueados y pagados.
      expect(state.unlocked,
          containsAll(['ach_first_delivery', 'ach_grade_s_1', 'ach_long_haul']));
      expect(w.messengers.list.first.denarios, greaterThan(0));
      // La segunda lectura no vuelve a migrar ni a pagar.
      final before = w.messengers.list.first.denarios;
      await w.get.execute();
      expect(w.messengers.list.first.denarios, before);
    });

    test('el estado sobrevive el ida y vuelta por JSON', () {
      const s = ProgressionState(
        stats: PlayerStats(missions: 4, routes: {'real_01'}, payStreak: 2,
            lastPayDay: '2026-03-01'),
        unlocked: {'ach_first_delivery'},
        titles: ['Cartógrafo'],
        equippedTitle: 'Cartógrafo',
      );
      final back = ProgressionState.fromJson(s.toJson());
      expect(back.stats.missions, 4);
      expect(back.stats.routes, {'real_01'});
      expect(back.stats.lastPayDay, '2026-03-01');
      expect(back.unlocked, {'ach_first_delivery'});
      expect(back.equippedTitle, 'Cartógrafo');
    });

    test('el repositorio local lee los títulos del esquema v1', () async {
      SharedPreferences.setMockInitialValues({
        'cosmetic_titles_v1': ['El que sabe demasiado'],
        'cosmetic_title_equipped_v1': 'El que sabe demasiado',
      });
      final repo = LocalProgressionRepository();
      expect(await repo.load(), isNull);
      final legacy = await repo.legacyTitles();
      expect(legacy.titles, ['El que sabe demasiado']);
      expect(legacy.equipped, 'El que sabe demasiado');
    });
  });
}
