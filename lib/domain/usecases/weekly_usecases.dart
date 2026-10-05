import '../entities/entities.dart';
import '../entities/weekly.dart';
import '../repositories/content_catalog.dart';
import '../repositories/repositories.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Encargos semanales: leer (y renovar el lunes), registrar avance y cobrar.
// Ver domain/entities/weekly.dart.
// ═══════════════════════════════════════════════════════════════════════════

Map<String, WeeklyCommissionDef> _defsById(GameContentCatalog c) =>
    {for (final d in c.weeklyCommissions) d.id: d};

class GetWeeklyUseCase {
  final WeeklyRepository _repo;
  final GameContentCatalog _content;
  GetWeeklyUseCase(this._repo, this._content);

  /// El tablón de esta semana. Si cambió la semana (o nunca hubo), arma uno
  /// nuevo: lo que no se cobró a tiempo se pierde, como en el gremio.
  Future<WeeklyState> execute({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final saved = await _repo.load();
    if (saved != null && saved.weekKey == isoWeekKey(at)) return saved;
    final fresh = WeeklyState.freshFor(at, _content.weeklyCommissions);
    await _repo.save(fresh);
    return fresh;
  }
}

class RecordWeeklyProgressUseCase {
  final GetWeeklyUseCase _get;
  final WeeklyRepository _repo;
  final GameContentCatalog _content;
  RecordWeeklyProgressUseCase(this._get, this._repo, this._content);

  /// Una entrega con [grade]. El tutorial no cuenta.
  Future<WeeklyState> recordDelivery(Mission mission, String grade,
      {DateTime? now}) async {
    final state = await _get.execute(now: now);
    if (mission.isTutorial) return state;
    final route = mission.arcId == null ? _content.routeById(mission.routeId) : null;
    final minutes = route?.durationMinutes ??
        mission.deadlineAt.difference(mission.startedAt).inMinutes;
    final next = state.advance(_defsById(_content), (d) => switch (d.goal) {
          WeeklyGoal.deliver => true,
          WeeklyGoal.gradeS => grade == 'S',
          WeeklyGoal.gradeAOrS => grade == 'S' || grade == 'A',
          WeeklyGoal.patronDelivery =>
            route?.patron != null && route!.patron == d.faction,
          WeeklyGoal.longRoute => minutes >= kWeeklyLongMinutes,
          _ => false,
        });
    if (!identical(next, state)) await _repo.save(next);
    return next;
  }

  /// Un evento resuelto con [outcome].
  Future<WeeklyState> recordEvent(OutcomeType outcome, {DateTime? now}) async {
    final state = await _get.execute(now: now);
    final next = state.advance(_defsById(_content), (d) => switch (d.goal) {
          WeeklyGoal.resolveEvents => true,
          WeeklyGoal.eventSuccesses => outcome == OutcomeType.success,
          _ => false,
        });
    if (!identical(next, state)) await _repo.save(next);
    return next;
  }
}

class ClaimWeeklyCommissionUseCase {
  final GetWeeklyUseCase _get;
  final WeeklyRepository _repo;
  final MessengerRepository _messengers;
  final WorldRepository _world;
  final GameContentCatalog _content;
  ClaimWeeklyCommissionUseCase(
      this._get, this._repo, this._messengers, this._world, this._content);

  /// Cobra el encargo [id]: paga a la billetera común, suma la reputación y
  /// deja la entrada en el diario.
  Future<({WeeklyState state, WeeklyCommissionDef def})> execute(String id,
      {DateTime? now}) async {
    final state = await _get.execute(now: now);
    final idx = state.entries.indexWhere((e) => e.id == id);
    final def = _defsById(_content)[id];
    if (idx < 0 || def == null) throw Exception('Encargo inexistente');
    final entry = state.entries[idx];
    if (entry.claimed) throw Exception('Encargo ya cobrado');
    if (entry.progress < def.target) throw Exception('Encargo incompleto');

    final all = await _messengers.getAllMessengers();
    if (all.isNotEmpty) {
      final primary = all.first;
      await _messengers.saveMessenger(primary.copyWith(
        denarios: primary.denarios + def.denarios,
        seals: primary.seals + def.seals,
      ));
    }
    final world = await _world.getState();
    await _world.saveState(
        world.applyRepDeltas(def.rep).addJournal(def.journal));

    final entries = [...state.entries];
    entries[idx] = entry.copyWith(claimed: true);
    final next = state.copyWith(entries: entries);
    await _repo.save(next);
    return (state: next, def: def);
  }
}
