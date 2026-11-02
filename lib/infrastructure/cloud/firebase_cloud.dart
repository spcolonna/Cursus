import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/entities/save_snapshot.dart';
import '../../domain/repositories/repositories.dart';

// ─── Qué proveedores están listos ─────────────────────────────────────────────
// Cada uno necesita configuración fuera del código (ver docs/CUENTAS.md):
// Google, el proveedor habilitado en Firebase y los archivos de config
// bajados de nuevo; Apple, la cuenta de Apple Developer y el entitlement.
// Mientras estén en false, la app no muestra esos botones.
const kGoogleSignInReady = false;

/// Guardado en la nube (cuenta anónima + Firestore). Apagado mientras el
/// juego no tenga nada online: la partida vive solo en el teléfono y no se
/// crea ninguna cuenta. Para prenderlo, habilitar el acceso anónimo en
/// Firebase y desplegar firestore.rules (docs/CUENTAS.md).
const kCloudSaveReady = false;
const kAppleSignInReady = false;

/// Proveedores que se pueden ofrecer en este dispositivo. En iOS, Apple
/// exige ofrecer Sign in with Apple si se ofrece Google (guía 4.8).
Set<AccountProvider> availableProviders() {
  final isIOS = !kIsWeb && Platform.isIOS;
  final apple = kAppleSignInReady && isIOS;
  final google = kGoogleSignInReady && (!isIOS || apple);
  return {
    if (apple) AccountProvider.apple,
    if (google) AccountProvider.google,
  };
}

class FirebaseCloudAccount implements CloudAccount {
  final FirebaseAuth _auth;
  FirebaseCloudAccount([FirebaseAuth? auth])
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  String? get uid => _auth.currentUser?.uid;

  @override
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  @override
  Set<AccountProvider> get linkedProviders => {
        for (final info in _auth.currentUser?.providerData ?? <UserInfo>[])
          if (info.providerId == 'google.com')
            AccountProvider.google
          else if (info.providerId == 'apple.com')
            AccountProvider.apple,
      };

  @override
  Future<String?> ensureSignedIn() async {
    if (_auth.currentUser != null) return _auth.currentUser!.uid;
    try {
      final cred = await _auth
          .signInAnonymously()
          .timeout(const Duration(seconds: 8));
      return cred.user?.uid;
    } catch (e) {
      // Sin red, o Auth anónimo sin habilitar en la consola.
      debugPrint('Cloud auth: $e');
      return null;
    }
  }

  @override
  Future<LinkOutcome> link(AccountProvider provider) async {
    final credential = await _credential(provider);
    if (credential == null) return LinkOutcome.canceled;
    final user = _auth.currentUser;
    if (user == null) {
      await _auth.signInWithCredential(credential);
      return LinkOutcome.switchedAccount;
    }
    try {
      await user.linkWithCredential(credential);
      return LinkOutcome.linked;
    } on FirebaseAuthException catch (e) {
      // Esa cuenta ya existe (otro dispositivo): se entra en ella.
      if (e.code != 'credential-already-in-use') rethrow;
      await _auth.signInWithCredential(e.credential ?? credential);
      return LinkOutcome.switchedAccount;
    }
  }

  @override
  Future<LinkOutcome> signInWith(AccountProvider provider) async {
    final credential = await _credential(provider);
    if (credential == null) return LinkOutcome.canceled;
    await _auth.signInWithCredential(credential);
    return LinkOutcome.switchedAccount;
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login' || linkedProviders.isEmpty) {
        rethrow;
      }
      final credential = await _credential(linkedProviders.first);
      if (credential == null) rethrow;
      await user.reauthenticateWithCredential(credential);
      await user.delete();
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// null si el jugador canceló.
  Future<AuthCredential?> _credential(AccountProvider provider) async {
    switch (provider) {
      case AccountProvider.google:
        final google = GoogleSignIn.instance;
        await google.initialize(
            clientId: Firebase.app().options.iosClientId);
        try {
          final account = await google.authenticate();
          final idToken = account.authentication.idToken;
          if (idToken == null) return null;
          return GoogleAuthProvider.credential(idToken: idToken);
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) return null;
          rethrow;
        }
      case AccountProvider.apple:
        try {
          final apple = await SignInWithApple.getAppleIDCredential(
              scopes: const []);
          return OAuthProvider('apple.com').credential(
            idToken: apple.identityToken,
            accessToken: apple.authorizationCode,
          );
        } on SignInWithAppleAuthorizationException catch (e) {
          if (e.code == AuthorizationErrorCode.canceled) return null;
          rethrow;
        }
    }
  }
}

/// La partida vive en `users/{uid}` (reglas en firestore.rules: cada
/// jugador solo ve su documento).
class FirestoreSaveRemote implements CloudSaveRemote {
  final FirebaseFirestore _db;
  FirestoreSaveRemote([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<SaveSnapshot?> fetch(String uid) async {
    final snap = await _doc(uid)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    final d = snap.data();
    if (d == null || d['payload'] is! String) return null;
    return SaveSnapshot.decode(
      payload: d['payload'] as String,
      schemaVersion: (d['schemaVersion'] as num?)?.toInt() ?? 1,
      revision: (d['revision'] as num?)?.toInt() ?? 0,
      deviceId: d['deviceId'] as String? ?? '',
      savedAt: (d['savedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<int> put(String uid, SaveSnapshot snapshot) async {
    final summary = snapshot.summary;
    await _doc(uid).set({
      'schemaVersion': snapshot.schemaVersion,
      'revision': snapshot.revision,
      'deviceId': snapshot.deviceId,
      'savedAt': FieldValue.serverTimestamp(),
      'summary': {
        'name': summary.name,
        'completedMissions': summary.completedMissions,
      },
      'payload': snapshot.encodePayload(),
    }).timeout(const Duration(seconds: 10));
    return snapshot.revision;
  }

  @override
  Future<void> delete(String uid) =>
      _doc(uid).delete().timeout(const Duration(seconds: 10));
}
