# Compras y anuncios

Corresponde a la fase L4 del plan de lanzamiento y entra entera en el plan gratis de Firebase (Spark): no hay validación de recibos en un servidor. Eso queda para cuando haya plan Blaze.

## Compras (`lib/infrastructure/monetization/iap_service.dart`)

- **Productos:** son consumibles. Sus ids están en `IapProducts` y tienen que coincidir con App Store Connect y con Play Console. Lo que entrega cada uno está en `purchaseRewardFor` (`usecases.dart`).
- **Precio:** se muestra el que devuelve la tienda (`localizedPrice`), con la moneda y los impuestos del jugador. Si la tienda no cargó el producto, se muestra el precio de referencia en USD del catálogo.
- **Estados:** `IapService.updates` avisa a la tienda del juego cada caso:

  | Estado | Qué ve el jugador |
  |---|---|
  | `credited` | Toast con lo recibido. |
  | `pending` | Por ejemplo, Ask to Buy o efectivo en Android. Se acredita sola cuando la tienda confirma. |
  | `canceled` | "Compra cancelada." |
  | `failed` | Error. Si la tienda cobró, la compra se acredita al reabrir el juego. |

- **Sin doble crédito:** `PurchaseLedger` guarda los ids de transacción ya acreditados en `iap_credited_v1`, que viaja con la partida a la nube. Si la tienda vuelve a entregar una compra, se cierra sin volver a acreditarla.
- **Orden:** primero se acredita y después se cierra la transacción. Si acreditar falla, la transacción queda abierta y la tienda la vuelve a entregar.
- **Sandbox:** en debug, si la tienda no tiene productos, se acredita al instante, para poder probar la economía.
- **Sin servidor:** con el plan gratis no se verifican los recibos. Un jugador con el teléfono rooteado podría falsificar una compra. Validar en el servidor (App Store Server API y Play Developer API desde una Cloud Function) necesita el plan Blaze.

## Anuncios (`lib/infrastructure/monetization/rewarded_ads_service.dart`)

- **Formato:** AdMob rewarded, con un solo lugar de aparición: el botón "Ver anuncio · −30 min" de la misión. El tope diario es `travel_ads_per_day` en Remote Config (4 por defecto).
- **Arranque:** al abrir la app, `init()` pide el consentimiento (UMP: GDPR en Europa y Reino Unido), inicializa el SDK y precarga un anuncio.
- **Resultado:** `showRewarded` devuelve uno de tres valores:
  - `rewarded`: hay recompensa;
  - `dismissed`: el jugador cerró el anuncio antes de tiempo;
  - `unavailable`: el jugador ve "No hay anuncios disponibles ahora".

  En debug, si AdMob no carga, aparece un diálogo simulado.
- **Privacidad:** Ajustes → Datos de uso muestra "Privacidad de los anuncios" cuando el jugador está en una región que lo exige.
- **Hoy:** se usan los ids de prueba de Google, que muestran anuncios de prueba, nunca reales.

## Para publicar (lo hacés vos, en L8)

1. **Cuenta y bloques de anuncios:** creá la cuenta de AdMob y las dos apps (iOS y Android). En cada app creá un bloque *Rewarded*.
2. **Ids de app:** reemplazá los ids de prueba por los de tus apps:
   - iOS: `GADApplicationIdentifier` en `ios/Runner/Info.plist`;
   - Android: `com.google.android.gms.ads.APPLICATION_ID` en `android/app/src/main/AndroidManifest.xml`.
3. **Ids de los bloques:** se pasan al compilar el release:

   ```bash
   flutter build ipa --dart-define=ADMOB_REWARDED_IOS=ca-app-pub-XXXX/YYYY
   flutter build appbundle --dart-define=ADMOB_REWARDED_ANDROID=ca-app-pub-XXXX/ZZZZ
   ```

4. **Formularios de consentimiento:** en AdMob → Privacidad y mensajes, creá el mensaje de GDPR. Sin ese mensaje, UMP no muestra formulario.
5. **app-ads.txt:** publicalo en el dominio del sitio de la app, el mismo de la política de privacidad.
6. **Productos de compra:**
   - en App Store Connect, como *Consumible*, y en Play Console, como *Producto integrado*, con los ids de `IapProducts`;
   - en Play, además, completá el perfil de pagos y en App Store Connect el acuerdo de apps pagas.

Esta fase no cambió los números. La economía sigue con el presupuesto de la skill `balance`: 4 anuncios de −30 min por día, unos 60 Denarios diarios.
