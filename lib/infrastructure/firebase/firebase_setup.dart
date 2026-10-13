import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// Proyecto según el build, por la config nativa de cada uno:
// debug → cursus-dev, release y profile → cursus-prod
// (`ios/config/<env>/GoogleService-Info.plist`,
// `android/app/src/<buildType>/google-services.json`).

/// Firebase quedó inicializado. Si es false (sin red no importa: falla solo
/// por config rota o en tests), el juego sigue con los servicios locales.
bool firebaseReady = false;

/// Inicializa Firebase y Crashlytics. Nunca tira: el juego funciona sin
/// backend.
Future<void> initFirebase() async {
  try {
    final app = await Firebase.initializeApp();
    firebaseReady = true;
    if (kDebugMode) debugPrint('Firebase: ${app.options.projectId}');
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    return;
  }

  final crashlytics = FirebaseCrashlytics.instance;
  // En debug los errores ya se ven en la consola: no ensucian el tablero.
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    crashlytics.recordFlutterError(details);
    previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };
}
