import '../entities/content.dart';

/// Contenido del juego que necesitan los use cases. La implementación vive en
/// `lib/data/` (contenido estático); el dominio solo conoce esta interfaz.
abstract class GameContentCatalog {
  /// Pruebas del tutorial, en orden.
  List<TutorialMission> get tutorialMissions;

  /// Arco principal de la historia.
  String get mainArcId;

  /// Cantidad de capítulos del arco (índices 0..n-1).
  int arcStageCount(String arcId);

  /// Capítulo que corresponde jugar para un arco/stage según los flags.
  StoryMissionConfig? storyMissionFor(String arcId, int stage, Set<String> flags);

  /// Capítulo de historia por id (el `routeId` de una misión de historia).
  StoryMissionConfig? storyMissionById(String id);

  /// Evento (de historia o del pool real) por id, para encadenar eventos.
  RealEventConfig? eventById(String id);
}
