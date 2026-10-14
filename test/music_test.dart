// La música (infrastructure/audio/music_service.dart) y quién la elige
// (widgets/music_director.dart): respeta el ajuste del jugador, funde al
// cambiar, baja en eventos y celebraciones, se calla en segundo plano. Y el
// motivo llega como sonido de aviso a las dos plataformas.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:the_messenger/infrastructure/audio/music_service.dart';
import 'package:the_messenger/infrastructure/audio/sfx_service.dart';
import 'package:the_messenger/infrastructure/notifications/notification_service.dart';
import 'package:the_messenger/presentation/theme/sky.dart';
import 'package:the_messenger/presentation/widgets/music_director.dart';
import 'helpers/localized_app.dart';

/// Un player de mentira: recuerda qué suena, a qué volumen y si está en pausa.
class _FakeChannel implements MusicChannel {
  String? asset;
  double volume = 0;
  bool paused = false;
  int plays = 0;

  bool get sounding => asset != null && !paused && volume > 0;

  @override
  Future<void> play(String a, double v) async {
    asset = a;
    volume = v;
    paused = false;
    plays++;
  }

  @override
  Future<void> setVolume(double v) async => volume = v;
  @override
  Future<void> pause() async => paused = true;
  @override
  Future<void> resume() async => paused = false;
  @override
  Future<void> stop() async => asset = null;
  @override
  Future<void> dispose() async {}
}

