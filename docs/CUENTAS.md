# Cuentas y guardado en la nube

Fase L2 del plan de lanzamiento. Todo entra en el plan gratis (Spark) de Firebase: Auth y Firestore, sin Cloud Functions.

## Cómo funciona

- **Cuenta anónima e invisible.** El splash inicia sesión anónima en Firebase Auth. El jugador no ve nada; su partida queda asociada a un `uid`.
- **Guardado local primero.** El juego escribe en SharedPreferences como siempre. `CloudSyncService` arma un `SaveSnapshot` (las claves de `kCloudSaveKeys`) y lo sube a `users/{uid}` en Firestore:
  - unos segundos después de cada cambio (`markDirty` en las recargas de los notifiers);
  - enseguida al pasar a segundo plano (`flush`).

  Si la partida no cambió (misma huella), no sube.
- **Al arrancar**, el splash compara la partida local con la de la nube (`decideSync`):
  - **Subir:** cuando la nube está vacía o la última subida fue de este teléfono.
  - **Restaurar sola:** cuando el teléfono es nuevo y la nube tiene progreso.
  - **Preguntar:** cuando hay progreso distinto en los dos lados. El jugador elige "Usar la de la nube" o "Usar la de este teléfono".
- **Vincular** (Ajustes → Cuenta, con Google o Apple) convierte la cuenta anónima en permanente. Si esa cuenta de Google o Apple ya tenía partida, se entra en ella y aplica la misma decisión.
- **"Ya tengo partida"** en la bienvenida entra con la cuenta vinculada y baja la partida.
- **Borrar cuenta y datos** (Ajustes) borra el documento de Firestore, la cuenta de Auth y la partida local. Las preferencias del teléfono (sonido, avisos) quedan. Apple y Google lo exigen.

## Qué viaja y qué no

| Viaja (partida) | Se queda en el teléfono |
|---|---|
| nombre, onboarding, mensajeros, misiones activas y completadas, gremio, mundo, progresión, semanales, retención, primeros pasos, tooltips vistos | sonido, música, vibración, movimiento reducido, consentimiento de analytics, avisos, topes diarios de anuncios, buffer de analytics |

Toda clave nueva de SharedPreferences tiene que clasificarse. `test/cloud_save_test.dart` falla si aparece una sin clasificar.

**Cambio de esquema:** subí `kSaveSchemaVersion` y agregá el paso en `migrateSnapshotData` (`lib/domain/entities/save_snapshot.dart`).

## Firestore

- Base `(default)` en `nam5`, creada en `cursus-dev` y en `cursus-prod`.
- Las reglas (`firestore.rules`) solo dejan que cada jugador lea y escriba su propio documento. También validan los campos y que el paquete pese menos de 900 KB.
- Para desplegar las reglas:

```bash
firebase deploy --only firestore:rules --project cursus-dev
firebase deploy --only firestore:rules --project cursus-prod
```

## Pendiente en la consola (lo hacés vos)

### 1. Habilitar Auth, necesario para que funcione la nube

En los dos proyectos (`cursus-dev` y `cursus-prod`), entrá a Firebase Console → Authentication → **Comenzar** y habilitá **Anónimo**.

Mientras no esté habilitado, la app sigue funcionando: Ajustes muestra "Tu partida se guarda en este teléfono".

### 2. Google, opcional hasta el lanzamiento

1. En Authentication → Sign-in method, habilitá **Google** en los dos proyectos.
2. En Android, agregá las huellas SHA-1 y SHA-256 de la app:
   - para la clave debug: `cd android && ./gradlew signingReport`;
   - la de release se agrega en L8.
3. Volvé a bajar la config:

   ```bash
   flutterfire configure --project=cursus-dev --out=/dev/null --ios-out=ios/config/dev/GoogleService-Info.plist --android-out=android/app/src/debug/google-services.json --yes
   ```

   Repetí con prod: `cursus-prod`, `ios/config/prod/...` y `android/app/src/release/...`.

   El build de iOS agrega solo el esquema de URL `REVERSED_CLIENT_ID` (script "Firebase config").
4. Poné `kGoogleSignInReady = true` en `lib/infrastructure/cloud/firebase_cloud.dart`.

### 3. Apple, necesario en iOS si se ofrece Google (guía 4.8)

1. Con la cuenta de Apple Developer, habilitá la capability **Sign in with Apple** en el App ID y en Xcode (Runner → Signing & Capabilities).
2. En Firebase, habilitá el proveedor **Apple** en Authentication.
3. Poné `kAppleSignInReady = true`.

Mientras Apple no esté listo, en iOS no se muestra Google (`availableProviders()`).

## Archivos

- `lib/domain/entities/save_snapshot.dart`: paquete, migración y `decideSync`.
- `lib/infrastructure/cloud/local_save_store.dart`: claves, captura y restauración.
- `lib/infrastructure/cloud/cloud_sync_service.dart`: subir, bajar, vincular y borrar.
- `lib/infrastructure/cloud/firebase_cloud.dart`: Auth (anónimo, Google, Apple) y Firestore.
- `lib/presentation/widgets/cloud_widgets.dart`: elegir partida y `AccountCard` de Ajustes.
