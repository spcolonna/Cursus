import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../infrastructure/monetization/iap_service.dart';
import '../../../infrastructure/progress/player_progress.dart';
import '../../widgets/primeros_pasos.dart';

// ─── Shop Item Model ──────────────────────────────────────────────────────────
enum ShopCategory { boosters, skills, aureosPacks, bundles }

extension ShopCategoryX on ShopCategory {
  String get label => switch (this) {
        ShopCategory.boosters => 'Potenciadores',
        ShopCategory.skills => 'Habilidades',
        ShopCategory.aureosPacks => 'Aureos',
        ShopCategory.bundles => 'Paquetes',
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
  final String name;
  final String description;
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

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.currency,
    required this.icon,
    required this.color,
    this.tag,
    this.isLimited = false,
    this.dinariosReward,
    this.aureosReward,
  });
}

// ─── Shop Catalogue ───────────────────────────────────────────────────────────
final shopCatalogue = <ShopItem>[
  // ── Potenciadores (Denarios) ──────────────────────────────────────────────
  const ShopItem(
    id: 'boost_health_small',
    name: 'Pocion de salud',
    description: 'Restaura 30 puntos de salud al instante.',
    category: ShopCategory.boosters,
    price: 50,
    currency: PriceCurrency.denarios,
    icon: Icons.favorite,
    color: AppColors.red,
  ),
  const ShopItem(
    id: 'boost_health_full',
    name: 'Curacion completa',
    description: 'Salud al 100%. Ideal antes de una mision larga.',
    category: ShopCategory.boosters,
    price: 120,
    currency: PriceCurrency.denarios,
    icon: Icons.healing,
    color: AppColors.red,
    tag: 'POPULAR',
  ),
  const ShopItem(
    id: 'boost_fatigue',
    name: 'Descanso rapido',
    description: 'Elimina toda la fatiga acumulada.',
    category: ShopCategory.boosters,
    price: 80,
    currency: PriceCurrency.denarios,
    icon: Icons.hotel,
    color: AppColors.sky,
  ),
  const ShopItem(
    id: 'boost_speed',
    name: 'Sandalias de Mercurio',
    description: 'Reduce el tiempo de tu proxima mision un 20%.',
    category: ShopCategory.boosters,
    price: 3,
    currency: PriceCurrency.aureos,
    icon: Icons.speed,
    color: AppColors.amber,
    tag: 'PREMIUM',
  ),
  const ShopItem(
    id: 'boost_events',
    name: 'Mapa del explorador',
    description: 'Revela el proximo evento de la mision antes de que ocurra.',
    category: ShopCategory.boosters,
    price: 5,
    currency: PriceCurrency.aureos,
    icon: Icons.map,
    color: AppColors.gold,
    tag: 'POPULAR',
  ),

  // ── Habilidades (Denarios) ────────────────────────────────────────────────
  const ShopItem(
    id: 'skill_speed_1',
    name: 'Manual de velocidad I',
    description: 'Sube Velocidad un nivel (hasta 5). Más rápido en el camino.',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.bolt,
    color: AppColors.skillSpeed,
  ),
  const ShopItem(
    id: 'skill_stealth_1',
    name: 'Tratado de sigilo I',
    description: 'Sube Sigilo un nivel (hasta 5). Evita controles y patrullas.',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.visibility_off,
    color: AppColors.skillStealth,
  ),
  const ShopItem(
    id: 'skill_combat_1',
    name: 'Adiestramiento de combate I',
    description: 'Sube Combate un nivel (hasta 5). Mejora en enfrentamientos.',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.shield,
    color: AppColors.skillCombat,
  ),
  const ShopItem(
    id: 'skill_survival_1',
    name: 'Conocimiento del campo I',
    description: 'Sube Supervivencia un nivel (hasta 5). Aguanta más en ruta.',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.eco,
    color: AppColors.skillSurvival,
  ),
  const ShopItem(
    id: 'skill_contacts_1',
    name: 'Red de contactos I',
    description: 'Sube Contactos un nivel (hasta 5). Mejores opciones diplomáticas.',
    category: ShopCategory.skills,
    price: 200,
    currency: PriceCurrency.denarios,
    icon: Icons.people,
    color: AppColors.skillContacts,
  ),

  // ── Paquetes de Aureos (real money) ───────────────────────────────────────
  const ShopItem(
    id: 'aureos_small',
    name: 'Bolsa de Aureos',
    description: '50 Aureos para gastar en la tienda.',
    category: ShopCategory.aureosPacks,
    price: 199, currency: PriceCurrency.realMoney, // en centavos USD → $1.99
    icon: Icons.monetization_on, color: AppColors.gold,
    aureosReward: 50,
  ),
  const ShopItem(
    id: 'aureos_medium',
    name: 'Cofre de Aureos',
    description: '120 Aureos. El preferido del mensajero veterano.',
    category: ShopCategory.aureosPacks,
    price: 399, currency: PriceCurrency.realMoney, // $3.99
    icon: Icons.savings, color: AppColors.gold,
    tag: 'POPULAR',
    aureosReward: 120,
  ),
  const ShopItem(
    id: 'aureos_large',
    name: 'Tesoro del Imperio',
    description: '300 Aureos. El mejor valor disponible.',
    category: ShopCategory.aureosPacks,
    price: 799, currency: PriceCurrency.realMoney, // $7.99
    icon: Icons.workspace_premium, color: AppColors.amber,
    tag: 'MEJOR VALOR',
    aureosReward: 300,
  ),
  const ShopItem(
    id: 'aureos_mega',
    name: 'Boveda Imperial',
    description: '800 Aureos + 500 Denarios de bonus.',
    category: ShopCategory.aureosPacks,
    price: 1999, currency: PriceCurrency.realMoney, // $19.99
    icon: Icons.account_balance, color: AppColors.amber,
    tag: 'VIP',
    aureosReward: 800,
    dinariosReward: 500,
  ),

  // ── Paquetes bundle ───────────────────────────────────────────────────────
  const ShopItem(
    id: 'bundle_starter',
    name: 'Pack del Correo',
    description:
        '30 Aureos + 2.º slot de mensajero + 2 Sellos. El momento "ajá" del juego paralelo.',
    category: ShopCategory.bundles,
    price: 299, currency: PriceCurrency.realMoney, // $2.99
    icon: Icons.card_giftcard, color: AppColors.green,
    tag: 'OFERTA',
    aureosReward: 30,
    isLimited: true,
  ),
  const ShopItem(
    id: 'bundle_warrior',
    name: 'Pack del Guerrero',
    description: 'Sube 2 niveles de habilidad a tu elección + 50 Aureos.',
    category: ShopCategory.bundles,
    price: 699,
    currency: PriceCurrency.realMoney,
    icon: Icons.military_tech,
    color: AppColors.amber,
    tag: 'POPULAR',
    aureosReward: 50,
  ),

  // ── Sellos (sink de Aureos, GDD §5.3) ─────────────────────────────────────
  const ShopItem(
    id: 'seal_single',
    name: 'Sello del Gremio',
    description: '1 Sello para subir nodos élite del árbol (niveles 6-10).',
    category: ShopCategory.boosters,
    price: 15,
    currency: PriceCurrency.aureos,
    icon: Icons.verified,
    color: AppColors.amber,
    tag: 'ÉLITE',
  ),
  const ShopItem(
    id: 'seal_pack_10',
    name: 'Paquete de 10 Sellos',
    description: '10 Sellos del Gremio. Ahorrás 30 Aureos vs comprar de a uno.',
    category: ShopCategory.boosters,
    price: 120,
    currency: PriceCurrency.aureos,
    icon: Icons.workspace_premium,
    color: AppColors.gold,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSpotlight());
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
      title: 'La tienda del gremio',
      body:
          'Denarios para el día a día. Aureos para acelerar. Sellos para el árbol élite. '
          'Nada es pay-to-win destructivo: pagar acelera, no reemplaza jugar.',
    );
  }

  List<ShopItem> get _items =>
      shopCatalogue.where((i) => i.category == _activeTab).toList();

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider).valueOrNull;
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
              itemCount: _items.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ShopCard(
                  item: _items[i],
                  messenger: messenger,
                  price: _priceFor(_items[i], target),
                  justBought: _purchasedId == _items[i].id,
                  onBuy: () => _buy(_items[i], target),
                )
                    .animate(delay: Duration(milliseconds: i * 60))
                    .fadeIn()
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

  Future<void> _buy(ShopItem item, Messenger? target) async {
    final messenger = ref.read(homeProvider).valueOrNull?.messenger;
    if (messenger == null || target == null) return;

    // Real money → show paywall dialog (fictitious for now)
    if (item.currency == PriceCurrency.realMoney) {
      await _showPaywallDialog(item);
      return;
    }

    final price = _priceFor(item, target);
    if (price == null) return; // botón deshabilitado: skill al máximo

    // Soft currency check
    final balance = item.currency == PriceCurrency.denarios
        ? messenger.denarios
        : messenger.aureos;
    if (balance < price) {
      _showInsufficientFunds(item.currency);
      return;
    }

    // El use case cobra (validando saldo) y aplica el efecto real del item.
    try {
      await ref.read(applyShopItemUseCaseProvider).execute(
            targetId: target.id,
            itemId: item.id,
            denariosCost: item.currency == PriceCurrency.denarios ? price : 0,
            aureosCost: item.currency == PriceCurrency.aureos ? price : 0,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
      return;
    }
    ref.invalidate(homeProvider);
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
            type: item.currency == PriceCurrency.denarios
                ? CurrencyType.denarios
                : CurrencyType.aureos,
            amount: -price,
          ),
        ],
        note: item.name,
      );
      _showEffectApplied(item);
    }

    setState(() => _purchasedId = item.id);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _purchasedId = null);
  }

  void _showEffectApplied(ShopItem item) {
    final msg = switch (item.id) {
      'boost_health_small' => '+30 de salud',
      'boost_health_full' => 'Salud restaurada al 100%',
      'boost_fatigue' => 'Fatiga eliminada',
      'boost_speed' => 'Sandalias listas: tu próxima misión durará 20% menos',
      'boost_events' => 'Mapa listo: tu próxima misión revelará el evento por venir',
      'skill_speed_1' ||
      'skill_stealth_1' ||
      'skill_combat_1' ||
      'skill_survival_1' ||
      'skill_contacts_1' =>
        '¡Habilidad mejorada!',
      _ => 'Compra aplicada',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.green.withValues(alpha: 0.5), width: 2),
      ),
      content: Row(children: [
        const Icon(Icons.check_circle, color: AppColors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(msg,
              style: AppTextStyles.fredoka(14, color: AppColors.white)),
        ),
      ]),
    ));
  }

  Future<void> _showPaywallDialog(ShopItem item) async {
    await showDialog(
      context: context,
      builder: (_) => _PaywallDialog(
        item: item,
        onConfirm: () => _purchaseIap(item),
      ),
    );
  }

  Future<void> _purchaseIap(ShopItem item) async {
    final productId = IapProducts.productIdForShopItem(item.id);
    if (productId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.bgCard,
        content: Text('Producto no configurado',
            style: AppTextStyles.fredoka(14, color: AppColors.red)),
      ));
      return;
    }

    final result =
        await ref.read(iapServiceProvider).purchase(productId);
    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.bgCard,
        content: Text(result.error ?? 'Compra cancelada',
            style: AppTextStyles.fredoka(14, color: AppColors.red)),
      ));
      return;
    }

    // Sandbox (debug sin productos de store): acreditamos ya. Con tienda
    // real, el crédito llega por el stream de compras (IapService.onPurchased).
    if (result.usedSandbox) {
      await _creditIap(item);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.bgCard,
        content: Text(
          'Compra iniciada. La tienda confirmará el pago.',
          style: AppTextStyles.fredoka(14, color: AppColors.gold),
        ),
      ));
    }
  }

  Future<void> _creditIap(ShopItem item) async {
    try {
      await ref.read(creditPurchaseUseCaseProvider).execute(item.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''))));
      return;
    }

    ref.invalidate(homeProvider);
    await ref
        .read(primerosPasosProvider.notifier)
        .markTask(PlayerProgress.taskBuyItem);

    if (!mounted) return;
    showRewardToast(
      context,
      [
        if (item.aureosReward != null)
          (type: CurrencyType.aureos, amount: item.aureosReward!),
        if (item.dinariosReward != null)
          (type: CurrencyType.denarios, amount: item.dinariosReward!),
      ],
      note: resultSandboxNote(item),
    );
  }

  String resultSandboxNote(ShopItem item) {
    final iap = ref.read(iapServiceProvider);
    final sandbox = !iap.hasProducts;
    return sandbox ? '${item.name} (sandbox de prueba)' : item.name;
  }

  void _showInsufficientFunds(PriceCurrency type) {
    final name = type == PriceCurrency.denarios ? 'Denarios' : 'Aureos';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.red.withValues(alpha: 0.5), width: 2),
      ),
      content: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.red),
        const SizedBox(width: 10),
        Text('No tienes suficientes $name',
            style: AppTextStyles.fredoka(14, color: AppColors.white)),
      ]),
    ));
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
            bottom:
                BorderSide(color: AppColors.gold.withValues(alpha: 0.3), width: 2)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x88000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.bgLine, width: 2),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textSecondary, size: 16),
          ),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TIENDA',
              style: AppTextStyles.fredoka(18,
                  color: AppColors.gold,
                  letterSpacing: 1,
                  weight: FontWeight.bold)),
          Text('Imperio Romano', style: AppTextStyles.bodySmall),
        ]),
        const Spacer(),
        // Wallet display
        if (messenger != null) ...[
          CurrencyChip(
              type: CurrencyType.denarios, value: messenger!.denarios),
          const SizedBox(width: 8),
          CurrencyChip(type: CurrencyType.aureos, value: messenger!.aureos),
          const SizedBox(width: 8),
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
      color: AppColors.bgDark,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: ShopCategory.values.map((cat) {
          final selected = cat == active;
          return GestureDetector(
            onTap: () => onTap(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected ? AppGradients.gold : null,
                color: selected ? null : AppColors.bgCard2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.outline : AppColors.bgLine,
                  width: selected ? 2.5 : 2,
                ),
                boxShadow: selected
                    ? [
                        const BoxShadow(
                            color: AppColors.goldShadow,
                            offset: Offset(0, 3),
                            blurRadius: 0)
                      ]
                    : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(cat.icon,
                    size: 14,
                    color:
                        selected ? AppColors.outline : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(cat.label,
                    style: AppTextStyles.fredoka(13,
                        color: selected
                            ? AppColors.outline
                            : AppColors.textSecondary,
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
        Text('Para:',
            style: AppTextStyles.fredoka(13, color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        for (final m in messengers) ...[
          ChoiceChip(
            label: Text(m.name),
            selected: m.id == selectedId,
            onSelected: (_) => onSelect(m.id),
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
  final bool justBought;
  final VoidCallback onBuy;
  const _ShopCard({
    required this.item,
    required this.messenger,
    required this.price,
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

  String get priceLabel {
    if (price == null) return 'MÁX';
    if (item.currency == PriceCurrency.realMoney) {
      final dollars = price! ~/ 100;
      final cents = price! % 100;
      return '\$$dollars.${cents.toString().padLeft(2, '0')}';
    }
    return '$price';
  }

  @override
  Widget build(BuildContext context) {
    final isRealMoney = item.currency == PriceCurrency.realMoney;

    return GameCard(
      borderColor: justBought
          ? AppColors.green
          : item.isLimited
              ? AppColors.red.withValues(alpha: 0.6)
              : AppColors.bgLine,
      gradient: justBought
          ? const LinearGradient(
              colors: [Color(0xFF0A2E0A), Color(0xFF061406)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          : null,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Icon box
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: item.color.withValues(alpha: 0.5), width: 2.5),
          ),
          child: Center(
            child: justBought
                ? const Icon(Icons.check_circle,
                    color: AppColors.green, size: 28)
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
                child: Text(item.name,
                    style: AppTextStyles.fredoka(15,
                        color: AppColors.white, weight: FontWeight.bold)),
              ),
              if (item.tag != null) _Tag(label: item.tag!, item: item),
            ]),
            const SizedBox(height: 3),
            Text(item.description,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            // Reward preview for aureo packs
            if (item.aureosReward != null || item.dinariosReward != null) ...[
              const SizedBox(height: 5),
              Row(children: [
                if (item.aureosReward != null) ...[
                  const Icon(Icons.monetization_on,
                      size: 12, color: AppColors.gold),
                  const SizedBox(width: 3),
                  Text('+${item.aureosReward} Aureos',
                      style: AppTextStyles.fredoka(11, color: AppColors.gold)),
                  const SizedBox(width: 8),
                ],
                if (item.dinariosReward != null) ...[
                  const Icon(Icons.toll, size: 12, color: AppColors.sky),
                  const SizedBox(width: 3),
                  Text('+${item.dinariosReward} Denarios',
                      style: AppTextStyles.fredoka(11, color: AppColors.sky)),
                ],
              ]),
            ],
            if (item.isLimited) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.timer, size: 11, color: AppColors.red),
                const SizedBox(width: 3),
                Text('TIEMPO LIMITADO',
                    style: AppTextStyles.fredoka(10,
                        color: AppColors.red, letterSpacing: 0.5)),
              ]),
            ],
          ]),
        ),
        const SizedBox(width: 10),
        // Buy button
        _BuyButton(
          priceLabel: priceLabel,
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
      'POPULAR' => AppColors.sky,
      'MEJOR VALOR' => AppColors.green,
      'VIP' => AppColors.amber,
      'OFERTA' => AppColors.red,
      _ => AppColors.gold,
    };
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(label,
          style: AppTextStyles.fredoka(9,
              color: color, letterSpacing: 0.5, weight: FontWeight.bold)),
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
          color: AppColors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.green, width: 2),
        ),
        child: Text('COMPRADO',
            style: AppTextStyles.fredoka(11,
                color: AppColors.green, weight: FontWeight.bold)),
      );
    }

    final (gradient, shadow, iconColor, textColor) = switch (currency) {
      PriceCurrency.realMoney => (
          AppGradients.green,
          AppColors.greenShadow,
          AppColors.outline,
          AppColors.outline,
        ),
      PriceCurrency.aureos => (
          AppGradients.gold,
          AppColors.goldShadow,
          AppColors.outline,
          AppColors.outline,
        ),
      PriceCurrency.denarios => (
          AppGradients.sky,
          AppColors.skyDark,
          AppColors.outline,
          AppColors.outline,
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: canAfford
              ? gradient
              : const LinearGradient(
                  colors: [Color(0xFF3A4A5A), Color(0xFF2A3A4A)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline, width: 2.5),
          boxShadow: [
            BoxShadow(
                color: canAfford ? shadow : Colors.black38,
                offset: const Offset(0, 3),
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
            color: canAfford ? iconColor : Colors.white38,
          ),
          const SizedBox(height: 2),
          Text(priceLabel,
              style: AppTextStyles.fredoka(13,
                  color: canAfford ? textColor : Colors.white38,
                  weight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

// ─── Paywall Dialog ───────────────────────────────────────────────────────────
class _PaywallDialog extends StatelessWidget {
  final ShopItem item;
  final VoidCallback onConfirm;
  const _PaywallDialog({required this.item, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5), width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: item.color.withValues(alpha: 0.6), width: 3),
            ),
            child: Center(child: Icon(item.icon, color: item.color, size: 32)),
          ),
          const SizedBox(height: 14),
          Text(item.name,
              style: AppTextStyles.fredoka(20, color: AppColors.white),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(item.description,
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bgLine, width: 2),
            ),
            child: Column(children: [
              if (item.aureosReward != null)
                _rewardRow(Icons.monetization_on, AppColors.gold,
                    '+${item.aureosReward} Aureos'),
              if (item.dinariosReward != null)
                _rewardRow(Icons.toll, AppColors.sky,
                    '+${item.dinariosReward} Denarios'),
              if (item.id == 'bundle_starter') ...[
                _rewardRow(Icons.person_add, AppColors.green, '+2.º mensajero'),
                _rewardRow(Icons.verified, AppColors.amber, '+2 Sellos'),
              ],
              if (item.id == 'bundle_warrior')
                _rewardRow(Icons.trending_up, AppColors.green,
                    '+2 niveles de habilidad a elección (en Caminos)'),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GameButton(
              label: 'COMPRAR · ${_priceStr(item.price)}',
              icon: Icons.shopping_cart,
              gradient: AppGradients.green,
              shadowColor: AppColors.greenShadow,
              fontSize: 16,
              onTap: () {
                Navigator.pop(context);
                onConfirm();
              },
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: AppTextStyles.fredoka(14, color: AppColors.textMuted)),
          ),
        ]),
      ),
    );
  }

  Widget _rewardRow(IconData icon, Color color, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text,
              style: AppTextStyles.fredoka(14,
                  color: color, weight: FontWeight.bold)),
        ]),
      );

  String _priceStr(int cents) {
    final d = cents ~/ 100;
    final c = cents % 100;
    return '\$$d.${c.toString().padLeft(2, '0')}';
  }
}
