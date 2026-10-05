import 'world.dart';

// ─── Skill progression config ─────────────────────────────────────────────────
/// XP necesario para subir un nivel de skill.
const int kXpPerSkillLevel = 100;
/// Nivel máximo alcanzable con XP/manuales. Los niveles 6-10 se ascienden
/// con Sellos del Gremio en los Caminos del Mensajero (ver skill_tree.dart).
const int kMaxSkillLevel = 5;

/// Nombre de cada rango (índice 1-5).
const kRankTitles = ['', 'Correo', 'Mensajero', 'Courier', 'Maestro', 'Leyenda'];

// ─── User ─────────────────────────────────────────────────────────────────────
class User {
  final String id;
  final String name;
  final bool isFirstLogin;
  const User({required this.id, required this.name, required this.isFirstLogin});
  User copyWith({String? name, bool? isFirstLogin}) =>
      User(id: id, name: name ?? this.name, isFirstLogin: isFirstLogin ?? this.isFirstLogin);
}

// ─── Messenger ────────────────────────────────────────────────────────────────
class Messenger {
  final String id;
  final String name;
  final MessengerGender gender;
  final int health;
  final int fatigue;
  final MessengerStatus status;
  final Map<SkillType, int> skills;
  final Map<SkillType, int> skillXp;
  final List<String> completedMissionIds;
  final int tutorialPhase;
  final int tutorialMissionIndex;
  final bool tutorialComplete;
  final int denarios;
  final int aureos;
  // Sellos del Gremio: recurso de élite para ascender skills a niveles 6-10.
  final int seals;
  // Slot index: 0 = primer mensajero, 1+ = desbloqueados
  final int slotIndex;
  // Boosts comprados en la tienda, pendientes de consumir en la próxima misión.
  // Ej: 'boost_speed' (Sandalias), 'boost_events' (Mapa del explorador).
  final Set<String> activeBoosts;

  const Messenger({
    required this.id,
    required this.name,
    required this.gender,
    required this.health,
    required this.fatigue,
    required this.status,
    required this.skills,
    required this.skillXp,
    required this.completedMissionIds,
    required this.tutorialPhase,
    required this.tutorialMissionIndex,
    required this.tutorialComplete,
    this.denarios = 0,
    this.aureos = 0,
    this.seals = 0,
    this.slotIndex = 0,
    this.activeBoosts = const {},
  });

  int get totalSkillLevel => skills.values.fold(0, (a, b) => a + b);
  int get rank => switch (totalSkillLevel) {
    < 8 => 1, < 14 => 2, < 20 => 3, < 26 => 4, _ => 5,
  };
  String get rankTitle => kRankTitles[rank];
  int skillLevel(SkillType t) => skills[t] ?? 1;

  /// Suma XP a una skill y sube de nivel cada vez que cruza [kXpPerSkillLevel].
  /// El XP restante se conserva como progreso hacia el siguiente nivel (0–99).
  /// Devuelve el mensajero actualizado y la lista de skills que subieron de nivel
  /// (para mostrar feedback en pantalla).
  ({Messenger messenger, List<SkillType> leveledUp}) addSkillXp(SkillType skill, int amount) {
    final newSkills = Map<SkillType, int>.from(skills);
    final newXp = Map<SkillType, int>.from(skillXp);
    final leveledUp = <SkillType>[];
    var level = newSkills[skill] ?? 1;
    var xp = (newXp[skill] ?? 0) + amount;
    while (xp >= kXpPerSkillLevel && level < kMaxSkillLevel) {
      xp -= kXpPerSkillLevel;
      level++;
      leveledUp.add(skill);
    }
    if (level >= kMaxSkillLevel) xp = 0; // nivel máximo: barra llena
    newSkills[skill] = level;
    newXp[skill] = xp;
    return (
      messenger: copyWith(skills: newSkills, skillXp: newXp),
      leveledUp: leveledUp,
    );
  }

  /// Sube una skill [by] niveles de forma directa (manuales de la tienda).
  /// Limita al nivel máximo base (5).
  Messenger raiseSkill(SkillType skill, {int by = 1}) {
    final newSkills = Map<SkillType, int>.from(skills);
    newSkills[skill] = ((newSkills[skill] ?? 1) + by).clamp(1, kMaxSkillLevel);
    return copyWith(skills: newSkills);
  }

