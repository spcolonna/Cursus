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

/// Nombre del estado de reputación (para las barras del perfil).
String reputationTitle(int value) => switch (value) {
      >= 60 => 'Leyenda',
      >= 30 => 'Respetado',
      >= 10 => 'Conocido',
      > -10 => 'Desconocido',
      > -40 => 'Sospechoso',
      _ => 'Enemigo',
    };

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

  const WorldState({
    required this.reputation,
    required this.flags,
    required this.journal,
    required this.arcProgress,
    required this.completedArcs,
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
  bool hasFlag(String flag) => flags.contains(flag);
  bool arcCompleted(String arcId) =>
      completedArcs.any((c) => c == arcId || c.startsWith('$arcId:'));

  WorldState copyWith({
    Map<Faction, int>? reputation,
    Set<String>? flags,
    List<JournalEntry>? journal,
    Map<String, int>? arcProgress,
    Set<String>? completedArcs,
  }) =>
      WorldState(
        reputation: reputation ?? this.reputation,
        flags: flags ?? this.flags,
        journal: journal ?? this.journal,
        arcProgress: arcProgress ?? this.arcProgress,
        completedArcs: completedArcs ?? this.completedArcs,
      );

  /// Aplica deltas de reputación (clamp -100..100).
  WorldState applyRepDeltas(Map<Faction, int>? deltas) {
    if (deltas == null || deltas.isEmpty) return this;
    final next = Map<Faction, int>.from(reputation);
    for (final e in deltas.entries) {
      next[e.key] = ((next[e.key] ?? 0) + e.value).clamp(-100, 100);
    }
    return copyWith(reputation: next);
  }

  WorldState addFlags(Iterable<String>? newFlags) {
    if (newFlags == null || newFlags.isEmpty) return this;
    return copyWith(flags: {...flags, ...newFlags});
  }

  /// Agrega una entrada al diario (se guardan las últimas 40).
  WorldState addJournal(String text) {
    final next = [...journal, JournalEntry(date: DateTime.now(), text: text)];
    if (next.length > 40) next.removeRange(0, next.length - 40);
    return copyWith(journal: next);
  }
}
