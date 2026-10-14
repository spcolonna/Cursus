import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/feedback/feedback.dart';
import 'presentation/widgets/art_image.dart';
import 'presentation/widgets/celebration_host.dart';
import 'presentation/widgets/music_director.dart';
import 'presentation/widgets/force_update_gate.dart';
import 'infrastructure/firebase/firebase_setup.dart';
import 'infrastructure/firebase/firebase_remote_flags.dart';
import 'infrastructure/time/trusted_time_service.dart';

/// Reloj del juego: anclado al servidor, inmune a cambiar la hora del teléfono.
final _clock = TrustedTimeService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Crashes, analytics y ajustes remotos. Sin Firebase el juego sigue igual.
  await initFirebase();
  // Hora del juego antes de leer cualquier timer; el servidor la corrige
  // en segundo plano.
  await _clock.restore();
  unawaited(_clock.syncWithServer());

  // Las fuentes van empaquetadas: su licencia OFL tiene que figurar en la app.
  LicenseRegistry.addLicense(() async* {
    for (final family in const ['Marcellus', 'Figtree', 'Literata']) {
      final text = await rootBundle.loadString('assets/fonts/OFL-$family.txt');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final container = ProviderContainer();
  final flags = container.read(remoteFlagsSourceProvider);
  if (flags is FirebaseRemoteFlags) await flags.init();
  unawaited(flags.refresh());
  final scheduler = container.read(notificationSchedulerProvider);
  await scheduler.init();
  // Tocar un aviso deja la ruta pendiente; el Home la abre cuando está listo.
  void openFromNotification(String? payload) {
    final route = routeForNotification(payload);
    if (route != null) {
      container.read(pendingNotificationRouteProvider.notifier).state = route;
    }
  }

  scheduler.onTap = openFromNotification;
  openFromNotification(await scheduler.launchPayload());
  final sfx = container.read(sfxServiceProvider);
  final progress = container.read(playerProgressProvider);
  await Future.wait([sfx.init(), ArtCatalog.load()]);
  sfx.setEnabled(await progress.isSfxEnabled());
  AppFeedback.configure(sfx: sfx, haptics: await progress.isHapticsEnabled());
  final music = container.read(musicServiceProvider)
    ..setEnabled(await progress.isMusicEnabled());
  final volume = await progress.musicVolume();
  if (volume != null) music.setVolume(volume);
  AppMotion.userPrefersReduced.value = await progress.isReduceMotion();
  await container.read(iapServiceProvider).init();
  container.read(analyticsProvider).enabled =
      await progress.isAnalyticsEnabled();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const TheMessengerApp(),
  ));
}

class TheMessengerApp extends ConsumerStatefulWidget {
  const TheMessengerApp({super.key});

  @override
  ConsumerState<TheMessengerApp> createState() => _TheMessengerAppState();
}

class _TheMessengerAppState extends ConsumerState<TheMessengerApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Sesiones para la retención: abrir y volver de segundo plano. La
    // música se calla en segundo plano (en Android seguiría sonando).
    final sessions = ref.read(trackSessionUseCaseProvider);
    final music = ref.read(musicServiceProvider);
    sessions.open();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _resyncClock();
        sessions.open();
        music.resumeFromBackground();
      },
      onPause: () {
        sessions.pause();
        music.pauseForBackground();
        // Al salir, la partida sube ya (el teléfono puede cerrar la app).
        ref.read(cloudSyncProvider).flush();
      },
    );
  }

  /// Al volver, la hora del juego se reestima (el teléfono pudo dormir o
  /// cambiar de hora) y las misiones se recalculan con ella.
  Future<void> _resyncClock() async {
    await _clock.restore();
    if (mounted) ref.invalidate(homeProvider);
    if (await _clock.syncWithServer() && mounted) ref.invalidate(homeProvider);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cursus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
      // Logros y rangos nuevos se festejan sobre cualquier pantalla, y la
      // música sigue a la pantalla y a la hora.
      // La barra de estado va en tinta sobre el papel; las pantallas con
      // cielo (home, login) la cambian con su propio AnnotatedRegion.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MusicDirector(
          router: appRouter,
          child: ForceUpdateGate(
            child: CelebrationHost(
                router: appRouter, child: child ?? const SizedBox()),
          ),
        ),
      ),
    );
  }
}
