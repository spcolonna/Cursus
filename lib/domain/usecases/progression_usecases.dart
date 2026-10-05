import 'dart:math' as math;

import '../entities/entities.dart';
import '../entities/progression.dart';
import '../entities/world.dart';
import '../repositories/content_catalog.dart';
import '../repositories/repositories.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Progresión: registrar lo que hizo el jugador, desbloquear logros, pagar sus
// premios y avisar a la UI qué celebrar. Ver domain/entities/progression.dart.
// ═══════════════════════════════════════════════════════════════════════════

/// Lo que cambió con un registro. La UI lo convierte en celebraciones.
class ProgressionUpdate {
  final List<AchievementDef> unlocked;
  final int denarios;
  final int seals;
  final List<String> newTitles;
  /// Nuevo rango alcanzado (2-5), si subió con este registro.
  final int? rankReached;
  final ProgressionState state;

  const ProgressionUpdate({
    required this.state,
    this.unlocked = const [],
    this.denarios = 0,
    this.seals = 0,
    this.newTitles = const [],
    this.rankReached,
  });

  bool get isEmpty => unlocked.isEmpty && rankReached == null;
}

/// Una ruta de 24 h o más cuenta como "larga" para los logros.
const int kLongMissionMinutes = 24 * 60;

/// Estadísticas después de entregar [mission] con [grade] y [denarios].
PlayerStats statsAfterDelivery(
    PlayerStats s, Mission mission, String grade, int denarios) {
  final real = !mission.isTutorial && mission.arcId == null;
  final minutes = mission.deadlineAt.difference(mission.startedAt).inMinutes;
  return s.copyWith(
    missions: s.missions + 1,
    gradeS: s.gradeS + (grade == 'S' ? 1 : 0),
    routes: real ? {...s.routes, mission.routeId} : null,
    longMissions: s.longMissions + (minutes >= kLongMissionMinutes ? 1 : 0),
    denariosEarned: s.denariosEarned + denarios,
  );
}

/// Lo que se lee directo del estado actual (mensajeros, mundo): no hace
/// falta contarlo, y así nunca se desincroniza.
PlayerStats withSnapshot(
    PlayerStats s, List<Messenger> messengers, WorldState world) {
  var rank = 1, maxLevel = 1, elite = 0;
  for (final m in messengers) {
    rank = math.max(rank, m.rank);
    for (final lv in m.skills.values) {
      maxLevel = math.max(maxLevel, lv);
      elite += math.max(0, lv - kMaxSkillLevel);
    }
  }
  return s.copyWith(
    // El rango nunca baja en las estadísticas (los logros no se pierden).
    rank: math.max(s.rank, rank),
    maxSkillLevel: math.max(s.maxSkillLevel, maxLevel),
    eliteLevels: math.max(s.eliteLevels, elite),
    messengers: math.max(s.messengers, messengers.length),
    arcEndings: math.max(s.arcEndings, world.completedArcs.length),
  );
}

// ─── Leer (y migrar) ─────────────────────────────────────────────────────────
/// Devuelve la progresión. La primera vez la reconstruye desde lo que ya
/// existe: misiones entregadas, mensajeros, mundo y títulos del esquema v1.
/// Los logros que ya estaban cumplidos se desbloquean y pagan en silencio.
class GetProgressionUseCase {
  final ProgressionRepository _progression;
  final MessengerRepository _messengers;
  final MissionRepository _missions;
  final WorldRepository _world;
  final GameContentCatalog _content;
  GetProgressionUseCase(this._progression, this._messengers, this._missions,
      this._world, this._content);