  /// Asciende una skill un nivel élite (6-10). La validación de Sellos
  /// vive en AscendSkillUseCase; acá solo se aplica el nivel.
  Messenger ascendSkill(SkillType skill) {
    final newSkills = Map<SkillType, int>.from(skills);
    newSkills[skill] = ((newSkills[skill] ?? 1) + 1).clamp(1, 10);
    return copyWith(skills: newSkills);
  }

  Messenger copyWith({
    String? name,
    MessengerGender? gender,
    int? health,
    int? fatigue,
    MessengerStatus? status,
    Map<SkillType, int>? skills,
    Map<SkillType, int>? skillXp,
    List<String>? completedMissionIds,
    int? tutorialPhase,
    int? tutorialMissionIndex,
    bool? tutorialComplete,
    int? denarios,
    int? aureos,
    int? seals,
    int? slotIndex,
    Set<String>? activeBoosts,
  }) => Messenger(
    id: id,
    name: name ?? this.name,
    gender: gender ?? this.gender,
    health: health ?? this.health,
    fatigue: fatigue ?? this.fatigue,
    status: status ?? this.status,
    skills: skills ?? this.skills,
    skillXp: skillXp ?? this.skillXp,
    completedMissionIds: completedMissionIds ?? this.completedMissionIds,
    tutorialPhase: tutorialPhase ?? this.tutorialPhase,
    tutorialMissionIndex: tutorialMissionIndex ?? this.tutorialMissionIndex,
    tutorialComplete: tutorialComplete ?? this.tutorialComplete,
    denarios: denarios ?? this.denarios,
    aureos: aureos ?? this.aureos,
    seals: seals ?? this.seals,
    slotIndex: slotIndex ?? this.slotIndex,
    activeBoosts: activeBoosts ?? this.activeBoosts,
  );
}

enum MessengerGender { male, female }
extension MessengerGenderX on MessengerGender {
  String get label => this == MessengerGender.male ? 'Hombre' : 'Mujer';
}

enum MessengerStatus { idle, onMission, resting, injured }
extension MessengerStatusX on MessengerStatus {
  String get label => switch (this) {
    MessengerStatus.idle      => 'Disponible',
    MessengerStatus.onMission => 'En misión',
    MessengerStatus.resting   => 'Descansando',
    MessengerStatus.injured   => 'Herido',
  };
}

enum SkillType { speed, stealth, combat, survival, contacts }
extension SkillTypeX on SkillType {
  String get label => switch (this) {
    SkillType.speed    => 'Velocidad',
    SkillType.stealth  => 'Sigilo',
    SkillType.combat   => 'Combate',
    SkillType.survival => 'Supervivencia',
    SkillType.contacts => 'Contactos',
  };
  String get icon => switch (this) {
    SkillType.speed    => 'V',
    SkillType.stealth  => 'S',
    SkillType.combat   => 'C',
    SkillType.survival => 'SU',
    SkillType.contacts => 'CO',
  };
  String get emoji => switch (this) {
    SkillType.speed    => '\u26A1',
    SkillType.stealth  => '\uD83D\uDD75',
    SkillType.combat   => '\u2694',
    SkillType.survival => '\uD83C\uDF3F',
    SkillType.contacts => '\uD83E\uDD1D',
  };
}

// ─── Game Route ───────────────────────────────────────────────────────────────
class GameRoute {
  final String id;
  final String origin;
  final String destination;
  final int distanceKm;
  final int durationMinutes;
  final double danger;
  final int requiredRank;
  final int eventCount;
  final String lore;

  const GameRoute({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationMinutes,
    required this.danger,
    required this.requiredRank,
    required this.eventCount,
    required this.lore,
  });

  String get durationLabel {
    if (durationMinutes < 60) return '${durationMinutes}m';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h < 24) return m == 0 ? '${h}h' : '${h}h ${m}m';
    final d = h ~/ 24;
    final rh = h % 24;
    return rh == 0 ? '${d}d' : '${d}d ${rh}h';
  }

  int get dangerLevel => (danger * 5).round().clamp(1, 5);
}

