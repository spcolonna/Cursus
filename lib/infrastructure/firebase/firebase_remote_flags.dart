import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/remote_flags.dart';
import '../../domain/repositories/repositories.dart';

/// Remote Config sin bloquear el arranque: [init] activa lo que se bajó en
/// la sesión anterior (ya está en disco) y [refresh] baja valores nuevos en
/// segundo plano, que entran en la próxima apertura. Así un cambio en la
/// consola nunca cambia las reglas en medio de una partida.
class FirebaseRemoteFlags implements RemoteFlagsSource {
  RemoteFlags _current = RemoteFlags.defaults;

  @override
  RemoteFlags get current => _current;

  Future<void> init() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 8),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 6),
      ));
      await rc.setDefaults(RemoteFlags.defaults.toDefaultsMap());
      await rc.activate();
      _current = _read(rc);
    } catch (e) {
      debugPrint('Remote Config init failed: $e');
    }
  }

  @override
  Future<void> refresh() async {
    try {
      await FirebaseRemoteConfig.instance.fetch();
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }
  }

  RemoteFlags _read(FirebaseRemoteConfig rc) => RemoteFlags.fromValues({
        for (final key in RemoteFlags.defaults.toDefaultsMap().keys)
          key: rc.getValue(key).asString(),
      });
}

/// Sin Firebase (tests o config rota): siempre los defaults.
class DefaultRemoteFlags implements RemoteFlagsSource {
  @override
  final RemoteFlags current;
  const DefaultRemoteFlags([this.current = RemoteFlags.defaults]);
  @override
  Future<void> refresh() async {}
}
