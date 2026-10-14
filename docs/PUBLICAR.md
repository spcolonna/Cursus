# Publicar Cursus

Fase L8 del plan de lanzamiento. Lo que ya está en el código y lo que tenés que hacer vos, en orden.

## Ya está en el código

- **Android:**
  - Firma de release desde `android/key.properties`, que no se commitea. Sin ese archivo, firma con la clave debug.
  - Sin `USE_EXACT_ALARM`: Play solo lo acepta en apps de alarma o calendario. Los avisos son exactos si el sistema da el permiso y, si no, inexactos (pueden correrse unos minutos).
- **iOS:**
  - `PrivacyInfo.xcprivacy`: sin rastreo; datos declarados: identificador de usuario, partida, interacción, errores y compras.
  - `ITSAppUsesNonExemptEncryption = false`: solo HTTPS estándar.
- **Políticas:**
  - Política de privacidad y términos en español e inglés, en `site/`.
  - Enlaces desde Ajustes → Legal. La URL base es `LEGAL_BASE_URL`, por defecto `https://spcolonna.github.io/cursus`.
- **Borrar cuenta y datos:** Ajustes → Cuenta. Apple y Google lo exigen.
- **CI:** `.github/workflows/ci.yml` corre analyze y test en cada push y PR.
- **Restaurar compras:** todos los productos son consumibles, y Apple solo exige el botón para no consumibles y suscripciones. El crédito idempotente (`PurchaseLedger`) evita que se dupliquen.

## Lo que hacés vos

### 1. Firebase (gratis, plan Spark)

1. En `cursus-dev` y `cursus-prod`, entrá a Authentication → Comenzar y habilitá **Anónimo**.
2. Desplegá las reglas de Firestore:

   ```bash
   firebase deploy --only firestore:rules --project cursus-prod
   ```

3. Google y Apple como inicio de sesión son opcionales. Los pasos están en [CUENTAS.md](CUENTAS.md).

### 2. Política de privacidad publicada

1. Completá el contacto: reemplazá `CONTACTO@COMPLETAR` en los cinco archivos de `site/`.
2. Publicá `site/`, por ejemplo con GitHub Pages: Settings → Pages → Deploy from branch, carpeta `/site`, o subilo a tu dominio.
3. Si la URL no es `https://spcolonna.github.io/cursus`, compilá con `--dart-define=LEGAL_BASE_URL=https://…`.

### 3. Firma de Android (una sola vez; guardá backup)

```bash
keytool -genkey -v -keystore ~/cursus-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copiá `android/key.properties.example` a `android/key.properties` y completalo. **Si perdés la keystore, no podés actualizar la app**: guardala en dos lugares. Activá también Play App Signing.

### 4. AdMob

Seguí [MONETIZACION.md](MONETIZACION.md) → "Para publicar": ids de las apps y de los bloques, mensaje de GDPR y `app-ads.txt`.

### 5. App Store Connect

1. Creá la app con el bundle `com.spcolonna.cursus`, en español e inglés.
2. **Compras:** 6 consumibles con los ids de `IapProducts`.
3. **Privacidad (Nutrition Labels):** tienen que coincidir con `PrivacyInfo.xcprivacy`.

   | Dato | ¿Vinculado al usuario? | Para qué |
   |---|---|---|
   | Identificador de usuario | sí | funcionalidad |
   | Contenido del juego | sí | funcionalidad |
   | Interacción con el producto | no | analítica |
   | Datos de errores | no | funcionalidad |
   | Historial de compras | no | funcionalidad |

   Además, por AdMob:
   - "Identificadores del dispositivo / Datos de publicidad", sin rastreo, mientras no se pida ATT.
4. **Clasificación por edad:** violencia de fantasía o caricaturesca poco frecuente. Sin apuestas: los dados son un evento narrativo y no se juega dinero.
5. **Ficha y capturas:** ver [STORE_LISTING.md](STORE_LISTING.md).

### 6. Google Play Console

1. Creá la app y activá Play App Signing.
2. **Productos integrados:** los 6 ids de `IapProducts`.
3. **Seguridad de los datos.** Se recopila:
   - ID de la app;
   - actividad en la app;
   - errores;
   - compras;
   - ID de publicidad (AdMob).

   Todo se cifra en tránsito, y el usuario puede pedir el borrado desde la app.
4. **Clasificación de contenido (IARC):** cuestionario con las mismas respuestas que en iOS.
5. **Prueba cerrada:** las cuentas personales nuevas necesitan **12 testers durante 14 días** antes de producción. Conviene arrancarla cuanto antes.

## Compilar

```bash
flutter build appbundle --release --dart-define=ADMOB_REWARDED_ANDROID=ca-app-pub-XXXX/ZZZZ
```

```bash
flutter build ipa --release --dart-define=ADMOB_REWARDED_IOS=ca-app-pub-XXXX/YYYY
```

**Versión:** `version:` en `pubspec.yaml`, con formato `x.y.z+build`. Subí el `+build` en cada envío a las tiendas.
