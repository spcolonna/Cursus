import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/cloud_widgets.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../infrastructure/cloud/firebase_cloud.dart';
import '../../widgets/art_image.dart';
import '../../widgets/living_sky.dart';
import '../../../l10n/app_localizations.dart';

/// Bienvenida: empezar sin cuenta (GDD §7) o recuperar una partida vinculada.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _enterAsGuest() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ref.read(authProvider.notifier).signInAsGuest();
      if (!mounted) return;

      if (result.isFirstLogin) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).loginError;
          _loading = false;
        });
      }
    }
  }

  /// "Ya tengo partida": entra con la cuenta vinculada y baja su partida.
  Future<void> _restore(AccountProvider provider) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final (outcome, conflict) =
          await ref.read(cloudSyncProvider).signInWith(provider);
      if (!mounted) return;
      if (outcome == LinkOutcome.canceled) {
        setState(() => _loading = false);
        return;
      }
      if (conflict != null) await resolveSaveConflict(context, ref, conflict);
      if (!mounted) return;
      reloadGameState(ref);
      context.go('/');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).loginRestoreError;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final providers = availableProviders();
    // Portada: el arte pintado a pantalla completa; abajo, sobre el velo de
    // tinta, la marca y la acción (texto chico nunca sobre la pintura clara).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Stack(fit: StackFit.expand, children: [
          const _TitleArt(),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.titleScrim),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
              child: Column(children: [
                const Spacer(),
                const BrandSeal(size: 72)
                    .animate(delay: 300.ms)
                    .scale(
                      begin: const Offset(1.6, 1.6),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 250.ms),
                const SizedBox(height: 14),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: BrandMark(
                    size: 44,
                    layout: BrandLayout.wordmark,
                    color: AppColors.onSky,
                    shadows: [
                      Shadow(color: AppColors.shadowHard, blurRadius: 12),
                    ],
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: 12),
                Container(width: 56, height: 2, color: AppColors.ochre)
                    .animate(delay: 750.ms)
                    .scaleX(begin: 0, duration: 500.ms),
                const SizedBox(height: 12),
                Text(
                  l.loginTagline,
                  style: AppTextStyles.proseItalic(
                      size: 17, color: AppColors.onSky),
                  textAlign: TextAlign.center,
                ).animate(delay: 850.ms).fadeIn(duration: 600.ms),
                const SizedBox(height: 32),
                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: AppColors.cinnabar, width: 2),
                    ),
                    child: Text(_error!,
                        style: AppTextStyles.ui(13, color: AppColors.cinnabar),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: GameButton(
                    label: l.loginStart,
                    icon: Icons.directions_walk,
                    onTap: _loading ? null : _enterAsGuest,
                    isLoading: _loading,
                  ),
                )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),
                for (final p in providers) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: GameButton(
                      label: providers.length == 1
                          ? l.loginHaveSave
                          : l.loginHaveSaveWith(
                              p == AccountProvider.apple ? 'Apple' : 'Google'),
                      icon: providerIcon(p),
                      fontSize: 14,
                      variant: GameButtonVariant.secondary,
                      onTap: _loading ? null : () => _restore(p),
                    ),
                  ).animate(delay: 1100.ms).fadeIn(duration: 500.ms),
                ],
                const SizedBox(height: 14),
                Text(
                  providers.isEmpty ? l.loginNoSignup : l.loginNoSignupLink,
                  style: AppTextStyles.ui(13, color: AppColors.onSky),
                  textAlign: TextAlign.center,
                ).animate(delay: 1200.ms).fadeIn(duration: 500.ms),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Arte de portada (`assets/art/title/title.jpg`, ver docs/CHATGPT_PROMPTS.md
/// Bloque 0) con un paneo lento. Mientras no esté, usa el camino del style
/// master; sin ese tampoco, el cielo vivo.
class _TitleArt extends StatefulWidget {
  const _TitleArt();

  @override
  State<_TitleArt> createState() => _TitleArtState();
}

class _TitleArtState extends State<_TitleArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pan = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _pan.stop();
    } else if (!_pan.isAnimating) {
      _pan.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const art = ArtImage(
      asset: 'assets/art/title/title.jpg',
      alignment: Alignment.topCenter,
      fallback: ArtImage(
        asset: 'assets/art/scenes/road.jpg',
        alignment: Alignment.topCenter,
        fallback: LivingSkyBackground(horizon: 0.8),
      ),
    );
    return AnimatedBuilder(
      animation: _pan,
      builder: (_, child) => Transform.scale(
        scale: 1.0 + 0.08 * Curves.easeInOut.transform(_pan.value),
        alignment: Alignment.topCenter,
        child: child,
      ),
      child: art,
    );
  }
}
