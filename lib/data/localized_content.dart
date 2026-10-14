// ═════════════════════════════════════════════════════════════════════════════
// Contenido en el idioma del jugador. El resto del juego lee el contenido
// desde acá (o desde StaticGameContent, que usa esto), nunca las constantes
// en español directo. Cada lista se traduce una vez por idioma.
//
// `contentKeys()` enumera TODAS las claves con su texto en español: es lo
// que hay que traducir, y lo que verifica test/content_l10n_test.dart.
// ═════════════════════════════════════════════════════════════════════════════

import '../domain/entities/content_l10n.dart';
import '../domain/entities/domain_strings.dart';
import '../domain/entities/progression.dart';
import '../domain/entities/weekly.dart';
import '../domain/entities/world.dart';
import 'faction_content.dart';
import 'game_content.dart';
import 'game_content_expansion.dart';
import 'npc_content.dart';
import 'progression_content.dart';
import 'story_content.dart';
import 'story_rewards.dart';

String _t(String key, String es) => ContentL10n.t(key, es);
String? _tn(String key, String? es) => ContentL10n.tn(key, es);

// ─── Caché por idioma ─────────────────────────────────────────────────────────

final Map<String, Object> _cache = {};
int _cacheRevision = -1;

List<T> _memo<T>(String name, List<T> Function() build) {
  if (_cacheRevision != ContentL10n.revision) {
    _cache.clear();
    _cacheRevision = ContentL10n.revision;
  }
  return (_cache[name] ??= build()) as List<T>;
}

// ─── Listas traducidas ────────────────────────────────────────────────────────

List<TutorialMission> get lTutorialMissions =>
    _memo('tutorialMissions', () => [for (final m in tutorialMissions) m.l10n]);
List<TutorialEvent> get lTutorialEvents =>
    _memo('tutorialEvents', () => [for (final e in tutorialEvents) e.l10n]);
List<RealMissionConfig> get lRealMissions =>
    _memo('realMissions', () => [for (final m in allRealMissions) m.l10n]);
List<RealEventConfig> get lRealEvents =>
    _memo('realEvents', () => [for (final e in allRealEvents) e.l10n]);
List<RealEventConfig> get lStoryEvents =>
    _memo('storyEvents', () => [for (final e in allStoryEvents) e.l10n]);
List<StoryMissionConfig> get lStoryChapters =>
    _memo('storyChapters', () => [for (final c in allStoryChapters) c.l10n]);
List<StoryArcDef> get lArcs =>
    _memo('arcs', () => [for (final a in storyArcs) a.l10n]);
List<AchievementDef> get lAchievements =>
    _memo('achievements', () => [for (final a in allAchievements) a.l10n]);
List<FactionUnlock> get lFactionUnlocks =>
    _memo('unlocks', () => [for (final u in factionUnlocks) u.l10n]);
List<WeeklyCommissionDef> get lWeeklyCommissions => _memo(
    'weekly', () => [for (final w in weeklyCommissionPool) w.l10n]);
List<NpcDef> get lNpcs => _memo('npcs', () => [for (final n in allNpcs) n.l10n]);
List<RestStop> get lRestStops =>
    _memo('restStops', () => [for (final r in restStops) r.l10n]);

/// Capítulo traducido que corresponde jugar (ver `storyMissionFor`).
StoryMissionConfig? lStoryMissionFor(
    String arcId, int stage, Set<String> flags) {
  final id = storyMissionFor(arcId, stage, flags)?.id;
  return id == null ? null : lStoryChapters.where((c) => c.id == id).first;
}

/// Qué significa un flag para el jugador (pantalla de resultado).
String? lFlagDescription(String flag) =>
    _tn('flag.$flag', flagDescription(flag));

// ─── Traducción de cada tipo ──────────────────────────────────────────────────

extension TutorialMissionL10n on TutorialMission {
  TutorialMission get l10n => TutorialMission(
        id: id,
        phase: phase,
        durationMinutes: durationMinutes,
        origin: origin,
        destination: destination,
        packageDescription: _t('$id.package', packageDescription),
        lore: _t('$id.lore', lore),
        narrativeIntro: _t('$id.intro', narrativeIntro),
        eventIds: eventIds,
        rewardXp: rewardXp,
        unlockNextOnComplete: unlockNextOnComplete,
      );
}

