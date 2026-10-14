// El cielo vivo (theme/sky.dart): continuo, fiel a sus cuatro cielos,
// legible y con override de debug.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/presentation/screens/login/login_screen.dart';
import 'package:the_messenger/presentation/providers/providers.dart';
import 'package:the_messenger/presentation/theme/app_theme.dart';
import 'package:the_messenger/presentation/theme/sky.dart';
import 'helpers/localized_app.dart';

int _channelDelta(Color a, Color b) => [
      (a.r - b.r).abs(),
      (a.g - b.g).abs(),
      (a.b - b.b).abs(),
    ].map((d) => (d * 255).round()).reduce((x, y) => x > y ? x : y);

void main() {
  test('cada fase cae en su franja horaria', () {
    expect(SkyPalette.at(6).phase, SkyPhase.dawn);
    expect(SkyPalette.at(13).phase, SkyPhase.day);
    expect(SkyPalette.at(19).phase, SkyPhase.dusk);
    expect(SkyPalette.at(23).phase, SkyPhase.night);
    expect(SkyPalette.at(3).phase, SkyPhase.night);
    expect(SkyPalette.at(24 + 13).phase, SkyPhase.day, reason: 'da la vuelta');
  });

  test('en sus horas puras, el cielo es exactamente su keyframe', () {
    for (final (h, k) in [
      (6.5, SkyKeyframe.dawn),
      (13.0, SkyKeyframe.day),
      (19.25, SkyKeyframe.dusk),
      (1.0, SkyKeyframe.night),
    ]) {
      final p = SkyPalette.at(h);
      expect(
          [p.top, p.mid, p.horizon, p.land], [k.top, k.mid, k.horizon, k.land],
          reason: 'hora $h');
    }
  });

  test('el cielo es continuo: de un minuto al siguiente no salta', () {
    var worst = 0;
    var prev = SkyPalette.at(0);
    for (var m = 1; m <= 24 * 60; m++) {
      final p = SkyPalette.at(m / 60);
      for (final (a, b) in [
        (prev.top, p.top),
        (prev.mid, p.mid),
        (prev.horizon, p.horizon),
        (prev.land, p.land),
      ]) {
        final d = _channelDelta(a, b);
        if (d > worst) worst = d;
      }
      prev = p;
    }
    expect(worst, lessThanOrEqualTo(6), reason: 'salto máximo por minuto');
  });

  test('los pesos de cada cielo suman 1 y las estrellas solo salen de noche',
      () {
    for (var m = 0; m < 24 * 60; m += 15) {
      final p = SkyPalette.at(m / 60);
      expect(p.dawn + p.day + p.dusk + p.night, closeTo(1, 1e-9));
    }
    expect(SkyPalette.at(13).stars, 0);
    expect(SkyPalette.at(23).stars, 1);
  });

  test('el sol de día, la luna de noche, y más alto al mediodía', () {
    expect(SkyPalette.at(13).isMoon, isFalse);
    expect(SkyPalette.at(23).isMoon, isTrue);
    expect(SkyPalette.at(13).celestialAltitude,
        greaterThan(SkyPalette.at(7).celestialAltitude));
  });

  test('el título sobre el cielo se lee a toda hora (≥3:1, título grande)', () {
    for (var m = 0; m < 24 * 60; m += 10) {
      final p = SkyPalette.at(m / 60);
      expect(
          SkyPalette.contrastOn(p.top, p.titleColor), greaterThanOrEqualTo(3.0),
          reason: 'minuto $m');
    }
  });

  test('con el velo scrimSky, la cal se lee sobre cualquier cielo (≥3:1)', () {
    for (var m = 0; m < 24 * 60; m += 10) {
      final p = SkyPalette.at(m / 60);
      for (final sky in [p.top, p.mid]) {
        final veiled = Color.alphaBlend(AppColors.scrimSky, sky);
        expect(SkyPalette.contrastOn(veiled, AppColors.onSky),
            greaterThanOrEqualTo(3.0),
            reason: 'minuto $m');
      }
    }
  });

  test('las monedas del home se leen sobre su chip opaco', () {
    for (final c in [
      AppColors.egyptianBlue,
      AppColors.ochreDeep,
      AppColors.ink
    ]) {
      final bg = paperTint(c, amount: 0.1, paper: AppColors.paperHigh);
      expect(SkyPalette.contrastOn(bg, c), greaterThanOrEqualTo(4.5),
          reason: '$c');
    }
  });

  test('el override de debug manda sobre el reloj', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(debugSkyHourProvider.notifier).state = 23;
    expect(container.read(skyHourProvider), 23);
    expect(container.read(skyPaletteProvider).phase, SkyPhase.night);
    container.read(debugSkyHourProvider.notifier).state = 13;
    expect(container.read(skyPaletteProvider).phase, SkyPhase.day);
  });

  for (final hour in [6.5, 13.0, 19.25, 23.0]) {
    testWidgets('el login entra en pantalla chica a las $hour h',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [debugSkyHourProvider.overrideWith((_) => hour)],
        child: const MaterialApp(locale: kTestLocale,
      supportedLocales: kTestSupportedLocales,
      localizationsDelegates: kTestLocalizationsDelegates,
      home: LoginScreen()),
      ));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      expect(find.text('EMPEZAR'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
