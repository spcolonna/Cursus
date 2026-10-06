import '../entities/analytics.dart';
import '../repositories/repositories.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sesiones: cada vez que el juego vuelve a primer plano se decide si es una
// sesión nueva y se anota el día. De acá sale la retención del dispositivo.
// ─────────────────────────────────────────────────────────────────────────────

class TrackSessionUseCase {
  final RetentionRepository _repo;
  final AnalyticsSink _sink;
  TrackSessionUseCase(this._repo, this._sink);

  /// El juego se abrió o volvió de segundo plano.
  Future<RetentionLog> open({DateTime? now}) async {
    final t = now ?? DateTime.now();
    final log = await _repo.load() ?? RetentionLog.start(t);
    final r = log.open(t);
    await _repo.save(r.log);
    if (r.newSession) {
      final day = r.log.dayIndex(t);
      await _sink.log(AnalyticsEvent.gameSession(
        day: day,
        sessionOfDay: r.log.sessionsOn(day),
        daysActive: r.log.daysActive,
      ));
    }
    return r.log;
  }

  /// El juego se fue a segundo plano: corre la ventana de la sesión.
  Future<void> pause({DateTime? now}) async {
    final log = await _repo.load();
    if (log == null) return;
    await _repo.save(log.touch(now ?? DateTime.now()));
  }
}
