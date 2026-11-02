import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../../infrastructure/cloud/cloud_sync_service.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/cloud_widgets.dart';
import '../../../l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // La firma de Cursus suena cuando el sello termina de caer.
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) AppFeedback.motif();
    });
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Mientras se ve la animación, se compara la partida con la nube (una
    // restauración automática tiene que estar escrita antes de leer nada).
    final sync = ref.read(cloudSyncProvider);
    final results = await Future.wait<Object?>([
      Future.delayed(const Duration(milliseconds: 2200)),
      sync.start().timeout(const Duration(seconds: 6), onTimeout: () => null),
    ]);
    if (!mounted) return;
    final conflict = results[1] as SaveConflict?;
    if (conflict != null) {
      await resolveSaveConflict(context, ref, conflict);
      if (!mounted) return;
    }

    // Si la sesión todavía está cargando, se la espera: mandar al login a
    // un jugador que ya tiene partida es peor que un splash un poco más largo.
    Object? user;
    try {
      user = await ref
          .read(authProvider.future)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      user = null;
    }
    if (!mounted) return;
    context.go(user != null ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    // El mismo cal del launch screen nativo: no hay salto al abrir. La
    // pintura aparece recién en la portada (/login) o en el home.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandSeal(size: 140)
                  .animate()
                  .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      curve: Curves.elasticOut)
                  .fade(duration: 400.ms),

              const SizedBox(height: 24),

              const BrandMark(
                      size: 40,
                      layout: BrandLayout.wordmark,
                      color: AppColors.ink)
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              Text(AppLocalizations.of(context).splashSubtitle,
                      style: AppTextStyles.bodyMedium)
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 48),

              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.ochreDeep,
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(
                                delay: Duration(milliseconds: 900 + i * 150),
                                onPlay: (c) => c.repeat())
                            .scaleXY(
                                begin: 0.5,
                                end: 1.2,
                                duration: 600.ms,
                                curve: Curves.easeInOut)
                            .then()
                            .scaleXY(begin: 1.2, end: 0.5, duration: 600.ms)),
              ).animate(delay: 900.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
