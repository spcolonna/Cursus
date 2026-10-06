// ─────────────────────────────────────────────────────────────────────────────
// Analytics: el diccionario de eventos y el registro de días activos.
//
// Todo es puro. Los nombres y parámetros viven acá (y en ningún otro lado)
// para que el tablero no se llene de variantes del mismo evento. Quién los
// manda (Firebase, la consola, el buffer local) es problema de la capa de
// infraestructura. Ver docs/ANALYTICS.md.
// ─────────────────────────────────────────────────────────────────────────────

/// Una sesión nueva empieza tras 30 min sin uso (mismo criterio que Firebase).
const kSessionTimeout = Duration(minutes: 30);

/// Días de historial de sesiones que se guardan en el dispositivo.
const kRetentionHistoryDays = 120;

/// Nombres que Firebase reserva: un evento propio con estos nombres se
/// descarta en silencio.
const kReservedEventNames = {
  'ad_activeview',
  'ad_click',
  'ad_exposure',
  'ad_impression',
  'ad_query',
  'ad_reward',
  'adunit_exposure',
  'app_background',
  'app_clear_data',
  'app_exception',
  'app_remove',
  'app_store_refund',
  'app_store_subscription_cancel',
  'app_store_subscription_convert',
  'app_store_subscription_renew',
  'app_uninstall',
  'app_update',
  'app_upgrade',
  'dynamic_link_app_open',
  'dynamic_link_app_update',
  'dynamic_link_first_open',
  'error',
  'first_open',
  'first_visit',
  'in_app_purchase',
  'notification_dismiss',
  'notification_foreground',
  'notification_open',
  'notification_receive',
  'os_update',
  'screen_view',
  'session_start',
  'session_start_with_rollout',
  'user_engagement',
};

class AnalyticsEvent {
  final String name;

  /// Solo String, int o double.
  final Map<String, Object> params;
  const AnalyticsEvent(this.name, [this.params = const {}]);

  // ─── Sesión ────────────────────────────────────────────────────────────────
  /// [day] es el día desde la instalación (0 = el día que instaló).
  factory AnalyticsEvent.gameSession({
    required int day,
    required int sessionOfDay,
    required int daysActive,
  }) =>
      AnalyticsEvent('game_session', {
        'day': day,
        'session_of_day': sessionOfDay,
        'days_active': daysActive,
      });

  // ─── Embudo de entrada ─────────────────────────────────────────────────────
  factory AnalyticsEvent.tutorialStep(int index) =>
      AnalyticsEvent('tutorial_step', {'step': index});

  factory AnalyticsEvent.tutorialComplete() =>
      const AnalyticsEvent('tutorial_complete');

  // ─── Loop ──────────────────────────────────────────────────────────────────
  /// [kind]: real | story | tutorial.
  factory AnalyticsEvent.missionAccept({
    required String routeId,
    required String kind,
    required int rank,
    required int minutes,
    required int busy,
  }) =>
      AnalyticsEvent('mission_accept', {
        'route_id': routeId,
        'kind': kind,
        'rank': rank,
        'minutes': minutes,
        'busy_messengers': busy,
      });

  /// [event] es el id del contenido (`evt_storm`); si un guardado viejo no
  /// lo trae, el título.
  factory AnalyticsEvent.eventResolved({
    required String event,
    required String category,
    required String outcome,
    required int risk,
    required int score,
  }) =>
      AnalyticsEvent('event_resolved', {
        'event': event,
        'category': category,
        'outcome': outcome,
        'risk': risk,
        'score': score,
      });

  /// Eventos que se resolvieron solos porque el jugador no volvió a tiempo:
  /// la mejor señal de que los avisos no alcanzan.
  factory AnalyticsEvent.eventsAutoResolved(int count) =>
      AnalyticsEvent('events_auto_resolved', {'count': count});

  factory AnalyticsEvent.missionComplete({
    required String routeId,
    required String kind,
    required String grade,
    required int denarios,
  }) =>
      AnalyticsEvent('mission_complete', {
        'route_id': routeId,
        'kind': kind,
        'grade': grade,
        'denarios': denarios,
      });

  factory AnalyticsEvent.skipToEvent(int cost) =>
      AnalyticsEvent('skip_to_event', {'cost': cost});

  factory AnalyticsEvent.rewardedAd(String placement) =>
      AnalyticsEvent('rewarded_ad', {'placement': placement});

