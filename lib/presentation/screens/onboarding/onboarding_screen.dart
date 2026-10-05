import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

const _slides = [
  _Slide(
    icon: Icons.location_city,
    title: 'Roma, 50 a.C.',
    body: 'El Imperio Romano controla el mundo conocido.\nMillones de personas. Incontables rutas.\nY cada decisión que importa viaja en manos de alguien.',
    gradient: [Color(0xFF1A2A1E), Color(0xFF0D1810)],
    accentColor: Color(0xFF8BC34A),
  ),
  _Slide(
    icon: Icons.description,
    title: 'Vos sos ese alguien.',
    body: 'Un mensajero. El eslabón entre el poder y sus extremos.\nNadie sabe tu nombre. Nadie necesita saberlo.\nSolo importa que el mensaje llegue.',
    gradient: [Color(0xFF1A1A2E), Color(0xFF0D0D1E)],
    accentColor: Color(0xFFFFD93D),
  ),
  _Slide(
    icon: Icons.bolt,
    title: 'El camino no perdona.',
    body: 'Legionarios. Tormentas. Bandidos. Traidores.\nCada viaje es una prueba.\nCada decisión tiene consecuencias reales.',
    gradient: [Color(0xFF2E1A0D), Color(0xFF1E0D00)],
    accentColor: Color(0xFFFF8C00),
  ),
  _Slide(
    icon: Icons.shield,
    title: 'Ganá reputación. Crecé.',
    body: 'Con cada misión completada, tu mensajero se vuelve más hábil.\nVeloz. Sigiloso. Letal.\nEl Imperio tiene muchos mensajeros. Solo uno puede ser el mejor.',
    gradient: [Color(0xFF1E0D1E), Color(0xFF0D0010)],
    accentColor: Color(0xFFAB47BC),
  ),
  _Slide(
    icon: Icons.emoji_events,
    title: '¿Estás listo?',
    body: 'Tu primera misión te espera.\nEl Senado confía en vos.\nNo los decepciones.',
    gradient: [Color(0xFF0D1A2E), Color(0xFF060E1E)],
    accentColor: Color(0xFF42A5F5),
    isLast: true,
  ),
];

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  final List<Color> gradient;
  final Color accentColor;
  final bool isLast;

  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
    required this.gradient,
    required this.accentColor,
    this.isLast = false,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _animating = false;

  Future<void> _next() async {
    if (_animating) return;

    if (_currentIndex < _slides.length - 1) {
      setState(() { _animating = true; });
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() { _currentIndex++; _animating = false; });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(authProvider.notifier).markOnboardingDone();
    if (mounted) context.go('/character');
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _next,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: slide.gradient,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 20),
                    child: GestureDetector(
                      onTap: _finish,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text('Saltar',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.white60)),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon — Flutter Material, siempre renderiza
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: Container(
                          key: ValueKey('icon_$_currentIndex'),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slide.accentColor.withValues(alpha: 0.1),
                            border: Border.all(
                                color: slide.accentColor.withValues(alpha: 0.4),
                                width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: slide.accentColor.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 5)
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              slide.icon,
                              size: 56,
                              color: slide.accentColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Padding(
                          key: ValueKey('title_$_currentIndex'),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            slide.title,
                            style: AppTextStyles.fredoka(26,
                                color: slide.accentColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Body
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Padding(
                          key: ValueKey('body_$_currentIndex'),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            slide.body,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white70,
                              height: 1.8,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom area
                Padding(
                  padding: const EdgeInsets.only(
                      left: 28, right: 28, bottom: 48),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            _slides.length,
                                (i) => AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 300),
                              width: i == _currentIndex ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 3),
                              decoration: BoxDecoration(
                                color: i == _currentIndex
                                    ? slide.accentColor
                                    : Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )),
                      ),

                      const SizedBox(height: 28),

                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _next,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  slide.accentColor,
                                  slide.accentColor.withValues(alpha: 0.7)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.black38, width: 3),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                    slide.accentColor.withValues(alpha: 0.4),
                                    offset: const Offset(0, 6),
                                    blurRadius: 0)
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 4,
                                  left: 12,
                                  right: 12,
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color:
                                      Colors.white.withValues(alpha: 0.25),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    slide.isLast
                                        ? '¡COMENZAR!'
                                        : 'CONTINUAR →',
                                    style: AppTextStyles.fredoka(20,
                                        color: Colors.black.withValues(alpha: 
                                            0.8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        'Tocá en cualquier lugar para continuar',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white24, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}