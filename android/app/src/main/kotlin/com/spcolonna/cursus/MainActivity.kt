package com.spcolonna.cursus

import android.os.Build
import android.os.SystemClock
import android.provider.Settings
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
                } else if (call.method == "bootId") {
                    result.success(bootId())
                } else {
                    result.notImplemented()
                }
            }
    }

    /** Cuántas veces se encendió el teléfono: cambia al reiniciar, no al
     *  cambiar la hora. null si el sistema no lo da. */
    private fun bootId(): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return null
        return try {
            Settings.Global.getInt(contentResolver, Settings.Global.BOOT_COUNT).toString()
        } catch (e: Settings.SettingNotFoundException) {
            null
        }
    }
}
