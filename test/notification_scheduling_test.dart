// Avisos locales: qué programa LocalNotificationService para una misión, con
// qué ids, cuándo los cancela y de dónde saca la hora. El plugin se reemplaza
// por un canal falso que guarda lo pendiente en memoria, como el sistema.
import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_messenger/domain/entities/content_l10n.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/game_clock.dart';
import 'package:the_messenger/domain/entities/notifications.dart';
import 'package:the_messenger/infrastructure/notifications/notification_service.dart';
import 'package:the_messenger/l10n/app_localizations.dart';
import 'package:the_messenger/presentation/providers/providers.dart';

const _pluginChannel =
    MethodChannel('dexterous.com/flutter/local_notifications');
const _tzChannel = MethodChannel('flutter_timezone');

/// El sistema operativo, de mentira: guarda los avisos pendientes por id.
class _FakeOs {
  final Map<int, Map<String, Object?>> pending = {};
  final List<Map<String, Object?>> scheduled = [];
  bool enabled = true;

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'initialize':
        return true;
      case 'areNotificationsEnabled':
        return enabled;
      case 'canScheduleExactNotifications':
        return false;
      case 'pendingNotificationRequests':
        return [for (final p in pending.values) Map<String, Object?>.of(p)];
      case 'zonedSchedule':
        final args = Map<String, Object?>.from(call.arguments as Map);
        scheduled.add(args);
        pending[args['id'] as int] = {
          'id': args['id'],
          'title': args['title'],
          'body': args['body'],
          'payload': args['payload'],
        };
        return null;
      case 'cancel':
        final args = call.arguments;
        pending.remove(args is Map ? args['id'] : args);
        return null;
      case 'cancelAll':
        pending.clear();
        return null;
      default:
        return null;
    }
  }

  List<Map<String, Object?>> ofKind(String kind) => pending.values
      .where((p) => (p['payload'] as String).startsWith(kind))
      .toList();
}

/// Hora del juego fija para todos los tests (lejos del reloj real a
/// propósito: así se nota si algo lee DateTime.now()).
final _now = DateTime(2030, 3, 10, 12);

MissionEvent _event(String id, DateTime at,
        {EventStatus status = EventStatus.pending}) =>
    MissionEvent(
      id: id,
      title: 'Puente caído $id',
      description: '',
      triggersAt: at,
      deadlineAt: at.add(const Duration(minutes: kDecisionWindowMinutes)),
      status: status,
      options: const [],
    );

Mission _mission({
  String id = 'mis_1',
  String messengerId = 'msg_1',
  DateTime? deadline,
  List<MissionEvent> events = const [],
  DateTime? startedAt,
}) =>
    Mission(
      id: id,
      routeId: 'r1',
      messengerId: messengerId,
      origin: 'Roma',
      destination: 'Ostia',
      packageDescription: '',
      lore: '',
      isTutorial: false,
      tutorialIndex: 0,
      startedAt: startedAt ?? _now.subtract(const Duration(hours: 1)),
      deadlineAt: deadline ?? _now.add(const Duration(hours: 5)),
      progressPct: 0,
      status: MissionStatus.active,
      packageState: PackageState.intact,
      events: events,
    );