extension TutorialEventL10n on TutorialEvent {
  TutorialEvent get l10n => TutorialEvent(
        id: id,
        title: _t('$id.title', title),
        description: _t('$id.description', description),
        decisionWindowMinutes: decisionWindowMinutes,
        category: category,
        npcId: npcId,
        options: [
          for (final o in options)
            TutorialOption(
              id: o.id,
              text: _t('${o.id}.text', o.text),
              riskLevel: o.riskLevel,
              timeCostMinutes: o.timeCostMinutes,
              requiredSkills: o.requiredSkills,
              outcomeSuccess: _t('${o.id}.success', o.outcomeSuccess),
              outcomePartial: _t('${o.id}.partial', o.outcomePartial),
              outcomeFail: _t('${o.id}.fail', o.outcomeFail),
            ),
        ],
      );
}

extension RealMissionConfigL10n on RealMissionConfig {
  RealMissionConfig get l10n => RealMissionConfig(
        id: id,
        origin: origin,
        destination: destination,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        danger: danger,
        requiredRank: requiredRank,
        lore: _t('$id.lore', lore),
        packageOptions: [
          for (var i = 0; i < packageOptions.length; i++)
            _t('$id.package.$i', packageOptions[i]),
        ],
        eventPoolIds: eventPoolIds,
        minEvents: minEvents,
        maxEvents: maxEvents,
        requiredFlag: requiredFlag,
        patron: patron,
        minReputation: minReputation,
        openedByFlag: openedByFlag,
      );
}

extension RealEventConfigL10n on RealEventConfig {
  RealEventConfig get l10n => RealEventConfig(
        id: id,
        title: _t('$id.title', title),
        description: _t('$id.description', description),
        category: category,
        npcId: npcId,
        requiredFlag: requiredFlag,
        forbiddenFlag: forbiddenFlag,
        minReputation: minReputation,
        weight: weight,
        once: once,
        options: [for (final o in options) o.l10n],
      );
}

extension RealOptionConfigL10n on RealOptionConfig {
  RealOptionConfig get l10n => RealOptionConfig(
        id: id,
        text: _t('$id.text', text),
        riskLevel: riskLevel,
        timeCostMinutes: timeCostMinutes,
        requiredSkills: requiredSkills,
        outcomeSuccess: _tn('$id.success', outcomeSuccess),
        outcomePartial: _tn('$id.partial', outcomePartial),
        outcomeFail: _tn('$id.fail', outcomeFail),
        repDelta: repDelta,
        setFlags: setFlags,
        requiredFlag: requiredFlag,
        forbiddenFlag: forbiddenFlag,
        minReputation: minReputation,
        lockedHint: _tn('$id.locked', lockedHint),
        followUpEventId: followUpEventId,
        journalNote: _tn('$id.journal', journalNote),
      );
}

extension StoryMissionConfigL10n on StoryMissionConfig {
  StoryMissionConfig get l10n => StoryMissionConfig(
        id: id,
        arcId: arcId,
        stage: stage,
        chapterTitle: _t('$id.title', chapterTitle),
        origin: origin,
        destination: destination,
        packageDescription: _t('$id.package', packageDescription),
        durationMinutes: durationMinutes,
        lore: _t('$id.lore', lore),
        narrativeIntro: _t('$id.intro', narrativeIntro),
        epilogue: _t('$id.epilogue', epilogue),
        journalEntry: _t('$id.journal', journalEntry),
        fixedEventIds: fixedEventIds,
        requiredFlag: requiredFlag,
        forbiddenFlag: forbiddenFlag,
        isDefaultVariant: isDefaultVariant,
        minRank: minRank,
        setFlagsOnComplete: setFlagsOnComplete,
        repDeltaOnComplete: repDeltaOnComplete,
        endingId: endingId,
        endingTitle: _tn('$id.ending', endingTitle),
      );
}

extension StoryArcDefL10n on StoryArcDef {
  StoryArcDef get l10n => StoryArcDef(
        id: id,
        title: _t('$id.title', title),
        stageCount: stageCount,
        minRank: minRank,
        requiredArc: requiredArc,
      );
}

extension AchievementDefL10n on AchievementDef {
  AchievementDef get l10n => AchievementDef(
        id: id,
        name: _t('$id.name', name),
        goal: _t('$id.goal', goal),
        kind: kind,
        metric: metric,
        target: target,
        secret: secret,
        reward: AchievementReward(
          denarios: reward.denarios,
          seals: reward.seals,
          title: _tn('$id.reward_title', reward.title),
        ),
      );
}

/// Clave estable de un desbloqueo de facción (no tienen id propio).
String unlockKey(FactionUnlock u) =>
    'unlock.${u.faction.name}.${u.tier.name}.${u.kind.name}.${u.ref ?? u.perk?.name ?? ''}';

