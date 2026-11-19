// Guardado en la nube: casos de conflicto que cloud_save_test no cubre. La
// regla real (decideSync) decide por REVISIÓN y por quién subió, nunca por
// la hora (savedAt) ni por cuánto progreso tiene cada partida.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_messenger/domain/entities/save_snapshot.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/infrastructure/cloud/cloud_sync_service.dart';
import 'package:the_messenger/infrastructure/cloud/local_save_store.dart';

class _FakeAccount implements CloudAccount {
  @override
  String? uid;
  bool offline = false;

  @override
  bool get isAnonymous => true;
  @override
  Set<AccountProvider> get linkedProviders => {};
  @override
  Future<String?> ensureSignedIn() async => offline ? null : uid ??= 'anon';
  @override
  Future<LinkOutcome> link(AccountProvider provider) async =>
      LinkOutcome.linked;
  @override
  Future<LinkOutcome> signInWith(AccountProvider provider) => link(provider);
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<void> signOut() async => uid = null;
}

class _FakeRemote implements CloudSaveRemote {
  final Map<String, SaveSnapshot> docs = {};
  int puts = 0;
  bool failFetch = false;
  bool failPut = false;

  /// Si no es null, la nube asigna esta revisión (en vez de la pedida).
  int? serverRevision;

  @override
  Future<SaveSnapshot?> fetch(String uid) async {
    if (failFetch) throw Exception('sin red');
    return docs[uid];
  }

  @override
  Future<int> put(String uid, SaveSnapshot snapshot) async {
    if (failPut) throw Exception('sin red');
    puts++;
    final rev = serverRevision ?? snapshot.revision;
    docs[uid] = snapshot.copyWith(revision: rev);
    return rev;
  }

  @override
  Future<void> delete(String uid) async => docs.remove(uid);
}

const _me = 'yo';

SaveSnapshot _played(String name,
        {int missions = 3,
        String device = 'otro',
        int revision = 1,
        DateTime? savedAt}) =>
    SaveSnapshot(
      data: {
        'user_name': name,
        'onboarding_done': true,
        'completed_missions': [for (var i = 0; i < missions; i++) 'm$i'],
      },
      deviceId: device,
      revision: revision,
      savedAt: savedAt,
    );

SyncAction _decide(SaveSnapshot local, SaveSnapshot? remote,
        {int synced = 0}) =>
    decideSync(
        local: local,
        remote: remote,
        lastSyncedRevision: synced);

/// La partida local que dejan las preferencias de [_localPrefs].
final _localData = <String, Object>{
  'user_name': 'Local',
  'onboarding_done': true,
  'completed_missions': ['a'],
};

Map<String, Object> _localPrefs({int? syncedRevision, String? syncedHash}) => {
      ..._localData,
      'cloud_device_id_v1': _me,
      if (syncedRevision != null) 'cloud_synced_revision_v1': syncedRevision,
      if (syncedHash != null) 'cloud_synced_hash_v1': syncedHash,
    };

