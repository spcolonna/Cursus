import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/character/character_select_screen.dart';
import 'presentation/screens/shop/shop_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/mission/mission_screen.dart';
import 'presentation/screens/mission/mission_result_screen.dart';
import 'presentation/screens/event/event_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/skills/skill_tree_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/achievements/achievements_screen.dart';
import 'domain/entities/entities.dart';
import 'presentation/theme/motion.dart';
import 'domain/usecases/usecases.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (_, state) => _fadePage(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (_, state) => _slidePage(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (_, state) => _fadePage(state, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/character',
      pageBuilder: (_, state) => _fadePage(state, const CharacterSelectScreen()),
    ),
    GoRoute(
      path: '/shop',
      pageBuilder: (_, state) => _slidePage(state, const ShopScreen(), fromBottom: true),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (_, state) => _fadePage(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/mission',
      pageBuilder: (_, state) => _slidePage(
          state, MissionScreen(messengerId: state.uri.queryParameters['m'])),
    ),
    GoRoute(
      path: '/event',
      pageBuilder: (_, state) => _slidePage(
          state, EventScreen(messengerId: state.uri.queryParameters['m']),
          fromBottom: true),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (_, state) => _slidePage(state, const ProfileScreen()),
    ),
    GoRoute(
      path: '/skills',
      pageBuilder: (_, state) => _slidePage(state, const SkillTreeScreen()),
    ),
    GoRoute(
      path: '/achievements',
      pageBuilder: (_, state) => _slidePage(state, const AchievementsScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (_, state) => _slidePage(state, const SettingsScreen()),
    ),
    GoRoute(
      path: '/mission-result',
      pageBuilder: (_, state) {
        final extra = state.extra as Map<String, dynamic>;
        return _fullScalePage(state, MissionResultScreen(
          mission: extra['mission'] as Mission,
          completion: extra['completion'] as MissionCompletion?,
        ));
      },
    ),
  ],
);

// ─── Transiciones ─────────────────────────────────────────────────────────────
// Duraciones y curvas de AppMotion. Con movimiento reducido (sistema o
// Ajustes) todas se vuelven un fade corto.

Duration _d(Duration d) =>
    AppMotion.userPrefersReduced.value ? AppMotion.fast : d;

Widget _reducedFade(Animation<double> animation, Widget child) =>
    FadeTransition(opacity: animation, child: child);

// Slide desde la derecha (o desde abajo). La pantalla de atrás se corre un
// poco hacia el otro lado: da sensación de profundidad sin distraer.
CustomTransitionPage<void> _slidePage(
    GoRouterState state,
    Widget child, {
      bool fromBottom = false,
    }) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _d(AppMotion.slow),
    reverseTransitionDuration: _d(AppMotion.base + AppMotion.stagger),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (AppMotion.reduced(context)) return _reducedFade(animation, child);
      final begin = fromBottom ? const Offset(0, 1) : const Offset(1, 0);
      final slideIn = Tween(begin: begin, end: Offset.zero).chain(
          CurveTween(curve: AppMotion.enter));
      final fade = Tween<double>(begin: 0, end: 1)
          .chain(CurveTween(curve: const Interval(0, 0.6)));
      final pushBack = Tween(
              begin: Offset.zero,
              end: fromBottom ? Offset.zero : const Offset(-0.25, 0))
          .chain(CurveTween(curve: AppMotion.enter));
      return SlideTransition(
        position: secondaryAnimation.drive(pushBack),
        child: SlideTransition(
          position: animation.drive(slideIn),
          child: FadeTransition(opacity: animation.drive(fade), child: child),
        ),
      );
    },
  );
}

// Fade
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _d(AppMotion.slow),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation.drive(CurveTween(curve: AppMotion.standard)),
        child: child,
      );
    },
  );
}

// Zoom + fade — para la pantalla de resultado de misión
CustomTransitionPage<void> _fullScalePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _d(AppMotion.slow + AppMotion.stagger * 2),
    transitionsBuilder: (context, animation, __, child) {
      if (AppMotion.reduced(context)) return _reducedFade(animation, child);
      final scale = Tween<double>(begin: 0.92, end: 1.0)
          .chain(CurveTween(curve: AppMotion.enter));
      final fade = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut));
      return ScaleTransition(
        scale: animation.drive(scale),
        child: FadeTransition(opacity: animation.drive(fade), child: child),
      );
    },
  );
}