extension FactionUnlockL10n on FactionUnlock {
  FactionUnlock get l10n => FactionUnlock(
        faction: faction,
        tier: tier,
        kind: kind,
        name: _t('${unlockKey(this)}.name', name),
        description: _t('${unlockKey(this)}.description', description),
        ref: ref,
        perk: perk,
        orFlag: orFlag,
      );
}

extension WeeklyCommissionDefL10n on WeeklyCommissionDef {
  // El nombre del NPC no se traduce: enlaza el retrato (NpcDef.idFromName).
  WeeklyCommissionDef get l10n => WeeklyCommissionDef(
        id: id,
        npcName: npcName,
        npcRole: _t('$id.role', npcRole),
        npcFaction: npcFaction,
        intro: _t('$id.intro', intro),
        goalText: _t('$id.goal', goalText),
        goal: goal,
        target: target,
        faction: faction,
        denarios: denarios,
        seals: seals,
        rep: rep,
        journal: _t('$id.journal', journal),
      );
}

extension NpcDefL10n on NpcDef {
  NpcDef get l10n => NpcDef(
        id: id,
        name: name,
        role: _t('npc.$id.role', role),
        faction: faction,
        look: look,
      );
}

extension RestStopL10n on RestStop {
  RestStop get l10n => RestStop(
        flag: flag,
        name: _t('rest.$flag.name', name),
        routeIds: routeIds,
        fatigueRelief: fatigueRelief,
      );
}

// ─── Inventario de claves ─────────────────────────────────────────────────────

/// Toda clave traducible del contenido con su texto en español.
Map<String, String> contentKeys() {
  final k = <String, String>{};
  void put(String key, String? es) {
    if (es != null && es.trim().isNotEmpty) k[key] = es;
  }

  void option(RealOptionConfig o) {
    put('${o.id}.text', o.text);
    put('${o.id}.success', o.outcomeSuccess);
    put('${o.id}.partial', o.outcomePartial);
    put('${o.id}.fail', o.outcomeFail);
    put('${o.id}.locked', o.lockedHint);
    put('${o.id}.journal', o.journalNote);
  }

  void event(RealEventConfig e) {
    put('${e.id}.title', e.title);
    put('${e.id}.description', e.description);
    e.options.forEach(option);
  }

  final places = <String>{};
  for (final m in tutorialMissions) {
    put('${m.id}.package', m.packageDescription);
    put('${m.id}.lore', m.lore);
    put('${m.id}.intro', m.narrativeIntro);
    places..add(m.origin)..add(m.destination);
  }
  for (final e in tutorialEvents) {
    put('${e.id}.title', e.title);
    put('${e.id}.description', e.description);
    for (final o in e.options) {
      put('${o.id}.text', o.text);
      put('${o.id}.success', o.outcomeSuccess);
      put('${o.id}.partial', o.outcomePartial);
      put('${o.id}.fail', o.outcomeFail);
    }
  }
  for (final m in allRealMissions) {
    put('${m.id}.lore', m.lore);
    for (var i = 0; i < m.packageOptions.length; i++) {
      put('${m.id}.package.$i', m.packageOptions[i]);
    }
    places..add(m.origin)..add(m.destination);
  }
  allRealEvents.forEach(event);
  allStoryEvents.forEach(event);
  for (final c in allStoryChapters) {
    put('${c.id}.title', c.chapterTitle);
    put('${c.id}.package', c.packageDescription);
    put('${c.id}.lore', c.lore);
    put('${c.id}.intro', c.narrativeIntro);
    put('${c.id}.epilogue', c.epilogue);
    put('${c.id}.journal', c.journalEntry);
    put('${c.id}.ending', c.endingTitle);
    places..add(c.origin)..add(c.destination);
  }
  for (final a in storyArcs) {
    put('${a.id}.title', a.title);
  }
  for (final a in allAchievements) {
    put('${a.id}.name', a.name);
    put('${a.id}.goal', a.goal);
    put('${a.id}.reward_title', a.reward.title);
  }
  for (final u in factionUnlocks) {
    put('${unlockKey(u)}.name', u.name);
    put('${unlockKey(u)}.description', u.description);
  }
  for (final w in weeklyCommissionPool) {
    put('${w.id}.role', w.npcRole);
    put('${w.id}.intro', w.intro);
    put('${w.id}.goal', w.goalText);
    put('${w.id}.journal', w.journal);
  }
  for (final n in allNpcs) {
    put('npc.${n.id}.role', n.role);
  }
  for (final r in restStops) {
    put('rest.${r.flag}.name', r.name);
  }
  for (final f in flagDescriptions.entries) {
    put('flag.${f.key}', f.value);
  }
  for (final p in places) {
    put('place.$p', p);
  }
  kDomainStrings.forEach(put);
  return k;
}
