import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/domain/entities/analytics.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/domain/usecases/analytics_usecases.dart';
import 'package:the_messenger/infrastructure/analytics/analytics_service.dart';

class _MemRetention implements RetentionRepository {
  RetentionLog? log;
  @override
  Future<RetentionLog?> load() async => log;
  @override
  Future<void> save(RetentionLog l) async => log = l;
}

class _MemSink implements AnalyticsSink {
  final events = <AnalyticsEvent>[];
  @override
  Future<void> log(AnalyticsEvent e) async => events.add(e);
  @override
  Future<void> setUserProperty(String name, String? value) async {}
}

class _ThrowingSink implements AnalyticsSink {
  @override
  Future<void> log(AnalyticsEvent e) => throw StateError('sin red');
  @override
  Future<void> setUserProperty(String name, String? value) =>
      throw StateError('sin red');
}

/// Un jugador que instaló el [install] y jugó los días [days].
RetentionLog _player(DateTime install, List<int> days) {
  var log = RetentionLog.start(install);
  for (final d in days) {
    log = log.open(install.add(Duration(days: d, hours: 1))).log;
  }
  return log;
}

void main() {
  final t0 = DateTime(2026, 10, 1, 9);

  group('Diccionario de eventos', () {
    final all = [
      AnalyticsEvent.gameSession(day: 0, sessionOfDay: 1, daysActive: 1),
      AnalyticsEvent.tutorialStep(0),
      AnalyticsEvent.tutorialComplete(),
      AnalyticsEvent.missionAccept(
          routeId: 'real_01', kind: 'real', rank: 1, minutes: 60, busy: 0),
      AnalyticsEvent.eventResolved(
          event: 'Patrulla en el puente',
          outcome: 'success',
          risk: 3,
          score: 61),
      AnalyticsEvent.eventsAutoResolved(2),
      AnalyticsEvent.missionComplete(
          routeId: 'real_01', kind: 'real', grade: 'S', denarios: 135),
      AnalyticsEvent.skipToEvent(40),
      AnalyticsEvent.rewardedAd('advance_30'),
      AnalyticsEvent.storyChapter(
          arcId: 'arc_claudius', chapter: 1, variant: 'claudius_1'),
      AnalyticsEvent.arcComplete(
          arcId: 'arc_claudius', ending: 'Hombre de Varus'),
      AnalyticsEvent.skillLevel(skill: 'stealth', level: 6, via: 'ascend'),
      AnalyticsEvent.rankUp(3),
      AnalyticsEvent.achievement('ach_first_s'),
      AnalyticsEvent.factionTier(faction: 'guild', tier: 'respected'),
      AnalyticsEvent.slotUnlock(2),
      AnalyticsEvent.dailyPay(7),
      AnalyticsEvent.contractClaim('c_deliver_2'),
      AnalyticsEvent.contractReroll(),
      AnalyticsEvent.weeklyClaim('w_first_s'),
      AnalyticsEvent.shopItem(
          itemId: 'potion', currency: 'denarios', price: 40),
      AnalyticsEvent.iapCredited('aureos_100'),
    ];

    test('todos cumplen los límites de Firebase', () {
      for (final e in all) {
        expect(e.isValid, isTrue, reason: '$e');
      }
    });

    test('ningún nombre se repite', () {
      final names = all.map((e) => e.name).toList();
      expect(names.toSet().length, names.length);
    });

    test('rechaza nombres reservados, largos o con valores raros', () {
      expect(const AnalyticsEvent('session_start').isValid, isFalse);
      expect(const AnalyticsEvent('firebase_x').isValid, isFalse);
      expect(const AnalyticsEvent('Mission').isValid, isFalse);
      expect(AnalyticsEvent('ok', {'t': 'x' * 101}).isValid, isFalse);
      expect(const AnalyticsEvent('ok', {'b': true}).isValid, isFalse);
    });
  });

  group('RetentionLog', () {
    test('la primera apertura es el día 0 y una sesión', () {
      final r = RetentionLog.start(t0).open(t0);
      expect(r.newSession, isTrue);
      expect(r.newDay, isTrue);
      expect(r.log.dayIndex(t0), 0);
      expect(r.log.totalSessions, 1);
    });

    test('volver antes de 30 min sigue la misma sesión', () {
      var log = RetentionLog.start(t0).open(t0).log;
      log = log.touch(t0.add(const Duration(minutes: 5)));
      final r = log.open(t0.add(const Duration(minutes: 20)));
      expect(r.newSession, isFalse);
      expect(r.log.totalSessions, 1);
    });

    test('volver tras 30 min es otra sesión del mismo día', () {
      final log = RetentionLog.start(t0).open(t0).log;
      final r = log.open(t0.add(const Duration(minutes: 31)));
      expect(r.newSession, isTrue);
      expect(r.newDay, isFalse);
      expect(r.log.sessionsOn(0), 2);
    });

    test('cruzar la medianoche cuenta el día nuevo', () {
      final late = DateTime(2026, 10, 1, 23, 50);
      final log = RetentionLog.start(late).open(late).log;
      final r = log.open(DateTime(2026, 10, 2, 0, 5));
      expect(r.newDay, isTrue);
      expect(r.log.activeOn(1), isTrue);
    });

    test('el cambio de horario no corre el índice de días', () {
      // Argentina no tiene DST, pero el cálculo no debe depender de eso.
      final log = RetentionLog.start(DateTime(2026, 3, 1));
      expect(log.dayIndex(DateTime(2026, 4, 1, 12)), 31);
    });

    test('ida y vuelta por JSON', () {
      final log = _player(t0, [0, 1, 3]);
      final back = RetentionLog.fromJson(log.toJson());
      expect(back.sessionsByDay, log.sessionsByDay);
      expect(back.installDay, log.installDay);
      expect(back.lastSeen, log.lastSeen);
    });
  });

  group('Métricas de cohorte', () {
    final now = t0.add(const Duration(days: 40));
    final cohort = [
      _player(t0, [0, 1, 7, 30]),
      _player(t0, [0, 1, 2]),
      _player(t0, [0, 8]),
      _player(t0, [0]),
    ];

    test('D1 y D7 clásicos', () {
      expect(classicRetention(cohort, 1, now), 0.5);
      expect(classicRetention(cohort, 7, now), 0.25);
    });

    test('D7 rolling cuenta a quien volvió después', () {
      expect(rollingRetention(cohort, 7, now), 0.5);
    });

    test('solo cuenta a quien ya pudo llegar a ese día', () {
      final recent = [
        _player(now.subtract(const Duration(days: 2)), [0])
      ];
      expect(classicRetention([...cohort, ...recent], 7, now), 0.25);
    });

    test('stickiness: DAU/MAU de los últimos 30 días', () {
      final today = now;
      final daily = _player(today.subtract(const Duration(days: 29)),
          List.generate(30, (i) => i));
      final once = _player(today.subtract(const Duration(days: 29)), [29]);
      // (30 + 1) / 30 / 2
      expect(stickiness([daily, once], today), closeTo(31 / 60, 1e-9));
    });
  });

  group('TrackSessionUseCase', () {
    test('manda game_session solo en sesiones nuevas', () async {
      final repo = _MemRetention();
      final sink = _MemSink();
      final uc = TrackSessionUseCase(repo, sink);
      await uc.open(now: t0);
      await uc.pause(now: t0.add(const Duration(minutes: 3)));
      await uc.open(now: t0.add(const Duration(minutes: 10)));
      await uc.open(now: t0.add(const Duration(days: 1)));
      expect(sink.events.map((e) => e.name), ['game_session', 'game_session']);
      expect(sink.events.last.params['day'], 1);
      expect(repo.log!.daysActive, 2);
    });
  });

  group('AnalyticsService', () {
    test('un sink que falla no frena a los demás', () async {
      final mem = _MemSink();
      final s = AnalyticsService([_ThrowingSink(), mem]);
      await s.log(AnalyticsEvent.tutorialComplete());
      await s.setUserProperty('player_rank', '2');
      expect(mem.events, hasLength(1));
    });

    test('con el opt-out apagado no manda nada', () async {
      final mem = _MemSink();
      final s = AnalyticsService([mem], enabled: false);
      await s.log(AnalyticsEvent.tutorialComplete());
      expect(mem.events, isEmpty);
    });
  });
}
