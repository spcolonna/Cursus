import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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

class IapPurchaseResult {
  final bool success;
  final String? productId;
  final String? error;
  final bool usedSandbox;

  const IapPurchaseResult({
    required this.success,
    this.productId,
    this.error,
    this.usedSandbox = false,
  });
}

/// Integra `in_app_purchase`. Si la tienda no está disponible (sim/dev sin
/// productos), en debug acredita vía sandbox para poder playtestear la economía.
class IapService {
  /// Acredita una compra confirmada por la tienda. Se llama ANTES de cerrar
  /// la transacción: si falla, la tienda la vuelve a entregar al reabrir.
  final Future<void> Function(String productId)? onPurchased;
  IapService({this.onPurchased});

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _available = false;
  final Map<String, ProductDetails> _products = {};

  bool get isAvailable => _available;
  bool get hasProducts => _products.isNotEmpty;

  Future<void> init() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        debugPrint('IAP: store not available');
        return;
      }
      _sub = _iap.purchaseStream.listen(_onPurchases, onError: (e) {
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

  /// Compra real si hay producto; si no, sandbox en debug.
  Future<IapPurchaseResult> purchase(String productId) async {
    final details = _products[productId];
    if (details != null && _available) {
      final param = PurchaseParam(productDetails: details);
      final ok = await _iap.buyConsumable(purchaseParam: param);
      if (!ok) {
        return const IapPurchaseResult(
            success: false, error: 'No se pudo iniciar la compra');
      }
      // El crédito real llega por purchaseStream; el caller en shop usa
      // sandbox inmediato solo cuando no hay store.
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
      error:
          'Compras no disponibles. Configurá los productos en App Store / Play Console.',
    );
  }

  Future<void> restore() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        try {
          await onPurchased?.call(purchase.productID);
        } catch (e) {
          // Sin completar: la tienda reintenta la entrega en el próximo inicio.
          debugPrint('IAP credit failed for ${purchase.productID}: $e');
          continue;
        }
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('IAP purchase error: ${purchase.error}');
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
