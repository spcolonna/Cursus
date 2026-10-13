// Fase L1: ajustes remotos con defaults seguros, opt-out de analytics que
// llega a Firebase, y el pedido de actualizar cuando la versión es vieja.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/domain/entities/analytics.dart';
import 'package:the_messenger/domain/entities/remote_flags.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/infrastructure/analytics/analytics_service.dart';
import 'package:the_messenger/infrastructure/firebase/firebase_remote_flags.dart';
import 'package:the_messenger/infrastructure/firebase/firebase_setup.dart';
import 'package:the_messenger/presentation/providers/providers.dart';
import 'package:the_messenger/presentation/widgets/force_update_gate.dart';

class _ControlledSink implements AnalyticsSink, AnalyticsCollectionControl {
  final List<String> logged = [];
  bool? collection;
  @override
  Future<void> log(AnalyticsEvent event) async => logged.add(event.name);
  @override
  Future<void> setUserProperty(String name, String? value) async {}
  @override
  Future<void> setCollectionEnabled(bool enabled) async => collection = enabled;
}

void main() {
  group('RemoteFlags', () {
    test('sin valores remotos, los defaults', () {
      final f = RemoteFlags.fromValues({});
      expect(f.travelAdsPerDay, 4);
      expect(f.minSupportedVersion, isEmpty);
      expect(f.contentBundleVersion, 0);
      expect(f.requiresUpdate('1.0.0'), isFalse);
    });

    test('Remote Config manda todo como texto', () {
      final f = RemoteFlags.fromValues({
        RemoteFlags.kTravelAdsPerDay: '6',
        RemoteFlags.kMinSupportedVersion: ' 1.2.0 ',
        RemoteFlags.kContentBundleVersion: '3',
      });
      expect(f.travelAdsPerDay, 6);
      expect(f.minSupportedVersion, '1.2.0');
      expect(f.contentBundleVersion, 3);
    });

    test('un valor roto en la consola no rompe el juego', () {
      final f = RemoteFlags.fromValues({
        RemoteFlags.kTravelAdsPerDay: 'muchos',
        RemoteFlags.kContentBundleVersion: '-5',
      });
      expect(f.travelAdsPerDay, RemoteFlags.defaults.travelAdsPerDay);
      expect(f.contentBundleVersion, 0);
      expect(RemoteFlags.fromValues({RemoteFlags.kTravelAdsPerDay: '999'})
              .travelAdsPerDay,
          10,
          reason: 'se acota');
    });

    test('los defaults se pueden registrar en Remote Config', () {
      final map = RemoteFlags.defaults.toDefaultsMap();
      expect(RemoteFlags.fromValues(map).travelAdsPerDay,
          RemoteFlags.defaults.travelAdsPerDay);
      for (final v in map.values) {
        expect(v is String || v is int, isTrue);
      }
    });

    test('comparación de versiones', () {
      expect(compareVersions('1.0.0', '1.0.1'), lessThan(0));
      expect(compareVersions('1.10.0', '1.9.9'), greaterThan(0));
      expect(compareVersions('1.2', '1.2.0'), 0);
      expect(compareVersions('1.2.0+7', '1.2.0'), 0);
      const f = RemoteFlags(minSupportedVersion: '1.1.0');
      expect(f.requiresUpdate('1.0.9'), isTrue);
      expect(f.requiresUpdate('1.1.0'), isFalse);
      expect(f.requiresUpdate('2.0.0'), isFalse);
    });
  });

  group('Analytics', () {
    test('el opt-out también apaga lo que Firebase mide solo', () async {
      final sink = _ControlledSink();
      final a = AnalyticsService([sink]);
      a.enabled = false;
      await Future<void>.delayed(Duration.zero);
      expect(sink.collection, isFalse);
      await a.log(const AnalyticsEvent('tutorial_complete'));
      expect(sink.logged, isEmpty);
      a.enabled = true;
      await Future<void>.delayed(Duration.zero);
      expect(sink.collection, isTrue);
    });

    test('sin Firebase (tests) el juego usa los servicios locales', () {
      expect(firebaseReady, isFalse);
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(remoteFlagsSourceProvider), isA<DefaultRemoteFlags>());
      expect(c.read(remoteFlagsProvider).travelAdsPerDay, 4);
      expect(c.read(analyticsProvider).sinks.length, 2);
    });
  });

  group('Actualización obligatoria', () {
    Future<void> pump(WidgetTester tester, RemoteFlags flags, String version) =>
        tester.pumpWidget(ProviderScope(
          overrides: [
            remoteFlagsProvider.overrideWithValue(flags),
            appVersionProvider.overrideWith((_) async => version),
          ],
          child: const MaterialApp(
              home: ForceUpdateGate(child: Text('juego'))),
        ));

    testWidgets('versión al día: se juega', (tester) async {
      await pump(tester, const RemoteFlags(minSupportedVersion: '1.0.0'),
          '1.0.0');
      await tester.pumpAndSettle();
      expect(find.text('juego'), findsOneWidget);
    });

    testWidgets('versión vieja: pide actualizar', (tester) async {
      await pump(
          tester,
          const RemoteFlags(
              minSupportedVersion: '1.1.0',
              storeUrlIos: 'https://apps.apple.com/app/id1',
              storeUrlAndroid: 'https://play.google.com/store/apps'),
          '1.0.0');
      await tester.pumpAndSettle();
      expect(find.text('juego'), findsNothing);
      expect(find.text('Hay una versión nueva'), findsOneWidget);
      expect(find.text('Actualizar'), findsOneWidget);
    });
  });
}
