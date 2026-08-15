import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'entities/b2bking/tiered_price.dart';
import 'entities/product.dart';
import 'entities/product_addons.dart';
import 'entities/product_component.dart';
import 'entities/product_variation.dart';
import 'entities/pw_gift_card_info.dart';
import 'entities/yith_product_addons.dart';
import 'rental/rental_cart_info.dart';

class ProductVariantModel extends ChangeNotifier {
  Product? product;
  ProductVariation? productVariation;
  Map<String, Map<String, AddonsOption>> selectedOptions = {};
  List<AddonsOption> addonsOptions = [];
  int quantity = 1;
  bool isInAppPurchaseChecking = false;
  Map<String?, String?>? mapAttribute;
  Map<String, SelectedProductComponent>? selectedComponents;
  B2BKingTieredPrice? selectedTieredPrice;
  List<B2BKingTieredPrice>? tieredPrices;
  PWGiftCardInfo? pwGiftCardInfo;
  Map<String, Map<String, YithAddonsOption>> selectedYithOptions = {};
  RentalCartInfo? rentalInfo;

  void initWithProduct(Product p) {
    product = p;
    quantity = product?.minQuantity ?? quantity;
  }

  void updateValues({
    Product? product,
    ProductVariation? productVariation,
    Map<String, Map<String, AddonsOption>>? selectedOptions,
    List<AddonsOption>? addonsOptions,
    int? quantity,
    bool? isInAppPurchaseChecking,
    Map<String?, String?>? mapAttribute,
    Map<String, SelectedProductComponent>? selectedComponents,
    B2BKingTieredPrice? selectedTieredPrice,
    List<B2BKingTieredPrice>? tieredPrices,
    PWGiftCardInfo? pwGiftCardInfo,
    Map<String, Map<String, YithAddonsOption>>? selectedYithOptions,
    RentalCartInfo? rentalInfo,
  }) {
    this.product = product ?? this.product;

    this.tieredPrices = tieredPrices ?? this.tieredPrices;

    this.productVariation = productVariation ?? this.productVariation;

    this.selectedOptions = selectedOptions ?? this.selectedOptions;

    this.selectedTieredPrice = selectedTieredPrice ?? this.selectedTieredPrice;

    this.selectedComponents = selectedComponents ?? this.selectedComponents;
    if (this.selectedOptions.values.isNotEmpty) {
      final options = <AddonsOption>[];
      for (var addOns in this.selectedOptions.values) {
        options.addAll(addOns.values);
      }
      product?.selectedOptions = options;
    }

    this.addonsOptions = addonsOptions ?? this.addonsOptions;
    var resolvedQty =
        quantity ?? selectedTieredPrice?.quantity ?? this.quantity;
    // Clamp to product min/max (covers both WC and B2BKing limits)
    final minQty = (product ?? this.product)?.minQuantity;
    final maxQty = (product ?? this.product)?.maxQuantity;
    if (minQty != null && resolvedQty < minQty) resolvedQty = minQty;
    if (maxQty != null && resolvedQty > maxQty) resolvedQty = maxQty;
    this.quantity = resolvedQty;
    this.isInAppPurchaseChecking =
        isInAppPurchaseChecking ?? this.isInAppPurchaseChecking;
    this.mapAttribute = mapAttribute ?? this.mapAttribute;

    //update the correct selectedTieredPrice when change quantity
    if (quantity != null && (this.tieredPrices?.isNotEmpty ?? false)) {
      this.selectedTieredPrice = this.tieredPrices?.reversed.firstWhereOrNull(
        (e) => e.quantity <= quantity,
      );
    }
    if (pwGiftCardInfo != null) {
      this.pwGiftCardInfo = pwGiftCardInfo;
    }

    this.selectedYithOptions = selectedYithOptions ?? this.selectedYithOptions;
    this.rentalInfo = rentalInfo ?? this.rentalInfo;
    notifyListeners();
  }

  void updateState() {
    notifyListeners();
  }
}
