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
  final EventCategory category;
  final String? npcId;

  const TutorialEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.decisionWindowMinutes,
    required this.options,
    this.category = EventCategory.road,
    this.npcId,
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
  /// Con este flag la ruta se ofrece aunque falte la reputación: es el
  /// premio de un final de arco ("Varus te abre el correo exprés").
  final String? openedByFlag;

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
    this.openedByFlag,
  });

  /// ¿Se la ofrecen a un mensajero de [rank] con este [world]?
  bool isOfferedTo(int rank, WorldState world) =>
      requiredRank <= rank &&
      (requiredFlag == null || world.hasFlag(requiredFlag!)) &&
      (patron == null ||
          world.repOf(patron!) >= minReputation ||
          (openedByFlag != null && world.hasFlag(openedByFlag!)));

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

  /// Escenario pintado detrás del evento. La ilustración propia, si existe,
  /// va en `assets/art/events/<id>.jpg` y tapa al escenario.
  final EventCategory category;

  /// Personaje con retrato (`NpcDef.id`) que aparece en el evento.
  final String? npcId;

  // ── Cuándo puede salir (ver `pickEventsForMission`) ──
  /// Solo sale si el jugador tiene este flag: es una consecuencia de algo
  /// que hizo antes. Las consecuencias pesan triple en el sorteo.
  final String? requiredFlag;

  /// No sale si el jugador tiene este flag.
  final String? forbiddenFlag;

  /// Reputación mínima por facción para que salga.
  final Map<Faction, int>? minReputation;

  /// Peso relativo en el sorteo (1 = normal).
  final int weight;

  /// Sale una sola vez por partida (las consecuencias, casi siempre).
  final bool once;

  const RealEventConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    this.category = EventCategory.road,
    this.npcId,
    this.requiredFlag,
    this.forbiddenFlag,
    this.minReputation,
    this.weight = 1,
    this.once = false,
  });

  /// Es la vuelta de una decisión anterior.
  bool get isConsequence => requiredFlag != null;
}

/// Personaje recurrente con retrato. El retrato va en
/// `assets/art/npcs/<id>.jpg`; sin archivo se dibuja la inicial.
class NpcDef {
  final String id;
  final String name;
  final String role;
  final Faction? faction;

  /// Descripción física para el prompt del retrato (docs/ART_PROMPTS.md).
  final String look;

  const NpcDef({
    required this.id,
    required this.name,
    required this.role,
    this.faction,
    required this.look,
  });

  /// 'Décimo' → 'decimo'. Así se enlazan los NPC de los encargos semanales,
  /// que se guardan por nombre.
  static String idFromName(String name) {
    const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n'};
    final lower = name.toLowerCase().trim();
    final buf = StringBuffer();
    for (final ch in lower.split('')) {
      final c = accents[ch] ?? ch;
      buf.write(RegExp(r'[a-z0-9]').hasMatch(c) ? c : '_');
    }
    return buf.toString();
  }
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
  /// Rango del mensajero principal que pide el capítulo (0 = el del arco).
  final int minRank;
  /// Variante que se juega si ninguna otra matchea (p. ej. el evento que
  /// decide el camino se resolvió sin dejar flag). Una por stage ramificado.
  final bool isDefaultVariant;
  // Efectos al completar el capítulo.
  final List<String>? setFlagsOnComplete;
  final Map<Faction, int>? repDeltaOnComplete;
  // Solo capítulos finales:
  final String? endingId;    // 'end_varus', 'end_lucius_family'...
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
    this.minRank = 0,
    this.setFlagsOnComplete,
    this.repDeltaOnComplete,
    this.endingId,
    this.endingTitle,
  });

  bool get isFinal => endingId != null;
}

/// Un arco de historia: una cadena de capítulos con su propia puerta.
class StoryArcDef {
  final String id;
  final String title;

  /// Cantidad de capítulos (stages 0..n-1).
  final int stageCount;

  /// Rango del mensajero principal para empezarlo.
  final int minRank;

  /// Arco que hay que terminar antes (con cualquier final).
  final String? requiredArc;

  const StoryArcDef({
    required this.id,
    required this.title,
    required this.stageCount,
    required this.minRank,
    this.requiredArc,
  });
}

/// Una posta amiga en el camino: con [flag], las rutas de [routeIds] cansan
/// [fatigueRelief] puntos menos al llegar.
class RestStop {
  final String flag;
  final String name;
  final Set<String> routeIds;
  final int fatigueRelief;

  const RestStop({
    required this.flag,
    required this.name,
    required this.routeIds,
    required this.fatigueRelief,
  });
}
