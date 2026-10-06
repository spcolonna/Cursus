import '../domain/entities/content.dart';
import '../domain/entities/geo.dart';
import '../domain/entities/progression.dart';
import '../domain/entities/weekly.dart';
import '../domain/entities/world.dart';
import '../domain/repositories/content_catalog.dart';
import 'faction_content.dart' as faction;
import 'game_content.dart' as base;
import 'game_content_expansion.dart';
import 'geo_content.dart';
import 'npc_content.dart';
import 'consequence_content.dart' as consequences;
import 'progression_content.dart';
import 'story_content.dart' as story;
import 'story_rewards.dart' as rewards;

/// Catálogo con el contenido estático de `lib/data/`.
class StaticGameContent implements GameContentCatalog {
  const StaticGameContent();

  @override
  List<TutorialMission> get tutorialMissions =>
      base.tutorialMissions;

  @override
  String get mainArcId => story.kArcClaudius;

  @override
  List<StoryArcDef> get arcs => story.storyArcs;

  @override
  int arcStageCount(String arcId) => story.arcStageCount(arcId);

  @override
  StoryMissionConfig? storyMissionFor(
          String arcId, int stage, Set<String> flags) =>
      story.storyMissionFor(arcId, stage, flags);

  @override
  StoryMissionConfig? storyMissionById(String id) =>
      story.allStoryChapters.where((c) => c.id == id).firstOrNull;

  @override
  RealEventConfig? eventById(String id) =>
      story.storyEventById(id) ??
      allRealEvents.where((e) => e.id == id).firstOrNull;

  @override
  List<AchievementDef> get achievements => allAchievements;

  @override
  List<RealEventConfig> get consequenceEvents => consequences.consequenceEvents;

  @override
  List<RestStop> get restStops => rewards.restStops;

  @override
  RealMissionConfig? routeById(String id) =>
      allRealMissions.where((m) => m.id == id).firstOrNull;

  @override
  List<FactionUnlock> get factionUnlocks => faction.factionUnlocks;

  @override
  List<WeeklyCommissionDef> get weeklyCommissions =>
      faction.weeklyCommissionPool;

  @override
  List<NpcDef> get npcs => allNpcs;

  @override
  GeoAtlas get atlas => geoAtlas;
}
