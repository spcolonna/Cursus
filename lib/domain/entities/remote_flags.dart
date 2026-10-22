// Ajustes que se pueden cambiar sin publicar una versión nueva (Firebase
// Remote Config). El juego siempre arranca con [RemoteFlags.defaults]: si no
// hay red o Firebase falla, se juega igual.

import 'economy.dart';

class RemoteFlags {
  /// Versión mínima soportada (semver `x.y.z`). Si la app es más vieja, se
  /// pide actualizar. Vacío = sin mínimo.
  final String minSupportedVersion;

  /// Adelantos de viaje con anuncio por día.
  final int travelAdsPerDay;

  /// Versión del paquete de contenido remoto (fase L5). 0 = el incluido.
  final int contentBundleVersion;

  /// Fichas de tienda, para el botón de actualizar. Vacío = sin botón.
  final String storeUrlIos;
  final String storeUrlAndroid;

  /// Economía (ver [EconomyTuning]): escala de la curva de XP en %, Denarios
  /// por minuto adelantado y escala del precio en Aureos de los manuales.
  final int xpCurvePercent;
  final int skipDenariosPerMinute;
  final int manualAureosPercent;

  const RemoteFlags({
    this.minSupportedVersion = '',
    this.travelAdsPerDay = 4,
    this.contentBundleVersion = 0,
    this.storeUrlIos = '',
    this.storeUrlAndroid = '',
    this.xpCurvePercent = 100,
    this.skipDenariosPerMinute = 2,
    this.manualAureosPercent = 100,
  });

  static const defaults = RemoteFlags();

  // Claves en la consola de Remote Config.
  static const kMinSupportedVersion = 'min_supported_version';
  static const kTravelAdsPerDay = 'travel_ads_per_day';
  static const kContentBundleVersion = 'content_bundle_version';
  static const kStoreUrlIos = 'store_url_ios';
  static const kStoreUrlAndroid = 'store_url_android';
  static const kXpCurvePercent = 'economy_xp_curve_percent';
  static const kSkipDenariosPerMinute = 'economy_skip_denarios_per_minute';
  static const kManualAureosPercent = 'economy_manual_aureos_percent';

  Map<String, Object> toDefaultsMap() => {
        kMinSupportedVersion: minSupportedVersion,
        kTravelAdsPerDay: travelAdsPerDay,
        kContentBundleVersion: contentBundleVersion,
        kStoreUrlIos: storeUrlIos,
        kStoreUrlAndroid: storeUrlAndroid,
        kXpCurvePercent: xpCurvePercent,
        kSkipDenariosPerMinute: skipDenariosPerMinute,
        kManualAureosPercent: manualAureosPercent,
      };

  /// Lee los valores crudos; lo que falte o venga mal cae al default, y los
  /// números se acotan para que un error en la consola no rompa el juego.
  factory RemoteFlags.fromValues(Map<String, Object?> v) {
    String str(String k, String d) => v[k] is String ? v[k] as String : d;
    int integer(String k, int d) {
      final x = v[k];
      if (x is int) return x;
      if (x is String) return int.tryParse(x) ?? d;
      return d;
    }

    return RemoteFlags(
      minSupportedVersion:
          str(kMinSupportedVersion, defaults.minSupportedVersion).trim(),
      travelAdsPerDay:
          integer(kTravelAdsPerDay, defaults.travelAdsPerDay).clamp(0, 10),
      contentBundleVersion: integer(
              kContentBundleVersion, defaults.contentBundleVersion)
          .clamp(0, 1 << 30),
      storeUrlIos: str(kStoreUrlIos, defaults.storeUrlIos).trim(),
      storeUrlAndroid: str(kStoreUrlAndroid, defaults.storeUrlAndroid).trim(),
      // Topes anchos pero sanos: ni regalar niveles ni volver el grind eterno.
      xpCurvePercent:
          integer(kXpCurvePercent, defaults.xpCurvePercent).clamp(50, 200),
      skipDenariosPerMinute:
          integer(kSkipDenariosPerMinute, defaults.skipDenariosPerMinute)
              .clamp(1, 5),
      manualAureosPercent:
          integer(kManualAureosPercent, defaults.manualAureosPercent)
              .clamp(50, 200),
    );
  }

  EconomyTuning get economy => EconomyTuning(
        xpCurvePercent: xpCurvePercent,
        skipDenariosPerMinute: skipDenariosPerMinute,
        manualAureosPercent: manualAureosPercent,
      );

  /// true si [appVersion] es más vieja que [minSupportedVersion].
  bool requiresUpdate(String appVersion) {
    if (minSupportedVersion.isEmpty) return false;
    return compareVersions(appVersion, minSupportedVersion) < 0;
  }
}

/// Compara semver `x.y.z` (ignora `+build` y sufijos). Lo que no parsea
/// cuenta como 0.
int compareVersions(String a, String b) {
  List<int> parts(String s) => s
      .split('+')
      .first
      .split('.')
      .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList();
  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}
