import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/save_snapshot.dart';

/// Claves de SharedPreferences que son partida (viajan a la nube). Las
/// preferencias del dispositivo (sonido, avisos, consentimiento, topes de
/// anuncios) y los caches se quedan en el teléfono. Una clave nueva de
/// estado de juego tiene que sumarse acá (lo controla cloud_save_test).
const kCloudSaveKeys = <String>[
  'user_name',
  'onboarding_done',
  'messengers_v2',
  'active_missions_v2',
  'completed_missions',
  'guild_v1',
  'world_v1',
  'progression_v2',
  'weekly_v2',
  'retention_v2',
  'primeros_pasos_v1',
  'primeros_pasos_claimed_v1',
  'tooltip_home_seen_v1',
  'tooltip_event_seen_v1',
  'tooltip_shop_seen_v1',
  'iap_credited_v1',
];

/// Claves viejas o de respaldo que también son partida: al restaurar o
/// borrar se limpian para que ninguna migración las resucite.
const _kLegacyGameKeys = <String>[
  'user_id',
  'messenger_data',
  'active_mission',
  'cosmetic_titles_v1',
  'cosmetic_title_equipped_v1',
];

/// Lee y escribe la partida del dispositivo como un [SaveSnapshot], y
/// recuerda qué se sincronizó (eso no viaja).
class LocalSaveStore {
  static const _kUserId = 'user_id';
  static const _kDevice = 'cloud_device_id_v1';
  static const _kRevision = 'cloud_synced_revision_v1';
  static const _kHash = 'cloud_synced_hash_v1';
  static const _kSyncedAt = 'cloud_synced_at_v1';

  Future<SaveSnapshot> capture() async {
    final p = await SharedPreferences.getInstance();
    final data = <String, Object>{};
    for (final k in kCloudSaveKeys) {
      final v = p.get(k);
      if (v is String || v is bool || v is int) data[k] = v!;
      if (v is List) data[k] = v.cast<String>();
    }
    return SaveSnapshot(data: data, deviceId: await deviceId());
  }

  /// Reemplaza la partida local por [snapshot].
  Future<void> restore(SaveSnapshot snapshot) async {
    final p = await SharedPreferences.getInstance();
    // La sesión local no viaja: se conserva (o se crea, si se restaura desde
    // el login) para que el splash no vuelva a mandar al login.
    final userId = p.getString(_kUserId) ?? const Uuid().v4();
    await _removeGameKeys(p);
    await p.setString(_kUserId, userId);
    for (final e in snapshot.data.entries) {
      if (!kCloudSaveKeys.contains(e.key)) continue;
      final v = e.value;
      if (v is String) await p.setString(e.key, v);
      if (v is bool) await p.setBool(e.key, v);
      if (v is int) await p.setInt(e.key, v);
      if (v is List<String>) await p.setStringList(e.key, v);
    }
    await markSynced(snapshot.revision, snapshot.contentHash);
  }

  /// Borra la partida y el estado de sincronización (no las preferencias).
  Future<void> wipe() async {
    final p = await SharedPreferences.getInstance();
    await _removeGameKeys(p);
    for (final k in [_kRevision, _kHash, _kSyncedAt]) {
      await p.remove(k);
    }
  }

  Future<void> _removeGameKeys(SharedPreferences p) async {
    for (final k in p.getKeys().toList()) {
      final base = k.endsWith('_corrupt_backup')
          ? k.substring(0, k.length - '_corrupt_backup'.length)
          : k;
      if (kCloudSaveKeys.contains(base) || _kLegacyGameKeys.contains(base)) {
        await p.remove(k);
      }
    }
  }

  /// Identificador de este dispositivo (no es del jugador: no viaja).
  Future<String> deviceId() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString(_kDevice);
    if (id != null) return id;
    final created = const Uuid().v4();
    await p.setString(_kDevice, created);
    return created;
  }

  Future<int> syncedRevision() async =>
      (await SharedPreferences.getInstance()).getInt(_kRevision) ?? 0;

  Future<String?> syncedHash() async =>
      (await SharedPreferences.getInstance()).getString(_kHash);

  Future<DateTime?> syncedAt() async {
    final ms = (await SharedPreferences.getInstance()).getInt(_kSyncedAt);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markSynced(int revision, String hash) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kRevision, revision);
    await p.setString(_kHash, hash);
    await p.setInt(_kSyncedAt, DateTime.now().millisecondsSinceEpoch);
  }
}
