import 'package:intl/intl.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feedback/feedback.dart';
import '../../../domain/entities/analytics.dart';
import '../../providers/providers.dart';
import '../../widgets/messenger_avatar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../infrastructure/monetization/iap_service.dart';
import '../../../infrastructure/progress/player_progress.dart';
import '../../widgets/primeros_pasos.dart';
import '../../../l10n/app_localizations.dart';

// ─── Shop Item Model ──────────────────────────────────────────────────────────
enum ShopCategory { boosters, skills, aureosPacks, bundles }

extension ShopCategoryX on ShopCategory {
  String label(AppLocalizations l) => switch (this) {
        ShopCategory.boosters => l.shopCatBoosters,
        ShopCategory.skills => l.shopCatSkills,
        ShopCategory.aureosPacks => l.shopCatAurei,
        ShopCategory.bundles => l.shopCatBundles,
      };
  IconData get icon => switch (this) {
        ShopCategory.boosters => Icons.bolt,
        ShopCategory.skills => Icons.auto_awesome,
        ShopCategory.aureosPacks => Icons.monetization_on,
        ShopCategory.bundles => Icons.card_giftcard,
      };
}

/// Con qué se paga un item de la tienda (incluye dinero real).
enum PriceCurrency { denarios, aureos, realMoney }

class ShopItem {
  final String id;
  final ShopCategory category;
  final int price;
  final PriceCurrency currency;
  final IconData icon;
  final Color color;
  final String? tag; // "POPULAR", "MEJOR VALOR", etc.
  final bool isLimited;
  final int?
      dinariosReward; // if category == aureosPacks, how many aureos given
  final int? aureosReward;
  /// Solo se vende con este flag de historia (premio de un final).
  final String? requiredFlag;

  const ShopItem({
    required this.id,
    required this.category,
    required this.price,
    required this.currency,
    required this.icon,
    required this.color,
    this.tag,
    this.isLimited = false,
    this.dinariosReward,
    this.aureosReward,
    this.requiredFlag,
  });
}


// ─── Textos de cada item (por id) ──────────────────────────────────────────────
extension ShopItemText on ShopItem {
  String name(AppLocalizations l) => switch (id) {
        'boost_health_small' => l.shopItemBoostHealthSmallName,
        'boost_health_full' => l.shopItemBoostHealthFullName,
        'boost_fatigue' => l.shopItemBoostFatigueName,
        'boost_speed' => l.shopItemBoostSpeedName,
        'boost_events' => l.shopItemBoostEventsName,
        'boost_events_black' => l.shopItemBoostEventsBlackName,
        'skill_speed_1' => l.shopItemSkillSpeed1Name,
        'skill_stealth_1' => l.shopItemSkillStealth1Name,
        'skill_combat_1' => l.shopItemSkillCombat1Name,
        'skill_survival_1' => l.shopItemSkillSurvival1Name,
        'skill_contacts_1' => l.shopItemSkillContacts1Name,
        'aureos_small' => l.shopItemAureosSmallName,
        'aureos_medium' => l.shopItemAureosMediumName,
        'aureos_large' => l.shopItemAureosLargeName,
        'aureos_mega' => l.shopItemAureosMegaName,
        'bundle_starter' => l.shopItemBundleStarterName,
        'bundle_warrior' => l.shopItemBundleWarriorName,
        'seal_single' => l.shopItemSealSingleName,
        'seal_pack_10' => l.shopItemSealPack10Name,
        _ => id,
      };

  String description(AppLocalizations l) => switch (id) {
        'boost_health_small' => l.shopItemBoostHealthSmallDesc,
        'boost_health_full' => l.shopItemBoostHealthFullDesc,
        'boost_fatigue' => l.shopItemBoostFatigueDesc,
        'boost_speed' => l.shopItemBoostSpeedDesc,
        'boost_events' => l.shopItemBoostEventsDesc,
        'boost_events_black' => l.shopItemBoostEventsBlackDesc,
        'skill_speed_1' => l.shopItemSkillSpeed1Desc,
        'skill_stealth_1' => l.shopItemSkillStealth1Desc,
        'skill_combat_1' => l.shopItemSkillCombat1Desc,
        'skill_survival_1' => l.shopItemSkillSurvival1Desc,
        'skill_contacts_1' => l.shopItemSkillContacts1Desc,
        'aureos_small' => l.shopItemAureosSmallDesc,
        'aureos_medium' => l.shopItemAureosMediumDesc,
        'aureos_large' => l.shopItemAureosLargeDesc,
        'aureos_mega' => l.shopItemAureosMegaDesc,
        'bundle_starter' => l.shopItemBundleStarterDesc,
        'bundle_warrior' => l.shopItemBundleWarriorDesc,
        'seal_single' => l.shopItemSealSingleDesc,
        'seal_pack_10' => l.shopItemSealPack10Desc,
        _ => '',
      };
}

