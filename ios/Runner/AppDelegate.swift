import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Necesario para que las notificaciones locales programadas se muestren
    // también con la app en primer plano (iOS 10+).
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate =
        self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Reloj monotónico (incluye el tiempo dormido y no se puede cambiar a
    // mano): lo usa TrustedTimeService para el reloj del juego.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CursusClock") {
      let channel = FlutterMethodChannel(
        name: "cursus/clock", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        if call.method == "elapsedRealtime" {
          result(Int(clock_gettime_nsec_np(CLOCK_MONOTONIC) / 1_000_000))
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}
