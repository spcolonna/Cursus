import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/living_sky.dart';

/// Entrada por modo invitado — sin credenciales dummy (GDD §7).
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
          _error = 'No se pudo entrar. Probá de nuevo.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Arriba, el cielo de la hora real con la marca; abajo, la hoja de papel
    // con todo lo que se lee (texto chico nunca sobre el cielo).
    final sky = ref.watch(skyPaletteProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: sky.statusBar,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: Column(children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              const LivingSkyBackground(horizon: 0.8),
              SafeArea(
                bottom: false,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const BrandSeal(size: 150).animate().scale(
                            begin: const Offset(0.5, 0.5),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 18),
                      BrandMark(
                              size: 40,
                              layout: BrandLayout.wordmark,
                              color: sky.titleColor,
                          shadows: sky.titleHalo)
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppGradients.paper,
              border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    'Roma, 50 a.C. El correo te espera.',
                    style: AppTextStyles.prose(size: 17),
                    textAlign: TextAlign.center,
                  ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
                  const SizedBox(height: 20),
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: paperTint(AppColors.cinnabar, amount: 0.06),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(color: AppColors.cinnabar, width: 2),
                      ),
                      child: Text(_error!,
                          style:
                              AppTextStyles.ui(13, color: AppColors.cinnabar),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: GameButton(
                      label: 'ENTRAR COMO INVITADO',
                      icon: Icons.directions_walk,
                      onTap: _loading ? null : _enterAsGuest,
                      isLoading: _loading,
                    ),
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 14),
                  Text(
                    'Sin cuenta. Tus partidas se guardan en este dispositivo.\nMás adelante vas a poder sincronizar en la nube.',
                    style: AppTextStyles.ui(13, color: AppColors.inkSoft),
                    textAlign: TextAlign.center,
                  ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