// ─── Shop Catalogue ───────────────────────────────────────────────────────────
final shopCatalogue = <ShopItem>[
  // ── Potenciadores (Denarios) ──────────────────────────────────────────────
  const ShopItem(
    id: 'boost_health_small',
    category: ShopCategory.boosters,
    price: 50,
    currency: PriceCurrency.denarios,
    icon: Icons.favorite,
    color: AppColors.cinnabar,
  ),
  const ShopItem(
    id: 'boost_health_full',
    category: ShopCategory.boosters,
    price: 120,
    currency: PriceCurrency.denarios,
    icon: Icons.healing,
    color: AppColors.cinnabar,
    tag: 'POPULAR',
  ),
  const ShopItem(
    id: 'boost_fatigue',
    category: ShopCategory.boosters,
    price: 80,
    currency: PriceCurrency.denarios,
    icon: Icons.hotel,
    color: AppColors.egyptianBlue,
  ),
  const ShopItem(
    id: 'boost_speed',
    category: ShopCategory.boosters,
    price: 3,
    currency: PriceCurrency.aureos,
    icon: Icons.speed,
    color: AppColors.sienna,
    tag: 'PREMIUM',
  ),
  const ShopItem(
    id: 'boost_events',
    category: ShopCategory.boosters,
    price: 5,
    currency: PriceCurrency.aureos,
    icon: Icons.map,
    color: AppColors.ochreDeep,
    tag: 'POPULAR',
  ),
  // Final "El que lleva el libro" (arco 2): el mercado de la noche de la
  // Viuda vende el mismo mapa en Denarios. Solo información: no suma score.
  const ShopItem(
    id: 'boost_events_black',
    category: ShopCategory.boosters,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.map_outlined,
    color: AppColors.tyrian,
    tag: 'MERCADO NEGRO',
    requiredFlag: 'ending_lucius_book',
  ),

  // ── Habilidades (Denarios) ────────────────────────────────────────────────
  const ShopItem(
    id: 'skill_speed_1',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.bolt,
    color: AppColors.egyptianBlue,
  ),
  const ShopItem(
    id: 'skill_stealth_1',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.visibility_off,
    color: AppColors.tyrian,
  ),
  const ShopItem(
    id: 'skill_combat_1',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.shield,
    color: AppColors.cinnabar,
  ),
  const ShopItem(
    id: 'skill_survival_1',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.eco,
    color: AppColors.verdigris,
  ),
  const ShopItem(
    id: 'skill_contacts_1',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.people,
    color: AppColors.ochreDeep,
  ),

  // ── Paquetes de Aureos (real money) ───────────────────────────────────────
  const ShopItem(
    id: 'aureos_small',
    category: ShopCategory.aureosPacks,
    price: 199, currency: PriceCurrency.realMoney, // en centavos USD → $1.99
    icon: Icons.monetization_on, color: AppColors.ochreDeep,
    aureosReward: 50,
  ),
  const ShopItem(
    id: 'aureos_medium',
    category: ShopCategory.aureosPacks,
    price: 399, currency: PriceCurrency.realMoney, // $3.99
    icon: Icons.savings, color: AppColors.ochreDeep,
    tag: 'POPULAR',
    aureosReward: 120,
  ),
  const ShopItem(
    id: 'aureos_large',
    category: ShopCategory.aureosPacks,
    price: 799, currency: PriceCurrency.realMoney, // $7.99
    icon: Icons.workspace_premium, color: AppColors.sienna,
    tag: 'MEJOR VALOR',
    aureosReward: 300,
  ),
  const ShopItem(
    id: 'aureos_mega',
    category: ShopCategory.aureosPacks,
    price: 1999, currency: PriceCurrency.realMoney, // $19.99
    icon: Icons.account_balance, color: AppColors.sienna,
    tag: 'VIP',
    aureosReward: 800,
    dinariosReward: 500,
  ),

  // ── Paquetes bundle ───────────────────────────────────────────────────────
  const ShopItem(
    id: 'bundle_starter',
    category: ShopCategory.bundles,
    price: 299, currency: PriceCurrency.realMoney, // $2.99
    icon: Icons.card_giftcard, color: AppColors.verdigris,
    tag: 'OFERTA',
    aureosReward: 30,
    isLimited: true,
  ),
  const ShopItem(
    id: 'bundle_warrior',
    category: ShopCategory.bundles,
    price: 699,
    currency: PriceCurrency.realMoney,
    icon: Icons.military_tech,
    color: AppColors.sienna,
    tag: 'POPULAR',
    aureosReward: 50,
  ),

  // ── Sellos (sink de Aureos, GDD §5.3) ─────────────────────────────────────
  const ShopItem(
    id: 'seal_single',
    category: ShopCategory.boosters,
    price: 15,
    currency: PriceCurrency.aureos,
    icon: Icons.verified,
    color: AppColors.sienna,
    tag: 'ÉLITE',
  ),
  const ShopItem(
    id: 'seal_pack_10',
    category: ShopCategory.boosters,
    price: 120,
    currency: PriceCurrency.aureos,
    icon: Icons.workspace_premium,
    color: AppColors.ochreDeep,
    tag: 'PACK',
  ),
];

