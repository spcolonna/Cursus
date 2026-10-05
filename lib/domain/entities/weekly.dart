import 'world.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Encargos semanales: tres pedidos de gente con nombre que duran de lunes a
// domingo. Uno es siempre "la primera S de la semana" (el Sello semanal del
// GDD §6.1); los otros dos pagan Denarios y reputación. El contenido (quién
// pide qué) vive en data/ y llega por el catálogo.
// ═══════════════════════════════════════════════════════════════════════════

enum WeeklyGoal {
  /// Entregas con nota S.
  gradeS,

  /// Entregas de cualquier tipo (menos el tutorial).
  deliver,

  /// Entregas con nota A o S.
  gradeAOrS,

  /// Entregas en rutas que encarga [WeeklyCommissionDef.faction].
  patronDelivery,

  /// Entregas de rutas de [kWeeklyLongMinutes] o más.
  longRoute,

  /// Eventos resueltos con éxito.
  eventSuccesses,

  /// Eventos resueltos, salga como salga.
  resolveEvents,
}

/// Una ruta "larga" para los encargos: 8 h nominales o más.
const int kWeeklyLongMinutes = 8 * 60;

/// Id del encargo fijo de cada semana: la primera S paga un Sello.
const String kWeeklySealId = 'w_first_s';

class WeeklyCommissionDef {
  final String id;
  final String npcName;
  /// Quién es, en pocas palabras: "centurión de la puerta Capena".
  final String npcRole;
  final Faction? npcFaction;
  /// Lo que dice al pedirlo, una o dos frases.
  final String intro;
  /// La meta en segunda persona: "Entregá 2 mensajes en rutas de las Legiones".
  final String goalText;
  final WeeklyGoal goal;
  final int target;
  /// Facción de las rutas que cuentan (solo para [WeeklyGoal.patronDelivery]).
  final Faction? faction;
  final int denarios;
  final int seals;
  final Map<Faction, int> rep;
  /// Entrada del diario al cobrarlo.
  final String journal;

  const WeeklyCommissionDef({
    required this.id,
    required this.npcName,
    required this.npcRole,
    this.npcFaction,
    required this.intro,
    required this.goalText,
    required this.goal,
    required this.target,
    this.faction,
    this.denarios = 0,
    this.seals = 0,
    this.rep = const {},
    required this.journal,
  });
}

class WeeklyEntry {
  final String id;
  final int progress;
  final bool claimed;
  const WeeklyEntry({required this.id, this.progress = 0, this.claimed = false});

  WeeklyEntry copyWith({int? progress, bool? claimed}) => WeeklyEntry(
        id: id,
        progress: progress ?? this.progress,
        claimed: claimed ?? this.claimed,
      );
}

class WeeklyState {
  /// Semana ISO: '2026-W41'.
  final String weekKey;
  final List<WeeklyEntry> entries;
  const WeeklyState({required this.weekKey, required this.entries});

  /// El tablón de la semana de [now], elegido de [pool] de forma determinista.
  factory WeeklyState.freshFor(DateTime now, List<WeeklyCommissionDef> pool) {
    final key = isoWeekKey(now);
    return WeeklyState(
      weekKey: key,
      entries: [for (final id in weeklyIdsFor(key, pool)) WeeklyEntry(id: id)],
    );
  }

  WeeklyState copyWith({List<WeeklyEntry>? entries}) =>
      WeeklyState(weekKey: weekKey, entries: entries ?? this.entries);

  /// Suma uno a los encargos sin cobrar cuyo objetivo cumple [matches].
  WeeklyState advance(Map<String, WeeklyCommissionDef> defs,
      bool Function(WeeklyCommissionDef) matches) {
    var changed = false;
    final next = entries.map((e) {
      final def = defs[e.id];
      if (def == null || e.claimed || e.progress >= def.target) return e;
      if (!matches(def)) return e;
      changed = true;
      return e.copyWith(progress: e.progress + 1);
    }).toList();
    return changed ? copyWith(entries: next) : this;
  }

  Map<String, dynamic> toJson() => {
        'weekKey': weekKey,
        'entries': [
          for (final e in entries)
            {'id': e.id, 'progress': e.progress, 'claimed': e.claimed}
        ],
      };

  factory WeeklyState.fromJson(Map<String, dynamic> j) => WeeklyState(
        weekKey: j['weekKey'] as String? ?? '',
        entries: [
          for (final e in (j['entries'] as List? ?? const []))
            WeeklyEntry(
              id: (e as Map)['id'] as String,
              progress: (e['progress'] as num?)?.toInt() ?? 0,
              claimed: e['claimed'] as bool? ?? false,
            )
        ],
      );
}

/// Clave de semana ISO 8601 (las semanas empiezan el lunes).
String isoWeekKey(DateTime d) {
  final date = DateTime.utc(d.year, d.month, d.day);
  // El jueves de esta semana decide a qué año pertenece.
  final thursday = date.add(Duration(days: 4 - date.weekday));
  final firstDay = DateTime.utc(thursday.year, 1, 1);
  final week = thursday.difference(firstDay).inDays ~/ 7 + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

/// Los tres encargos de la semana [weekKey]: el del Sello y dos del resto,
/// distintos y siempre los mismos para la misma semana.
List<String> weeklyIdsFor(String weekKey, List<WeeklyCommissionDef> pool) {
  final rest = pool.where((d) => d.id != kWeeklySealId).toList();
  final hasSeal = pool.any((d) => d.id == kWeeklySealId);
  var seed = 0;
  for (final c in weekKey.codeUnits) {
    seed = (seed * 31 + c) & 0x7fffffff;
  }
  final picks = <String>[];
  if (rest.isNotEmpty) {
    final a = seed % rest.length;
    picks.add(rest[a].id);
    if (rest.length > 1) {
      final b = (a + 1 + (seed ~/ 7) % (rest.length - 1)) % rest.length;
      picks.add(rest[b].id);
    }
  }
  return [if (hasSeal) kWeeklySealId, ...picks];
}
