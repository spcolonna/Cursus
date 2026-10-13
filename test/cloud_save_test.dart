// Fase L2: la partida en un paquete, la decisión de qué partida queda y el
// servicio de sincronización con una nube falsa.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_messenger/domain/entities/save_snapshot.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/infrastructure/cloud/cloud_sync_service.dart';
import 'package:the_messenger/infrastructure/cloud/local_save_store.dart';
import 'package:the_messenger/presentation/providers/providers.dart';
import 'package:the_messenger/presentation/widgets/cloud_widgets.dart';

class _FakeAccount implements CloudAccount {
  @override
  String? uid;
  String? nextUid;
  bool deleted = false;
  _FakeAccount();

  @override
  bool get isAnonymous => true;
  @override
  Set<AccountProvider> get linkedProviders => {};
  @override
  Future<String?> ensureSignedIn() async => uid ??= 'anon';
  @override
  Future<LinkOutcome> link(AccountProvider provider) async {
    if (nextUid == null) return LinkOutcome.linked;
    uid = nextUid;
    return LinkOutcome.switchedAccount;
  }

  @override
  Future<LinkOutcome> signInWith(AccountProvider provider) => link(provider);
  @override
  Future<void> deleteAccount() async => deleted = true;
  @override
  Future<void> signOut() async => uid = null;
}

class _FakeRemote implements CloudSaveRemote {
  final Map<String, SaveSnapshot> docs = {};
  int puts = 0;
  @override
  Future<SaveSnapshot?> fetch(String uid) async => docs[uid];
  @override
  Future<int> put(String uid, SaveSnapshot snapshot) async {
    puts++;
    docs[uid] = snapshot.copyWith(savedAt: DateTime(2026, 10, 13));
    return snapshot.revision;
  }

  @override
  Future<void> delete(String uid) async => docs.remove(uid);
}

SaveSnapshot _played(String name, {int missions = 3, String device = 'otro', int revision = 1}) =>
    SaveSnapshot(
      data: {
        'user_name': name,
        'onboarding_done': true,
        'completed_missions': [for (var i = 0; i < missions; i++) 'm$i'],
      },
      deviceId: device,
      revision: revision,
    );

