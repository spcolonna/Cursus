import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/save_snapshot.dart';
import '../../domain/repositories/repositories.dart';
import 'local_save_store.dart';

enum CloudStatus {
  /// Sin Firebase o sin Auth habilitado: el juego guarda solo en el teléfono.
  unavailable,
  syncing,
  synced,

  /// Hubo un error (sin red, casi siempre); se reintenta en la próxima.
  offline,
}

/// Dos partidas con progreso distinto: la del teléfono y la de la nube.
class SaveConflict {
  final SaveSnapshot local;
  final SaveSnapshot remote;
  const SaveConflict(this.local, this.remote);
}

/// Guardado en la nube. Siempre local primero: el juego nunca espera a la
/// red. Sube con demora tras cada cambio y enseguida al pasar a segundo
/// plano; al arrancar decide qué partida queda ([decideSync]).
class CloudSyncService {
  final CloudAccount? account;
  final CloudSaveRemote? remote;
  final LocalSaveStore store;
  final Duration debounce;

  CloudSyncService({
    required this.account,
    required this.remote,
    LocalSaveStore? store,
    this.debounce = const Duration(seconds: 8),
  }) : store = store ?? LocalSaveStore();

  bool get available => account != null && remote != null;

  final status = ValueNotifier<CloudStatus>(CloudStatus.unavailable);
  Timer? _timer;
  Future<void> _running = Future.value();

  /// Al arrancar: entra (anónimo si hace falta) y compara con la nube.
  /// Una restauración automática se aplica antes de cargar el juego. Si
  /// devuelve un conflicto, la pantalla le pregunta al jugador.
  Future<SaveConflict?> start() async {
    if (!available) return null;
    final uid = await account!.ensureSignedIn();
    if (uid == null) {
      status.value = CloudStatus.unavailable;
      return null;
    }
    return _reconcile(uid);
  }

  Future<SaveConflict?> _reconcile(String uid) async {
    status.value = CloudStatus.syncing;
    try {
      final local = await store.capture();
      final cloud = await remote!.fetch(uid);
      final action = decideSync(
        local: local,
        remote: cloud,
        deviceId: local.deviceId,
        lastSyncedRevision: await store.syncedRevision(),
      );
      switch (action) {
        case SyncAction.upload:
          await _upload(uid, local);
        case SyncAction.restore:
          await store.restore(cloud!);
        case SyncAction.none:
          await store.markSynced(cloud!.revision, cloud.contentHash);
        case SyncAction.askUser:
          status.value = CloudStatus.synced;
          return SaveConflict(local, cloud!);
      }
      status.value = CloudStatus.synced;
    } catch (e) {
      debugPrint('Cloud sync: $e');
      status.value = CloudStatus.offline;
    }
    return null;
  }

  /// El jugador eligió en un conflicto.
  Future<void> resolve(SaveConflict conflict, {required bool keepRemote}) async {
    final uid = account?.uid;
    if (uid == null) return;
    if (keepRemote) {
      await store.restore(conflict.remote);
    } else {
      // La del teléfono pisa la de la nube: se sube encima de su revisión.
      await store.markSynced(conflict.remote.revision, '');
      await _upload(uid, await store.capture());
    }
    status.value = CloudStatus.synced;
  }

  /// Algo cambió: sube en unos segundos (se agrupan los cambios seguidos).
  void markDirty() {
    if (!available || account!.uid == null) return;
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(flush()));
  }

  /// Sube ya si hay cambios (segundo plano, compra).
  Future<void> flush() {
    _timer?.cancel();
    final uid = account?.uid;
    if (!available || uid == null) return Future.value();
    return _running = _running.then((_) async {
      try {
        final local = await store.capture();
        if (local.contentHash == await store.syncedHash()) return;
        status.value = CloudStatus.syncing;
        await _upload(uid, local);
        status.value = CloudStatus.synced;
      } catch (e) {
        debugPrint('Cloud sync: $e');
        status.value = CloudStatus.offline;
      }
    });
  }

  Future<void> _upload(String uid, SaveSnapshot local) async {
    final next = local.copyWith(revision: await store.syncedRevision() + 1);
    final revision = await remote!.put(uid, next);
    await store.markSynced(revision, local.contentHash);
  }

  /// Vincular la cuenta anónima. Si la cuenta elegida ya tenía partida,
  /// devuelve el conflicto (o restaura sola si este teléfono no tiene
  /// progreso).
  Future<(LinkOutcome, SaveConflict?)> link(AccountProvider provider) =>
      _withAccount(() => account!.link(provider));

  /// "Ya tengo partida": entrar con una cuenta existente.
  Future<(LinkOutcome, SaveConflict?)> signInWith(AccountProvider provider) =>
      _withAccount(() => account!.signInWith(provider));

  Future<(LinkOutcome, SaveConflict?)> _withAccount(
      Future<LinkOutcome> Function() action) async {
    if (!available) return (LinkOutcome.canceled, null);
    await flush();
    final outcome = await action();
    if (outcome == LinkOutcome.canceled) return (outcome, null);
    if (outcome == LinkOutcome.linked) {
      await flush();
      return (outcome, null);
    }
    // Otra cuenta: lo sincronizado antes era de la anónima.
    await store.markSynced(0, '');
    return (outcome, await _reconcile(account!.uid!));
  }

  /// Borra la partida de la nube, la cuenta y la partida local. Lo exigen
  /// Apple y Google para cualquier app con cuentas.
  Future<void> deleteEverything() async {
    _timer?.cancel();
    // Una subida en vuelo reescribiría la partida después de borrarla.
    await _running;
    final uid = account?.uid;
    if (available && uid != null) {
      await remote!.delete(uid);
      await account!.deleteAccount();
    }
    await store.wipe();
    status.value =
        available ? CloudStatus.syncing : CloudStatus.unavailable;
  }
}