// ─── Mission ──────────────────────────────────────────────────────────────────
class Mission {
  final String id;
  final String routeId;
  final String messengerId;   // ← qué mensajero lleva esta misión
  final String origin;
  final String destination;
  final String packageDescription;
  final String lore;
  final String? narrativeIntro;
  final bool isTutorial;
  final int tutorialIndex;
  final DateTime startedAt;
  final DateTime deadlineAt;
  final int progressPct;
  final MissionStatus status;
  final PackageState packageState;
  final List<MissionEvent> events;
  final MissionResult? result;
  // Si el jugador usó "Mapa del explorador", se revela el próximo evento antes de tiempo.
  final bool revealEvents;
  // ── Historia ── misión de arco narrativo (null = misión normal)
  final String? arcId;
  final int arcStage;
  final String? epilogue;
  /// Factor de paga fijado al aceptar, según la ruta nominal (ver
  /// `routePayFactor`). Se guarda para que un boost de velocidad no la baje.
  final double payFactor;

  const Mission({
    required this.id,
    required this.routeId,
    required this.messengerId,
    required this.origin,
    required this.destination,
    required this.packageDescription,
    required this.lore,
    this.narrativeIntro,
    required this.isTutorial,
    required this.tutorialIndex,
    required this.startedAt,
    required this.deadlineAt,
    required this.progressPct,
    required this.status,
    required this.packageState,
    required this.events,
    this.result,
    this.revealEvents = false,
    this.arcId,
    this.arcStage = 0,
    this.epilogue,
    this.payFactor = 1.0,
  });

  Duration get timeRemaining => deadlineAt.difference(DateTime.now());
  bool get isOverdue => DateTime.now().isAfter(deadlineAt);

  String get timeRemainingLabel {
    final r = timeRemaining;
    // Tardar en entregar no baja la nota (ver timeScoreFor): no es "atraso".
    if (r.isNegative) return 'LLEGÓ';
    if (r.inDays > 0) return '${r.inDays}d ${r.inHours % 24}h';
    if (r.inHours > 0) return '${r.inHours}h ${r.inMinutes % 60}m';
    if (r.inMinutes > 0) return '${r.inMinutes}m ${r.inSeconds % 60}s';
    return '${r.inSeconds}s';
  }

  /// Evento que bloquea el viaje ahora: el primero sin resolver cuyo momento
  /// ya llegó. Un evento futuro nunca se muestra antes de su `triggersAt`.
  MissionEvent? get pendingEvent => blockingEventAt(DateTime.now());

  /// Evento que bloquea el viaje en [now] (ver [pendingEvent]).
  MissionEvent? blockingEventAt(DateTime now) => events
      .where((e) => e.isUnresolved && !now.isBefore(e.triggersAt))
      .firstOrNull;

  /// Eventos sin resolver que todavía no llegaron en [now], por hora.
  List<MissionEvent> upcomingEventsAt(DateTime now) => events
      .where((e) => e.isUnresolved && now.isBefore(e.triggersAt))
      .toList()
    ..sort((a, b) => a.triggersAt.compareTo(b.triggersAt));

  /// Próximo evento sin resolver que todavía no llegó en [now].
  MissionEvent? nextUpcomingEventAt(DateTime now) =>
      upcomingEventsAt(now).firstOrNull;

  /// Avance del viaje en [now], entre 0 y 1. Se congela en el momento en que
  /// llegó un evento sin resolver.
  double progressAt(DateTime now) {
    final total = deadlineAt.difference(startedAt).inSeconds;
    if (total <= 0) return 1.0;
    final blocking = blockingEventAt(now);
    final until = blocking?.triggersAt ?? now;
    return (until.difference(startedAt).inSeconds / total).clamp(0.0, 1.0);
  }

  /// Se puede entregar: el tiempo se cumplió y no queda evento bloqueando.
  bool readyToDeliverAt(DateTime now) =>
      !now.isBefore(deadlineAt) && blockingEventAt(now) == null;