  // ─── Historia ──────────────────────────────────────────────────────────────
  /// [chapter] es 1-based, como lo ve el jugador.
  factory AnalyticsEvent.storyChapter({
    required String arcId,
    required int chapter,
    required String variant,
  }) =>
      AnalyticsEvent('story_chapter', {
        'arc_id': arcId,
        'chapter': chapter,
        'variant': variant,
      });

  factory AnalyticsEvent.arcComplete({
    required String arcId,
    required String ending,
  }) =>
      AnalyticsEvent('arc_complete', {'arc_id': arcId, 'ending': ending});

  // ─── Progresión ────────────────────────────────────────────────────────────
  /// [via]: xp | pick | ascend.
  factory AnalyticsEvent.skillLevel({
    required String skill,
    required int level,
    required String via,
  }) =>
      AnalyticsEvent(
          'skill_level', {'skill': skill, 'level': level, 'via': via});

  factory AnalyticsEvent.rankUp(int rank) =>
      AnalyticsEvent('rank_up', {'rank': rank});

  factory AnalyticsEvent.achievement(String id) =>
      AnalyticsEvent('achievement_unlock', {'achievement_id': id});

  factory AnalyticsEvent.factionTier({
    required String faction,
    required String tier,
  }) =>
      AnalyticsEvent('faction_tier', {'faction': faction, 'tier': tier});

  factory AnalyticsEvent.slotUnlock(int slots) =>
      AnalyticsEvent('slot_unlock', {'slots': slots});

  // ─── Gremio y semanales ────────────────────────────────────────────────────
  factory AnalyticsEvent.dailyPay(int streakDay) =>
      AnalyticsEvent('daily_pay_claim', {'streak_day': streakDay});

  factory AnalyticsEvent.contractClaim(String templateId) =>
      AnalyticsEvent('contract_claim', {'contract_id': templateId});

  factory AnalyticsEvent.contractReroll() =>
      const AnalyticsEvent('contract_reroll');

  factory AnalyticsEvent.weeklyClaim(String id) =>
      AnalyticsEvent('weekly_claim', {'commission_id': id});

  // ─── Tienda ────────────────────────────────────────────────────────────────
  /// [currency]: denarios | aureos.
  factory AnalyticsEvent.shopItem({
    required String itemId,
    required String currency,
    required int price,
  }) =>
      AnalyticsEvent('shop_item',
          {'item_id': itemId, 'currency': currency, 'price': price});

  factory AnalyticsEvent.iapCredited(String productId) =>
      AnalyticsEvent('iap_credited', {'product_id': productId});

  // ─── Validación ────────────────────────────────────────────────────────────
  static final _namePattern = RegExp(r'^[a-z][a-z0-9_]{0,39}$');

  /// Cumple los límites de Firebase: nombre y claves ≤40 en snake_case,
  /// ≤25 parámetros, textos ≤100, nada reservado.
  bool get isValid {
    if (!_namePattern.hasMatch(name)) return false;
    if (kReservedEventNames.contains(name)) return false;
    if (name.startsWith('firebase_') ||
        name.startsWith('google_') ||
        name.startsWith('ga_')) {
      return false;
    }
    if (params.length > 25) return false;
    for (final e in params.entries) {
      if (!_namePattern.hasMatch(e.key)) return false;
      final v = e.value;
      if (v is String) {
        if (v.length > 100) return false;
      } else if (v is! int && v is! double) {
        return false;
      }
    }
    return true;
  }

  Map<String, Object> toJson() => {'name': name, ...params};

  @override
  String toString() => '$name $params';
}

// ─── Registro de días activos ─────────────────────────────────────────────────
/// Lo que el dispositivo sabe de su propia retención: el día que instaló,
/// qué días abrió el juego y cuántas sesiones hizo cada día. Alcanza para
/// el panel de Ajustes y para que un tester exporte sus datos; la retención
/// del público se mide en Firebase con estos mismos criterios.
class RetentionLog {
  /// Día de instalación, medianoche local.
  final DateTime installDay;

  /// Sesiones por día desde la instalación (0 = el día que instaló).
  final Map<int, int> sessionsByDay;
  final DateTime? lastSeen;

  const RetentionLog({
    required this.installDay,
    this.sessionsByDay = const {},
    this.lastSeen,
  });