void main() {
  group('SaveSnapshot', () {
    test('partida nueva vs jugada, y su resumen', () {
      expect(const SaveSnapshot(data: {}).isFresh, isTrue);
      final s = _played('Varus', missions: 4);
      expect(s.isFresh, isFalse);
      expect(s.summary.name, 'Varus');
      expect(s.summary.completedMissions, 4);
    });

    test('la huella no depende del orden de las claves', () {
      const a = SaveSnapshot(data: {'a': 1, 'b': 'x'});
      const b = SaveSnapshot(data: {'b': 'x', 'a': 1});
      expect(a.contentHash, b.contentHash);
      expect(a.contentHash,
          isNot(const SaveSnapshot(data: {'a': 2, 'b': 'x'}).contentHash));
    });

    test('ida y vuelta por el texto de la nube; lo raro se descarta', () {
      final s = _played('Varus');
      final back = SaveSnapshot.decode(
          payload: s.encodePayload(), schemaVersion: kSaveSchemaVersion)!;
      expect(back.contentHash, s.contentHash);
      final weird = SaveSnapshot.decode(
          payload: '{"ok":"si","n":1.5,"l":[1,2],"m":{"x":1}}',
          schemaVersion: 1)!;
      expect(weird.data.keys, ['ok']);
      expect(SaveSnapshot.decode(payload: 'no es json', schemaVersion: 1),
          isNull);
    });
  });

  group('decideSync', () {
    final local = _played('Local', device: 'yo');
    SyncAction decide(SaveSnapshot l, SaveSnapshot? r, {int synced = 0}) =>
        decideSync(
            local: l, remote: r, deviceId: 'yo', lastSyncedRevision: synced);

    test('sin nube: se sube', () {
      expect(decide(local, null), SyncAction.upload);
    });
    test('iguales: nada', () {
      expect(decide(local, local.copyWith(deviceId: 'otro', revision: 9)),
          SyncAction.none);
    });
    test('teléfono nuevo y nube jugada: se restaura sola', () {
      expect(decide(const SaveSnapshot(data: {}), _played('Nube')),
          SyncAction.restore);
    });
    test('nube vacía: manda el teléfono', () {
      expect(decide(local, const SaveSnapshot(data: {'x': 1}, deviceId: 'otro', revision: 5)),
          SyncAction.upload);
    });
    test('la última subida fue mía: se sube', () {
      expect(decide(local, _played('Vieja', device: 'yo', revision: 7)),
          SyncAction.upload);
      expect(decide(local, _played('Vieja', revision: 3), synced: 3),
          SyncAction.upload);
    });
    test('otro dispositivo avanzó: pregunta', () {
      expect(decide(local, _played('Nube', revision: 4), synced: 3),
          SyncAction.askUser);
    });
  });

  group('LocalSaveStore', () {
    test('captura solo la partida y restaura sin tocar las preferencias',
        () async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Varus',
        'onboarding_done': true,
        'completed_missions': ['a'],
        'guild_v1': '{"x":1}',
        'sfx_enabled_v1': false,
        'guild_v1_corrupt_backup': 'roto',
        'messenger_data': 'legado',
      });
      final store = LocalSaveStore();
      final snap = await store.capture();
      expect(snap.data.keys.toSet(),
          {'user_name', 'onboarding_done', 'completed_missions', 'guild_v1'});
      expect(snap.deviceId, isNotEmpty);

      await store.restore(_played('Nube', missions: 2, revision: 6));
      final p = await SharedPreferences.getInstance();
      expect(p.getString('user_name'), 'Nube');
      expect(p.getStringList('completed_missions'), ['m0', 'm1']);
      expect(p.getString('guild_v1'), isNull, reason: 'no estaba en la nube');
      expect(p.getString('guild_v1_corrupt_backup'), isNull);
      expect(p.getString('messenger_data'), isNull);
      expect(p.getBool('sfx_enabled_v1'), isFalse, reason: 'es del teléfono');
      expect(await store.syncedRevision(), 6);
    });

    test('toda clave persistida está clasificada (nube o teléfono)', () {
      // Si este test falla, sumaste una clave: decidí si es partida
      // (kCloudSaveKeys) o del dispositivo (la lista de abajo).
      const deviceKeys = {
        'user_id', 'messenger_data', 'active_mission', 'cosmetic_titles_v1',
        'cosmetic_title_equipped_v1', 'ads_travel_day_v1',
        'ads_travel_count_v1', 'ads_double_pay_day_v1', 'sfx_enabled_v1',
        'music_enabled_v1', 'music_volume_v1', 'haptics_enabled_v1',
        'reduce_motion_v1', 'analytics_enabled_v1',
      };
      final keyDecl = RegExp(r"static const _k\w*\s*=\s*'([a-z0-9_]+)'");
      final found = <String>{};
      for (final f in [
        'lib/infrastructure/local/local_repositories.dart',
        'lib/infrastructure/progress/player_progress.dart',
      ]) {
        found.addAll(keyDecl
            .allMatches(File(f).readAsStringSync())
            .map((m) => m.group(1)!));
      }
      expect(found, isNotEmpty);
      final unclassified = found
          .where((k) => !kCloudSaveKeys.contains(k) && !deviceKeys.contains(k));
      expect(unclassified, isEmpty);
    });
  });

  group('CloudSyncService', () {
    late _FakeAccount account;
    late _FakeRemote remote;
    late CloudSyncService sync;

    setUp(() {
      account = _FakeAccount();
      remote = _FakeRemote();
      sync = CloudSyncService(
          account: account, remote: remote, debounce: Duration.zero);
    });

    test('sin cuenta (sin Firebase) no hace nada', () async {
      SharedPreferences.setMockInitialValues({'user_name': 'Varus'});
      final off = CloudSyncService(account: null, remote: null);
      expect(await off.start(), isNull);
      await off.flush();
      expect(off.status.value, CloudStatus.unavailable);
    });

    test('primer arranque: entra anónimo y sube la partida', () async {
      SharedPreferences.setMockInitialValues(
          {'user_name': 'Varus', 'onboarding_done': true});
      expect(await sync.start(), isNull);
      expect(account.uid, 'anon');
      expect(remote.docs['anon']!.data['user_name'], 'Varus');
      expect(remote.docs['anon']!.revision, 1);
      expect(sync.status.value, CloudStatus.synced);
    });

    test('sin cambios no vuelve a subir; con cambios, sí', () async {
      SharedPreferences.setMockInitialValues({'user_name': 'Varus'});
      await sync.start();
      await sync.flush();
      expect(remote.puts, 1);
      (await SharedPreferences.getInstance()).setString('guild_v1', '{}');
      await sync.flush();
      expect(remote.puts, 2);
      expect(remote.docs['anon']!.revision, 2);
    });

    test('vincular una cuenta que ya tenía partida: teléfono nuevo restaura',
        () async {
      SharedPreferences.setMockInitialValues({});
      await sync.start();
      remote.docs['google'] = _played('Varus', missions: 9, revision: 12);
      account.nextUid = 'google';
      final (outcome, conflict) = await sync.signInWith(AccountProvider.google);
      expect(outcome, LinkOutcome.switchedAccount);
      expect(conflict, isNull);
      final p = await SharedPreferences.getInstance();
      expect(p.getString('user_name'), 'Varus');
      expect(p.getStringList('completed_missions'), hasLength(9));
    });

    test('dos partidas con progreso: pregunta y respeta la elección',
        () async {
      SharedPreferences.setMockInitialValues(
          {'user_name': 'Local', 'onboarding_done': true});
      await sync.start();
      remote.docs['google'] = _played('Nube', revision: 4);
      account.nextUid = 'google';
      final (_, conflict) = await sync.link(AccountProvider.google);
      expect(conflict, isNotNull);
      expect(conflict!.remote.summary.name, 'Nube');

      await sync.resolve(conflict, keepRemote: false);
      expect(remote.docs['google']!.data['user_name'], 'Local');
      expect(remote.docs['google']!.revision, 5,
          reason: 'pisa por encima de la revisión de la nube');
    });

    test('borrar todo: nube, cuenta y teléfono', () async {
      SharedPreferences.setMockInitialValues(
          {'user_name': 'Varus', 'onboarding_done': true, 'sfx_enabled_v1': true});
      await sync.start();
      await sync.deleteEverything();
      expect(remote.docs, isEmpty);
      expect(account.deleted, isTrue);
      final p = await SharedPreferences.getInstance();
      expect(p.getString('user_name'), isNull);
      expect(p.getBool('sfx_enabled_v1'), isTrue);
    });
  });

  group('Ajustes: cuenta', () {
    testWidgets('sin nube avisa que guarda en el teléfono y deja borrar',
        (tester) async {
      SharedPreferences.setMockInitialValues({'user_name': 'Varus'});
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AccountCard())),
      ));
      await tester.pump();
      expect(find.text('Tu partida se guarda en este teléfono.'),
          findsOneWidget);
      await tester.tap(find.text('Borrar cuenta y datos'));
      await tester.pumpAndSettle();
      expect(find.text('¿Borrar todo?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect((await SharedPreferences.getInstance()).getString('user_name'),
          'Varus');
    });

    test('hace cuánto', () {
      final now = DateTime(2026, 10, 13, 12);
      expect(timeAgo(now.subtract(const Duration(seconds: 10)), now: now),
          'recién');
      expect(timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
          'hace 5 min');
      expect(timeAgo(now.subtract(const Duration(days: 3)), now: now),
          'hace 3 días');
      expect(cloudSyncProviderIsLocal(), isTrue);
    });
  });
}

/// En tests no hay Firebase: el guardado queda local.
bool cloudSyncProviderIsLocal() {
  final c = ProviderContainer();
  addTearDown(c.dispose);
  return !c.read(cloudSyncProvider).available;
}
