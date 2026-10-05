import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/feedback/feedback.dart';
import 'presentation/widgets/celebration_host.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Las fuentes van empaquetadas: su licencia OFL tiene que figurar en la app.
  LicenseRegistry.addLicense(() async* {
    for (final family in const ['Fredoka', 'Nunito']) {
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
  await sfx.init();
  sfx.setEnabled(await progress.isSfxEnabled());
  AppFeedback.configure(sfx: sfx, haptics: await progress.isHapticsEnabled());
  AppMotion.userPrefersReduced.value = await progress.isReduceMotion();
  await container.read(iapServiceProvider).init();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const TheMessengerApp(),
  ));
}

class TheMessengerApp extends StatelessWidget {
  const TheMessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The Messenger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
      // Logros y rangos nuevos se festejan sobre cualquier pantalla.
      builder: (context, child) =>
          CelebrationHost(router: appRouter, child: child ?? const SizedBox()),
    );
  }
}