// ─── Shop Screen ──────────────────────────────────────────────────────────────
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});
  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopCategory _activeTab = ShopCategory.boosters;
  String? _purchasedId;

  /// Mensajero que recibe el efecto (pociones, manuales, boosts).
  String? _targetId;
  static bool _spotlightShown = false;
  StreamSubscription<IapUpdate>? _iapSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSpotlight());
    _iapSub = ref.read(iapServiceProvider).updates.listen(_onIapUpdate);
  }

  @override
  void dispose() {
    _iapSub?.cancel();
    super.dispose();
  }

  /// La tienda confirmó, dejó pendiente, canceló o falló una compra.
  void _onIapUpdate(IapUpdate u) {
    if (!mounted) return;
    final itemId = IapProducts.shopItemIdForProduct(u.productId);
    final item = shopCatalogue.where((i) => i.id == itemId).firstOrNull;
    switch (u.kind) {
      case IapUpdateKind.credited:
        if (item == null) return;
        AppFeedback.reward();
        setState(() => _purchasedId = item.id);
        _showPurchaseToast(item, item.name(AppLocalizations.of(context)));
      case IapUpdateKind.pending:
        showGameSnack(context, AppLocalizations.of(context).shopPending);
      case IapUpdateKind.canceled:
        showGameSnack(context, AppLocalizations.of(context).shopCanceled);
      case IapUpdateKind.failed:
        showGameSnack(context, AppLocalizations.of(context).shopFailed,
            isError: true);
    }
  }

  void _showPurchaseToast(ShopItem item, String note) {
    showRewardToast(
      context,
      [
        if (item.aureosReward != null)
          (type: CurrencyType.aureos, amount: item.aureosReward!),
        if (item.dinariosReward != null)
          (type: CurrencyType.denarios, amount: item.dinariosReward!),
      ],
      note: note,
    );
  }

  Future<void> _maybeSpotlight() async {
    if (_spotlightShown || !mounted) return;
    final progress = ref.read(playerProgressProvider);
    final seen = await progress.shopTooltipSeen;
    if (!mounted || seen) return;
    _spotlightShown = true;
    await maybeShowSpotlight(
      context: context,
      alreadySeen: false,
      onSeen: () => progress.markShopTooltipSeen(),
      title: AppLocalizations.of(context).shopSpotlightTitle,
      body: AppLocalizations.of(context).shopSpotlightBody,
    );
  }

  List<ShopItem> get _items {
    final flags = ref.watch(worldProvider).valueOrNull?.flags ?? const {};
    return shopCatalogue
        .where((i) => i.category == _activeTab)
        .where((i) => i.requiredFlag == null || flags.contains(i.requiredFlag))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider).valueOrNull;
    final items = _items;
    // Billetera común: la del principal. El efecto va al mensajero elegido.
    final messenger = home?.messenger;
    final target = home?.slotFor(_targetId)?.messenger;
    final showTarget = (home?.slots.length ?? 0) > 1 &&
        (_activeTab == ShopCategory.boosters ||
            _activeTab == ShopCategory.skills);

    return GradientScaffold(
      body: SafeArea(
        child: Column(children: [
          _TopBar(messenger: messenger),
          _TabRow(
            active: _activeTab,
            onTap: (c) => setState(() => _activeTab = c),
          ),
          if (showTarget)
            _TargetSelector(
              messengers: home!.slots.map((s) => s.messenger).toList(),
              selectedId: target!.id,
              onSelect: (id) => setState(() => _targetId = id),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
              itemCount: items.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ShopCard(
                  item: items[i],
                  messenger: messenger,
                  price: _priceFor(items[i], target),
                  storePrice: ref
                      .read(iapServiceProvider)
                      .localizedPrice(items[i].id),
                  justBought: _purchasedId == items[i].id,
                  onBuy: () => _buy(items[i], target),
                )
                    .animate(delay: AppMotion.stagger * i.clamp(0, 8))
                    .fadeIn(duration: AppMotion.of(context, AppMotion.base))
                    .slideY(begin: 0.08, end: 0),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /// Precio efectivo para [target]: los manuales escalan con el nivel.
  /// null = no se puede comprar (skill ya en el máximo).
  int? _priceFor(ShopItem item, Messenger? target) {
    final skill = manualSkillFor(item.id);
    if (skill == null || target == null) return item.price;
    return manualPriceFor(target.skillLevel(skill));
  }

  // Un doble toque no cobra dos veces.
  bool _buying = false;

  Future<void> _buy(ShopItem item, Messenger? target) async {
    if (_buying) return;
    _buying = true;
    try {
      await _buyNow(item, target);
    } finally {
      _buying = false;
    }
  }

  Future<void> _buyNow(ShopItem item, Messenger? target) async {
    final messenger = ref.read(homeProvider).valueOrNull?.messenger;
    if (messenger == null || target == null) return;

    // Real money → show paywall dialog (fictitious for now)
    if (item.currency == PriceCurrency.realMoney) {
      await _showPaywallDialog(item);
      return;
    }

    var price = _priceFor(item, target);
    if (price == null) return; // botón deshabilitado: skill al máximo
    var currency = item.currency;

    // Soft currency check
    final balance = currency == PriceCurrency.denarios
        ? messenger.denarios
        : messenger.aureos;
    // Un manual sin Denarios suficientes se puede pagar con Aureos: es el
    // atajo para quien no quiere esperar a juntarlos.
    final skill = manualSkillFor(item.id);
    final aureosPrice =
        skill == null ? null : manualAureosPriceFor(target.skillLevel(skill));
    var payWithAureos = false;
    if (balance < price && aureosPrice != null) {
      final ok = await showGameDialog<bool>(
        context,
        builder: (_) => _ManualAureosDialog(
            denarios: price!, aureos: aureosPrice, have: messenger.aureos),
      );
      if (ok != true || !mounted) return;
      if (messenger.aureos < aureosPrice) {
        _showInsufficientFunds(PriceCurrency.aureos);
        return;
      }
      payWithAureos = true;
      price = aureosPrice;
      currency = PriceCurrency.aureos;
    } else if (balance < price) {
      _showInsufficientFunds(currency);
      return;
    }

    // El use case cobra (validando saldo) y aplica el efecto real del item.
    try {
      await ref.read(applyShopItemUseCaseProvider).execute(
            targetId: target.id,
            itemId: item.id,
            denariosCost: currency == PriceCurrency.denarios ? price : 0,
            aureosCost: currency == PriceCurrency.aureos ? price : 0,
            payWithAureos: payWithAureos,
          );
      ref.read(analyticsProvider).track(AnalyticsEvent.shopItem(
            itemId: item.id,
            currency: currency.name,
            price: price,
          ));
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
      return;
    }
    AppFeedback.reward();
    ref.invalidate(homeProvider);
    ref.read(cloudSyncProvider).markDirty();
    if (manualSkillFor(item.id) != null) {
      await ref
          .read(primerosPasosProvider.notifier)
          .markTask(PlayerProgress.taskLevelSkill);
    }
    await ref
        .read(primerosPasosProvider.notifier)
        .markTask(PlayerProgress.taskBuyItem);

    if (mounted) {
      // El gasto también es feedback: que se vea salir la moneda.
      showRewardToast(
        context,
        [
          (
            type: currency == PriceCurrency.denarios
                ? CurrencyType.denarios
                : CurrencyType.aureos,
            amount: -price,
          ),
        ],
        note: item.name(AppLocalizations.of(context)),
      );
      _showEffectApplied(item);
    }

    if (!mounted) return;
    setState(() => _purchasedId = item.id);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _purchasedId = null);
  }

  void _showEffectApplied(ShopItem item) {
    final l = AppLocalizations.of(context);
    final msg = switch (item.id) {
      'boost_health_small' => l.shopEffectHealthSmall,
      'boost_health_full' => l.shopEffectHealthFull,
      'boost_fatigue' => l.shopEffectFatigue,
      'boost_speed' => l.shopEffectSpeed,
      'boost_events' || 'boost_events_black' => l.shopEffectMap,
      'skill_speed_1' ||
      'skill_stealth_1' ||
      'skill_combat_1' ||
      'skill_survival_1' ||
      'skill_contacts_1' =>
        l.shopEffectSkill,
      _ => l.shopEffectApplied,
    };
    showGameSnack(context, msg);
  }

  Future<void> _showPaywallDialog(ShopItem item) async {
    await showGameDialog(
      context,
      builder: (_) => _PaywallDialog(
        item: item,
        priceLabel: realMoneyLabel(
            item, ref.read(iapServiceProvider).localizedPrice(item.id)),
        onConfirm: () => _purchaseIap(item),
      ),
    );
  }

  Future<void> _purchaseIap(ShopItem item) async {
    final productId = IapProducts.productIdForShopItem(item.id);
    if (productId == null) {
      if (!mounted) return;
      showGameSnack(context, AppLocalizations.of(context).shopUnavailable,
          isError: true);
      return;
    }

    final result = await ref.read(iapServiceProvider).purchase(productId);
    if (!mounted) return;

    if (!result.success) {
      final l = AppLocalizations.of(context);
      final message = switch (result.error) {
        IapPurchaseError.startFailed => l.shopStartFailed,
        IapPurchaseError.noResponse => l.shopNoResponse,
        IapPurchaseError.storeUnavailable => l.shopStoreUnavailable,
        null => l.shopCanceled,
      };
      showGameSnack(context, message, isError: true);
      return;
    }

    // Sandbox (debug sin productos de store): acreditamos ya. Con tienda
    // real, el crédito llega por el stream de compras y se avisa en
    // _onIapUpdate.
    if (result.usedSandbox) await _creditIap(item);
  }

  Future<void> _creditIap(ShopItem item) async {
    try {
      await ref.read(creditPurchaseUseCaseProvider).execute(item.id);
      ref.read(analyticsProvider).track(AnalyticsEvent.iapCredited(item.id));
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
      return;
    }

    AppFeedback.reward();
    ref.invalidate(homeProvider);
    await ref
        .read(primerosPasosProvider.notifier)
        .markTask(PlayerProgress.taskBuyItem);

    if (!mounted) return;
    _showPurchaseToast(
        item,
        AppLocalizations.of(context)
            .shopSandbox(item.name(AppLocalizations.of(context))));
  }

  void _showInsufficientFunds(PriceCurrency type) {
    final l = AppLocalizations.of(context);
    showGameSnack(
        context,
        type == PriceCurrency.denarios
            ? l.shopNoDenarii
            : l.shopNoAurei,
        isError: true);
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final Messenger? messenger;
  const _TopBar({required this.messenger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        gradient: AppGradients.header,
        border: Border(
            bottom: BorderSide(
                color: AppColors.ochreDeep.withValues(alpha: 0.3), width: 2)),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        GameBackButton(onTap: () => Navigator.of(context).pop()),
        const SizedBox(width: 10),
        Expanded(
          child: Text(AppLocalizations.of(context).shopTitle,
              style: AppTextStyles.heading(18,
                  color: AppColors.ochreDeep,
                  letterSpacing: 1)),
        ),
        // Wallet display
        if (messenger != null) ...[
          CurrencyChip(type: CurrencyType.denarios, value: messenger!.denarios),
          const SizedBox(width: 6),
          CurrencyChip(type: CurrencyType.aureos, value: messenger!.aureos),
          const SizedBox(width: 6),
          CurrencyChip(type: CurrencyType.seals, value: messenger!.seals),
        ],
      ]),
    );
  }
}

// ─── Tab Row ──────────────────────────────────────────────────────────────────
class _TabRow extends StatelessWidget {
  final ShopCategory active;
  final void Function(ShopCategory) onTap;
  const _TabRow({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.paperDeep,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: ShopCategory.values.map((cat) {
          final selected = cat == active;
          return GestureDetector(
            onTap: () {
              AppFeedback.tap();
              onTap(cat);
            },
            child: AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.base),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected ? AppGradients.ochre : null,
                color: selected ? null : AppColors.paperDeep,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.ink : AppColors.paperLine,
                  width: selected ? 2.5 : 2,
                ),
                boxShadow: selected
                    ? [
                        const BoxShadow(
                            color: AppColors.ink,
                            offset: Offset(0, 3),
                            blurRadius: 0)
                      ]
                    : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(cat.icon,
                    size: 14,
                    color:
                        selected ? AppColors.ink : AppColors.inkSoft),
                const SizedBox(width: 6),
                Text(cat.label(AppLocalizations.of(context)),
                    style: AppTextStyles.ui(13,
                        color: selected
                            ? AppColors.ink
                            : AppColors.inkSoft,
                        weight:
                            selected ? FontWeight.bold : FontWeight.normal)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Para quién es la compra ──────────────────────────────────────────────────
class _TargetSelector extends StatelessWidget {
  final List<Messenger> messengers;
  final String selectedId;
  final ValueChanged<String> onSelect;
  const _TargetSelector({
    required this.messengers,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(children: [
        Text(AppLocalizations.of(context).shopFor,
            style: AppTextStyles.ui(13, color: AppColors.inkSoft)),
        const SizedBox(width: 8),
        for (final m in messengers) ...[
          GestureDetector(
            onTap: () {
              AppFeedback.tap();
              onSelect(m.id);
            },
            child: AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.base),
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color:
                    m.id == selectedId ? AppColors.paper : AppColors.paperDeep,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                    color:
                        m.id == selectedId ? AppColors.ochreDeep : AppColors.paperLine,
                    width: m.id == selectedId ? 2.5 : 1.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                MessengerAvatar.from(m, size: 22),
                const SizedBox(width: 6),
                Text(m.name,
                    style: AppTextStyles.ui(13,
                        color: m.id == selectedId
                            ? AppColors.ochreDeep
                            : AppColors.inkSoft,
                        weight: FontWeight.bold)),
              ]),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ]),
    );
  }
}

// ─── Shop Card ────────────────────────────────────────────────────────────────
class _ShopCard extends StatelessWidget {
  final ShopItem item;
  final Messenger? messenger;

  /// Precio efectivo (los manuales escalan); null = no disponible.
  final int? price;

  /// Precio de la tienda en la moneda del jugador (solo dinero real).
  final String? storePrice;
  final bool justBought;
  final VoidCallback onBuy;
  const _ShopCard({
    required this.item,
    required this.messenger,
    required this.price,
    this.storePrice,
    required this.justBought,
    required this.onBuy,
  });

  bool get canAfford {
    if (messenger == null || price == null) return false;
    if (item.currency == PriceCurrency.realMoney) return true;
    final bal = item.currency == PriceCurrency.denarios
        ? messenger!.denarios
        : messenger!.aureos;
    return bal >= price!;
  }

  String priceLabel(AppLocalizations l) {
    if (price == null) return l.shopMax;
    if (item.currency == PriceCurrency.realMoney) {
      return realMoneyLabel(item, storePrice);
    }
    return NumberFormat.decimalPattern().format(price);
  }

  @override
  Widget build(BuildContext context) {
    final isRealMoney = item.currency == PriceCurrency.realMoney;
    final l = AppLocalizations.of(context);

    return GameCard(
      borderColor: justBought
          ? AppColors.verdigris
          : item.isLimited
              ? AppColors.cinnabar.withValues(alpha: 0.6)
              : AppColors.paperLine,
      gradient: justBought ? AppGradients.verdigrisTint : null,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Icon box
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: item.color.withValues(alpha: 0.5), width: 2.5),
          ),
          child: Center(
            child: justBought
                ? const Icon(Icons.check_circle,
                    color: AppColors.verdigris, size: 28)
                : Icon(item.icon, color: item.color, size: 26),
          ),
        ),
        const SizedBox(width: 12),
        // Text
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(item.name(l),
                    style: AppTextStyles.ui(15, weight: FontWeight.bold)),
              ),
              if (item.tag != null) _Tag(label: item.tag!, item: item),
            ]),
            const SizedBox(height: 3),
            Text(item.description(l),
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            // Reward preview for aureo packs
            if (item.aureosReward != null || item.dinariosReward != null) ...[
              const SizedBox(height: 5),
              // Wrap: en inglés y a 360 dp los dos premios no entran en fila.
              Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                if (item.aureosReward != null) ...[
                  const Icon(Icons.monetization_on,
                      size: 12, color: AppColors.ochreDeep),
                  const SizedBox(width: 3),
                  Text(l.shopPlusAurei(item.aureosReward!),
                      style: AppTextStyles.ui(12, color: AppColors.ochreDeep)),
                  const SizedBox(width: 8),
                ],
                if (item.dinariosReward != null) ...[
                  const Icon(Icons.toll, size: 12, color: AppColors.egyptianBlue),
                  const SizedBox(width: 3),
                  Text(l.rewardDenarii(item.dinariosReward!),
                      style: AppTextStyles.ui(12, color: AppColors.egyptianBlue)),
                ],
              ]),
            ],
            if (item.isLimited) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.timer, size: 14, color: AppColors.cinnabar),
                const SizedBox(width: 4),
                Text(l.shopLimited,
                    style: AppTextStyles.ui(12,
                        color: AppColors.ink, letterSpacing: 0.5)),
              ]),
            ],
          ]),
        ),
        const SizedBox(width: 10),
        // Buy button
        _BuyButton(
          priceLabel: priceLabel(l),
          currency: item.currency,
          canAfford: canAfford,
          justBought: justBought,
          isRealMoney: isRealMoney,
          onTap: onBuy,
        ),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final ShopItem item;
  const _Tag({required this.label, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'POPULAR' => AppColors.egyptianBlue,
      'MEJOR VALOR' => AppColors.verdigris,
      'VIP' => AppColors.sienna,
      'OFERTA' => AppColors.cinnabar,
      _ => AppColors.ochreDeep,
    };
    final l = AppLocalizations.of(context);
    final text = switch (label) {
      'POPULAR' => l.shopTagPopular,
      'MEJOR VALOR' => l.shopTagBestValue,
      'VIP' => l.shopTagVip,
      'OFERTA' => l.shopTagOffer,
      'PREMIUM' => l.shopTagPremium,
      'MERCADO NEGRO' => l.shopTagBlackMarket,
      'ÉLITE' => l.shopTagElite,
      'PACK' => l.shopTagPack,
      _ => label,
    };
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GameChip(text, color: color),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final String priceLabel;
  final PriceCurrency currency;
  final bool canAfford;
  final bool justBought;
  final bool isRealMoney;
  final VoidCallback onTap;
  const _BuyButton({
    required this.priceLabel,
    required this.currency,
    required this.canAfford,
    required this.justBought,
    required this.isRealMoney,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (justBought) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: paperTint(AppColors.verdigris),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.verdigris, width: 2),
        ),
        child: Text(AppLocalizations.of(context).shopBought,
            style: AppTextStyles.ui(12,
                color: AppColors.verdigris, weight: FontWeight.bold)),
      );
    }

    final (gradient, shadow, iconColor, textColor) = switch (currency) {
      PriceCurrency.realMoney => (
          AppGradients.verdigris,
          AppColors.ink,
          AppColors.paper,
          AppColors.paper,
        ),
      PriceCurrency.aureos => (
          AppGradients.ochre,
          AppColors.ink,
          AppColors.ink,
          AppColors.ink,
        ),
      PriceCurrency.denarios => (
          AppGradients.egyptianBlue,
          AppColors.ink,
          AppColors.paper,
          AppColors.paper,
        ),
    };

    return Semantics(
      button: true,
      label: AppLocalizations.of(context).shopBuyFor(priceLabel),
      child: GestureDetector(
        onTap: () {
          canAfford ? AppFeedback.tap() : AppFeedback.denied();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: canAfford ? gradient : AppGradients.disabled,
            borderRadius: BorderRadius.circular(AppRadii.xs),
            border: Border.all(
                color: canAfford ? AppColors.ink : AppColors.inkMuted, width: 2),
            boxShadow: [
              BoxShadow(
                  color: canAfford ? shadow : AppColors.paperLine,
                  offset: const Offset(3, 3),
                  blurRadius: 0),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              isRealMoney
                  ? Icons.shopping_cart
                  : currency == PriceCurrency.aureos
                      ? Icons.monetization_on
                      : Icons.toll,
              size: 16,
              color: canAfford ? iconColor : AppColors.inkSoft,
            ),
            const SizedBox(height: 2),
            Text(priceLabel,
                style: AppTextStyles.ui(13,
                    color: canAfford ? textColor : AppColors.inkSoft,
                    weight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}

/// Precio de un producto de dinero real: el de la tienda (moneda e impuestos
/// del jugador) o, si la tienda no cargó, el de referencia en USD.
String realMoneyLabel(ShopItem item, String? storePrice) {
  if (storePrice != null && storePrice.isNotEmpty) return storePrice;
  final cents = item.price;
  return 'US\$${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
}

// ─── Paywall Dialog ───────────────────────────────────────────────────────────
class _PaywallDialog extends StatelessWidget {
  final ShopItem item;
  final String priceLabel;
  final VoidCallback onConfirm;
  const _PaywallDialog(
      {required this.item, required this.priceLabel, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GameDialog(
      title: item.name(l),
      actions: [
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: l.shopBuyButton(priceLabel),
            icon: Icons.shopping_cart,
            fontSize: 16,
            onTap: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
        ),
        GameButton(
          label: l.cancel,
          fontSize: 14,
          variant: GameButtonVariant.secondary,
          onTap: () => Navigator.pop(context),
        ),
      ],
      child: Column(children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: item.color, width: 3),
          ),
          child: Icon(item.icon, color: item.color, size: 32),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(item.description(l),
            style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.paperDeep,
            borderRadius: BorderRadius.circular(AppRadii.md - 2),
            border: Border.all(color: AppColors.paperLine, width: 2),
          ),
          child: Column(children: [
            if (item.aureosReward != null)
              _rewardRow(Icons.monetization_on, AppColors.ochreDeep,
                  l.shopPlusAurei(item.aureosReward!)),
            if (item.dinariosReward != null)
              _rewardRow(Icons.toll, AppColors.egyptianBlue,
                  l.rewardDenarii(item.dinariosReward!)),
            if (item.id == 'bundle_starter') ...[
              _rewardRow(Icons.person_add, AppColors.verdigris,
                  l.shopRewardSecondMessenger),
              _rewardRow(Icons.verified, AppColors.sienna, l.rewardSeals(2)),
            ],
            if (item.id == 'bundle_warrior')
              _rewardRow(Icons.trending_up, AppColors.verdigris,
                  l.shopRewardSkillLevels),
          ]),
        ),
      ]),
    );
  }

  Widget _rewardRow(IconData icon, Color color, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                textAlign: TextAlign.center,
                style: AppTextStyles.ui(14,
                    color: GameChip.legibleText(color),
                    weight: FontWeight.bold)),
          ),
        ]),
      );
}

/// Ofrece pagar un manual con Aureos cuando no alcanzan los Denarios.
class _ManualAureosDialog extends StatelessWidget {
  final int denarios;
  final int aureos;
  final int have;
  const _ManualAureosDialog(
      {required this.denarios, required this.aureos, required this.have});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GameDialog(
      icon: Icons.menu_book,
      title: l.shopManualAureosTitle,
      actions: [
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: l.shopManualAureosPay(aureos),
            icon: Icons.monetization_on,
            fontSize: 15,
            onTap: () => Navigator.pop(context, true),
          ),
        ),
        GameButton(
          label: l.cancel,
          fontSize: 14,
          variant: GameButtonVariant.secondary,
          onTap: () => Navigator.pop(context, false),
        ),
      ],
      child: Text(
        l.shopManualAureosBody(denarios, aureos, have),
        style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
        textAlign: TextAlign.center,
      ),
    );
  }
}
