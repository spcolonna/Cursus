// lib/domain/entities/notifications.dart
//
// El pilar 2 del GDD: "el juego te busca a vos, no al revés".
// Acá viven las reglas de QUÉ se avisa y CUÁNDO — sin nada de Flutter.

import 'domain_strings.dart';

/// Tipos de aviso, en orden de valor para el jugador (GDD §4.1).
enum NotificationKind {
  /// Llegó un evento en el camino. El disparador n.º 1 de sesión.
  event,

  /// La misión llegó al 100% y espera el botón ENTREGAR.
  delivery,

  /// El mensajero está ocioso hace rato.
  idle,

  /// El tablón del gremio renueva a medianoche.
  contracts,
}

extension NotificationKindX on NotificationKind {
  String get label => ds('ui.notification.$name.label');

  String get description => ds('ui.notification.$name.description');

  /// Los eventos de una misión ya aceptada pueden sonar de noche: el jugador
  /// eligió salir a esa hora. El resto respeta el silencio nocturno.
  bool get ignoresQuietHours => this == NotificationKind.event;
}

/// Estado del permiso del sistema operativo.
enum NotificationPermission { granted, denied, notRequested }

/// Preferencias del jugador. Opt-out granular, como pide el GDD.
class NotificationPrefs {
  final bool enabled;
  final Set<NotificationKind> muted;

  const NotificationPrefs({this.enabled = true, this.muted = const {}});

  bool allows(NotificationKind kind) => enabled && !muted.contains(kind);

  NotificationPrefs copyWith({bool? enabled, Set<NotificationKind>? muted}) =>
      NotificationPrefs(
        enabled: enabled ?? this.enabled,
        muted: muted ?? this.muted,
      );

  NotificationPrefs toggle(NotificationKind kind) => copyWith(
        muted: muted.contains(kind)
            ? ({...muted}..remove(kind))
            : {...muted, kind},
      );
}

/// Una notificación ya programada (para el panel de diagnóstico).
class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime at;
  final NotificationKind kind;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
    required this.kind,
  });
}

/// Minutos que tiene el jugador para responder un evento antes de que se
/// resuelva solo, con la opción más segura y a resultado parcial (GDD §4.2).
const int kDecisionWindowMinutes = 60;

// ─── Reglas de horario ────────────────────────────────────────────────────────

/// Silencio nocturno: nada suena entre las 22:00 y las 08:00.
const int kQuietStartHour = 22;
const int kQuietEndHour = 8;

/// Máximo de avisos por día (GDD §4.1).
const int kMaxNotificationsPerDay = 4;

/// Tope de notificaciones pendientes. iOS descarta todo lo que pase de 64
/// por app, así que nos quedamos cómodos por debajo.
const int kMaxPendingNotifications = 56;

bool isQuietHour(DateTime t) =>
    t.hour >= kQuietStartHour || t.hour < kQuietEndHour;

/// Corre un horario fuera de la franja de silencio. Los avisos de evento
/// están exentos: el jugador aceptó una misión nocturna a sabiendas.
DateTime applyQuietHours(DateTime when, NotificationKind kind) {
  if (kind.ignoresQuietHours || !isQuietHour(when)) return when;
  // Antes de medianoche → a las 8 del día siguiente. Después → hoy a las 8.
  final target = when.hour >= kQuietStartHour
      ? DateTime(when.year, when.month, when.day + 1, kQuietEndHour)
      : DateTime(when.year, when.month, when.day, kQuietEndHour);
  return target;
}

// ─── Recordatorios (ocioso y contratos) ───────────────────────────────────────

/// Horas sin salir a la ruta antes de avisar que un mensajero está ocioso.
const int kIdleReminderHours = 4;

/// Hora del recordatorio de contratos: con margen antes de que venza el tablón.
const int kContractsReminderHour = 19;

/// Cuándo avisar que hay un mensajero ocioso, contando desde [now] (el último
/// momento en que el jugador miró). Respeta el silencio nocturno.
DateTime idleReminderAt(DateTime now) => applyQuietHours(
    now.add(const Duration(hours: kIdleReminderHours)), NotificationKind.idle);

/// Próximo recordatorio de contratos. Si hoy quedan contratos sin cobrar y
/// todavía no pasó la hora, es hoy; si no, mañana (el tablón nuevo arranca
/// sin cobrar).
DateTime contractsReminderAt(DateTime now, {required bool pendingToday}) {
  final today = DateTime(now.year, now.month, now.day, kContractsReminderHour);
  if (pendingToday && now.isBefore(today)) return today;
  return DateTime(now.year, now.month, now.day + 1, kContractsReminderHour);
}

// ─── Payload ──────────────────────────────────────────────────────────────────

/// A dónde lleva tocar un aviso. El payload tiene la forma
/// `tipo:misión:mensajero|horario`; los avisos viejos no traen el mensajero.
class NotificationTarget {
  final NotificationKind kind;
  final String? messengerId;
  const NotificationTarget(this.kind, {this.messengerId});

  static NotificationTarget? parse(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    final parts = payload.split('|').first.split(':');
    final kind = switch (parts.first) {
      'event' => NotificationKind.event,
      'delivery' => NotificationKind.delivery,
      'idle' => NotificationKind.idle,
      'contracts' => NotificationKind.contracts,
      _ => null,
    };
    if (kind == null) return null;
    final messengerId = parts.length >= 3 && parts[2].isNotEmpty ? parts[2] : null;
    return NotificationTarget(kind, messengerId: messengerId);
  }
}
