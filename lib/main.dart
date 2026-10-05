import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await container.read(sfxServiceProvider).init();
  final sfxOn = await container.read(playerProgressProvider).isSfxEnabled();
  container.read(sfxServiceProvider).setEnabled(sfxOn);
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
    );
  }
}
