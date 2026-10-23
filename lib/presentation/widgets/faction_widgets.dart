import 'package:flutter/material.dart';
import '../../domain/entities/world.dart';
import '../../domain/entities/content.dart';
import '../theme/app_theme.dart';
import 'art_image.dart';
import 'components.dart';
import 'insignia.dart';
import '../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Piezas de facción: insignia, color, retrato de NPC y la escalera de favores
// que abre cada escalón. Las usan el perfil, el gremio y las celebraciones.
// ─────────────────────────────────────────────────────────────────────────────

IconData factionIcon(Faction f) => switch (f) {
      Faction.guild => Icons.forward_to_inbox,
      Faction.legions => Icons.shield,
      Faction.underworld => Icons.nightlight_round,
      Faction.patricians => Icons.account_balance,
    };

/// Acento de la facción. Ninguno es rojo: el rojo es solo para peligro.
Color factionColor(Faction f) => switch (f) {
      Faction.guild => AppColors.ochreDeep,
      Faction.legions => AppColors.sienna,
      Faction.underworld => AppColors.egyptianBlue,
      Faction.patricians => AppColors.tyrian,
    };

IconData unlockKindIcon(FactionUnlockKind k) => switch (k) {
      FactionUnlockKind.route => Icons.alt_route,
      FactionUnlockKind.perk => Icons.handshake,
      FactionUnlockKind.title => Icons.military_tech,
    };

/// Escalón siguiente con algo que ganar, o null si ya está en Leyenda.
FactionTier? nextTier(FactionTier t) => switch (t) {
      FactionTier.legend => null,
      FactionTier.respected => FactionTier.legend,
      FactionTier.known => FactionTier.respected,
      _ => FactionTier.known,
    };

// ─── Insignia ─────────────────────────────────────────────────────────────────
/// Escudo de la facción en un cuadrado de [size] (el escudo es más alto que
/// ancho y se centra).
class FactionBadge extends StatelessWidget {
  final Faction faction;
  final double size;
  const FactionBadge({super.key, required this.faction, this.size = 40});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Center(child: FactionCrest(faction: faction, size: size * 0.86)),
      );
}

// ─── Retrato de NPC ───────────────────────────────────────────────────────────
/// Retrato del personaje (`assets/art/npcs/<id>.jpg`) en un medallón con el
/// borde de su facción. Sin ilustración, la inicial.
class NpcPortrait extends StatelessWidget {
  final String name;
  final Faction? faction;
  final double size;

  /// Id del personaje. Por defecto sale del nombre ('Décimo' → 'decimo').
  final String? npcId;
  const NpcPortrait(
      {super.key, required this.name, this.faction, this.size = 48, this.npcId});

  @override
  Widget build(BuildContext context) {
    final c =
        faction == null ? AppColors.inkSoft : factionColor(faction!);
    final initial = Center(
      child: Text(name.isEmpty ? '?' : name.characters.first,
          style: AppTextStyles.ui(size * 0.42,
              color: AppColors.paper, weight: FontWeight.bold)),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.paper,
        border: Border.all(color: c, width: 2.5),
      ),
      child: ClipOval(
        child: ArtImage(
          asset: ArtPaths.npc(npcId ?? NpcDef.idFromName(name)),
          fallback: initial,
        ),
      ),
    );
  }
}

// ─── Escalera de favores ──────────────────────────────────────────────────────
/// Lo que abre cada escalón de [faction], con lo ganado arriba y lo que falta
/// apagado y con el escalón que pide.
class FactionUnlockList extends StatelessWidget {
  final Faction faction;
  final WorldState world;
  final List<FactionUnlock> unlocks;
  const FactionUnlockList({
    super.key,
    required this.faction,
    required this.world,
    required this.unlocks,
  });

  @override
  Widget build(BuildContext context) {
    final mine = unlocks.where((u) => u.faction == faction).toList()
      ..sort((a, b) => a.tier.index.compareTo(b.tier.index));
    final color = factionColor(faction);
    return Column(children: [
      for (final u in mine)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Semantics(
            label: '${u.name}. ${u.description}. '
                '${u.isOpen(world) ? AppLocalizations.of(context).unlocked : AppLocalizations.of(context).requiresTier(u.tier.label)}',
            excludeSemantics: true,
            child: GameCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              borderColor: u.isOpen(world) ? color : null,
              child: Row(children: [
                Icon(
                    u.isOpen(world)
                        ? unlockKindIcon(u.kind)
                        : Icons.lock_outline,
                    color: u.isOpen(world) ? color : AppColors.inkMuted,
                    size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name,
                            style: AppTextStyles.ui(14,
                                color: u.isOpen(world)
                                    ? AppColors.ink
                                    : AppColors.inkSoft,
                                weight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(u.description, style: AppTextStyles.bodySmall),
                      ]),
                ),
                const SizedBox(width: AppSpacing.sm),
                u.isOpen(world)
                    ? GameChip(AppLocalizations.of(context).open,
                        icon: Icons.check, color: AppColors.verdigris)
                    : GameChip(u.tier.label),
              ]),
            ),
          ),
        ),
    ]);
  }
}
