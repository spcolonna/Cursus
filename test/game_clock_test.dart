import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/game_clock.dart';
import 'package:the_messenger/infrastructure/time/trusted_time_service.dart';

void main() {
  final t0 = DateTime(2026, 10, 14, 12);

  setUp(() {
    GameClock.debugReset();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(GameClock.debugReset);

  // ─── estimateGameTime ───────────────────────────────────────────────────────

  group('estimateGameTime', () {
    const anchor = 50000;

    test('mismo encendido: adelantar el reloj del teléfono no mueve el juego',
        () {
      final game = estimateGameTime(
        deviceNow: t0.add(const Duration(days: 3)), // reloj adelantado
        lastSkew: Duration.zero,
        anchor: ClockAnchor(t0, anchor),
        elapsedMs: anchor + 10 * 60 * 1000, // pasaron 10 min reales
      );
      expect(game, t0.add(const Duration(minutes: 10)));
    });

    test('mismo encendido: atrasar el reloj tampoco', () {
      final game = estimateGameTime(
        deviceNow: t0.subtract(const Duration(days: 1)),
        lastSkew: Duration.zero,
        anchor: ClockAnchor(t0, anchor),
        elapsedMs: anchor + 60000,
      );
      expect(game, t0.add(const Duration(minutes: 1)));
    });

    test('reinicio: hora del teléfono más la última diferencia', () {
      final game = estimateGameTime(
        deviceNow: t0.add(const Duration(hours: 2)),
        lastSkew: const Duration(minutes: -5),
        anchor: ClockAnchor(t0, anchor),
        elapsedMs: 1000, // el monotónico volvió a cero
      );
      expect(game, t0.add(const Duration(hours: 2, minutes: -5)));
    });

    test('reinicio con el reloj atrasado: nunca antes del ancla', () {
      final game = estimateGameTime(
        deviceNow: t0.subtract(const Duration(days: 2)),
        lastSkew: Duration.zero,
        anchor: ClockAnchor(t0, anchor),
        elapsedMs: 1000,
      );
      expect(game, t0);
    });

    test('sin monotónico ni ancla: hora del teléfono', () {
      expect(
        estimateGameTime(deviceNow: t0, lastSkew: Duration.zero),
        t0,
      );
    });
  });

  // ─── TrustedTimeService ─────────────────────────────────────────────────────

  group('TrustedTimeService', () {
    late DateTime device;
    late int elapsed;
    DateTime? server;

    TrustedTimeService service() => TrustedTimeService(
          elapsedMs: () async => elapsed,
          serverTime: () async => server,
          deviceNow: () => device,
        );

    setUp(() {
      device = t0;
      elapsed = 100000;
      server = null;
    });

    test('el servidor corrige un teléfono adelantado', () async {
      device = t0.add(const Duration(days: 1));
      server = t0;
      await service().syncWithServer();
      expect(GameClock.now().difference(t0).inSeconds, lessThan(2));
    });

    test('offline, cambiar la hora entre aperturas no adelanta el juego',
        () async {
      server = t0;
      await service().syncWithServer(); // ancla: t0 con monotónico 100000
      server = null;

      // El jugador cierra, adelanta el reloj 2 días y vuelve 5 min después.
      device = t0.add(const Duration(days: 2));
      elapsed += 5 * 60 * 1000;
      GameClock.debugReset();
      await service().restore();
      final drift = GameClock.now().difference(t0.add(const Duration(minutes: 5)));
      expect(drift.inSeconds.abs(), lessThan(2));
    });

    test('sin red y sin ancla: queda la hora del teléfono', () async {
      expect(await service().syncWithServer(), isFalse);
      await service().restore();
      expect(GameClock.now().difference(t0).inSeconds.abs(), lessThan(2));
    });

    test('sin canal nativo: usa la diferencia guardada', () async {
      server = t0.subtract(const Duration(minutes: 30)); // teléfono adelantado
      final s = TrustedTimeService(
        elapsedMs: () async => null,
        serverTime: () async => server,
        deviceNow: () => device,
      );
      await s.syncWithServer();
      GameClock.debugReset();
      device = t0.add(const Duration(hours: 1));
      await s.restore();
      final expected = t0.add(const Duration(minutes: 30));
      expect(GameClock.now().difference(expected).inSeconds.abs(), lessThan(2));
    });
  });

  // ─── GameClock y reglas ─────────────────────────────────────────────────────

  group('GameClock', () {
    test('las misiones leen la hora del juego, no la del teléfono', () {
      final mission = Mission(
        id: 'm',
        routeId: 'r',
        messengerId: 'x',
        origin: 'a',
        destination: 'b',
        packageDescription: 'carta',
        lore: '',
        isTutorial: false,
        tutorialIndex: 0,
        startedAt: t0,
        deadlineAt: t0.add(const Duration(hours: 1)),
        progressPct: 0,
        status: MissionStatus.active,
        packageState: PackageState.intact,
        events: const [],
      );
      GameClock.debugOverride(() => t0.add(const Duration(minutes: 30)));
      expect(mission.isOverdue, isFalse);
      GameClock.debugOverride(() => t0.add(const Duration(hours: 2)));
      expect(mission.isOverdue, isTrue);
    });

    test('toDevice pasa una hora del juego al reloj del teléfono', () {
      // El juego va 10 min atrás del teléfono.
      GameClock.setBase(DateTime.now().subtract(const Duration(minutes: 10)));
      final gameAt = GameClock.now().add(const Duration(hours: 1));
      final device = GameClock.toDevice(gameAt);
      final expected = DateTime.now().add(const Duration(hours: 1));
      expect(device.difference(expected).inSeconds.abs(), lessThan(2));
    });

    test('anclado, avanza con el tiempo real', () async {
      GameClock.setBase(t0);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(GameClock.now().isAfter(t0), isTrue);
      expect(GameClock.isAnchored, isTrue);
    });
  });

  // ─── Trinquete ──────────────────────────────────────────────────────────────

  test('domain/ no lee la hora del teléfono salvo los casos permitidos', () {
    // Ids, diario y analytics de retención usan la hora del teléfono a
    // propósito; toda regla de juego usa GameClock.now().
    const allowed = {
      'analytics_usecases.dart': 2,
      'world.dart': 1,
      'usecases.dart': 2,
    };
    final counts = <String, int>{};
    for (final f in Directory('lib/domain').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.endsWith('game_clock.dart')) continue;
      final n = 'DateTime.now()'.allMatches(f.readAsStringSync()).length;
      if (n > 0) counts[f.uri.pathSegments.last] = n;
    }
    expect(counts, allowed);
  });
}
