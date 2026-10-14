// Validador del contenido: ids, referencias y presupuesto de texto de TODO
// lo que está en lib/data/. Lo que no pasa acá es contenido roto.
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/data/game_content.dart';
import 'package:the_messenger/data/game_content_expansion.dart';
import 'package:the_messenger/data/npc_content.dart';
import 'package:the_messenger/data/story_content.dart';

void main() {
  final roadEvents = allRealEvents;
  final storyEvents = allStoryEvents;
  final events = [...roadEvents, ...storyEvents];
  final npcIds = allNpcs.map((n) => n.id).toSet();
  final eventIds = events.map((e) => e.id).toSet();

  List<String> dupes(Iterable<String> ids) {
    final seen = <String>{};
    return [for (final id in ids) if (!seen.add(id)) id];
  }

  test('ids de eventos y opciones únicos en todo el juego', () {
    expect(dupes([...events.map((e) => e.id), ...tutorialEvents.map((e) => e.id)]),
        isEmpty);
    expect(
        dupes([
          for (final e in events) ...e.options.map((o) => o.id),
          for (final e in tutorialEvents) ...e.options.map((o) => o.id),
        ]),
        isEmpty);
    expect(dupes(allRealMissions.map((m) => m.id)), isEmpty);
    expect(dupes(allStoryChapters.map((c) => c.id)), isEmpty);
  });

  test('cada evento: título, situación corta y 2-4 opciones a la vista', () {
    final bad = <String>[];
    for (final e in events) {
      if (e.title.trim().isEmpty) bad.add('${e.id}: sin título');
      if (e.description.length > 240) {
        bad.add('${e.id}: situación de ${e.description.length} caracteres');
      }
      // Las secretas (con flag) se suman a las de siempre, hasta 6.
      final always = e.options.where((o) => o.requiredFlag == null).length;
      if (always < 2 || always > 4 || e.options.length > 6) {
        bad.add('${e.id}: $always opciones a la vista, ${e.options.length} en total');
      }
    }
    expect(bad, isEmpty);
  });

  test('cada opción tiene sus tres resultados, cortos', () {
    final bad = <String>[];
    for (final e in events) {
      for (final o in e.options) {
        for (final t in [o.outcomeSuccess, o.outcomePartial, o.outcomeFail]) {
          if (t == null || t.trim().isEmpty) {
            bad.add('${o.id}: falta un resultado');
          } else if (t.length > 320) {
            bad.add('${o.id}: resultado de ${t.length} caracteres');
          }
        }
        if (o.riskLevel < 0 || o.riskLevel > 5) bad.add('${o.id}: riesgo');
      }
    }
    expect(bad, isEmpty);
  });

  test('referencias válidas: NPCs, eventos de seguimiento, rutas y capítulos',
      () {
    for (final e in events) {
      if (e.npcId != null) expect(npcIds, contains(e.npcId), reason: e.id);
      for (final o in e.options) {
        if (o.followUpEventId != null) {
          expect(eventIds, contains(o.followUpEventId), reason: o.id);
        }
      }
    }
    for (final r in allRealMissions) {
      for (final id in r.eventPoolIds) {
        expect(eventIds, contains(id), reason: '${r.id} → $id');
      }
    }
    for (final c in allStoryChapters) {
      for (final id in c.fixedEventIds) {
        expect(eventIds, contains(id), reason: '${c.id} → $id');
      }
    }
  });

  test('ningún evento de camino queda muerto', () {
    final pooled = {
      for (final r in allRealMissions) ...r.eventPoolIds,
      for (final c in allStoryChapters) ...c.fixedEventIds,
    };
    final followUps = {
      for (final e in events)
        for (final o in e.options)
          if (o.followUpEventId != null) o.followUpEventId!,
    };
    // Los de consecuencia salen por su flag, no por la ruta.
    final dead = roadEvents
        .where((e) => e.requiredFlag == null)
        .where((e) => !pooled.contains(e.id) && !followUps.contains(e.id))
        .map((e) => e.id)
        .toList();
    expect(dead, isEmpty);
  });
}
