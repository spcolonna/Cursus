// Regresiones de los bugs de la Fase 1: costo de tiempo, eventos que se
// adelantaban, nota S inalcanzable, opciones bloqueadas, multi-mensajero y
// compras reales.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/data/static_game_content.dart';
import 'package:the_messenger/data/story_content.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/notifications.dart';
import 'package:the_messenger/domain/entities/world.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/domain/usecases/forecast.dart';
import 'package:the_messenger/domain/usecases/usecases.dart';
import 'package:the_messenger/presentation/providers/providers.dart';

const kContent = StaticGameContent();

// ─── Fakes en memoria ─────────────────────────────────────────────────────────
class _MessengerRepo implements MessengerRepository {
  final List<Messenger> messengers;
  _MessengerRepo(this.messengers);

  @override
  Future<List<Messenger>> getAllMessengers() async => List.of(messengers);
  @override
  Future<Messenger?> getMessenger() async => messengers.firstOrNull;
  @override
  Future<void> saveMessenger(Messenger m) async {
    final i = messengers.indexWhere((x) => x.id == m.id);
    if (i != -1) {
      messengers[i] = m;
    } else {
      messengers.add(m);
    }
  }

  @override
  Future<void> saveAllMessengers(List<Messenger> ms) async => messengers
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
      required int slotIndex}) async {
    final cost = messengerSlotCosts[slotIndex]!;
    if (payer.aureos < cost) throw Exception('Aureos insuficientes');
    await saveMessenger(payer.copyWith(aureos: payer.aureos - cost));
    final m = _messenger(id: 'm$slotIndex', name: newName);
    messengers.add(m);
    return m;
  }
}

class _MissionRepo implements MissionRepository {
  Mission? saved;
  MissionResult? completed;
  _MissionRepo([this.saved]);

  @override
  Future<void> saveMission(Mission mission) async => saved = mission;
  @override
  Future<Mission?> getActiveMissionFor(String id) async => saved;
  @override
  Future<List<Mission>> getAllActiveMissions() async =>
      saved == null ? [] : [saved!];
  @override
  Future<void> completeMission(String id, MissionResult r) async =>
      completed = r;
  @override
  Future<List<Mission>> getCompletedMissions() async => [];
  @override
  Future<List<GameRoute>> getAvailableRoutes(int rank, WorldState world) async =>
      [];
  @override
  Future<Mission> createMission(GameRoute r, String id,
          {bool revealEvents = false,
      double payFactor = 1.0,
      List<String>? eventIds}) =>
      throw UnimplementedError();
  @override
  Future<Mission> createTutorialMission(int i, String id) =>
      throw UnimplementedError();
  @override
  Future<Mission> createStoryMission(
          StoryMissionConfig c, String id, List<RealEventConfig> events) =>
      throw UnimplementedError();
}

class _WorldRepo implements WorldRepository {
  WorldState state = WorldState.initial();
  @override
  Future<WorldState> getState() async => state;
  @override
  Future<void> saveState(WorldState s) async => state = s;
}

// ─── Datos de prueba ──────────────────────────────────────────────────────────
Messenger _messenger({
  String id = 'm1',
  String name = 'Marcus',
  Map<SkillType, int>? skills,
  Set<String> boosts = const {},
  int denarios = 0,
  int aureos = 0,
}) =>
    Messenger(
      id: id,
      name: name,
      gender: MessengerGender.male,
      health: 100,
      fatigue: 0,
      status: MessengerStatus.onMission,
      skills: skills ?? {for (final s in SkillType.values) s: 1},
      skillXp: const {},
      completedMissionIds: const [],
      tutorialPhase: 1,
      tutorialMissionIndex: 0,
      tutorialComplete: true,
      activeBoosts: boosts,
      denarios: denarios,
      aureos: aureos,
    );

EventOption _option({
  int timeCost = 0,
  int risk = 1,
  Map<SkillType, int> skills = const {},
}) =>
    EventOption(
      id: 'opt_test',
      text: 'Esperar',
      riskLevel: risk,
      timeCostMinutes: timeCost,
      requiredSkills: skills,
      outcomeSuccess: 'Bien.',
      outcomePartial: 'Más o menos.',
      outcomeFail: 'Mal.',
    );

