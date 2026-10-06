import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/event_scene.dart';
import '../../../domain/entities/entities.dart';

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
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(fit: StackFit.expand, children: [
        // El camino a la hora real; en la Fase I3 pasa a ser el cielo vivo.
        const EventScene(category: EventCategory.road),
        const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.coverScrim)),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const BrandSeal(size: 180)
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: 20),
                  const BrandMark(size: 40, layout: BrandLayout.wordmark)
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 6),
                  Text(
                    'Roma, 50 a.C. El correo te espera.',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.parchment),
                    textAlign: TextAlign.center,
                  ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
                  const SizedBox(height: 48),
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.5)),
                      ),
                      child: Text(_error!,
                          style: AppTextStyles.fredoka(13),
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
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
