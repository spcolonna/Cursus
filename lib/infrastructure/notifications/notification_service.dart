// lib/infrastructure/notifications/notification_service.dart
//
// Implementación de NotificationScheduler con flutter_local_notifications.
// Sin backend: todo son avisos locales programados en el dispositivo.
//
// Restricción dura de iOS: una app puede tener como máximo 64 notificaciones
// locales pendientes; las que pasan de ahí se descartan en silencio. Por eso
// programamos solo los DOS próximos eventos de cada misión más la entrega, y
// reprogramamos cada vez que el reloj de la misión se mueve.

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/entities.dart';
import '../../domain/entities/notifications.dart';
import '../../domain/repositories/repositories.dart';

const _prefsKey = 'notification_prefs_v1';
const _registryKey = 'notification_registry_v1';

/// Cuántos eventos futuros de una misma misión se programan por adelantado.
const _eventsAheadPerMission = 2;

// v2: el canal suena con el motivo de Cursus. Android fija el sonido al
// crear el canal, así que cambiarlo exige un id nuevo (y borrar el viejo).
const _channelId = 'cursus_road_v2';
const _legacyChannelIds = ['the_messenger_road'];

/// El motivo como sonido de aviso (sale de tool/gen_sfx.py): en Android es
/// res/raw/cursus_motif.wav; en iOS, cursus_motif.caf en el bundle.
const notificationSoundAndroid = 'cursus_motif';
const notificationSoundIos = 'cursus_motif.caf';
const _channelName = 'El camino';
const _channelDescription = 'Avisos de eventos en la ruta y entregas listas.';

