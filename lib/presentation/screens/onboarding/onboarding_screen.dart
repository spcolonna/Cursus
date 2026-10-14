import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

// Cinco láminas, una idea por lámina. Todas con la identidad del juego (navy,
// oro, pergamino): antes cada una tenía su propio color y la primera era verde.
List<_Slide> _buildSlides(AppLocalizations l) => [
      _Slide(
          icon: Icons.account_balance,
          title: l.onboardingTitle1,
          body: l.onboardingBody1),
      _Slide(
          icon: Icons.mail,
          title: l.onboardingTitle2,
          body: l.onboardingBody2),
      _Slide(
          icon: Icons.thunderstorm,
          title: l.onboardingTitle3,
          body: l.onboardingBody3),
      _Slide(
          icon: Icons.schedule,
          title: l.onboardingTitle4,
          body: l.onboardingBody4),
      _Slide(
          icon: Icons.flag,
          title: l.onboardingTitle5,
          body: l.onboardingBody5,
          isLast: true),
    ];

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  final bool isLast;

  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
    this.isLast = false,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _currentIndex = 0;

  List<_Slide> get _slides => _buildSlides(AppLocalizations.of(context));

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _slides.length - 1) {
      AppFeedback.tap();
      _pages.nextPage(
          duration: AppMotion.of(context, AppMotion.slow),
          curve: AppMotion.standard);
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

    return GradientScaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, AppSpacing.lg, 0),
              child: IntrinsicWidth(
                child: GameButton(
                label: AppLocalizations.of(context).onboardingSkip,
                fontSize: 13,
                variant: GameButtonVariant.ghost,
                onTap: _finish,
              )),
            ),
          ),

          // Las láminas se deslizan con el dedo o con el botón.
          Expanded(
            child: GestureDetector(
              onTap: _next,
              behavior: HitTestBehavior.opaque,
              child: PageView.builder(
                controller: _pages,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
            child: Column(children: [
              Semantics(
                label: AppLocalizations.of(context)
                    .onboardingSlideSemantics(_currentIndex + 1, _slides.length),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: AppMotion.of(context, AppMotion.base),
                      curve: AppMotion.enter,
                      width: i == _currentIndex ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _currentIndex
                            ? AppColors.ochreDeep
                            : AppColors.paperLine,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: GameButton(
                  label: slide.isLast
                      ? AppLocalizations.of(context).onboardingStart
                      : AppLocalizations.of(context).onboardingNext,
                  icon: slide.isLast ? Icons.flag : Icons.arrow_forward,
                  fontSize: 18,
                  onTap: _next,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Medallón dorado: el mismo lenguaje que el sello de las notas.
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.ochre,
            border: Border.all(color: AppColors.ink, width: 4),
            boxShadow: [
              BoxShadow(
                  color: AppColors.ochreDeep.withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: 4),
              const BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(0, 6),
                  blurRadius: 0),
            ],
          ),
          child: Icon(slide.icon, size: 56, color: AppColors.ink),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            slide.title,
            style: AppTextStyles.heading(28,
                color: AppColors.ochreDeep),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            slide.body,
            style: AppTextStyles.prose(size: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
