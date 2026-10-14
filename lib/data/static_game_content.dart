import '../domain/entities/content.dart';
import '../domain/entities/geo.dart';
import '../domain/entities/progression.dart';
import '../domain/entities/weekly.dart';
import '../domain/entities/world.dart';
import '../domain/repositories/content_catalog.dart';
import 'geo_content.dart';
import 'story_content.dart' as story;
import 'consequence_content.dart' as consequences;
import 'localized_content.dart';

final _consequenceIds = {
  for (final e in consequences.consequenceEvents) e.id,
};

/// Catálogo con el contenido estático de `lib/data/`.
class StaticGameContent implements GameContentCatalog {
  const StaticGameContent();

  @override
  List<TutorialMission> get tutorialMissions => lTutorialMissions;

  @override
  String get mainArcId => story.kArcClaudius;

  @override
  List<StoryArcDef> get arcs => lArcs;

  @override
  int arcStageCount(String arcId) => story.arcStageCount(arcId);

  @override
  StoryMissionConfig? storyMissionFor(
          String arcId, int stage, Set<String> flags) =>
      lStoryMissionFor(arcId, stage, flags);

  @override
  StoryMissionConfig? storyMissionById(String id) =>
      lStoryChapters.where((c) => c.id == id).firstOrNull;

  @override
  RealEventConfig? eventById(String id) =>
      lStoryEvents.where((e) => e.id == id).firstOrNull ??
      lRealEvents.where((e) => e.id == id).firstOrNull;

  @override
  List<AchievementDef> get achievements => lAchievements;

  @override
  List<RealEventConfig> get consequenceEvents =>
      lRealEvents.where((e) => _consequenceIds.contains(e.id)).toList();

  @override
  List<RestStop> get restStops => lRestStops;

  @override
  RealMissionConfig? routeById(String id) =>
      lRealMissions.where((m) => m.id == id).firstOrNull;

  @override
  List<FactionUnlock> get factionUnlocks => lFactionUnlocks;

  @override
  List<WeeklyCommissionDef> get weeklyCommissions => lWeeklyCommissions;

  @override
  List<NpcDef> get npcs => lNpcs;

  @override
  GeoAtlas get atlas => geoAtlas;
}