  Future<ProgressionState> execute() async {
    final saved = await _progression.load();
    if (saved != null) return saved;

    var stats = const PlayerStats();
    for (final m in await _missions.getCompletedMissions()) {
      final r = m.result;
      if (r == null) continue;
      stats = statsAfterDelivery(stats, m, r.grade, r.denarios);
      stats = stats.copyWith(
          eventsResolved: stats.eventsResolved +
              m.events.where((e) => e.status == EventStatus.resolved).length);
    }
    final messengers = await _messengers.getAllMessengers();
    stats = withSnapshot(stats, messengers, await _world.getState());

    final legacy = await _progression.legacyTitles();
    var state = ProgressionState(stats: stats).addTitles(legacy.titles);
    state = state.copyWith(
        equippedTitle:
            legacy.titles.contains(legacy.equipped) ? legacy.equipped : null);

    final earned = newlyUnlocked(_content.achievements, state);
    state = _grant(state, earned);
    await _payRewards(_messengers, earned);
    await _progression.save(state);
    return state;
  }
}

// ─── Registrar ───────────────────────────────────────────────────────────────
class RecordProgressUseCase {
  final GetProgressionUseCase _get;
  final ProgressionRepository _progression;
  final MessengerRepository _messengers;
  final WorldRepository _world;
  final GameContentCatalog _content;
  RecordProgressUseCase(this._get, this._progression, this._messengers,
      this._world, this._content);

  /// Aplica [change] a las estadísticas, suma [titles] y desbloquea lo que
  /// corresponda. Sin [change] solo refresca lo que se lee del estado
  /// (sirve después de ascender o contratar un mensajero).
  Future<ProgressionUpdate> execute({
    PlayerStats Function(PlayerStats)? change,
    Iterable<String> titles = const [],
  }) async {
    final before = await _get.execute();
    var stats = change?.call(before.stats) ?? before.stats;
    stats = withSnapshot(
        stats, await _messengers.getAllMessengers(), await _world.getState());

    final titlesBefore = before.titles.toSet();
    var state = before.copyWith(stats: stats).addTitles(titles);
    final earned = newlyUnlocked(_content.achievements, state);
    state = _grant(state, earned);
    final paid = await _payRewards(_messengers, earned);
    await _progression.save(state);

    return ProgressionUpdate(
      state: state,
      unlocked: earned,
      denarios: paid.denarios,
      seals: paid.seals,
      newTitles: state.titles.where((t) => !titlesBefore.contains(t)).toList(),
      rankReached: stats.rank > before.stats.rank ? stats.rank : null,
    );
  }
}

// ─── Equipar título ──────────────────────────────────────────────────────────
class EquipTitleUseCase {
  final GetProgressionUseCase _get;
  final ProgressionRepository _progression;
  EquipTitleUseCase(this._get, this._progression);

  /// Equipa [title], o lo saca si ya estaba puesto o es null.
  Future<ProgressionState> execute(String? title) async {
    final state = await _get.execute();
    final next = title == null || state.equippedTitle == title
        ? state.copyWith(clearEquipped: true)
        : state.titles.contains(title)
            ? state.copyWith(equippedTitle: title)
            : state;
    await _progression.save(next);
    return next;
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
ProgressionState _grant(ProgressionState s, List<AchievementDef> earned) {
  if (earned.isEmpty) return s;
  return s.copyWith(unlocked: {...s.unlocked, ...earned.map((a) => a.id)})
      .addTitles(earned.map((a) => a.reward.title).whereType<String>());
}

/// Los premios van a la billetera común (la del mensajero principal).
Future<({int denarios, int seals})> _payRewards(
    MessengerRepository repo, List<AchievementDef> earned) async {
  final denarios = earned.fold<int>(0, (a, e) => a + e.reward.denarios);
  final seals = earned.fold<int>(0, (a, e) => a + e.reward.seals);
  if (denarios == 0 && seals == 0) return (denarios: 0, seals: 0);
  final all = await repo.getAllMessengers();
  if (all.isEmpty) return (denarios: 0, seals: 0);
  final primary = all.first;
  await repo.saveMessenger(primary.copyWith(
    denarios: primary.denarios + denarios,
    seals: primary.seals + seals,
  ));
  return (denarios: denarios, seals: seals);
}
