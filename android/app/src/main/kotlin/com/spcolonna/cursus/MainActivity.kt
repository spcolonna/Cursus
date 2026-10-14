package com.spcolonna.cursus

import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Reloj monotónico (sigue con el teléfono dormido, no se puede
        // cambiar a mano): lo usa TrustedTimeService para el reloj del juego.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cursus/clock")
            .setMethodCallHandler { call, result ->
                if (call.method == "elapsedRealtime") {
                    result.success(SystemClock.elapsedRealtime())
                } else {
                    result.notImplemented()
                }
            }
    }
}
