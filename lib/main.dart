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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // Sesiones para la retención: abrir y volver de segundo plano.
    final sessions = ref.read(trackSessionUseCaseProvider);
    sessions.open();
    _lifecycle = AppLifecycleListener(
      onResume: () => sessions.open(),
      onPause: () => sessions.pause(),
    );
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
      // Logros y rangos nuevos se festejan sobre cualquier pantalla.
      // La barra de estado va en tinta sobre el papel; las pantallas con
      // cielo (home, login) la cambian con su propio AnnotatedRegion.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: CelebrationHost(
            router: appRouter, child: child ?? const SizedBox()),
      ),
    );
  }
}
