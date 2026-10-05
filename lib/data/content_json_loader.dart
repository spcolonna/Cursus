import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/entities/entities.dart';
import '../domain/entities/world.dart';
import 'game_content.dart';

/// Loader data-driven (Fase 2). Lee JSON de `assets/content/` y lo convierte
/// a las mismas configs que el contenido Dart. Hoy se usa para validar el
/// pipeline; el runtime sigue sirviendo Dart (`allRealMissions` /
/// `allRealEvents`) para no romper hot-reload ni tests.
class ContentJsonLoader {
  Future<List<RealMissionConfig>> loadExpansionRoutes() async {
    final raw =
        await rootBundle.loadString('assets/content/routes_expansion.json');
    final decoded = jsonDecode(raw);
    final list = decoded is List
        ? decoded
        : (decoded as Map<String, dynamic>)['missions'] as List<dynamic>;
    return list
        .map((e) => _missionFromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RealEventConfig>> loadExpansionEvents() async {
    final raw =
        await rootBundle.loadString('assets/content/events_expansion.json');
    final decoded = jsonDecode(raw);
    final list = decoded is List
        ? decoded
        : (decoded as Map<String, dynamic>)['events'] as List<dynamic>;
    return list.map((e) => _eventFromJson(e as Map<String, dynamic>)).toList();
  }

  RealMissionConfig _missionFromJson(Map<String, dynamic> j) => RealMissionConfig(
        id: j['id'] as String,
        origin: j['origin'] as String,
        destination: j['destination'] as String,
        distanceKm: j['distanceKm'] as int,
        durationMinutes: j['durationMinutes'] as int,
        danger: (j['danger'] as num).toDouble(),
        requiredRank: j['requiredRank'] as int,
        lore: j['lore'] as String,
        packageOptions:
            (j['packageOptions'] as List<dynamic>).cast<String>(),
        eventPoolIds: (j['eventPoolIds'] as List<dynamic>).cast<String>(),
        minEvents: j['minEvents'] as int,
        maxEvents: j['maxEvents'] as int,
        requiredFlag: j['requiredFlag'] as String?,
      );

  RealEventConfig _eventFromJson(Map<String, dynamic> j) => RealEventConfig(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        options: (j['options'] as List<dynamic>)
            .map((o) => _optionFromJson(o as Map<String, dynamic>))
            .toList(),
      );

  RealOptionConfig _optionFromJson(Map<String, dynamic> j) {
    final skillsRaw = j['requiredSkills'] as Map<String, dynamic>? ?? {};
    final skills = <SkillType, int>{};
    for (final e in skillsRaw.entries) {
      final skill = SkillType.values.where((s) => s.name == e.key).firstOrNull;
      if (skill != null) skills[skill] = e.value as int;
    }

    Map<Faction, int>? rep;
    final repRaw = j['repDelta'] as Map<String, dynamic>?;
    if (repRaw != null) {
      rep = {};
      for (final e in repRaw.entries) {
        final f = Faction.values.where((x) => x.name == e.key).firstOrNull;
        if (f != null) rep[f] = e.value as int;
      }
    }

    return RealOptionConfig(
      id: j['id'] as String,
      text: j['text'] as String,
      riskLevel: j['riskLevel'] as int,
      timeCostMinutes: j['timeCostMinutes'] as int,
      requiredSkills: skills,
      outcomeSuccess: j['outcomeSuccess'] as String?,
      outcomePartial: j['outcomePartial'] as String?,
      outcomeFail: j['outcomeFail'] as String?,
      repDelta: rep,
      setFlags: (j['setFlags'] as List<dynamic>?)?.cast<String>(),
      requiredFlag: j['requiredFlag'] as String?,
      forbiddenFlag: j['forbiddenFlag'] as String?,
      journalNote: j['journalNote'] as String?,
      followUpEventId: j['followUpEventId'] as String?,
    );
  }
}