  /// Minutos que se ahorran adelantando hasta el próximo evento (o hasta la
  /// llegada si no quedan eventos). 0 si no hay nada que adelantar.
  int minutesToNextStopAt(DateTime now) {
    final target = nextUpcomingEventAt(now)?.triggersAt ?? deadlineAt;
    final minutes = target.difference(now).inMinutes;
    return minutes > 0 ? minutes : 0;
  }

  /// Adelanta el reloj de la misión hasta [max] sin pasar del próximo evento
  /// (que queda activo) ni de la llegada. Corre hacia atrás la salida, la
  /// llegada y los eventos futuros, así conservan su distancia relativa.
  Mission fastForward(DateTime now, {Duration? max}) {
    final next = nextUpcomingEventAt(now);
    final Duration limit = next != null
        ? next.triggersAt.difference(now) + const Duration(seconds: 1)
        : deadlineAt.difference(now) - const Duration(seconds: 2);
    if (limit.isNegative || limit == Duration.zero) return this;
    final advance = (max != null && max < limit) ? max : limit;
    if (advance <= Duration.zero) return this;
    return copyWith(
      startedAt: startedAt.subtract(advance),
      deadlineAt: deadlineAt.subtract(advance),
      events: events
          .map((e) => e.isUnresolved && now.isBefore(e.triggersAt)
              ? e.shiftBy(-advance)
              : e)
          .toList(),
    );
  }

  /// La misión pierde [minutes]: la llegada se demora y los eventos que
  /// todavía no ocurrieron se corren lo mismo.
  Mission delayedBy(int minutes) {
    if (minutes <= 0) return this;
    final d = Duration(minutes: minutes);
    final now = DateTime.now();
    return copyWith(
      deadlineAt: deadlineAt.add(d),
      events: events.map((e) {
        final unresolved = e.status == EventStatus.pending ||
            e.status == EventStatus.active;
        if (!unresolved || !e.triggersAt.isAfter(now)) return e;
        return e.shiftBy(d);
      }).toList(),
    );
  }

  Mission copyWith({
    String? messengerId,
    int? progressPct,
    MissionStatus? status,
    PackageState? packageState,
    List<MissionEvent>? events,
    MissionResult? result,
    DateTime? deadlineAt,
    DateTime? startedAt,
    bool? revealEvents,
    String? epilogue,
  }) => Mission(
    id: id, routeId: routeId,
    messengerId: messengerId ?? this.messengerId,
    origin: origin, destination: destination,
    packageDescription: packageDescription, lore: lore,
    narrativeIntro: narrativeIntro, isTutorial: isTutorial, tutorialIndex: tutorialIndex,
    startedAt: startedAt ?? this.startedAt,
    deadlineAt: deadlineAt ?? this.deadlineAt,
    progressPct: progressPct ?? this.progressPct,
    status: status ?? this.status,
    packageState: packageState ?? this.packageState,
    events: events ?? this.events,
    result: result ?? this.result,
    revealEvents: revealEvents ?? this.revealEvents,
    arcId: arcId,
    arcStage: arcStage,
    epilogue: epilogue ?? this.epilogue,
    payFactor: payFactor,
  );
}

enum MissionStatus { active, completed, failed }
enum PackageState { intact, wetMinor, damaged, compromised, lost }

extension PackageStateX on PackageState {
  String get label => switch (this) {
    PackageState.intact      => 'Intacto',
    PackageState.wetMinor    => 'Humedad leve',
    PackageState.damaged     => 'Dañado',
    PackageState.compromised => 'Comprometido',
    PackageState.lost        => 'Perdido',
  };
  String get icon => switch (this) {
    PackageState.intact      => '[OK]',
    PackageState.wetMinor    => '[~]',
    PackageState.damaged     => '[!]',
    PackageState.compromised => '[X]',
    PackageState.lost        => '[XX]',
  };
}

class MissionResult {
  final String grade;
  final double timeScore;
  final double packageScore;
  final double decisionScore;
  final DateTime arrivedAt;
  // Denarios pagados por esta entrega (ya con bonus de perks aplicados).
  final int denarios;

  const MissionResult({
    required this.grade,
    required this.timeScore,
    required this.packageScore,
    required this.decisionScore,
    required this.arrivedAt,
    this.denarios = 0,
  });
}

