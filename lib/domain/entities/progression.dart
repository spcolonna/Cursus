import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════════════
// Progresión del jugador: paga por ruta, estadísticas de por vida, logros y
// títulos. Todo puro: el contenido (qué logros existen) llega por el catálogo.
// ═══════════════════════════════════════════════════════════════════════════

// ─── Paga por ruta ──────────────────────────────────────────────────────────

/// Paga base por nota, antes del factor de la ruta (GDD §6.2).
int gradeBaseReward(String grade) => switch (grade) {
      'S' => 135,
      'A' => 90,
      'B' => 55,
      'C' => 28,
      _ => 10,
    };

/// Factor de paga de una ruta según su duración NOMINAL y su peligro (0-1).
/// Crece con el logaritmo de las horas: una ruta de 3 días paga más que una
/// de 2 h, pero bastante menos por hora, así que nadie gana más esperando.
/// Ruta de 2 h tranquila ≈ 0,9 · 8 h ≈ 1,2 · 3 días = tope 1,6.
double routePayFactor(int nominalMinutes, double danger) {
  final hours = math.max(0, nominalMinutes) / 60;
  final raw = 0.6 +
      0.15 * (math.log(hours + 1) / math.ln2) +
      0.3 * danger.clamp(0.0, 1.0);
  return raw.clamp(kMinPayFactor, kMaxPayFactor).toDouble();
}

const double kMinPayFactor = 0.7;
const double kMaxPayFactor = 1.6;

/// Los capítulos de historia son cortos pero pesan: pagan como ruta larga.
const double kStoryPayFactor = 1.3;

// ─── Estadísticas de por vida ────────────────────────────────────────────────

/// Lo que mide un logro. Cada métrica se lee de [PlayerStats.valueOf].
enum StatMetric {
  missions,
  gradeS,
  eventsResolved,
  contractsClaimed,
  bestPayStreak,
  rank,
  maxSkillLevel,
  eliteLevels,
  arcEndings,
  distinctRoutes,
  longMissions,
  messengers,
  denariosEarned,
}

class PlayerStats {
  final int missions;
  final int gradeS;
  final int eventsResolved;
  final int contractsClaimed;
  final int bestPayStreak;
  /// Días seguidos cobrando la paga (la racha del gremio es cíclica de 7;
  /// esta no se reinicia mientras no se corte).
  final int payStreak;
  /// Último día cobrado, como 'aaaa-mm-dd'.
  final String? lastPayDay;
  final int rank;
  final int maxSkillLevel;
  /// Niveles 6-10 comprados con Sellos, sumando todos los caminos.
  final int eliteLevels;
  final int arcEndings;
  final Set<String> routes;
  /// Entregas de rutas de 24 h o más.
  final int longMissions;
  final int messengers;
  final int denariosEarned;

  const PlayerStats({
    this.missions = 0,
    this.gradeS = 0,
    this.eventsResolved = 0,
    this.contractsClaimed = 0,
    this.bestPayStreak = 0,
    this.payStreak = 0,
    this.lastPayDay,
    this.rank = 1,
    this.maxSkillLevel = 1,
    this.eliteLevels = 0,
    this.arcEndings = 0,
    this.routes = const {},
    this.longMissions = 0,
    this.messengers = 1,
    this.denariosEarned = 0,
  });

