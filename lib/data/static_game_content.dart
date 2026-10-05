import '../domain/entities/content.dart';
import '../domain/repositories/content_catalog.dart';
import 'game_content.dart' as base;
import 'game_content_expansion.dart';
import 'story_content.dart' as story;

/// Catálogo con el contenido estático de `lib/data/`.
class StaticGameContent implements GameContentCatalog {
  const StaticGameContent();

  @override
  List<TutorialMission> get tutorialMissions =>
      base.tutorialMissions;

  @override
  String get mainArcId => story.kArcClaudius;

  @override
  int arcStageCount(String arcId) => story.arcStageCount(arcId);

  @override
  StoryMissionConfig? storyMissionFor(
          String arcId, int stage, Set<String> flags) =>
      story.storyMissionFor(arcId, stage, flags);

  @override
  StoryMissionConfig? storyMissionById(String id) =>
      story.storyArcClaudius.where((c) => c.id == id).firstOrNull;

  @override
  RealEventConfig? eventById(String id) =>
      story.storyEventById(id) ??
      allRealEvents.where((e) => e.id == id).firstOrNull;
}
