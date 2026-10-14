// La marca: el nombre viejo no vuelve y el ícono sale del mismo dibujo.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/presentation/widgets/brand.dart';
import 'helpers/localized_app.dart';

void main() {
  test('el nombre viejo no aparece en el código ni en la config visible', () {
    final old = RegExp(r'The Messenger|THE MESSENGER|theMessenger');
    final files = [
      ...Directory('lib').listSync(recursive: true).whereType<File>(),
      File('ios/Runner/Info.plist'),
      File('ios/Runner.xcodeproj/project.pbxproj'),
      File('android/app/build.gradle.kts'),
      File('android/app/src/main/AndroidManifest.xml'),
    ].where((f) => f.path.endsWith('.dart') || !f.path.contains('lib/'));
    for (final f in files) {
      expect(old.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });

  test('el bundle ID es el de Cursus en iOS y Android', () {
    expect(File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync(),
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.spcolonna.cursus;'));
    expect(File('android/app/build.gradle.kts').readAsStringSync(),
        contains('applicationId = "com.spcolonna.cursus"'));
  });

  test('los PNG de la marca existen (tool/gen_icon_test.dart)', () {
    for (final p in [
      'assets/icon/icon.png',
      'assets/icon/icon_foreground.png',
      'assets/icon/splash_seal.png',
    ]) {
      expect(File(p).existsSync(), isTrue, reason: p);
    }
  });

  testWidgets('BrandMark se dibuja en sus dos disposiciones', (tester) async {
    for (final layout in BrandLayout.values) {
      await tester.pumpWidget(MaterialApp(
        locale: kTestLocale,
      supportedLocales: kTestSupportedLocales,
      localizationsDelegates: kTestLocalizationsDelegates,
      home: Scaffold(
          body: Center(child: BrandMark(layout: layout, tagline: true)),
        ),
      ));
      expect(find.text('CURSUS'), findsOneWidget);
      expect(find.byType(BrandSeal),
          layout == BrandLayout.wordmark ? findsNothing : findsOneWidget);
      expect(find.text('CARTAS DE ROMA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
