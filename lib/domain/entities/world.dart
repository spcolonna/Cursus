// ─── El mundo recuerda ────────────────────────────────────────────────────────
// Estado narrativo de la cuenta: reputación con las facciones de Roma,
// flags ocultos de historia y el diario del mensajero.
// Regla de diseño: las consecuencias son duras en lo narrativo pero suaves
// en lo mecánico — nunca quitan skills, monedas ni mensajeros.

enum Faction { guild, legions, underworld, patricians }

extension FactionX on Faction {
  String get label => switch (this) {
        Faction.guild => 'El Gremio',
        Faction.legions => 'Las Legiones',
        Faction.underworld => 'Bajos Fondos',
        Faction.patricians => 'Patricios',
      };

  String get lore => switch (this) {
        Faction.guild => 'La red de mensajeros de Varus. Tu casa.',
        Faction.legions => 'Centuriones y patrullas. Respetan el protocolo.',
        Faction.underworld => 'Bandidos, contrabandistas y oídos del foro.',
        Faction.patricians => 'Senadores y villas. Pagan bien, olvidan rápido.',
      };
}

// ─── Rangos de facción ───────────────────────────────────────────────────────
/// Escalones de reputación. El orden importa: se comparan por índice.
enum FactionTier { enemy, suspect, unknown, known, respected, legend }

extension FactionTierX on FactionTier {
  String get label => switch (this) {
        FactionTier.enemy => 'Enemigo',
        FactionTier.suspect => 'Sospechoso',
        FactionTier.unknown => 'Desconocido',
        FactionTier.known => 'Conocido',
        FactionTier.respected => 'Respetado',
        FactionTier.legend => 'Leyenda',
      };

  /// Reputación mínima para estar en este escalón (los negativos, el techo).
  int get threshold => switch (this) {
        FactionTier.enemy => -100,
        FactionTier.suspect => -39,
        FactionTier.unknown => -9,
        FactionTier.known => 10,
        FactionTier.respected => 30,
        FactionTier.legend => 60,
      };

  bool atLeast(FactionTier other) => index >= other.index;
}

FactionTier factionTier(int value) => switch (value) {
      >= 60 => FactionTier.legend,
      >= 30 => FactionTier.respected,
      >= 10 => FactionTier.known,
      > -10 => FactionTier.unknown,
      > -40 => FactionTier.suspect,
      _ => FactionTier.enemy,
    };

/// Nombre del estado de reputación (para las barras del perfil).
String reputationTitle(int value) => factionTier(value).label;

/// Lo que da cada facción al subir de escalón. Ninguno suma al score de
/// una decisión (cap de +25%): abren rutas, cambian la paga o dan títulos.
enum FactionUnlockKind { route, perk, title }

/// Ventajas con efecto mecánico que el código reconoce por id.
enum FactionPerk {
  /// Cambiar un contrato del tablón una vez por día.
  contractReroll,

  /// +10% de paga en las rutas que patrocina la facción.
  patronPay,
}

/// Paga extra de [FactionPerk.patronPay].
const double kPatronPayBonus = 1.10;

class FactionUnlock {
  final Faction faction;
  final FactionTier tier;
  final FactionUnlockKind kind;
  final String name;
  final String description;

  /// Id de la ruta (kind route), o el título (kind title).
  final String? ref;
  final FactionPerk? perk;

  /// Con este flag se abre aunque falte reputación (premio de un final).
  final String? orFlag;

  const FactionUnlock({
    required this.faction,
    required this.tier,
    required this.kind,
    required this.name,
    required this.description,
    this.ref,
    this.perk,
    this.orFlag,
  });

  bool isOpen(WorldState w) =>
      factionTier(w.repOf(faction)).atLeast(tier) ||
      (orFlag != null && w.hasFlag(orFlag!));
}

/// ¿Tiene el jugador [perk] con [faction] (o con cualquiera, si es null)?
bool hasFactionPerk(List<FactionUnlock> unlocks, WorldState world,
        FactionPerk perk, {Faction? faction}) =>
    unlocks.any((u) =>
        u.perk == perk &&
        (faction == null || u.faction == faction) &&
        u.isOpen(world));

/// Reputación que gana el patrón de la ruta al entregarle bien: +2 con S,
/// +1 con A o B. Una vez por día y por facción (ver [WorldState.patronDays]).
int patronRepFor(String grade) => switch (grade) {
      'S' => 2,
      'A' || 'B' => 1,
      _ => 0,
    };

/// Cuántos eventos recientes recuerda el sorteo para no repetirlos.
const int kRecentEventMemory = 12;

class JournalEntry {
  final DateTime date;
  final String text;
  const JournalEntry({required this.date, required this.text});
}

class WorldState {
  /// Reputación por facción, -100..100.
  final Map<Faction, int> reputation;

  /// Flags ocultos de historia ('paid_bandits', 'told_varus'...).
  final Set<String> flags;

  /// Diario del mensajero: la memoria visible del jugador.
  final List<JournalEntry> journal;

  /// arcId -> índice del próximo capítulo a jugar (0-based).
  final Map<String, int> arcProgress;

  /// Arcos terminados, con el final elegido: 'arc_claudius:end_varus'.
  final Set<String> completedArcs;

