import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_messenger/infrastructure/cloud/local_save_store.dart';
import 'package:the_messenger/infrastructure/monetization/iap_service.dart';
import 'package:the_messenger/infrastructure/monetization/rewarded_ads_service.dart';
import 'package:the_messenger/presentation/screens/shop/shop_screen.dart';

PurchaseDetails _purchase(
  PurchaseStatus status, {
  String? id = 'tx1',
  String product = IapProducts.aureos50,
}) =>
    PurchaseDetails(
      purchaseID: id,
      productID: product,
      verificationData: PurchaseVerificationData(
          localVerificationData: '', serverVerificationData: '', source: 'test'),
      transactionDate: '1',
      status: status,
    )..pendingCompletePurchase = true;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // ─── Compras ────────────────────────────────────────────────────────────────

  group('IapService', () {
    late List<String> credited;
    late List<String> completed;
    late List<IapUpdateKind> updates;
    late IapService iap;

    setUp(() {
      credited = [];
      completed = [];
      updates = [];
      iap = IapService(
        onPurchased: (id) async => credited.add(id),
        complete: (p) async => completed.add(p.purchaseID!),
      );
      iap.updates.listen((u) => updates.add(u.kind));
    });

    test('acredita una vez aunque la tienda la entregue de nuevo', () async {
      await iap.handlePurchases([_purchase(PurchaseStatus.purchased)]);
      await iap.handlePurchases([_purchase(PurchaseStatus.purchased)]);
      await iap.handlePurchases([_purchase(PurchaseStatus.restored)]);
      await pumpEventQueue();
      expect(credited, [IapProducts.aureos50]);
      expect(completed, ['tx1', 'tx1', 'tx1']); // siempre se cierra
      expect(updates, [IapUpdateKind.credited]);
    });

    test('transacciones distintas del mismo producto suman', () async {
      await iap.handlePurchases([
        _purchase(PurchaseStatus.purchased, id: 'a'),
        _purchase(PurchaseStatus.purchased, id: 'b'),
      ]);
      expect(credited.length, 2);
    });

    test('pendiente: avisa y no cierra ni acredita', () async {
      await iap.handlePurchases([_purchase(PurchaseStatus.pending)]);
      await pumpEventQueue();
      expect(credited, isEmpty);
      expect(completed, isEmpty);
      expect(updates, [IapUpdateKind.pending]);
    });

    test('cancelada y con error: avisa, cierra y no acredita', () async {
      await iap.handlePurchases([
        _purchase(PurchaseStatus.canceled, id: 'c'),
        _purchase(PurchaseStatus.error, id: 'e'),
      ]);
      await pumpEventQueue();
      expect(credited, isEmpty);
      expect(completed, ['c', 'e']);
      expect(updates, [IapUpdateKind.canceled, IapUpdateKind.failed]);
    });

    test('si acreditar falla, no se cierra (la tienda la reintenta)', () async {
      final failing = IapService(
        onPurchased: (_) async => throw StateError('disco lleno'),
        complete: (p) async => completed.add(p.purchaseID!),
      );
      await failing.handlePurchases([_purchase(PurchaseStatus.purchased)]);
      expect(completed, isEmpty);
      expect(await failing.ledger.contains('tx1'), isFalse);
    });

    test('un error después del crédito no lo repite', () async {
      final iap2 = IapService(
        onPurchased: (id) async => credited.add(id),
        onCredited: (_) async => throw StateError('tarea'),
        complete: (p) async => completed.add(p.purchaseID!),
      );
      await iap2.handlePurchases([_purchase(PurchaseStatus.purchased, id: 'x')]);
      await iap2.handlePurchases([_purchase(PurchaseStatus.purchased, id: 'x')]);
      expect(credited, [IapProducts.aureos50]);
      expect(completed, ['x', 'x']);
    });

    test('el registro de compras viaja con la partida', () {
      expect(kCloudSaveKeys, contains(PurchaseLedger.kKey));
    });

    test('id de transacción de respaldo sin purchaseID', () {
      expect(transactionIdOf(_purchase(PurchaseStatus.purchased, id: null)),
          '${IapProducts.aureos50}@1');
    });
  });

  // ─── Precios ────────────────────────────────────────────────────────────────

  group('Precios', () {
    final item = shopCatalogue.firstWhere((i) => i.id == 'aureos_small');

    test('usa el precio localizado de la tienda', () {
      expect(realMoneyLabel(item, r'ARS 2.499,00'), r'ARS 2.499,00');
    });

    test('sin tienda, el de referencia en USD', () {
      expect(realMoneyLabel(item, null), r'US$1.99');
      expect(realMoneyLabel(item, ''), r'US$1.99');
    });

    test('todo producto de dinero real tiene id de tienda', () {
      for (final i in shopCatalogue
          .where((i) => i.currency == PriceCurrency.realMoney)) {
        expect(IapProducts.productIdForShopItem(i.id), isNotNull, reason: i.id);
      }
    });
  });

  // ─── Anuncios ───────────────────────────────────────────────────────────────

  group('AdUnits', () {
    test('debug y sin ids reales: los de prueba de Google', () {
      expect(AdUnits.rewarded(ios: true, release: false),
          startsWith('ca-app-pub-3940256099942544/'));
      expect(AdUnits.rewarded(ios: false, release: true),
          startsWith('ca-app-pub-3940256099942544/'));
    });
  });
}
