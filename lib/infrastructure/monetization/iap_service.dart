import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Product IDs — deben coincidir con App Store Connect / Play Console.
class IapProducts {
  static const aureos50 = 'messenger_aureos_50';
  static const aureos120 = 'messenger_aureos_120';
  static const aureos300 = 'messenger_aureos_300';
  static const aureos800 = 'messenger_aureos_800';
  static const starter = 'messenger_starter_pack';
  static const warrior = 'messenger_warrior_pack';

  static const all = {
    aureos50,
    aureos120,
    aureos300,
    aureos800,
    starter,
    warrior,
  };

  /// Mapeo ShopItem.id → productId de tienda.
  static String? productIdForShopItem(String shopItemId) => switch (shopItemId) {
        'aureos_small' => aureos50,
        'aureos_medium' => aureos120,
        'aureos_large' => aureos300,
        'aureos_mega' => aureos800,
        'bundle_starter' => starter,
        'bundle_warrior' => warrior,
        _ => null,
      };

  /// Inverso de [productIdForShopItem].
  static String? shopItemIdForProduct(String productId) => switch (productId) {
        aureos50 => 'aureos_small',
        aureos120 => 'aureos_medium',
        aureos300 => 'aureos_large',
        aureos800 => 'aureos_mega',
        starter => 'bundle_starter',
        warrior => 'bundle_warrior',
        _ => null,
      };
}

/// Por qué no se pudo abrir la compra. La UI lo traduce.
enum IapPurchaseError { startFailed, noResponse, storeUnavailable }

class IapPurchaseResult {
  final bool success;
  final String? productId;
  final IapPurchaseError? error;
  final bool usedSandbox;

  const IapPurchaseResult({
    required this.success,
    this.productId,
    this.error,
    this.usedSandbox = false,
  });
}

// ─── Estados de compra para la UI ─────────────────────────────────────────────

enum IapUpdateKind { credited, pending, canceled, failed }

/// Lo que pasó con una compra después de abrir la hoja de la tienda.
class IapUpdate {
  final IapUpdateKind kind;
  final String productId;
  const IapUpdate(this.kind, this.productId);
}

// ─── Registro de compras acreditadas ──────────────────────────────────────────

/// Ids de transacción ya acreditadas. La tienda puede volver a entregar una
/// compra (reinicio, error al cerrarla); con esto nunca se acredita dos veces.
/// Viaja con la partida a la nube.
class PurchaseLedger {
  static const kKey = 'iap_credited_v1';
  static const _max = 200;

  Future<bool> contains(String transactionId) async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(kKey) ?? const []).contains(transactionId);
  }

  Future<void> add(String transactionId) async {
    final p = await SharedPreferences.getInstance();
    final ids = [...?p.getStringList(kKey), transactionId];
    await p.setStringList(
        kKey, ids.length > _max ? ids.sublist(ids.length - _max) : ids);
  }
}

/// Id único de una transacción (purchaseID; si la tienda no lo da, producto
/// y fecha).
String transactionIdOf(PurchaseDetails p) {
  // En Play, los códigos promocionales pueden traer purchaseID vacío: ahí
  // el token de compra es lo único que distingue una de otra.
  final id = p.purchaseID;
  if (id != null && id.isNotEmpty) return id;
  final token = p.verificationData.serverVerificationData;
  if (token.isNotEmpty) return token;
  return '${p.productID}@${p.transactionDate ?? ''}';
}

/// Integra `in_app_purchase`. Si la tienda no está disponible (sim/dev sin
/// productos), en debug acredita vía sandbox para poder playtestear la economía.
class IapService {
  /// Acredita una compra confirmada por la tienda. Se llama ANTES de cerrar
  /// la transacción: si falla, la tienda la vuelve a entregar al reabrir.
  /// Solo el crédito: lo demás va en [onCredited], así un error ahí no
  /// deja la compra fuera del registro (y acreditada otra vez al reabrir).
  final Future<void> Function(String productId)? onPurchased;

  /// Efectos después de anotar la compra (analytics, tareas, refrescar).
  /// Sus errores se ignoran: la compra ya está acreditada.
  final Future<void> Function(String productId)? onCredited;
  final PurchaseLedger ledger;
  final Future<void> Function(PurchaseDetails)? _complete;