void main() {
  late List<_FakeChannel> channels;
  MusicService service({Duration fade = Duration.zero}) {
    channels = [];
    return MusicService(
      channelFactory: () {
        final c = _FakeChannel();
        channels.add(c);
        return c;
      },
      crossfade: fade,
      duckFade: fade,
    );
  }

  Iterable<_FakeChannel> sounding() => channels.where((c) => c.sounding);

  group('MusicService', () {
    test('toca el tema pedido, a su volumen, y no lo reinicia si se repite',
        () {
      final m = service()..play(MusicTrack.homeDay);
      expect(sounding().single.asset, MusicTrack.homeDay.asset);
      expect(sounding().single.volume, MusicService.defaultVolume);
      m.play(MusicTrack.homeDay);
      expect(channels.fold<int>(0, (n, c) => n + c.plays), 1);
    });

    test('cambiar de tema apaga el anterior', () {
      service()
        ..play(MusicTrack.homeDay)
        ..play(MusicTrack.travel);
      expect(sounding().single.asset, MusicTrack.travel.asset);
    });

    test('con la música apagada no suena nada, y al prenderla vuelve', () {
      final m = service()
        ..setEnabled(false)
        ..play(MusicTrack.homeNight);
      expect(sounding(), isEmpty);
      expect(channels.every((c) => c.plays == 0), isTrue);
      m.setEnabled(true);
      expect(sounding().single.asset, MusicTrack.homeNight.asset);
      m.setEnabled(false);
      expect(sounding(), isEmpty);
    });

    test('el volumen del jugador manda', () {
      final m = service()..play(MusicTrack.travel);
      m.setVolume(0.25);
      expect(sounding().single.volume, 0.25);
      m.setVolume(3);
      expect(m.volume, 1, reason: 'se acota a 0-1');
    });

    test('ducking: −8 dB mientras haya algún motivo', () {
      final m = service()..play(MusicTrack.travel);
      m.duck('event', true);
      m.duck('celebration', true);
      expect(sounding().single.volume,
          closeTo(MusicService.defaultVolume * MusicService.duckGain, 1e-9));
      m.duck('event', false);
      expect(m.ducked, isTrue);
      m.duck('celebration', false);
      expect(sounding().single.volume, MusicService.defaultVolume);
    });

    test('en segundo plano se pausa; un tema pedido ahí entra al volver', () {
      final m = service()..play(MusicTrack.homeDay);
      m.pauseForBackground();
      expect(sounding(), isEmpty);
      m.play(MusicTrack.homeDusk);
      expect(sounding(), isEmpty);
      m.resumeFromBackground();
      expect(sounding().single.asset, MusicTrack.homeDusk.asset);
    });

    testWidgets('el cambio de tema es un fundido cruzado de 1,5 s',
        (tester) async {
      final m = service(fade: const Duration(milliseconds: 1500))
        ..play(MusicTrack.homeDay);
      await tester.pump(const Duration(milliseconds: 1600));
      m.play(MusicTrack.travel);
      await tester.pump(const Duration(milliseconds: 750));
      // A mitad de camino suenan los dos, cada uno a medias.
      expect(sounding().length, 2);
      for (final c in sounding()) {
        expect(c.volume, inExclusiveRange(0.1, 0.5));
      }
      await tester.pump(const Duration(milliseconds: 900));
      expect(sounding().single.asset, MusicTrack.travel.asset);
      expect(sounding().single.volume, MusicService.defaultVolume);
    });
  });

  group('MusicDirector: qué suena en cada pantalla', () {
    test('silencio en el arranque y el onboarding', () {
      for (final p in ['/', '/login', '/onboarding', '/character']) {
        expect(musicTrackFor(p, phase: SkyPhase.day), isNull, reason: p);
      }
    });

    test('el home y los menús siguen al cielo', () {
      expect(musicTrackFor('/home', phase: SkyPhase.dawn), MusicTrack.homeDawn);
      expect(musicTrackFor('/home', phase: SkyPhase.day), MusicTrack.homeDay);
      expect(musicTrackFor('/shop', phase: SkyPhase.dusk), MusicTrack.homeDusk);
      expect(musicTrackFor('/profile', phase: SkyPhase.night),
          MusicTrack.homeNight);
    });

    test('en misión: el camino, o el tema del arco en un capítulo', () {
      expect(musicTrackFor('/mission', phase: SkyPhase.day), MusicTrack.travel);
      expect(
          musicTrackFor('/event', phase: SkyPhase.day, arcId: 'arc_claudius'),
          MusicTrack.arcClaudius);
      expect(
          musicTrackFor('/mission', phase: SkyPhase.day, arcId: 'arc_lucius'),
          MusicTrack.arcLucius);
      expect(musicTrackFor('/mission', phase: SkyPhase.day, arcId: 'arc_nuevo'),
          MusicTrack.travel,
          reason: 'un arco sin tema propio usa el del camino');
    });

    test('el resultado sigue con el tema de la misión entregada', () {
      expect(
          musicTrackFor('/mission-result',
              phase: SkyPhase.day, previous: MusicTrack.arcLucius),
          MusicTrack.arcLucius);
      expect(
          musicTrackFor('/mission-result',
              phase: SkyPhase.day, previous: MusicTrack.homeDay),
          MusicTrack.travel);
    });

    testWidgets('lee la pantalla de arriba aunque se haya entrado con push',
        (tester) async {
      // go_router deja currentConfiguration.uri en /home bajo un push: el
      // director (y CelebrationHost) tienen que ver /event.
      final router = GoRouter(initialLocation: '/home', routes: [
        for (final p in ['/home', '/event'])
          GoRoute(path: p, builder: (_, __) => const SizedBox()),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(locale: kTestLocale,
      supportedLocales: kTestSupportedLocales,
      localizationsDelegates: kTestLocalizationsDelegates,
      routerConfig: router));
      router.push('/event?m=abc');
      await tester.pumpAndSettle();
      expect(visibleRouteUri(router).path, '/event');
      expect(visibleRouteUri(router).queryParameters['m'], 'abc');
      router.pop();
      await tester.pumpAndSettle();
      expect(visibleRouteUri(router).path, '/home');
    });

    test('la música baja solo mientras se decide un evento', () {
      expect(musicDucksOn('/event'), isTrue);
      expect(musicDucksOn('/mission'), isFalse);
      expect(musicDucksOn('/home'), isFalse);
    });
  });

  group('Archivos', () {
    test('cada tema y el motivo tienen su archivo', () {
      for (final t in MusicTrack.values) {
        expect(File('assets/${t.asset}').existsSync(), isTrue, reason: t.asset);
      }
      expect(File('assets/${Sfx.motif.asset}').existsSync(), isTrue);
    });

    test('el motivo es el sonido de aviso en Android y en iOS', () {
      expect(
          File('android/app/src/main/res/raw/$notificationSoundAndroid.wav')
              .existsSync(),
          isTrue);
      expect(
          File('android/app/src/main/res/raw/keep.xml')
              .readAsStringSync()
              .contains('@raw/$notificationSoundAndroid'),
          isTrue,
          reason: 'el shrinker de release no lo tiene que borrar');
      expect(File('ios/Runner/$notificationSoundIos').existsSync(), isTrue);
      final pbx =
          File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
      expect('$notificationSoundIos in Resources'.allMatches(pbx).length, 2,
          reason: 'el .caf tiene que ir al bundle de Runner');
    });
  });
}