  factory RetentionLog.start(DateTime now) =>
      RetentionLog(installDay: _midnight(now));

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Días de calendario desde la instalación. Redondea para no tropezar con
  /// los días de 23 o 25 h del cambio de horario.
  int dayIndex(DateTime now) =>
      (_midnight(now).difference(installDay).inHours / 24).round();

  /// Abrir (o volver a) el juego. Es sesión nueva si pasaron
  /// [kSessionTimeout] desde la última vez que se lo vio.
  ({RetentionLog log, bool newSession, bool newDay}) open(DateTime now) {
    final day = dayIndex(now);
    final newDay = !sessionsByDay.containsKey(day);
    // Cruzar la medianoche corta la sesión: si no, ese día no contaría.
    final isNew = lastSeen == null ||
        newDay ||
        now.difference(lastSeen!) >= kSessionTimeout;
    if (!isNew) return (log: touch(now), newSession: false, newDay: false);
    final counts = Map<int, int>.from(sessionsByDay)
      ..update(day, (n) => n + 1, ifAbsent: () => 1)
      ..removeWhere((d, _) => d < day - kRetentionHistoryDays && d != 0);
    return (
      log: RetentionLog(
          installDay: installDay, sessionsByDay: counts, lastSeen: now),
      newSession: true,
      newDay: newDay,
    );
  }

  /// El jugador sigue ahí (o se va a segundo plano): corre la ventana.
  RetentionLog touch(DateTime now) => RetentionLog(
      installDay: installDay, sessionsByDay: sessionsByDay, lastSeen: now);

  int get daysActive => sessionsByDay.length;
  int get totalSessions => sessionsByDay.values.fold(0, (a, b) => a + b);
  int sessionsOn(int day) => sessionsByDay[day] ?? 0;

  /// Retención clásica: abrió el juego exactamente el día [n].
  bool activeOn(int n) => sessionsByDay.containsKey(n);

  /// Retención "rolling": volvió el día [n] o cualquier día posterior.
  bool activeOnOrAfter(int n) => sessionsByDay.keys.any((d) => d >= n);

  /// Días distintos con sesión en los últimos [window] días (incluye hoy).
  int activeDaysInLast(DateTime now, int window) {
    final today = dayIndex(now);
    return sessionsByDay.keys
        .where((d) => d > today - window && d <= today)
        .length;
  }

  Map<String, dynamic> toJson() => {
        'installDay': installDay.toIso8601String(),
        'sessions': {
          for (final e in sessionsByDay.entries) '${e.key}': e.value,
        },
        if (lastSeen != null) 'lastSeen': lastSeen!.toIso8601String(),
      };

  factory RetentionLog.fromJson(Map<String, dynamic> j) => RetentionLog(
        installDay: DateTime.parse(j['installDay'] as String),
        sessionsByDay: {
          for (final e in (j['sessions'] as Map<String, dynamic>).entries)
            int.parse(e.key): e.value as int,
        },
        lastSeen: j['lastSeen'] == null
            ? null
            : DateTime.parse(j['lastSeen'] as String),
      );
}

// ─── Métricas de cohorte ──────────────────────────────────────────────────────
// La definición exacta de cada número del tablero, escrita como código para
// que no haya dos versiones. Solo cuentan los jugadores que ya pudieron
// llegar al día [n] (si instaló hace 3 días, no entra en el D7).

List<RetentionLog> _eligible(List<RetentionLog> c, int n, DateTime now) =>
    c.where((l) => l.dayIndex(now) >= n).toList();

/// D_n clásico: % de la cohorte que abrió el juego el día n.
double classicRetention(List<RetentionLog> cohort, int n, DateTime now) {
  final eligible = _eligible(cohort, n, now);
  if (eligible.isEmpty) return 0;
  return eligible.where((l) => l.activeOn(n)).length / eligible.length;
}

/// D_n rolling: % que volvió el día n o después.
double rollingRetention(List<RetentionLog> cohort, int n, DateTime now) {
  final eligible = _eligible(cohort, n, now);
  if (eligible.isEmpty) return 0;
  return eligible.where((l) => l.activeOnOrAfter(n)).length / eligible.length;
}

/// Stickiness: DAU promedio de los últimos 30 días sobre MAU.
double stickiness(List<RetentionLog> players, DateTime now) {
  final mau = players.where((l) => l.activeDaysInLast(now, 30) > 0).length;
  if (mau == 0) return 0;
  final activeDays =
      players.fold<int>(0, (a, l) => a + l.activeDaysInLast(now, 30));
  return activeDays / 30 / mau;
}
