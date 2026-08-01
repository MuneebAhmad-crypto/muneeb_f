import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/extensions/extensions.dart';
import '../../../models/cart/cart_base.dart';
import '../../../models/cart/cart_item_meta_data.dart';
import '../../../models/index.dart' show AppModel, Product;
import '../../../services/index.dart';
import '../action_button_mixin.dart';
import 'cart_item_state_ui.dart';
import 'layouts/cart_item_normal_widget.dart';
import 'layouts/cart_item_short_type_widget.dart';
import 'layouts/cart_item_style01_widget.dart';
import 'layouts/cart_item_web_widget.dart';

class ShoppingCartRow extends StatelessWidget with ActionButtonMixin {
  const ShoppingCartRow({
    required this.cartItemKey,
    required this.product,
    required this.quantity,
    this.onRemove,
    this.onChangeQuantity,
    this.cartItemMetaData,
    this.enableTopDivider,
    this.enableBottomDivider = true,
    this.showStoreName = true,
    this.enabledTextBoxQuantity = true,
    this.cartStyle = CartStyle.normal,
  });

  final bool? enableTopDivider;
  final bool enableBottomDivider;
  final bool enabledTextBoxQuantity;
  final String cartItemKey;
  final Product? product;
  final CartItemMetaData? cartItemMetaData;
  final int? quantity;
  final bool Function(int value)? onChangeQuantity;
  final VoidCallback? onRemove;
  final bool showStoreName;
  final CartStyle cartStyle;

  void _onRemoveItem(BuildContext context) async {
    final confirmed = await context.showFluxBottomSheetActionText(
      title: S.of(context).notice,
      body: S.of(context).confirmRemoveProductInCart,
      primaryAction: S.of(context).remove,
      secondaryAction: S.of(context).keep,
      directionButton: Axis.vertical,
      primaryAsDestructiveAction: true,
    );

    if (confirmed) {
      onRemove?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    var currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;

    /// Using Consumer instead of Selector to ensure rebuild when product updates.
    ///
    /// Why Consumer is needed:
    /// Product class implements == operator based on id and name only:
    ///   bool operator ==(Object other) =>
    ///       identical(this, other) ||
    ///       other is Product &&
    ///           runtimeType == other.runtimeType &&
    ///           id == other.id &&
    ///           name == other.name;
    ///
    /// When updateProduct() is called with a new Product instance that has the same
    /// id and name but different other properties (bookingInfo, price, etc),
    /// Selector would compare them as equal and skip rebuild.
    ///
    /// Consumer always rebuilds when CartModel.notifyListeners() is called,
    /// regardless of Product equality, ensuring UI always reflects the latest
    /// product data from the cart model.
    return Consumer<CartModel>(
      builder: (context, cartModel, __) {
        final product = cartModel.item[this.product?.id];
        if (product == null) {
          return const SizedBox();
        }

        final latestCartItemMetaData =
            cartModel.cartItemMetaDataInCart[cartItemKey]?.copyWith(
              variation: cartModel.getProductVariationById(cartItemKey),
            ) ??
            cartItemMetaData;
        final latestQuantity =
            cartModel.productsInCart[cartItemKey] ?? quantity;

        final price = Services().widget.getPriceItemInCart(
          product,
          latestCartItemMetaData,
          currencyRate,
          currency,
        );
        final imageFeature =
            (latestCartItemMetaData?.variation?.imageFeature?.isNotEmpty ??
                false)
            ? latestCartItemMetaData?.variation!.imageFeature
            : product.imageFeature;

        final maxAllowQuantity = kCartDetail.maxAllowQuantity;
        var totalQuantity = latestCartItemMetaData?.variation != null
            ? (latestCartItemMetaData?.variation!.stockQuantity ??
                  maxAllowQuantity)
            : (product.stockQuantity ?? maxAllowQuantity);
        var limitQuantity = totalQuantity > maxAllowQuantity
            ? maxAllowQuantity
            : totalQuantity;
        final inStock =
            (latestCartItemMetaData?.variation != null
                ? latestCartItemMetaData?.variation!.inStock
                : product.inStock) ??
            false;
        final allowBackorder = latestCartItemMetaData?.variation != null
            ? latestCartItemMetaData?.variation?.backordersAllowed ?? false
            : product.backordersAllowed;
        // Only show Backorder status when backorders are allowed AND the
        // product is actually out of stock. Products with stock qty > 0 should
        // show as In Stock even when backorders are configured.
        final isOnBackorder = allowBackorder && !inStock;
        final priceWithQuantity = Services().widget.getPriceItemInCart(
          product,
          latestCartItemMetaData,
          currencyRate,
          currency,
          quantity: latestQuantity ?? 1,
        );
        final stateUI = CartItemStateUI(
          enableBottomDivider: enableBottomDivider,
          inStock: inStock,
          isOnBackorder: isOnBackorder,
          onTapProduct: onTapProduct,
          product: product,
          showStoreName: showStoreName,
          cartItemMetaData: latestCartItemMetaData,
          enableTopDivider: enableTopDivider,
          imageFeature: imageFeature,
          limitQuantity: limitQuantity,
          enabledTextBoxQuantity: enabledTextBoxQuantity,
          onChangeQuantity: onChangeQuantity,
          onRemove: onRemove != null ? () => _onRemoveItem(context) : null,
          price: price,
          priceWithQuantity: priceWithQuantity,
          quantity: latestQuantity,
        );

        // Because this case does not need to
        // use LayoutBuilder, so separate it and use if
        if (cartStyle.isWeb) {
          return CartItemWebWidget(stateUI);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            switch (cartStyle) {
              case CartStyle.short:
                return CartItemShortTypeWidget(
                  stateUI,
                  constraintsCurrent: constraints,
                );
              case CartStyle.style01:
                return CartItemStyle01Widget(
                  stateUI,
                  constraintsCurrent: constraints,
                );
              case CartStyle.normal:
              default:
                return CartItemNormalWidget(
                  stateUI,
                  heightImageFeature: constraints.maxWidth * 0.3,
                  widthImageFeature: constraints.maxWidth * 0.25,
                );
            }
          },
        );
      },
    );
  }
}