class LocalNotificationService implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  void Function(String payload)? _onTap;

  @override
  set onTap(void Function(String payload)? handler) => _onTap = handler;

  /// missionId -> ids de notificación programados para esa misión.
  /// Se persiste porque hay que poder cancelarlos en un arranque posterior.
  Map<String, List<int>> _registry = {};

  @override
  Future<void> init() async {
    if (_ready) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Si el dispositivo no responde, UTC es mejor que no programar nada.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // El permiso se pide después, con contexto narrativo (GDD §7).
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _onTap?.call(payload);
      },
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      for (final id in _legacyChannelIds) {
        await android.deleteNotificationChannel(channelId: id);
      }
      await android.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(notificationSoundAndroid),
      ));
    }

    await _loadRegistry();
    _ready = true;
  }

  // ─── Permiso ───────────────────────────────────────────────────────────────

  @override
  Future<NotificationPermission> permissionStatus() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final enabled = await android.areNotificationsEnabled();
      return enabled == true
          ? NotificationPermission.granted
          : NotificationPermission.denied;
    }
    // iOS no expone el estado sin pedirlo: lo recordamos nosotros.
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('${_prefsKey}_asked') ?? false;
    if (!asked) return NotificationPermission.notRequested;
    return (prefs.getBool('${_prefsKey}_granted') ?? false)
        ? NotificationPermission.granted
        : NotificationPermission.denied;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    var granted = false;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      granted =
          await ios.requestPermissions(alert: true, badge: true, sound: true) ??
              false;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
      // Sin alarmas exactas los avisos se corren varios minutos.
      await android.requestExactAlarmsPermission();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefsKey}_asked', true);
    await prefs.setBool('${_prefsKey}_granted', granted);
    return granted;
  }

  // ─── Preferencias ──────────────────────────────────────────────────────────

  @override
  Future<NotificationPrefs> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return const NotificationPrefs();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationPrefs(
        enabled: json['enabled'] as bool? ?? true,
        muted: ((json['muted'] as List?) ?? [])
            .map((i) => NotificationKind.values[i as int])
            .toSet(),
      );
    } catch (_) {
      return const NotificationPrefs();
    }
  }

  @override
  Future<void> savePrefs(NotificationPrefs value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'enabled': value.enabled,
        'muted': value.muted.map((k) => k.index).toList(),
      }),
    );
    // Apagar el interruptor tiene que apagar lo ya programado.
    if (!value.enabled) await cancelAll();
  }

  // ─── Programación ──────────────────────────────────────────────────────────

  @override
  Future<void> syncMission(Mission mission,
      {required String messengerName}) async {
    await init();
    await cancelMission(mission.id);

    final prefs = await getPrefs();
    if (!prefs.enabled) return;
    if (await permissionStatus() != NotificationPermission.granted) return;

    final now = DateTime.now();
    final ids = <int>[];

    // Los próximos eventos, en orden y acotados: iOS no aguanta más.
    if (prefs.allows(NotificationKind.event)) {
      final upcoming = mission.upcomingEventsAt(now);

      for (final event in upcoming.take(_eventsAheadPerMission)) {
        final id = await _schedule(
          kind: NotificationKind.event,
          when: event.triggersAt,
          title: 'Algo pasó en el camino',
          body: '$messengerName necesita una decisión: ${event.title}.',
          payload: 'event:${mission.id}:${mission.messengerId}',
        );
        if (id != null) ids.add(id);
      }
    }

    // La entrega: cuando el viaje termina y falta apretar el botón.
    if (prefs.allows(NotificationKind.delivery) &&
        mission.deadlineAt.isAfter(now)) {
      final id = await _schedule(
        kind: NotificationKind.delivery,
        when: mission.deadlineAt,
        title: 'Tu entrega está lista',
        body:
            '$messengerName llegó a ${mission.destination}. Entregá el mensaje.',
        payload: 'delivery:${mission.id}:${mission.messengerId}',
      );
      if (id != null) ids.add(id);
    }

    if (ids.isNotEmpty) {
      _registry[mission.id] = ids;
      await _saveRegistry();
    }
  }

  @override
  Future<void> cancelMission(String missionId) async {
    await init();
    final ids = _registry.remove(missionId);
    if (ids == null) return;
    for (final id in ids) {
      await _plugin.cancel(id: id);
    }
    await _saveRegistry();
  }

  @override
  Future<void> syncReminders(
      {String? idleMessengerName, required bool contractsPending}) async {
    await init();
    await _plugin.cancel(id: _idleId);
    await _plugin.cancel(id: _contractsId);

    final prefs = await getPrefs();
    if (!prefs.enabled) return;
    if (await permissionStatus() != NotificationPermission.granted) return;

    final now = DateTime.now();
    if (idleMessengerName != null && prefs.allows(NotificationKind.idle)) {
      await _schedule(
        kind: NotificationKind.idle,
        when: idleReminderAt(now),
        title: 'El camino espera',
        body: '$idleMessengerName está sin misión. Hay rutas en el tablón.',
        payload: 'idle',
        fixedId: _idleId,
      );
    }
    if (prefs.allows(NotificationKind.contracts)) {
      await _schedule(
        kind: NotificationKind.contracts,
        when: contractsReminderAt(now, pendingToday: contractsPending),
        title: 'Contratos del gremio',
        body: 'Quedan contratos sin cobrar. Vencen a medianoche.',
        payload: 'contracts',
        fixedId: _contractsId,
      );
    }
  }

  @override
  Future<String?> launchPayload() async {
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details!.notificationResponse?.payload;
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
    _registry = {};
    await _saveRegistry();
  }

  @override
  Future<List<ScheduledNotification>> pending() async {
    await init();
    final requests = await _plugin.pendingNotificationRequests();
    return requests
        .map((r) => ScheduledNotification(
              id: r.id,
              title: r.title ?? '',
              body: r.body ?? '',
              // El plugin no devuelve el horario: lo guardamos en el payload.
              at: _timeFromPayload(r.payload) ?? DateTime.now(),
              kind: _kindFromPayload(r.payload),
            ))
        .toList()
      ..sort((a, b) => a.at.compareTo(b.at));
  }

  @override
  Future<void> fireTestNotification(
      {Duration delay = const Duration(seconds: 10)}) async {
    await init();
    await _plugin.zonedSchedule(
      id: _testId,
      title: 'Prueba del correo',
      body: 'Si estás leyendo esto, los avisos llegan bien.',
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: _details(NotificationKind.event),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'test|${DateTime.now().add(delay).toIso8601String()}',
    );
  }

  // ─── Interno ───────────────────────────────────────────────────────────────

  static const _testId = 999000;
  // Ids fijos: hay como mucho un recordatorio de cada tipo pendiente.
  static const _idleId = 999001;
  static const _contractsId = 999002;

  /// Programa un aviso y devuelve su id, o null si no correspondía.
  Future<int?> _schedule({
    required NotificationKind kind,
    required DateTime when,
    required String title,
    required String body,
    required String payload,
    int? fixedId,
  }) async {
    final at = applyQuietHours(when, kind);
    if (!at.isAfter(DateTime.now())) return null;

    // Tope global: por debajo del límite de iOS y del cupo diario del GDD.
    final already = await _plugin.pendingNotificationRequests();
    if (already.length >= kMaxPendingNotifications) return null;
    if (await _countForDay(at) >= kMaxNotificationsPerDay) return null;

    final id = fixedId ?? _idFor(payload, at);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: _details(kind),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '$payload|${at.toIso8601String()}',
    );
    return id;
  }

  NotificationDetails _details(NotificationKind kind) => NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          sound: RawResourceAndroidNotificationSound(notificationSoundAndroid),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: notificationSoundIos,
          threadIdentifier: kind.name,
        ),
      );

  /// Cuántos avisos ya hay programados para el mismo día que [day].
  Future<int> _countForDay(DateTime day) async {
    final requests = await _plugin.pendingNotificationRequests();
    var count = 0;
    for (final r in requests) {
      final at = _timeFromPayload(r.payload);
      if (at == null) continue;
      if (at.year == day.year && at.month == day.month && at.day == day.day) {
        count++;
      }
    }
    return count;
  }

  /// Id estable de 31 bits a partir del payload y el horario.
  int _idFor(String payload, DateTime at) =>
      Object.hash(payload, at.millisecondsSinceEpoch).abs() % 0x7FFFFFFF;

  static DateTime? _timeFromPayload(String? payload) {
    if (payload == null || !payload.contains('|')) return null;
    return DateTime.tryParse(payload.split('|').last);
  }

  static NotificationKind _kindFromPayload(String? payload) {
    final head = payload?.split(':').first ?? '';
    return switch (head) {
      'delivery' => NotificationKind.delivery,
      'idle' => NotificationKind.idle,
      'contracts' => NotificationKind.contracts,
      _ => NotificationKind.event,
    };
  }

  Future<void> _loadRegistry() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_registryKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _registry = {
        for (final e in json.entries)
          e.key: (e.value as List).map((i) => i as int).toList()
      };
    } catch (_) {
      _registry = {};
    }
  }

  Future<void> _saveRegistry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registryKey, jsonEncode(_registry));
  }
}
