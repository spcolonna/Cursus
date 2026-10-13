import 'dart:convert';

// ═════════════════════════════════════════════════════════════════════════════
// SaveSnapshot: toda la partida en un solo paquete, para subirla a la nube y
// restaurarla en otro dispositivo. Las claves y sus valores son los mismos
// que guarda el dispositivo (String, bool, int o lista de String).
// ═════════════════════════════════════════════════════════════════════════════

/// Versión del formato del paquete. Al cambiar el esquema de una entidad
/// persistida, subila y agregá el paso en [migrateSnapshotData].
const kSaveSchemaVersion = 1;

/// Lo que se muestra al elegir entre dos partidas.
class SaveSummary {
  final String name;
  final int completedMissions;
  final DateTime? savedAt;
  const SaveSummary(
      {required this.name, required this.completedMissions, this.savedAt});
}

class SaveSnapshot {
  final int schemaVersion;
  final Map<String, Object> data;

  /// Cuántas veces se subió esta partida (la nube la incrementa).
  final int revision;

  /// El dispositivo que la subió por última vez.
  final String deviceId;
  final DateTime? savedAt;

  const SaveSnapshot({
    required this.data,
    this.schemaVersion = kSaveSchemaVersion,
    this.revision = 0,
    this.deviceId = '',
    this.savedAt,
  });

  /// Partida recién instalada: sin personaje ni misiones.
  bool get isFresh =>
      data['onboarding_done'] != true &&
      (data['completed_missions'] as List?)?.isNotEmpty != true;

  SaveSummary get summary => SaveSummary(
        name: (data['user_name'] as String?) ?? 'Mensajero',
        completedMissions: (data['completed_missions'] as List?)?.length ?? 0,
        savedAt: savedAt,
      );

  /// Huella del contenido: si no cambió, no se vuelve a subir.
  String get contentHash {
    final keys = data.keys.toList()..sort();
    return _fnv1a(jsonEncode([for (final k in keys) [k, data[k]]]));
  }

  String encodePayload() => jsonEncode(data);

  SaveSnapshot copyWith(
          {int? revision, String? deviceId, DateTime? savedAt}) =>
      SaveSnapshot(
        data: data,
        schemaVersion: schemaVersion,
        revision: revision ?? this.revision,
        deviceId: deviceId ?? this.deviceId,
        savedAt: savedAt ?? this.savedAt,
      );

  /// Lee un paquete de la nube. Un valor de tipo raro se descarta; un
  /// paquete ilegible devuelve null (no se restaura nada).
  static SaveSnapshot? decode({
    required String payload,
    required int schemaVersion,
    int revision = 0,
    String deviceId = '',
    DateTime? savedAt,
  }) {
    try {
      final raw = jsonDecode(payload);
      if (raw is! Map) return null;
      final data = <String, Object>{};
      raw.forEach((k, v) {
        final value = _sanitize(v);
        if (k is String && value != null) data[k] = value;
      });
      return SaveSnapshot(
        data: migrateSnapshotData(data, from: schemaVersion),
        revision: revision,
        deviceId: deviceId,
        savedAt: savedAt,
      );
    } catch (_) {
      return null;
    }
  }

  static Object? _sanitize(Object? v) {
    if (v is String || v is bool || v is int) return v;
    if (v is List && v.every((e) => e is String)) return v.cast<String>();
    return null;
  }
}

/// Lleva los datos de un paquete viejo al formato actual. Un paquete de una
/// versión más nueva que la app no se toca: el pedido de actualizar
/// (min_supported_version) evita que se restaure en una app vieja.
Map<String, Object> migrateSnapshotData(Map<String, Object> data,
    {required int from}) {
  var version = from;
  final out = Map<String, Object>.of(data);
  // while (version < kSaveSchemaVersion) { switch (version) { case 1: … } version++; }
  while (version < kSaveSchemaVersion) {
    version++;
  }
  return out;
}

// ─── Qué hacer al conectarse ──────────────────────────────────────────────────

enum SyncAction {
  /// La partida de este dispositivo manda: se sube.
  upload,

  /// La de la nube manda: se baja y reemplaza la local.
  restore,

  /// Las dos tienen progreso distinto: elige el jugador.
  askUser,

  /// Ya están iguales.
  none,
}

/// Decide qué partida queda. [lastSyncedRevision] es la última revisión de
/// la nube que este dispositivo subió o bajó.
SyncAction decideSync({
  required SaveSnapshot local,
  required SaveSnapshot? remote,
  required String deviceId,
  required int lastSyncedRevision,
}) {
  if (remote == null) return SyncAction.upload;
  if (remote.contentHash == local.contentHash) return SyncAction.none;
  if (local.isFresh) return remote.isFresh ? SyncAction.upload : SyncAction.restore;
  if (remote.isFresh) return SyncAction.upload;
  // Nadie más tocó la nube desde la última vez que la vimos.
  if (remote.deviceId == deviceId || remote.revision <= lastSyncedRevision) {
    return SyncAction.upload;
  }
  return SyncAction.askUser;
}

String _fnv1a(String s) {
  var hash = 0x811c9dc5;
  for (final c in utf8.encode(s)) {
    hash ^= c;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
