// lib/domain/usecases/event_selection.dart
//
// Qué eventos salen en una misión. Antes era un sorteo plano del pool de la
// ruta; ahora el mundo pesa: lo que hiciste vuelve (las consecuencias pesan
// triple), los eventos de una vez no se repiten y los últimos que viste
// quedan afuera mientras haya otros.

import 'dart:math';

import '../entities/content.dart';
import '../entities/world.dart';

/// Cuánto más pesa en el sorteo un evento que es consecuencia de algo.
const int kConsequenceWeight = 3;

/// Consecuencias por misión, como máximo: que no se coman el camino.
const int kMaxConsequencesPerMission = 1;

/// ¿Puede salir [e] con este [world]?
bool eventEligible(RealEventConfig e, WorldState world) {
  if (e.requiredFlag != null && !world.hasFlag(e.requiredFlag!)) return false;
  if (e.forbiddenFlag != null && world.hasFlag(e.forbiddenFlag!)) return false;
  if (e.once && world.seenEvents.contains(e.id)) return false;
  final rep = e.minReputation;
  if (rep != null) {
    for (final entry in rep.entries) {
      if (world.repOf(entry.key) < entry.value) return false;
    }
  }
  return true;
}

/// Elige [count] eventos de [pool] para una misión, sin repetir dentro de
/// ella. Determinista para un mismo [rng].
///
/// 1. Se descartan los que el mundo no permite ([eventEligible]).
/// 2. Se prefieren los que no salieron en las últimas misiones; si no
///    alcanzan, se completa con los recientes, del más viejo al más nuevo.
/// 3. Entre los candidatos se sortea por peso, con las consecuencias ×3 y
///    como mucho [kMaxConsequencesPerMission] por misión.
List<RealEventConfig> pickEventsForMission({
  required List<RealEventConfig> pool,
  required int count,
  required WorldState world,
  required Random rng,
}) {
  // Sin duplicados: una consecuencia puede estar en el pool de la ruta y en
  // el global a la vez.
  final seen = <String>{};
  final eligible = [
    for (final e in pool)
      if (seen.add(e.id) && eventEligible(e, world)) e
  ];
  final recent = world.recentEvents;
  final fresh = eligible.where((e) => !recent.contains(e.id)).toList();

  final picked = <RealEventConfig>[];
  var consequences = 0;

  void draw(List<RealEventConfig> candidates) {
    while (picked.length < count) {
      final open = [
        for (final e in candidates)
          if (!picked.contains(e) &&
              (!e.isConsequence || consequences < kMaxConsequencesPerMission))
            e
      ];
      if (open.isEmpty) return;
      int weightOf(RealEventConfig e) =>
          max(1, e.weight) * (e.isConsequence ? kConsequenceWeight : 1);
      final total = open.fold<int>(0, (a, e) => a + weightOf(e));
      var roll = rng.nextInt(total);
      for (final e in open) {
        roll -= weightOf(e);
        if (roll < 0) {
          picked.add(e);
          if (e.isConsequence) consequences++;
          break;
        }
      }
    }
  }

  draw(fresh);
  if (picked.length < count) {
    // Los recientes, primero los más viejos: así lo último visto es lo
    // último en volver.
    final stale = [
      for (final id in recent)
        ...eligible.where((e) => e.id == id && !picked.contains(e))
    ];
    for (final e in stale) {
      if (picked.length >= count) break;
      if (e.isConsequence && consequences >= kMaxConsequencesPerMission) {
        continue;
      }
      picked.add(e);
      if (e.isConsequence) consequences++;
    }
  }
  return picked;
}