DateTime _payloadTime(Map<String, Object?> p) =>
    DateTime.parse((p['payload'] as String).split('|').last);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeOs os;
  late LocalNotificationService service;

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    os = _FakeOs();
    messenger.setMockMethodCallHandler(_pluginChannel, os.handle);
    messenger.setMockMethodCallHandler(_tzChannel, (_) async => 'UTC');
    GameClock.debugOverride(() => _now);
    service = LocalNotificationService();
  });

  tearDown(() {
    GameClock.debugReset();
    ContentL10n.use('es', const {});
    messenger.setMockMethodCallHandler(_pluginChannel, null);
    messenger.setMockMethodCallHandler(_tzChannel, null);
  });

  group('syncMission: qué se programa', () {
    test('los dos próximos eventos, en orden, más la entrega', () async {
      final mission = _mission(events: [
        _event('e3', _now.add(const Duration(hours: 3))),
        _event('e1', _now.add(const Duration(hours: 1))),
        _event('e2', _now.add(const Duration(hours: 2))),
      ]);
      await service.syncMission(mission, messengerName: 'Varus');

      final events = os.ofKind('event:');
      expect(events, hasLength(2), reason: 'tope de 2 por misión (iOS)');
      expect(events.map(_payloadTime).toList()..sort(), [
        _now.add(const Duration(hours: 1)),
        _now.add(const Duration(hours: 2)),
      ]);
      final delivery = os.ofKind('delivery:');
      expect(delivery, hasLength(1));
      // Con eventos pendientes, a la llegada más tardía (nunca antes).
      expect(_payloadTime(delivery.single), mission.latestArrival());
      expect(mission.latestArrival().isAfter(mission.deadlineAt), isTrue);
      expect((delivery.single['payload'] as String).split('|').first,
          'delivery:mis_1:msg_1');
    });

    test('el payload lleva a la pantalla correcta del mensajero', () async {
      await service.syncMission(
          _mission(events: [_event('e1', _now.add(const Duration(hours: 1)))]),
          messengerName: 'Varus');
      final event = os.ofKind('event:').single['payload'] as String;
      final delivery = os.ofKind('delivery:').single['payload'] as String;
      expect(routeForNotification(event), '/event?m=msg_1');
      expect(routeForNotification(delivery), '/mission?m=msg_1');
    });

    test('se saltean eventos resueltos o ya llegados y la entrega pasada',
        () async {
      final mission = _mission(
        deadline: _now.subtract(const Duration(minutes: 1)),
        events: [
          _event('pasado', _now.subtract(const Duration(minutes: 5)),
              status: EventStatus.resolved),
          _event('resuelto', _now.add(const Duration(hours: 1)),
              status: EventStatus.resolved),
          _event('vencido', _now.add(const Duration(hours: 2)),
              status: EventStatus.expired),
        ],
      );
      await service.syncMission(mission, messengerName: 'Varus');
      expect(os.pending, isEmpty);
      expect(os.scheduled, isEmpty,
          reason: 'nada en el pasado llega al plugin (tiraría ArgumentError)');
    });

    test('usa la hora del juego (GameClock), no la del teléfono', () async {
      // El evento ya pasó para el juego aunque para el teléfono (2026) falte.
      final mission = _mission(events: [
        _event('ya', _now.subtract(const Duration(seconds: 1))),
        _event('luego', _now.add(const Duration(minutes: 30))),
      ]);
      await service.syncMission(mission, messengerName: 'Varus');
      expect(os.ofKind('event:').map(_payloadTime),
          [_now.add(const Duration(minutes: 30))]);

      // Y se programa en la hora del dispositivo: misma distancia desde ahora.
      final args = os.scheduled.firstWhere(
          (a) => (a['payload'] as String).startsWith('event:'));
      final fires =
          DateTime.parse(args['scheduledDateTimeISO8601'] as String);
      final expected = DateTime.now().add(const Duration(minutes: 30));
      expect(fires.difference(expected).inSeconds.abs(), lessThan(60));
    });

    test('la entrega respeta el silencio nocturno; el evento no', () async {
      final night = DateTime(2030, 3, 10, 23);
      final mission = _mission(
        deadline: night,
        events: [_event('noche', night.subtract(const Duration(minutes: 30)))],
      );
      await service.syncMission(mission, messengerName: 'Varus');
      expect(_payloadTime(os.ofKind('delivery:').single),
          DateTime(2030, 3, 11, 8));
      expect(_payloadTime(os.ofKind('event:').single),
          DateTime(2030, 3, 10, 22, 30));
    });

    test('tipos silenciados, interruptor apagado o sin permiso: nada',
        () async {
      final mission = _mission(
          events: [_event('e1', _now.add(const Duration(hours: 1)))]);

      await service.savePrefs(
          const NotificationPrefs(muted: {NotificationKind.event}));
      await service.syncMission(mission, messengerName: 'Varus');
      expect(os.ofKind('event:'), isEmpty);
      expect(os.ofKind('delivery:'), hasLength(1));

      await service.savePrefs(const NotificationPrefs(enabled: false));
      expect(os.pending, isEmpty, reason: 'apagar cancela lo programado');
      await service.syncMission(mission, messengerName: 'Varus');
      expect(os.pending, isEmpty);

      await service.savePrefs(const NotificationPrefs());
      os.enabled = false;
      await service.syncMission(mission, messengerName: 'Varus');
      expect(os.pending, isEmpty);
    });

    test('tope diario: si el día ya tiene 4 avisos, no se suma otro',
        () async {
      for (var i = 0; i < kMaxNotificationsPerDay; i++) {
        os.pending[100 + i] = {
          'id': 100 + i,
          'title': '',
          'body': '',
          'payload':
              'event:otra:x|${_now.add(Duration(minutes: 10 + i)).toIso8601String()}',
        };
      }
      await service.syncMission(_mission(), messengerName: 'Varus');
      expect(os.ofKind('delivery:'), isEmpty);

      // Al día siguiente sí hay cupo.
      await service.syncMission(
          _mission(deadline: _now.add(const Duration(days: 1))),
          messengerName: 'Varus');
      expect(os.ofKind('delivery:'), hasLength(1));
    });

    test('tope global de pendientes (límite de iOS)', () async {
      for (var i = 0; i < kMaxPendingNotifications; i++) {
        os.pending[1000 + i] = {
          'id': 1000 + i,
          'title': '',
          'body': '',
          'payload': 'event:otra:x|${_now.add(Duration(days: 10 + i)).toIso8601String()}',
        };
      }
      await service.syncMission(_mission(), messengerName: 'Varus');
      expect(os.pending, hasLength(kMaxPendingNotifications));
    });

    test(
        'con un evento bloqueando, la entrega no suena antes de poder entregar',
        () async {
      // El evento llegó hace 20 min y nadie lo resolvió: el viaje está
      // congelado (progressAt) y la llegada se correrá al menos 20 min
      // (frozenBy). Avisar "tu entrega está lista" a la hora vieja es mentir.
      final blocking = _event('bloquea', _now.subtract(const Duration(minutes: 20)));
      final mission = _mission(
          deadline: _now.add(const Duration(minutes: 30)), events: [blocking]);
      expect(mission.readyToDeliverAt(mission.deadlineAt), isFalse);

      await service.syncMission(mission, messengerName: 'Varus');
      final earliest =
          mission.deadlineAt.add(_now.difference(blocking.triggersAt));
      for (final d in os.ofKind('delivery:')) {
        expect(_payloadTime(d).isBefore(earliest), isFalse);
      }
    });
  });

  group('ids', () {
    test('únicos por aviso y estables al reprogramar (sin duplicados)',
        () async {
      final mission = _mission(events: [
        _event('e1', _now.add(const Duration(hours: 1))),
        _event('e2', _now.add(const Duration(hours: 2))),
      ]);
      await service.syncMission(mission, messengerName: 'Varus');
      final first = os.pending.keys.toSet();
      expect(first, hasLength(3));
      for (final id in first) {
        expect(id, inInclusiveRange(1, 0x7FFFFFFF));
      }

      await service.syncMission(mission, messengerName: 'Varus');
      expect(os.pending.keys.toSet(), first);
    });

    test('dos misiones no se pisan', () async {
      await service.syncMission(_mission(id: 'a', messengerId: 'x'),
          messengerName: 'A');
      await service.syncMission(_mission(id: 'b', messengerId: 'y'),
          messengerName: 'B');
      expect(os.ofKind('delivery:'), hasLength(2));
    });

    test('recordatorios con id fijo: reprogramar reemplaza', () async {
      await service.syncReminders(
          idleMessengerName: 'Varus', contractsPending: true);
      await service.syncReminders(
          idleMessengerName: 'Varus', contractsPending: true);
      expect(os.pending.keys.toSet(), {999001, 999002});

      await service.syncReminders(contractsPending: false);
      expect(os.pending.keys.toSet(), {999002},
          reason: 'sin mensajero ocioso se cancela ese recordatorio');
      expect(_payloadTime(os.pending[999002]!), DateTime(2030, 3, 11, 19));
    });
  });

  group('cancelación', () {
    test('entregar una misión cancela solo sus avisos', () async {
      await service.syncMission(
          _mission(id: 'a', events: [_event('e', _now.add(const Duration(hours: 1)))]),
          messengerName: 'A');
      await service.syncMission(_mission(id: 'b'), messengerName: 'B');
      await service.cancelMission('a');
      expect(os.pending.values.map((p) => p['payload'] as String),
          everyElement(startsWith('delivery:b:')));
    });

    test('keepOnlyMissions borra las que ya no están activas', () async {
      await service.syncMission(_mission(id: 'a'), messengerName: 'A');
      await service.syncMission(_mission(id: 'b'), messengerName: 'B');
      await service.keepOnlyMissions({'b'});
      expect(os.pending, hasLength(1));
      expect(os.ofKind('delivery:b:'), hasLength(1));
    });

    test('el registro persiste: otro arranque puede cancelar', () async {
      await service.syncMission(_mission(id: 'a'), messengerName: 'A');
      final raw = (await SharedPreferences.getInstance())
          .getString('notification_registry_v1')!;
      expect((jsonDecode(raw) as Map).keys, ['a']);

      final restarted = LocalNotificationService();
      await restarted.cancelMission('a');
      expect(os.pending, isEmpty);
    });

    test('partida nueva (cancelAll) limpia avisos y registro', () async {
      await service.syncMission(_mission(id: 'a'), messengerName: 'A');
      await service.syncReminders(
          idleMessengerName: 'A', contractsPending: true);
      await service.cancelAll();
      expect(os.pending, isEmpty);
      final raw = (await SharedPreferences.getInstance())
          .getString('notification_registry_v1')!;
      expect(jsonDecode(raw), isEmpty);
    });
  });

  group('textos', () {
    test('salen de las traducciones, no de literales', () async {
      final mission = _mission(
          events: [_event('e1', _now.add(const Duration(hours: 1)))]);
      await service.syncMission(mission, messengerName: 'Varus');
      final es = lookupAppLocalizations(const Locale('es'));
      final event = os.ofKind('event:').single;
      expect(event['title'], es.notifEventTitle);
      expect(event['body'], es.notifEventBody('Varus', 'Puente caído e1'));
      final delivery = os.ofKind('delivery:').single;
      expect(delivery['title'], es.notifDeliveryTitle);
      expect(delivery['body'], es.notifDeliveryBody('Varus', 'Ostia'));

      ContentL10n.use('en', const {});
      await service.syncMission(mission, messengerName: 'Varus');
      final en = lookupAppLocalizations(const Locale('en'));
      expect(os.ofKind('delivery:').single['title'], en.notifDeliveryTitle);
      expect(en.notifDeliveryTitle, isNot(es.notifDeliveryTitle));
    });

    test('pending() reconstruye tipo y hora desde el payload, en orden',
        () async {
      await service.syncMission(
          _mission(events: [_event('e1', _now.add(const Duration(hours: 1)))]),
          messengerName: 'Varus');
      final m =
          _mission(events: [_event('e1', _now.add(const Duration(hours: 1)))]);
      final list = await service.pending();
      expect(list.map((n) => n.kind),
          [NotificationKind.event, NotificationKind.delivery]);
      expect(list.first.at, _now.add(const Duration(hours: 1)));
      expect(list.last.at, m.latestArrival());
    });

    test('pending() reconoce los recordatorios (ocioso y contratos)',
        () async {
      await service.syncReminders(
          idleMessengerName: 'Varus', contractsPending: true);
      final kinds = (await service.pending()).map((n) => n.kind).toSet();
      expect(kinds, {NotificationKind.idle, NotificationKind.contracts});
    });
  });
}