  IapService({
    this.onPurchased,
    this.onCredited,
    PurchaseLedger? ledger,
    Future<void> Function(PurchaseDetails)? complete,
  })  : ledger = ledger ?? PurchaseLedger(),
        _complete = complete;

  late final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _available = false;
  final Map<String, ProductDetails> _products = {};
  final _updates = StreamController<IapUpdate>.broadcast();

  bool get isAvailable => _available;
  bool get hasProducts => _products.isNotEmpty;

  /// Créditos, pendientes, cancelaciones y errores, para avisar al jugador.
  Stream<IapUpdate> get updates => _updates.stream;

  Future<void> init() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        debugPrint('IAP: store not available');
        return;
      }
      _sub = _iap.purchaseStream.listen(handlePurchases, onError: (e) {
        debugPrint('IAP stream error: $e');
      });
      final response = await _iap.queryProductDetails(IapProducts.all);
      for (final p in response.productDetails) {
        _products[p.id] = p;
      }
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IAP products not found: ${response.notFoundIDs}');
      }
    } catch (e) {
      debugPrint('IAP init failed: $e');
      _available = false;
    }
  }

  ProductDetails? product(String productId) => _products[productId];

  /// Precio de la tienda, en la moneda y el formato del jugador. Null si la
  /// tienda no cargó el producto.
  String? localizedPrice(String shopItemId) {
    final id = IapProducts.productIdForShopItem(shopItemId);
    return id == null ? null : _products[id]?.price;
  }

  /// Compra real si hay producto; si no, sandbox en debug.
  Future<IapPurchaseResult> purchase(String productId) async {
    final details = _products[productId];
    if (details != null && _available) {
      final param = PurchaseParam(productDetails: details);
      try {
        final ok = await _iap.buyConsumable(purchaseParam: param);
        if (!ok) {
          return const IapPurchaseResult(
              success: false, error: IapPurchaseError.startFailed);
        }
      } catch (e) {
        debugPrint('IAP buy failed: $e');
        return const IapPurchaseResult(
            success: false, error: IapPurchaseError.noResponse);
      }
      // El crédito llega por purchaseStream y se avisa por [updates].
      return IapPurchaseResult(success: true, productId: productId);
    }

    if (kDebugMode || kProfileMode) {
      debugPrint('IAP sandbox credit for $productId');
      return IapPurchaseResult(
        success: true,
        productId: productId,
        usedSandbox: true,
      );
    }

    return const IapPurchaseResult(
      success: false,
      error: IapPurchaseError.storeUnavailable,
    );
  }

  Future<void> restore() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  // Las entregas de la tienda se procesan de a una: dos emisiones con la
  // misma transacción no pueden pasar las dos el chequeo del registro.
  Future<void> _handling = Future.value();

  /// Procesa lo que entrega la tienda. Público para los tests.
  Future<void> handlePurchases(List<PurchaseDetails> purchases) {
    final next = _handling.then((_) => _handlePurchases(purchases));
    _handling = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final id = purchase.productID;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _updates.add(IapUpdate(IapUpdateKind.pending, id));
          continue; // se cierra cuando llegue purchased o error
        case PurchaseStatus.canceled:
          _updates.add(IapUpdate(IapUpdateKind.canceled, id));
        case PurchaseStatus.error:
          debugPrint('IAP purchase error: ${purchase.error}');
          _updates.add(IapUpdate(IapUpdateKind.failed, id));
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Son consumibles: restored solo llega por errores de la tienda y
          // se trata igual, con el registro evitando el doble crédito.
          final tx = transactionIdOf(purchase);
          if (!await ledger.contains(tx)) {
            try {
              await onPurchased?.call(id);
              await ledger.add(tx);
            } catch (e) {
              // Sin cerrar: la tienda la vuelve a entregar en el próximo inicio.
              debugPrint('IAP credit failed for $id: $e');
              _updates.add(IapUpdate(IapUpdateKind.failed, id));
              continue;
            }
            try {
              await onCredited?.call(id);
            } catch (e) {
              debugPrint('IAP post-credit failed for $id: $e');
            }
            _updates.add(IapUpdate(IapUpdateKind.credited, id));
          }
      }
      if (purchase.pendingCompletePurchase) {
        await (_complete ?? _iap.completePurchase)(purchase);
      }
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _updates.close();
  }
}