// ─── Mission Event ────────────────────────────────────────────────────────────
class MissionEvent {
  final String id;
  final String title;
  final String description;
  final DateTime triggersAt;
  final DateTime deadlineAt;
  final EventStatus status;
  final List<EventOption> options;
  final EventOutcome? outcome;

  const MissionEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.triggersAt,
    required this.deadlineAt,
    required this.status,
    required this.options,
    this.outcome,
  });

  bool get isExpired => DateTime.now().isAfter(deadlineAt);

  MissionEvent copyWith({
    EventStatus? status,
    EventOutcome? outcome,
    DateTime? triggersAt,
    DateTime? deadlineAt,
  }) => MissionEvent(
    id: id, title: title, description: description,
    triggersAt: triggersAt ?? this.triggersAt,
    deadlineAt: deadlineAt ?? this.deadlineAt,
    status: status ?? this.status,
    options: options,
    outcome: outcome ?? this.outcome,
  );

  bool get isUnresolved =>
      status == EventStatus.pending || status == EventStatus.active;

  /// Desplaza los tiempos del evento por [delta] (negativo = adelantar).
  MissionEvent shiftBy(Duration delta) => copyWith(
        triggersAt: triggersAt.add(delta),
        deadlineAt: deadlineAt.add(delta),
      );
}

enum EventStatus { pending, active, resolved, expired }

class EventOption {
  final String id;
  final String text;
  final int riskLevel;
  final int timeCostMinutes;
  final Map<SkillType, int> requiredSkills;
  final bool isCardOption;
  final String? outcomeSuccess;
  final String? outcomePartial;
  final String? outcomeFail;

  // ── Efectos narrativos (el mundo recuerda) ──────────────────────────────
  // Los efectos representan la DECISIÓN, no el resultado: se aplican con
  // cualquier outcome. La auto-resolución no los aplica.
  /// Cambios de reputación por facción.
  final Map<Faction, int>? repDelta;
  /// Flags de historia que activa esta opción.
  final List<String>? setFlags;
  /// La opción solo aparece si el jugador tiene este flag (callback secreto).
  final String? requiredFlag;
  /// La opción se oculta si el jugador tiene este flag.
  final String? forbiddenFlag;
  /// Reputación mínima por facción. Si no alcanza, la opción se muestra
  /// bloqueada con [lockedHint].
  final Map<Faction, int>? minReputation;
  /// Motivo narrativo del candado ("Los patricios no confían en vos").
  final String? lockedHint;
  /// Evento que se encadena más adelante en la misma misión.
  final String? followUpEventId;
  /// Entrada de diario que deja esta decisión.
  final String? journalNote;

  const EventOption({
    required this.id,
    required this.text,
    required this.riskLevel,
    required this.timeCostMinutes,
    required this.requiredSkills,
    this.isCardOption = false,
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
}

class EventOutcome {
  final OutcomeType type;
  final String narrative;
  final int healthDelta;
  final int timeDeltaMinutes;
  final PackageState packageState;
  final String? chosenOptionText;
  /// Habilidad que se puso en juego (null si la opción no pedía ninguna).
  /// Se guarda para poder mostrar al cerrar la misión de dónde salió el XP.
  final SkillType? usedSkill;
  /// XP otorgado por resolver este evento.
  final int xpGained;

  const EventOutcome({
    required this.type,
    required this.narrative,
    required this.healthDelta,
    required this.timeDeltaMinutes,
    required this.packageState,
    this.chosenOptionText,
    this.usedSkill,
    this.xpGained = 0,
  });
}

enum OutcomeType { success, partial, fail }

// ─── Messenger slot unlock config ────────────────────────────────────────────
// Cuántos Aureos cuesta desbloquear cada slot adicional
const messengerSlotCosts = {
  1: 20,  // segundo mensajero
  2: 50,  // tercero
  3: 100, // cuarto
};

// Cuántas pruebas de Varus hay que haber completado para poder comprar cada slot
const messengerSlotRequiredTutorials = {
  1: 4,   // completar las 4 pruebas
  2: 4,
  3: 4,
};