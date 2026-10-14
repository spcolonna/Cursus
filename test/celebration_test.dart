// Celebraciones: el aviso de logro aparece, se va solo y nunca tapa un evento.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:the_messenger/data/progression_content.dart';
import 'package:the_messenger/domain/entities/progression.dart';
import 'package:the_messenger/domain/usecases/progression_usecases.dart';
import 'package:the_messenger/presentation/providers/providers.dart';
import 'package:the_messenger/presentation/widgets/celebration_host.dart';
import 'helpers/localized_app.dart';

GoRouter _router() => GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Text('inicio')),
      GoRoute(path: '/home', builder: (_, __) => const Text('home')),
      GoRoute(path: '/event', builder: (_, __) => const Text('evento')),
      GoRoute(path: '/achievements', builder: (_, __) => const Text('logros')),
    ], initialLocation: '/home');

Future<ProviderContainer> _pump(WidgetTester t, GoRouter router) async {
  final container = ProviderContainer();
  await t.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      locale: kTestLocale,
      supportedLocales: kTestSupportedLocales,
      localizationsDelegates: kTestLocalizationsDelegates,
      routerConfig: router,
      builder: (_, child) => CelebrationHost(router: router, child: child!),
    ),
  ));
  await t.pumpAndSettle();
  return container;
}

ProgressionUpdate _update({int? rank}) => ProgressionUpdate(
      state: const ProgressionState(),
      unlocked: [allAchievements.first],
      rankReached: rank,
    );

void main() {
  testWidgets('el logro aparece y se va solo', (t) async {
    final c = await _pump(t, _router());
    c.read(celebrationQueueProvider.notifier).enqueue(_update());
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text(allAchievements.first.name), findsOneWidget);

    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
    expect(find.text(allAchievements.first.name), findsNothing);
    expect(c.read(celebrationQueueProvider), isEmpty);
  });

  testWidgets('en un evento espera; al salir, celebra', (t) async {
    final router = _router();
    final c = await _pump(t, router);
    router.go('/event');
    await t.pumpAndSettle();

    c.read(celebrationQueueProvider.notifier).enqueue(_update());
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text(allAchievements.first.name), findsNothing);

    router.go('/home');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text(allAchievements.first.name), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
  });

  testWidgets('el rango va primero y se cierra con SEGUIR', (t) async {
    final c = await _pump(t, _router());
    c.read(celebrationQueueProvider.notifier).enqueue(_update(rank: 2));
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(find.text('¡NUEVO RANGO!'), findsOneWidget);
    expect(find.text('Mensajero'), findsOneWidget);

    await t.tap(find.text('SEGUIR'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('¡NUEVO RANGO!'), findsNothing);
    expect(find.text(allAchievements.first.name), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
  });
}