  /// Cobró la paga del gremio en [day]: la racha sigue si el último cobro
  /// fue ayer, vuelve a 1 si se cortó y no cambia si ya cobró hoy.
  PlayerStats recordDailyPay(DateTime day) {
    final today = _dayKey(day);
    if (lastPayDay == today) return this;
    final yesterday = _dayKey(DateTime(day.year, day.month, day.day - 1));
    final streak = lastPayDay == yesterday ? payStreak + 1 : 1;
    return copyWith(
      payStreak: streak,
      lastPayDay: today,
      bestPayStreak: math.max(bestPayStreak, streak),
    );
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int valueOf(StatMetric m) => switch (m) {
        StatMetric.missions => missions,
        StatMetric.gradeS => gradeS,
        StatMetric.eventsResolved => eventsResolved,
        StatMetric.contractsClaimed => contractsClaimed,
        StatMetric.bestPayStreak => bestPayStreak,
        StatMetric.rank => rank,
        StatMetric.maxSkillLevel => maxSkillLevel,
        StatMetric.eliteLevels => eliteLevels,
        StatMetric.arcEndings => arcEndings,
        StatMetric.distinctRoutes => routes.length,
        StatMetric.longMissions => longMissions,
        StatMetric.messengers => messengers,
        StatMetric.denariosEarned => denariosEarned,
      };

  PlayerStats copyWith({
    int? missions,
    int? gradeS,
    int? eventsResolved,
    int? contractsClaimed,
    int? bestPayStreak,
    int? payStreak,
    String? lastPayDay,
    int? rank,
    int? maxSkillLevel,
    int? eliteLevels,
    int? arcEndings,
    Set<String>? routes,
    int? longMissions,
    int? messengers,
    int? denariosEarned,
  }) =>
      PlayerStats(
        missions: missions ?? this.missions,
        gradeS: gradeS ?? this.gradeS,
        eventsResolved: eventsResolved ?? this.eventsResolved,
        contractsClaimed: contractsClaimed ?? this.contractsClaimed,
        bestPayStreak: bestPayStreak ?? this.bestPayStreak,
        payStreak: payStreak ?? this.payStreak,
        lastPayDay: lastPayDay ?? this.lastPayDay,
        rank: rank ?? this.rank,
        maxSkillLevel: maxSkillLevel ?? this.maxSkillLevel,
        eliteLevels: eliteLevels ?? this.eliteLevels,
        arcEndings: arcEndings ?? this.arcEndings,
        routes: routes ?? this.routes,
        longMissions: longMissions ?? this.longMissions,
        messengers: messengers ?? this.messengers,
        denariosEarned: denariosEarned ?? this.denariosEarned,
      );

  Map<String, dynamic> toJson() => {
        'missions': missions,
        'gradeS': gradeS,
        'eventsResolved': eventsResolved,
        'contractsClaimed': contractsClaimed,
        'bestPayStreak': bestPayStreak,
        'payStreak': payStreak,
        'lastPayDay': lastPayDay,
        'rank': rank,
        'maxSkillLevel': maxSkillLevel,
        'eliteLevels': eliteLevels,
        'arcEndings': arcEndings,
        'routes': routes.toList(),
        'longMissions': longMissions,
        'messengers': messengers,
        'denariosEarned': denariosEarned,
      };

  factory PlayerStats.fromJson(Map<String, dynamic> j) {
    int i(String k, [int d = 0]) => (j[k] as num?)?.toInt() ?? d;
    return PlayerStats(
      missions: i('missions'),
      gradeS: i('gradeS'),
      eventsResolved: i('eventsResolved'),
      contractsClaimed: i('contractsClaimed'),
      bestPayStreak: i('bestPayStreak'),
      payStreak: i('payStreak'),
      lastPayDay: j['lastPayDay'] as String?,
      rank: i('rank', 1),
      maxSkillLevel: i('maxSkillLevel', 1),
      eliteLevels: i('eliteLevels'),
      arcEndings: i('arcEndings'),
      routes: {...?(j['routes'] as List?)?.cast<String>()},
      longMissions: i('longMissions'),
      messengers: i('messengers', 1),
      denariosEarned: i('denariosEarned'),
    );
  }
}

// ─── Logros ─────────────────────────────────────────────────────────────────

/// Familia visual del logro: la UI elige ícono y color a partir de esto.
enum AchievementKind { road, grade, guild, skill, story, empire }

class AchievementReward {
  final int denarios;
  /// Como mucho 1 por logro; el total de por vida lo acota un test (≤ 8).
  final int seals;
  final String? title;
  const AchievementReward({this.denarios = 0, this.seals = 0, this.title});
}

class AchievementDef {
  final String id;
  final String name;
  /// Qué hay que hacer, en segunda persona: "Entregá 10 mensajes".
  final String goal;
  final AchievementKind kind;
  final StatMetric metric;
  final int target;
  final AchievementReward reward;
  /// Oculto hasta conseguirlo (logros de historia: no spoilear).
  final bool secret;

  const AchievementDef({
    required this.id,
    required this.name,
    required this.goal,
    required this.kind,
    required this.metric,
    required this.target,
    this.reward = const AchievementReward(),
    this.secret = false,
  });

  int progressOf(PlayerStats s) => math.min(s.valueOf(metric), target);
  bool isMet(PlayerStats s) => s.valueOf(metric) >= target;
}

// ─── Estado persistido ───────────────────────────────────────────────────────

class ProgressionState {
  final PlayerStats stats;
  final Set<String> unlocked;
  /// Títulos en el orden en que se ganaron.
  final List<String> titles;
  final String? equippedTitle;

  const ProgressionState({
    this.stats = const PlayerStats(),
    this.unlocked = const {},
    this.titles = const [],
    this.equippedTitle,
  });

  ProgressionState copyWith({
    PlayerStats? stats,
    Set<String>? unlocked,
    List<String>? titles,
    String? equippedTitle,
    bool clearEquipped = false,
  }) =>
      ProgressionState(
        stats: stats ?? this.stats,
        unlocked: unlocked ?? this.unlocked,
        titles: titles ?? this.titles,
        equippedTitle:
            clearEquipped ? null : (equippedTitle ?? this.equippedTitle),
      );

  /// Suma títulos nuevos sin duplicar.
  ProgressionState addTitles(Iterable<String> more) {
    final next = [...titles];
    for (final t in more) {
      if (t.isNotEmpty && !next.contains(t)) next.add(t);
    }
    return copyWith(titles: next);
  }

  Map<String, dynamic> toJson() => {
        'stats': stats.toJson(),
        'unlocked': unlocked.toList(),
        'titles': titles,
        'equippedTitle': equippedTitle,
      };

  factory ProgressionState.fromJson(Map<String, dynamic> j) => ProgressionState(
        stats: PlayerStats.fromJson(
            (j['stats'] as Map?)?.cast<String, dynamic>() ?? const {}),
        unlocked: {...?(j['unlocked'] as List?)?.cast<String>()},
        titles: [...?(j['titles'] as List?)?.cast<String>()],
        equippedTitle: j['equippedTitle'] as String?,
      );
}

/// Logros cumplidos que todavía no estaban desbloqueados, en orden de [defs].
List<AchievementDef> newlyUnlocked(
        List<AchievementDef> defs, ProgressionState state) =>
    defs
        .where((d) => !state.unlocked.contains(d.id) && d.isMet(state.stats))
        .toList();