MissionEvent _event(String id, DateTime at,
        {EventStatus status = EventStatus.pending, EventOption? option}) =>
    MissionEvent(
      id: id,
      title: 'Prueba',
      description: 'Algo pasa.',
      triggersAt: at,
      deadlineAt: at.add(const Duration(minutes: 60)),
      status: status,
      options: [option ?? _option()],
    );

Mission _mission({
  required DateTime startedAt,
  required DateTime deadlineAt,
  List<MissionEvent> events = const [],
  String messengerId = 'm1',
}) =>
    Mission(
      id: 'mis1',
      routeId: 'route_test',
      messengerId: messengerId,
      origin: 'Roma',
      destination: 'Tibur',
      packageDescription: 'Un tubo lacrado',
      lore: '',
      isTutorial: false,
      tutorialIndex: 0,
      startedAt: startedAt,
      deadlineAt: deadlineAt,
      progressPct: 10,
      status: MissionStatus.active,
      packageState: PackageState.intact,
      events: events,
    );

void main() {
  final now = DateTime.now();

  group('Costo de tiempo', () {
    test('esperar demora la llegada y nunca la deja antes de la salida',
        () async {
      // Roma→Tibur (30 min) con una espera de 120 min: antes trababa la misión.
      final ev = _event('e1', now.subtract(const Duration(minutes: 1)),
          option: _option(timeCost: 120));
      final mission = _mission(
        startedAt: now.subtract(const Duration(minutes: 10)),
        deadlineAt: now.add(const Duration(minutes: 20)),
        events: [ev],
      );
      final repo = _MissionRepo(mission);
      await ResolveEventUseCase(
              repo, _MessengerRepo([_messenger()]), _WorldRepo(), kContent)
          .execute(mission: mission, event: ev, option: ev.options.first);

      final after = repo.saved!;
      expect(after.deadlineAt.isAfter(mission.deadlineAt), isTrue);
      expect(after.deadlineAt.isAfter(after.startedAt), isTrue);
      final delay = after.deadlineAt.difference(mission.deadlineAt).inMinutes;
      expect(delay, greaterThanOrEqualTo(120)); // 120, o 240 si falló
    });

    test('delayedBy corre los eventos futuros, no los pasados', () {
      final past = _event('p', now.subtract(const Duration(minutes: 5)),
          status: EventStatus.resolved);
      final future = _event('f', now.add(const Duration(minutes: 30)));
      final m = _mission(
        startedAt: now.subtract(const Duration(minutes: 10)),
        deadlineAt: now.add(const Duration(hours: 1)),
        events: [past, future],
      ).delayedBy(15);
      expect(m.events[0].triggersAt, past.triggersAt);
      expect(m.events[1].triggersAt,
          future.triggersAt.add(const Duration(minutes: 15)));
    });
  });

  group('Eventos a su hora', () {
    test('resolver un evento no activa el siguiente antes de tiempo', () async {
      final ev1 = _event('e1', now.subtract(const Duration(minutes: 1)));
      final ev2 = _event('e2', now.add(const Duration(hours: 2)));
      final mission = _mission(
        startedAt: now.subtract(const Duration(minutes: 30)),
        deadlineAt: now.add(const Duration(hours: 3)),
        events: [ev1, ev2],
      );
      final repo = _MissionRepo(mission);
      await ResolveEventUseCase(
              repo, _MessengerRepo([_messenger()]), _WorldRepo(), kContent)
          .execute(mission: mission, event: ev1, option: ev1.options.first);

      expect(repo.saved!.events[1].status, EventStatus.pending);
      expect(repo.saved!.pendingEvent, isNull);
    });

    test('un evento marcado active pero futuro no bloquea', () {
      final m = _mission(
        startedAt: now,
        deadlineAt: now.add(const Duration(hours: 2)),
        events: [
          _event('e', now.add(const Duration(hours: 1)),
              status: EventStatus.active),
        ],
      );
      expect(m.pendingEvent, isNull);
    });
  });

  group('Requisitos de opciones', () {
    test('el dominio rechaza una opción sin la skill requerida', () async {
      final locked = _option(skills: {SkillType.combat: 3});
      final ev = _event('e1', now.subtract(const Duration(minutes: 1)),
          option: locked);
      final mission = _mission(
        startedAt: now.subtract(const Duration(minutes: 10)),
        deadlineAt: now.add(const Duration(hours: 1)),
        events: [ev],
      );
      final uc = ResolveEventUseCase(_MissionRepo(mission),
          _MessengerRepo([_messenger()]), _WorldRepo(), kContent);
      expect(() => uc.execute(mission: mission, event: ev, option: locked),
          throwsException);
    });
  });

  group('Nota', () {
    test('sin retraso el tiempo vale 100; con 25% de retraso, 50', () {
      final start = now.subtract(const Duration(hours: 2));
      expect(
          timeScoreFor(_mission(
              startedAt: start,
              deadlineAt: start.add(const Duration(hours: 2)))),
          100);

      final delayed = _event('e', start, status: EventStatus.resolved).copyWith(
          outcome: const EventOutcome(
        type: OutcomeType.partial,
        narrative: '',
        healthDelta: 0,
        timeDeltaMinutes: 30,
        packageState: PackageState.intact,
      ));
      // 120 min de viaje + 30 de retraso → 25%.
      expect(
          timeScoreFor(_mission(
              startedAt: start,
              deadlineAt: start.add(const Duration(minutes: 150)),
              events: [delayed])),
          50);
    });

    test('un viaje perfecto entregado tarde igual saca S', () async {
      final mission = _mission(
        startedAt: now.subtract(const Duration(hours: 3)),
        // Llegó hace 1 h y el jugador recién ahora toca ENTREGAR.
        deadlineAt: now.subtract(const Duration(hours: 1)),
        events: [
          _event('e', now.subtract(const Duration(hours: 2)),
                  status: EventStatus.resolved)
              .copyWith(
                  outcome: const EventOutcome(
            type: OutcomeType.success,
            narrative: '',
            healthDelta: 0,
            timeDeltaMinutes: 0,
            packageState: PackageState.intact,
          )),
        ],
      );
      final repo = _MissionRepo(mission);
      final completion = await CompleteMissionUseCase(
              repo, _MessengerRepo([_messenger()]), _WorldRepo(), kContent)
          .execute('m1');
      expect(completion!.result.grade, 'S');
    });
  });

  group('Varios mensajeros', () {
    test('slotFor devuelve el slot pedido y si no, el principal', () {
      final state = HomeState(slots: [
        MessengerSlot(messenger: _messenger(id: 'a')),
        MessengerSlot(messenger: _messenger(id: 'b')),
      ]);
      expect(state.slotFor('b')!.messenger.id, 'b');
      expect(state.slotFor(null)!.messenger.id, 'a');
      expect(state.slotFor('zzz')!.messenger.id, 'a');
    });
  });

  group('Compras reales', () {
    test('el Pack del Guerrero acredita Aureos y 2 niveles a elección',
        () async {
      final repo = _MessengerRepo([_messenger()]);
      await CreditPurchaseUseCase(repo).execute('bundle_warrior');
      expect(repo.messengers.first.aureos, 50);
      expect(skillPicksOf(repo.messengers.first), 2);

      await UseSkillPickUseCase(repo)
          .execute(messengerId: 'm1', skill: SkillType.stealth);
      expect(repo.messengers.first.skillLevel(SkillType.stealth), 2);
      expect(skillPicksOf(repo.messengers.first), 1);
    });

    test('el formato viejo iap_skill_pick_2 vale por dos', () async {
      final repo = _MessengerRepo([
        _messenger(boosts: {'iap_skill_pick_2'})
      ]);
      expect(skillPicksOf(repo.messengers.first), 2);
      await UseSkillPickUseCase(repo)
          .execute(messengerId: 'm1', skill: SkillType.combat);
      expect(skillPicksOf(repo.messengers.first), 1);
    });

    test('el Pack del Correo abre el 2.º mensajero sin cobrar el slot',
        () async {
      final repo = _MessengerRepo([_messenger()]);
      await CreditPurchaseUseCase(repo).execute('bundle_starter');
      expect(repo.messengers.length, 2);
      expect(repo.messengers.first.aureos, 30);
      expect(repo.messengers.first.seals, 2);
    });
  });

  group('Tiradas críticas', () {
    Future<List<EventResolution>> tirar(
        Messenger m, EventOption o, int n) async {
      final out = <EventResolution>[];
      for (var i = 0; i < n; i++) {
        final ev =
            _event('e', now.subtract(const Duration(minutes: 1)), option: o);
        final mission = _mission(
            startedAt: now.subtract(const Duration(minutes: 10)),
            deadlineAt: now.add(const Duration(hours: 1)),
            events: [ev]);
        out.add(await ResolveEventUseCase(_MissionRepo(mission),
                _MessengerRepo([m]), _WorldRepo(), kContent)
            .execute(mission: mission, event: ev, option: o));
      }
      return out;
    }

    test('el maxeado puede fallar en riesgo 5 (invariante 7)', () async {
      final maxeado = _messenger(skills: {
        for (final s in SkillType.values) s: 10,
      });
      final o = _option(risk: 5, skills: {SkillType.combat: 3});
      final res = await tirar(maxeado, o, 400);
      expect(res.any((r) => r.outcome.type == OutcomeType.fail), isTrue);
      // Y el desglose sigue cerrando con el score.
      for (final r in res) {
        expect(r.scoreFactors.fold<int>(0, (a, f) => a + f.value), r.score);
      }
    });

    test('una opción sin habilidad puede salir bien', () async {
      final res = await tirar(_messenger(), _option(risk: 1), 400);
      expect(res.any((r) => r.outcome.type == OutcomeType.success), isTrue);
    });

    test('el pronóstico del maxeado en riesgo 5 ya no es certeza', () {
      expect(mishapPercent(5), greaterThan(0));
      expect(mishapPercent(4), greaterThan(0));
      expect(mishapPercent(3), 0);
    });
  });

  group('Tienda', () {
    test('los manuales escalan y no se venden en nivel 5', () async {
      final repo = _MessengerRepo([
        _messenger(denarios: 5000, skills: {SkillType.speed: 2}),
      ]);
      final uc = ApplyShopItemUseCase(repo);
      await uc.execute(targetId: 'm1', itemId: 'skill_speed_1');
      expect(repo.messengers.first.skillLevel(SkillType.speed), 3);
      expect(repo.messengers.first.denarios, 5000 - 500);

      repo.messengers[0] = repo.messengers.first
          .copyWith(skills: {SkillType.speed: kMaxSkillLevel});
      expect(() => uc.execute(targetId: 'm1', itemId: 'skill_speed_1'),
          throwsException);
    });

    test('paga el principal y el efecto va al mensajero elegido', () async {
      final repo = _MessengerRepo([
        _messenger(denarios: 200),
        _messenger(id: 'm2', name: 'Livia').copyWith(health: 10),
      ]);
      await ApplyShopItemUseCase(repo).execute(
          targetId: 'm2', itemId: 'boost_health_full', denariosCost: 120);
      expect(repo.messengers[0].denarios, 80);
      expect(repo.messengers[0].health, 100);
      expect(repo.messengers[1].health, 100);
    });

    test('sin saldo no se cobra ni se aplica nada', () async {
      final repo = _MessengerRepo([_messenger(denarios: 10)]);
      expect(
          () => ApplyShopItemUseCase(repo).execute(
              targetId: 'm1', itemId: 'boost_fatigue', denariosCost: 80),
          throwsException);
      expect(repo.messengers.first.denarios, 10);
    });
  });

  group('Billetera común', () {
    test('la paga de un mensajero secundario va al principal', () async {
      final mission = _mission(
        startedAt: now.subtract(const Duration(hours: 2)),
        deadlineAt: now.subtract(const Duration(minutes: 1)),
        messengerId: 'm2',
      );
      final repo = _MessengerRepo([
        _messenger(denarios: 100),
        _messenger(id: 'm2', name: 'Livia'),
      ]);
      final completion = await CompleteMissionUseCase(
              _MissionRepo(mission), repo, _WorldRepo(), kContent)
          .execute('m2');
      expect(repo.messengers[0].denarios, 100 + completion!.denariosDelta);
      expect(repo.messengers[1].denarios, 0);
    });
  });

  group('Reloj de la misión (dominio)', () {
    final t0 = DateTime(2026, 1, 1, 12);
    Mission m() => _mission(
          startedAt: t0,
          deadlineAt: t0.add(const Duration(hours: 2)),
          events: [_event('e1', t0.add(const Duration(minutes: 30)))],
        );

    test('el avance se congela en el evento sin resolver', () {
      final at = t0.add(const Duration(minutes: 90));
      expect(m().progressAt(at), closeTo(0.25, 1e-9));
      expect(m().readyToDeliverAt(t0.add(const Duration(hours: 3))), isFalse);
    });

    test('adelantar por anuncio no saltea el próximo evento', () {
      final now = t0.add(const Duration(minutes: 10));
      final ff = m().fastForward(now, max: const Duration(minutes: 30));
      // Tope: el evento (a 20 min) queda activo, no se pasa de largo.
      expect(ff.blockingEventAt(now)?.id, 'e1');
      expect(ff.deadlineAt.difference(ff.startedAt), const Duration(hours: 2));
    });

    test('adelantar sin eventos llega al destino', () {
      final now = t0.add(const Duration(minutes: 10));
      final sinEventos = _mission(
          startedAt: t0, deadlineAt: t0.add(const Duration(hours: 2)));
      final ff = sinEventos.fastForward(now);
      expect(ff.readyToDeliverAt(now.add(const Duration(seconds: 3))), isTrue);
    });

    test('costo de adelantar: 1 denario por minuto, entre 5 y 300', () {
      final now = t0.add(const Duration(minutes: 10));
      expect(SkipToNextEventUseCase.costFor(m(), now: now), 20);
      final llegado = _mission(
          startedAt: t0, deadlineAt: t0.add(const Duration(minutes: 5)));
      expect(SkipToNextEventUseCase.costFor(llegado, now: now), 0);
    });
  });

  group('Auto-resolución separada del Home', () {
    test('GetHomeState solo lee; la auto-resolución escribe aparte', () async {
      final now = DateTime.now();
      final vencido = _event(
          'e1', now.subtract(const Duration(hours: 3)));
      final mission = _mission(
        startedAt: now.subtract(const Duration(hours: 4)),
        deadlineAt: now.add(const Duration(hours: 1)),
        events: [vencido],
      );
      final missions = _MissionRepo(mission);
      final messengers = _MessengerRepo([_messenger()]);
      final world = _WorldRepo();

      await GetHomeStateUseCase(messengers, missions, world, kContent)
          .execute();
      expect(identical(missions.saved, mission), isTrue);

      final report =
          await AutoResolveExpiredEventsUseCase(messengers, missions, world)
              .execute();
      expect(report, hasLength(1));
      expect(missions.saved!.events.single.status, EventStatus.resolved);
      expect(messengers.messengers.single.health, 95);
    });
  });

  group('Premio de Primeros pasos', () {
    test('se acredita en el principal', () async {
      final repo = _MessengerRepo(
          [_messenger(), _messenger(id: 'm2', name: 'Livia')]);
      await ClaimChecklistRewardUseCase(repo).execute();
      expect(repo.messengers[0].aureos, kChecklistRewardAureos);
      expect(repo.messengers[0].seals, kChecklistRewardSeals);
      expect(repo.messengers[1].aureos, 0);
    });
  });

  group('Contenido inyectado', () {
    test('encuentra eventos de historia y del pool real', () {
      for (final e in [...storyEventPool, ...kContent.tutorialMissions]) {
        final id = e is RealEventConfig ? e.id : null;
        if (id != null) expect(kContent.eventById(id)?.id, id);
      }
      expect(kContent.storyMissionFor(kContent.mainArcId, 0, const {}),
          isNotNull);
    });

    test('domain/ no importa Flutter ni data/', () {
      final dir = Directory('lib/domain');
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        final imports = f
            .readAsLinesSync()
            .where((l) => l.startsWith('import '))
            .join('\n');
        expect(imports.contains('package:flutter'), isFalse, reason: f.path);
        expect(imports.contains('data/'), isFalse, reason: f.path);
      }
    });
  });

  // ─── Avisos: tap y recordatorios ───────────────────────────────────────────
  group('Avisos', () {
    test('tocar un aviso de evento abre el evento de ese mensajero', () {
      expect(routeForNotification('event:mis_1:msg_2|2026-10-05T10:00:00'),
          '/event?m=msg_2');
      expect(routeForNotification('delivery:mis_1:msg_2|2026-10-05T10:00:00'),
          '/mission?m=msg_2');
    });

    test('los avisos viejos sin mensajero abren el principal', () {
      expect(routeForNotification('event:mis_1|2026-10-05T10:00:00'), '/event');
    });

    test('recordatorios y payloads raros', () {
      expect(routeForNotification('idle|2026-10-05T10:00:00'), '/home');
      expect(routeForNotification('contracts'), '/home');
      expect(routeForNotification('test|2026-10-05T10:00:00'), isNull);
      expect(routeForNotification(null), isNull);
    });

    test('el recordatorio de ocioso respeta el silencio nocturno', () {
      expect(idleReminderAt(DateTime(2026, 10, 5, 10)),
          DateTime(2026, 10, 5, 14));
      // 20 + 4 h = medianoche → se corre a las 8.
      expect(idleReminderAt(DateTime(2026, 10, 5, 20)),
          DateTime(2026, 10, 6, 8));
    });

    test('contratos: hoy si quedan pendientes, si no mañana', () {
      final morning = DateTime(2026, 10, 5, 9);
      expect(contractsReminderAt(morning, pendingToday: true),
          DateTime(2026, 10, 5, kContractsReminderHour));
      expect(contractsReminderAt(morning, pendingToday: false),
          DateTime(2026, 10, 6, kContractsReminderHour));
      expect(contractsReminderAt(DateTime(2026, 10, 5, 21), pendingToday: true),
          DateTime(2026, 10, 6, kContractsReminderHour));
    });
  });

  // ─── Fase 0: el arco no se traba ───────────────────────────────────────────
  group('Arco y auto-resolución', () {
    final arc = kContent.mainArcId;

    test('la auto-resolución aplica flags, reputación y diario', () async {
      final now = DateTime.now();
      const option = EventOption(
        id: 'opt_path',
        text: 'Elegir',
        riskLevel: 1,
        timeCostMinutes: 0,
        requiredSkills: {},
        outcomeSuccess: 'Bien.',
        outcomePartial: 'Más o menos.',
        outcomeFail: 'Mal.',
        setFlags: ['path_claudius'],
        repDelta: {Faction.patricians: 2},
        journalNote: 'Elegiste.',
      );
      final mission = _mission(
        startedAt: now.subtract(const Duration(hours: 4)),
        deadlineAt: now.add(const Duration(hours: 1)),
        events: [
          _event('e1', now.subtract(const Duration(hours: 3)), option: option)
        ],
      );
      final world = _WorldRepo();
      await AutoResolveExpiredEventsUseCase(
              _MessengerRepo([_messenger()]), _MissionRepo(mission), world)
          .execute();
      expect(world.state.hasFlag('path_claudius'), isTrue);
      expect(world.state.repOf(Faction.patricians), 2);
      expect(world.state.journal.last.text, contains('No estabas'));
    });

    test('sin flag de camino, los capítulos IV y V usan la variante por defecto',
        () {
      for (var stage = 0; stage < kContent.arcStageCount(arc); stage++) {
        expect(kContent.storyMissionFor(arc, stage, const {}), isNotNull,
            reason: 'stage $stage');
      }
    });

    test('cada camino tiene su variante en todos los capítulos', () {
      for (final path in ['path_varus', 'path_claudius', 'path_underworld']) {
        for (var stage = 3; stage < kContent.arcStageCount(arc); stage++) {
          expect(kContent.storyMissionFor(arc, stage, {path})?.requiredFlag,
              path);
        }
      }
    });

    test('la reparación pone el flag de la variante por defecto', () async {
      final world = _WorldRepo()
        ..state = WorldState.initial().copyWith(arcProgress: {arc: 3});
      final repaired = await RepairArcStateUseCase(world, kContent).execute();
      expect(repaired, isTrue);
      expect(world.state.hasFlag('path_varus'), isTrue);
      // Idempotente.
      expect(await RepairArcStateUseCase(world, kContent).execute(), isFalse);
    });

    test('la reparación no toca partidas sanas', () async {
      final world = _WorldRepo()
        ..state = WorldState.initial()
            .copyWith(arcProgress: {arc: 3}, flags: {'path_underworld'});
      expect(await RepairArcStateUseCase(world, kContent).execute(), isFalse);
      expect(world.state.hasFlag('path_varus'), isFalse);
    });
  });

  test('la prosa de los resultados no arrastra marcas sueltas', () {
    // Había outcomes que empezaban con "~ " (marca de borrador).
    final src = File('lib/data/game_content.dart').readAsStringSync();
    expect(RegExp(r"outcome(Success|Partial|Fail): '[~*#]").hasMatch(src),
        isFalse);
  });
}
