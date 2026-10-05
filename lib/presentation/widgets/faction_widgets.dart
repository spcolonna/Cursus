import 'package:flutter/material.dart';
import '../../domain/entities/world.dart';
import '../theme/app_theme.dart';
import 'components.dart';

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
      Faction.guild => AppColors.gold,
      Faction.legions => AppColors.amber,
      Faction.underworld => AppColors.sky,
      Faction.patricians => AppColors.purple,
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
class FactionBadge extends StatelessWidget {
  final Faction faction;
  final double size;
  const FactionBadge({super.key, required this.faction, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final c = factionColor(faction);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: 0.15),
        border: Border.all(color: c, width: size > 36 ? 2.5 : 2),
      ),
      child: Icon(factionIcon(faction), color: c, size: size * 0.5),
    );
  }
}

// ─── Retrato de NPC ───────────────────────────────────────────────────────────
/// Medallón con la inicial; el borde dice para quién trabaja. (La Fase 4
/// lo cambia por la ilustración, con este como respaldo.)
class NpcPortrait extends StatelessWidget {
  final String name;
  final Faction? faction;
  final double size;
  const NpcPortrait(
      {super.key, required this.name, this.faction, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final c =
        faction == null ? AppColors.textSecondary : factionColor(faction!);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.card,
        border: Border.all(color: c, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Text(name.isEmpty ? '?' : name.characters.first,
          style: AppTextStyles.fredoka(size * 0.42,
              color: AppColors.parchment, weight: FontWeight.bold)),
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
                '${u.isOpen(world) ? 'Desbloqueado' : 'Pide ${u.tier.label}'}',
            excludeSemantics: true,
            child: GameCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              borderColor: u.isOpen(world) ? color : null,
              child: Row(children: [
                Icon(
                    u.isOpen(world)
                        ? unlockKindIcon(u.kind)
                        : Icons.lock_outline,
                    color: u.isOpen(world) ? color : AppColors.textMuted,
                    size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name,
                            style: AppTextStyles.fredoka(14,
                                color: u.isOpen(world)
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                weight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(u.description, style: AppTextStyles.bodySmall),
                      ]),
                ),
                const SizedBox(width: AppSpacing.sm),
                u.isOpen(world)
                    ? const GameChip('Abierto',
                        icon: Icons.check, color: AppColors.green)
                    : GameChip(u.tier.label),
              ]),
            ),
          ),
        ),
    ]);
  }
}
