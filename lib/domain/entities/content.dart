// Tipos del contenido del juego (tutorial, rutas, eventos y arcos). Viven en
// el dominio para que los use cases no dependan de `data/`; los datos en sí
// están en `lib/data/` y llegan inyectados vía [GameContentCatalog].

import 'entities.dart';
import 'world.dart';

// ═══════════════════════════════════════════════════════════════
// DATA CLASSES — Solo estructuras, sin lógica
// ═══════════════════════════════════════════════════════════════

class TutorialMission {
  final String id;
  final int phase;
  final int durationMinutes;
  final String origin;
  final String destination;
  final String packageDescription;
  final String lore;
  final String narrativeIntro;
  final List<String> eventIds;
  final int rewardXp;
  final bool unlockNextOnComplete;

  const TutorialMission({
    required this.id,
    required this.phase,
    required this.durationMinutes,
    required this.origin,
    required this.destination,
    required this.packageDescription,
    required this.lore,
    required this.narrativeIntro,
    required this.eventIds,
    required this.rewardXp,
    required this.unlockNextOnComplete,
  });
}

class TutorialEvent {
  final String id;
  final String title;
  final String description;
  final int decisionWindowMinutes;
  final List<TutorialOption> options;

  const TutorialEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.decisionWindowMinutes,
    required this.options,
  });
}

class TutorialOption {
  final String id;
  final String text;
  final int riskLevel;
  final int timeCostMinutes;
  final Map<SkillType, int> requiredSkills;
  final String outcomeSuccess;
  final String outcomePartial;
  final String outcomeFail;

  const TutorialOption({
    required this.id,
    required this.text,
    required this.riskLevel,
    required this.timeCostMinutes,
    required this.requiredSkills,
    required this.outcomeSuccess,
    required this.outcomePartial,
    required this.outcomeFail,
  });
}

class RealMissionConfig {
  final String id;
  final String origin;
  final String destination;
  final int distanceKm;
  final int durationMinutes;
  final double danger;
  final int requiredRank;
  final String lore;
  final List<String> packageOptions;
  final List<String> eventPoolIds;
  final int minEvents;
  final int maxEvents;
  // La ruta solo aparece si el jugador tiene este flag (ej. final de un arco).
  final String? requiredFlag;
  /// Facción que encarga la ruta: gana reputación con cada buena entrega.
  final Faction? patron;
  /// Reputación con [patron] necesaria para que te la ofrezcan.
  final int minReputation;

  const RealMissionConfig({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationMinutes,
    required this.danger,
    required this.requiredRank,
    required this.lore,
    required this.packageOptions,
    required this.eventPoolIds,
    required this.minEvents,
    required this.maxEvents,
    this.requiredFlag,
    this.patron,
    this.minReputation = 0,
  });

  /// ¿Se la ofrecen a un mensajero de [rank] con este [world]?
  bool isOfferedTo(int rank, WorldState world) =>
      requiredRank <= rank &&
      (requiredFlag == null || world.hasFlag(requiredFlag!)) &&
      (patron == null || world.repOf(patron!) >= minReputation);

  int get dangerLevel => (danger * 5).round().clamp(1, 5);

  String get durationLabel {
    if (durationMinutes < 60) return '${durationMinutes}m';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h < 24) return m == 0 ? '${h}h' : '${h}h ${m}m';
    final d = h ~/ 24;
    final rh = h % 24;
    return rh == 0 ? '${d}d' : '${d}d ${rh}h';
  }
}

class RealEventConfig {
  final String id;
  final String title;
  final String description;
  final List<RealOptionConfig> options;

  const RealEventConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
  });
}

class RealOptionConfig {
  final String id;
  final String text;
  final int riskLevel;
  final int timeCostMinutes;
  final Map<SkillType, int> requiredSkills;
  // Prosa específica por resultado — obligatoria en eventos nuevos.
  final String? outcomeSuccess;
  final String? outcomePartial;
  final String? outcomeFail;
  // Efectos narrativos (representan la decisión, se aplican con cualquier outcome)
  final Map<Faction, int>? repDelta;
  final List<String>? setFlags;
  final String? requiredFlag;   // opción secreta: solo aparece con este flag
  final String? forbiddenFlag;  // se oculta si el jugador tiene este flag
  final Map<Faction, int>? minReputation;
  final String? lockedHint;
  final String? followUpEventId;
  final String? journalNote;

  const RealOptionConfig({
    required this.id,
    required this.text,
    required this.riskLevel,
    required this.timeCostMinutes,
    required this.requiredSkills,
    this.outcomeSuccess,
    this.outcomePartial,
    this.outcomeFail,
    this.repDelta,
    this.setFlags,
    this.requiredFlag,
    this.forbiddenFlag,
    this.minReputation,
    this.lockedHint,
    this.followUpEventId,
    this.journalNote,
  });

  /// Convierte la config en la entidad de dominio.
  EventOption toEventOption() => EventOption(
        id: id,
        text: text,
        riskLevel: riskLevel,
        timeCostMinutes: timeCostMinutes,
        requiredSkills: requiredSkills,
        outcomeSuccess: outcomeSuccess,
        outcomePartial: outcomePartial,
        outcomeFail: outcomeFail,
        repDelta: repDelta,
        setFlags: setFlags,
        requiredFlag: requiredFlag,
        forbiddenFlag: forbiddenFlag,
        minReputation: minReputation,
        lockedHint: lockedHint,
        followUpEventId: followUpEventId,
        journalNote: journalNote,
      );
}

class StoryMissionConfig {
  final String id;
  final String arcId;
  final int stage; // 0-based
  final String chapterTitle;
  final String origin;
  final String destination;
  final String packageDescription;
  final int durationMinutes;
  final String lore;           // texto corto en la card del Home
  final String narrativeIntro; // viñeta al aceptar
  final String epilogue;       // texto al entregar
  final String journalEntry;   // entrada de diario al completar
  final List<String> fixedEventIds;
  // Variantes de capítulo: se elige la primera cuyo flag matchea.
  final String? requiredFlag;
  final String? forbiddenFlag;
  /// Variante que se juega si ninguna otra matchea (p. ej. el evento que
  /// decide el camino se resolvió sin dejar flag). Una por stage ramificado.
  final bool isDefaultVariant;
  // Efectos al completar el capítulo.
  final List<String>? setFlagsOnComplete;
  final Map<Faction, int>? repDeltaOnComplete;
  // Solo capítulos finales:
  final String? endingId;    // 'end_varus' | 'end_claudius' | 'end_underworld'
  final String? endingTitle; // título que gana el jugador

  const StoryMissionConfig({
    required this.id,
    required this.arcId,
    required this.stage,
    required this.chapterTitle,
    required this.origin,
    required this.destination,
    required this.packageDescription,
    required this.durationMinutes,
    required this.lore,
    required this.narrativeIntro,
    required this.epilogue,
    required this.journalEntry,
    required this.fixedEventIds,
    this.requiredFlag,
    this.forbiddenFlag,
    this.isDefaultVariant = false,
    this.setFlagsOnComplete,
    this.repDeltaOnComplete,
    this.endingId,
    this.endingTitle,
  });

  bool get isFinal => endingId != null;
}
