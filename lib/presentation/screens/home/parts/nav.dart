part of '../home_screen.dart';

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
// Cinco destinos, el Home al centro. Etiquetas de 12 pt (antes 8,8) y áreas
// táctiles de ancho completo. "Misión" lleva al viaje más urgente y, si no
// hay ninguno, dice por qué en vez de quedar gris en silencio.
class _BottomNav extends StatelessWidget {
  final HomeState state;
  const _BottomNav({required this.state});

  /// El viaje al que conviene ir: primero el que tiene un evento esperando.
  MessengerSlot? get _missionTarget =>
      state.slots.where((s) => s.pendingEvent != null).firstOrNull ??
      state.slots.where((s) => s.activeMission != null).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final target = _missionTarget;
    final hasEvent = state.slots.any((s) => s.pendingEvent != null);

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, bottomPad + AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.ochreDeep, width: 2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowHard,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _NavTab(
            icon: Icons.storefront,
            label: 'Tienda',
            onTap: () => context.push('/shop'),
          ),
          _NavTab(
            icon: Icons.person,
            label: 'Perfil',
            onTap: () => context.push('/profile'),
          ),
          const _NavTabHome(),
          _NavTab(
            icon: Icons.map_outlined,
            label: 'Misión',
            accent: hasEvent ? AppColors.cinnabar : null,
            badge: hasEvent,
            onTap: target == null
                ? () => showGameSnack(
                    context, 'Ningún mensajero está en camino.',
                    isError: true)
                : () => context.push(
                    hasEvent
                        ? '/event?m=${target.messenger.id}'
                        : '/mission?m=${target.messenger.id}'),
            dimmed: target == null,
          ),
          _NavTab(
            icon: Icons.account_tree_outlined,
            label: 'Caminos',
            onTap: () => context.push('/skills'),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool badge;
  final bool dimmed;
  final Color? accent;
  const _NavTab({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = false,
    this.dimmed = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = dimmed ? AppColors.inkMuted : (accent ?? AppColors.ochreDeep);
    return Expanded(
      child: Semantics(
        button: true,
        label: badge ? '$label, hay un evento esperando' : label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: () {
            AppFeedback.tap();
            onTap();
          },
          radius: 36,
          highlightColor: AppColors.ochreDeep.withValues(alpha: 0.08),
          splashColor: AppColors.ochreDeep.withValues(alpha: 0.12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Icon(icon, color: color, size: 24),
                    if (badge)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: AppColors.cinnabar,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.ink, width: 1.5),
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 3),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.ui(12,
                          color: dimmed
                              ? AppColors.inkMuted
                              : (accent == null
                                  ? AppColors.inkSoft
                                  : AppColors.ink))),
                ]),
          ),
        ),
      ),
    );
  }
}

// Tab HOME central — sello dorado más grande, siempre "presionado" (estás acá).
class _NavTabHome extends StatelessWidget {
  const _NavTabHome();

  @override
  Widget build(BuildContext context) {
    const size = 50.0;
    return Expanded(
      child: Semantics(
        label: 'Inicio, pantalla actual',
        selected: true,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: AppGradients.ochre,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2.5),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(0, 4),
                    blurRadius: 0),
              ],
            ),
            child: const Icon(Icons.home_rounded,
                size: 26, color: AppColors.ink),
          ),
          const SizedBox(height: 3),
          Text('Inicio',
              style: AppTextStyles.ui(12,
                  color: AppColors.ochreDeep, weight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