void main() {
  final local = _played('Local', device: _me);

  group('decideSync: hora y revisiones', () {
    test('savedAt no decide nada (reloj adelantado o atrasado)', () {
      final future = DateTime(2099);
      final past = DateTime(1999);
      for (final at in [future, past, null]) {
        expect(
            _decide(local, _played('Nube', revision: 4, savedAt: at),
                synced: 3),
            SyncAction.askUser,
            reason: 'savedAt=$at');
        expect(
            _decide(local, _played('Nube', revision: 3, savedAt: at),
                synced: 3),
            SyncAction.upload,
            reason: 'savedAt=$at');
      }
    });

    test('misma revisión que la última vista: manda el teléfono', () {
      expect(_decide(local, _played('Nube', revision: 3), synced: 3),
          SyncAction.upload);
    });

    test('nube con revisión menor a la vista (rollback): manda el teléfono',
        () {
      expect(_decide(local, _played('Nube', revision: 1), synced: 5),
          SyncAction.upload);
    });

    test('nube una revisión adelante de otro dispositivo: pregunta', () {
      expect(_decide(local, _played('Nube', revision: 6), synced: 5),
          SyncAction.askUser);
    });

    test('igual contenido gana sobre todo (aunque la revisión difiera)', () {
      final same = local.copyWith(deviceId: 'otro', revision: 99);
      expect(_decide(local, same, synced: 0), SyncAction.none);
    });
  });

  group('decideSync: el progreso no desempata', () {
    test('la nube con mucho más progreso igual pregunta', () {
      final small = _played('Local', missions: 1, device: _me);
      expect(_decide(small, _played('Nube', missions: 50, revision: 4),
              synced: 3),
          SyncAction.askUser);
    });

    test('el teléfono con mucho más progreso igual pregunta', () {
      final big = _played('Local', missions: 50, device: _me);
      expect(
          _decide(big, _played('Nube', missions: 1, revision: 4), synced: 3),
          SyncAction.askUser);
    });

    test('las dos partidas recién instaladas pero distintas: se sube', () {
      expect(
          _decide(const SaveSnapshot(data: {'tooltip_home_seen_v1': true}),
              const SaveSnapshot(data: {'user_name': 'x'}, revision: 9)),
          SyncAction.upload);
    });

    test('teléfono nuevo restaura aunque la nube la haya subido él mismo',
        () {
      expect(
          _decide(const SaveSnapshot(data: {}),
              _played('Nube', device: _me, revision: 7)),
          SyncAction.restore);
    });

    test('isFresh: onboarding sin terminar pero con misiones no es nueva', () {
      const s = SaveSnapshot(data: {
        'onboarding_done': false,
        'completed_missions': ['m0'],
      });
      expect(s.isFresh, isFalse);
    });
  });

  group('decideSync: nube rota o vacía', () {
    SaveSnapshot? decoded(String payload, {int revision = 4}) =>
        SaveSnapshot.decode(
            payload: payload,
            schemaVersion: kSaveSchemaVersion,
            revision: revision,
            deviceId: 'otro');

    test('paquete ilegible o que no es un mapa: se trata como sin nube', () {
      expect(decoded('{roto'), isNull);
      expect(decoded('[1,2,3]'), isNull);
      expect(_decide(local, decoded('[1,2,3]'), synced: 3), SyncAction.upload);
    });

    test('paquete vacío: manda el teléfono (jugado o nuevo)', () {
      final empty = decoded('{}')!;
      expect(empty.isFresh, isTrue);
      expect(_decide(local, empty, synced: 3), SyncAction.upload);
      expect(_decide(const SaveSnapshot(data: {}), empty), SyncAction.none,
          reason: 'dos vacías tienen la misma huella');
    });

    test('campos de tipo raro se descartan: si queda vacía, no se restaura',
        () {
      // Misiones con un número: la lista entera se tira. onboarding_done como
      // texto se conserva, pero no cuenta como "terminado" (!= true).
      final weird = decoded(
          '{"onboarding_done":"true","completed_missions":["a",1],"user_name":"N"}')!;
      expect(weird.data.keys.toSet(), {'onboarding_done', 'user_name'});
      expect(weird.isFresh, isTrue);
      expect(_decide(local, weird, synced: 3), SyncAction.upload);
    });

    test('documento sin revisión (0) cuenta como no avanzado', () {
      final noRev = decoded(_played('Nube').encodePayload(), revision: 0)!;
      expect(noRev.isFresh, isFalse);
      expect(_decide(local, noRev, synced: 0), SyncAction.upload);
    });

    test('ida y vuelta conserva revisión, dispositivo y hora', () {
      final at = DateTime(2026, 11, 1);
      final back = SaveSnapshot.decode(
          payload: local.encodePayload(),
          schemaVersion: kSaveSchemaVersion,
          revision: 8,
          deviceId: 'otro',
          savedAt: at)!;
      expect(back.revision, 8);
      expect(back.deviceId, 'otro');
      expect(back.savedAt, at);
      expect(_decide(local, back), SyncAction.none);
    });
  });

  group('CloudSyncService: reconciliación al arrancar', () {
    late _FakeAccount account;
    late _FakeRemote remote;
    late CloudSyncService sync;
    final store = LocalSaveStore();

    setUp(() {
      account = _FakeAccount();
      remote = _FakeRemote();
      sync = CloudSyncService(
          account: account, remote: remote, debounce: Duration.zero);
    });

    test('teléfono nuevo y nube jugada: restaura antes de cargar', () async {
      SharedPreferences.setMockInitialValues({});
      remote.docs['anon'] = _played('Nube', missions: 4, revision: 6);
      expect(await sync.start(), isNull);
      final p = await SharedPreferences.getInstance();
      expect(p.getString('user_name'), 'Nube');
      expect(await store.syncedRevision(), 6);
      expect(remote.puts, 0);
      expect(sync.status.value, CloudStatus.synced);
    });

    test('iguales: no sube y recuerda la revisión de la nube', () async {
      SharedPreferences.setMockInitialValues(_localPrefs());
      remote.docs['anon'] =
          SaveSnapshot(data: _localData, deviceId: 'otro', revision: 7);
      expect(await sync.start(), isNull);
      expect(remote.puts, 0);
      expect(await store.syncedRevision(), 7);
    });

    test('conflicto al arrancar: devuelve las dos y no toca nada', () async {
      SharedPreferences.setMockInitialValues(_localPrefs(syncedRevision: 3));
      remote.docs['anon'] = _played('Nube', revision: 4);
      final conflict = await sync.start();
      expect(conflict, isNotNull);
      expect(conflict!.local.summary.name, 'Local');
      expect(conflict.remote.summary.name, 'Nube');
      expect(remote.puts, 0);
      expect((await SharedPreferences.getInstance()).getString('user_name'),
          'Local');
    });

    test('elegir la nube: reemplaza la local y no sube', () async {
      SharedPreferences.setMockInitialValues(_localPrefs(syncedRevision: 3));
      remote.docs['anon'] = _played('Nube', missions: 5, revision: 4);
      final conflict = (await sync.start())!;
      await sync.resolve(conflict, keepRemote: true);
      final p = await SharedPreferences.getInstance();
      expect(p.getString('user_name'), 'Nube');
      expect(p.getStringList('completed_missions'), hasLength(5));
      expect(await store.syncedRevision(), 4);
      expect(remote.puts, 0);
    });

    test('resolver sin sesión no hace nada', () async {
      SharedPreferences.setMockInitialValues(_localPrefs());
      final conflict = SaveConflict(local, _played('Nube', revision: 4));
      await sync.resolve(conflict, keepRemote: true);
      expect((await SharedPreferences.getInstance()).getString('user_name'),
          'Local');
    });

    test('sin red al leer la nube: offline, sin subir ni pisar', () async {
      SharedPreferences.setMockInitialValues(_localPrefs());
      remote.failFetch = true;
      expect(await sync.start(), isNull);
      expect(sync.status.value, CloudStatus.offline);
      expect(remote.puts, 0);
      expect((await SharedPreferences.getInstance()).getString('user_name'),
          'Local');

      // Vuelve la red: el próximo flush sube lo pendiente.
      remote.failFetch = false;
      await sync.flush();
      expect(remote.puts, 1);
      expect(sync.status.value, CloudStatus.synced);
    });

    test('sin red al subir: offline y no marca nada como sincronizado',
        () async {
      SharedPreferences.setMockInitialValues(_localPrefs());
      remote.failPut = true;
      await sync.start();
      expect(sync.status.value, CloudStatus.offline);
      expect(await store.syncedRevision(), 0);
      expect(await store.syncedHash(), isNull);
    });

    test('sin sesión (Auth caído): no disponible', () async {
      SharedPreferences.setMockInitialValues(_localPrefs());
      account.offline = true;
      expect(await sync.start(), isNull);
      expect(sync.status.value, CloudStatus.unavailable);
      expect(remote.puts, 0);
    });

    test('se recuerda la revisión que asignó la nube, no la pedida', () async {
      SharedPreferences.setMockInitialValues(_localPrefs());
      remote.serverRevision = 42;
      await sync.start();
      expect(await store.syncedRevision(), 42);
      // Y la próxima subida va encima de esa.
      remote.serverRevision = null;
      (await SharedPreferences.getInstance()).setString('guild_v1', '{}');
      await sync.flush();
      expect(remote.docs['anon']!.revision, 43);
    });

    test(
        'teléfono sin cambios desde la última sync y nube más nueva: restaura',
        () async {
      // Jugué en el teléfono A (rev 3), seguí en el B (rev 4) y vuelvo al A
      // sin haber tocado nada: no hay dos progresos distintos, solo uno viejo.
      final hash = SaveSnapshot(data: _localData).contentHash;
      SharedPreferences.setMockInitialValues(
          _localPrefs(syncedRevision: 3, syncedHash: hash));
      remote.docs['anon'] = _played('Nube', missions: 6, revision: 4);
      expect(await sync.start(), isNull, reason: 'no debería preguntar');
      expect((await SharedPreferences.getInstance()).getString('user_name'),
          'Nube');
    });

    test('mismo deviceId pero la nube avanzó (copia de seguridad de Android)',
        () async {
      // Android Auto Backup (allowBackup no está desactivado) restaura las
      // SharedPreferences en un teléfono nuevo, incluido cloud_device_id_v1:
      // dos teléfonos con el mismo id. El viejo siguió subiendo (rev 8).
      SharedPreferences.setMockInitialValues(_localPrefs(syncedRevision: 5));
      remote.docs['anon'] =
          _played('Nube', missions: 9, device: _me, revision: 8);
      final conflict = await sync.start();
      expect(conflict, isNotNull,
          reason: 'la nube avanzó 3 revisiones que este teléfono no vio');
      expect(remote.docs['anon']!.summary.name, 'Nube');
    });
  });
}