  /// Último día ('aaaa-mm-dd') en que cada facción sumó reputación por una
  /// entrega en su ruta: tope de una vez por día para que no se infle.
  final Map<Faction, String> patronDays;

  /// Últimos eventos del camino que salieron (ids, el más nuevo al final):
  /// el sorteo evita repetirlos.
  final List<String> recentEvents;

  /// Eventos de una sola vez que ya salieron.
  final Set<String> seenEvents;

  const WorldState({
    required this.reputation,
    required this.flags,
    required this.journal,
    required this.arcProgress,
    required this.completedArcs,
    this.patronDays = const {},
    this.recentEvents = const [],
    this.seenEvents = const {},
  });

  factory WorldState.initial() => WorldState(
        reputation: {
          for (final f in Faction.values) f: f == Faction.guild ? 10 : 0
        },
        flags: const {},
        journal: const [],
        arcProgress: const {},
        completedArcs: const {},
      );

  int repOf(Faction f) => reputation[f] ?? 0;
  FactionTier tierOf(Faction f) => factionTier(repOf(f));
  bool hasFlag(String flag) => flags.contains(flag);
  bool arcCompleted(String arcId) =>
      completedArcs.any((c) => c == arcId || c.startsWith('$arcId:'));

  WorldState copyWith({
    Map<Faction, int>? reputation,
    Set<String>? flags,
    List<JournalEntry>? journal,
    Map<String, int>? arcProgress,
    Set<String>? completedArcs,
    Map<Faction, String>? patronDays,
    List<String>? recentEvents,
    Set<String>? seenEvents,
  }) =>
      WorldState(
        reputation: reputation ?? this.reputation,
        flags: flags ?? this.flags,
        journal: journal ?? this.journal,
        arcProgress: arcProgress ?? this.arcProgress,
        completedArcs: completedArcs ?? this.completedArcs,
        patronDays: patronDays ?? this.patronDays,
        recentEvents: recentEvents ?? this.recentEvents,
        seenEvents: seenEvents ?? this.seenEvents,
      );

  /// Anota los eventos que salieron en una misión nueva. [once] son los que
  /// no se repiten nunca.
  WorldState recordEvents(Iterable<String> ids, {Iterable<String> once = const []}) {
    final recent = [...recentEvents, ...ids];
    if (recent.length > kRecentEventMemory) {
      recent.removeRange(0, recent.length - kRecentEventMemory);
    }
    return copyWith(recentEvents: recent, seenEvents: {...seenEvents, ...once});
  }

  /// Aplica deltas de reputación (clamp -100..100). Si una facción sube de
  /// escalón, el diario lo anota: es la memoria de por qué se abrió algo.
  WorldState applyRepDeltas(Map<Faction, int>? deltas) {
    if (deltas == null || deltas.isEmpty) return this;
    final next = Map<Faction, int>.from(reputation);
    for (final e in deltas.entries) {
      next[e.key] = ((next[e.key] ?? 0) + e.value).clamp(-100, 100);
    }
    var result = copyWith(reputation: next);
    for (final f in deltas.keys) {
      final before = tierOf(f), after = result.tierOf(f);
      if (after.index > before.index && after.atLeast(FactionTier.known)) {
        result = result.addJournal(
            '${f.label} ahora te tiene por ${after.label.toLowerCase()}.');
      }
    }
    return result;
  }

  /// Suma la reputación del patrón por una entrega con nota [grade] en
  /// [day], respetando el tope diario. Devuelve el estado y lo ganado.
  ({WorldState world, int gained}) applyPatronDelivery(
      Faction patron, String grade, String day) {
    final gain = patronRepFor(grade);
    if (gain == 0 || patronDays[patron] == day) return (world: this, gained: 0);
    final next = applyRepDeltas({patron: gain})
        .copyWith(patronDays: {...patronDays, patron: day});
    return (world: next, gained: gain);
  }

  /// Escalones que subieron de [before] a este estado, por facción.
  Map<Faction, FactionTier> tierUpsSince(WorldState before) => {
        for (final f in Faction.values)
          if (tierOf(f).index > before.tierOf(f).index &&
              tierOf(f).atLeast(FactionTier.known))
            f: tierOf(f),
      };

  WorldState addFlags(Iterable<String>? newFlags) {
    if (newFlags == null || newFlags.isEmpty) return this;
    return copyWith(flags: {...flags, ...newFlags});
  }

  /// Huella narrativa de una decisión: reputación, flags y diario. La usan
  /// tanto la decisión del jugador como la auto-resolución — si la segunda no
  /// la aplicara, un arco que depende de un flag de camino se trabaría.
  WorldState applyChoiceEffects({
    Map<Faction, int>? repDelta,
    Iterable<String>? setFlags,
    String? journalNote,
  }) {
    var next = applyRepDeltas(repDelta).addFlags(setFlags);
    if (journalNote != null) next = next.addJournal(journalNote);
    return next;
  }

  /// Agrega una entrada al diario (se guardan las últimas 40).
  WorldState addJournal(String text) {
    final next = [...journal, JournalEntry(date: DateTime.now(), text: text)];
    if (next.length > 40) next.removeRange(0, next.length - 40);
    return copyWith(journal: next);
  }
}
