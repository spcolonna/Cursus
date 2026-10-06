import '../entities/content.dart';
import '../entities/geo.dart';
import '../entities/progression.dart';
import '../entities/weekly.dart';
import '../entities/world.dart';

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

  /// Logros del juego, en el orden en que se muestran.
  List<AchievementDef> get achievements;

  /// Ruta real por id (para saber su patrón y su duración nominal).
  RealMissionConfig? routeById(String id);

  /// Lo que abre cada facción al subir de escalón.
  List<FactionUnlock> get factionUnlocks;

  /// Pool de encargos semanales (incluye el del Sello, [kWeeklySealId]).
  List<WeeklyCommissionDef> get weeklyCommissions;

  /// Personajes con retrato.
  List<NpcDef> get npcs;

  /// Coordenadas de los mapas de Italia y Roma.
  GeoAtlas get atlas;
}
