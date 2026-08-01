import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/config/models/cart_config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../common/tools/rental_tools.dart';
import '../../common/tools/yith_addons_tools.dart';
import '../../data/boxes.dart';
import '../../models/cart/cart_item_meta_data.dart';
import '../../models/cart/cart_model_woo.dart';
import '../../models/entities/filter_sorty_by.dart';
import '../../models/entities/index.dart';
import '../../models/entities/product_component.dart';
import '../../models/index.dart'
    show
        AdditionalPaymentInfo,
        AddonsOption,
        AddonsType,
        AppModel,
        Attribute,
        CartModel,
        Country,
        CountryState,
        Coupons,
        Discount,
        ListCountry,
        Order,
        PaymentMethod,
        Product,
        ProductVariation,
        ShippingMethodModel,
        User,
        UserModel,
        YithAddonsOption;
import '../../models/rental/rental_cart_info.dart';
import '../../models/tera_wallet/index.dart';
import '../../modules/analytics/analytics.dart';
import '../../modules/product_reviews/product_reviews_index.dart';
import '../../modules/re_order/re_order_index.dart';
import '../../modules/subscription/views/recurring_totals.dart';
import '../../routes/flux_navigate.dart';
import '../../screens/index.dart'
    show WebviewCheckout, WebviewCheckoutSuccessScreen;
import '../../services/index.dart';
import '../frameworks.dart';
import '../product_variant_mixin.dart';
import 'product_addons_mixin/index.dart';
import 'product_components_mixin.dart';
import 'profile/user_update_woo_screen.dart';
import 'pw_gift_card_mixin.dart';
import 'woo_variant_mixin.dart';
import 'yith_product_addons_mixin/index.dart';

class WooWidget extends BaseFrameworks
    with
        ProductVariantMixin,
        WooVariantMixin,
        ProductAddonsMixin,
        ProductComponentsMixin,
        PWGiftCardMixin,
        YithProductAddonsMixin {
  @override
  bool get enableProductReview => true;

  @override
  bool get enableMembershipUltimate => kAdvanceConfig.enableMembershipUltimate;

  @override
  bool get enableWooCommerceWholesalePrices =>
      kAdvanceConfig.enableWooCommerceWholesalePrices;

  @override
  bool get isSupportFilterOrder => true;

  @override
  bool enableShoppingCart(Product? product) =>
      (kAdvanceConfig.enableMembershipUltimate ||
              kAdvanceConfig.enableWooCommerceWholesalePrices
          ? kAdvanceConfig.enableCart && !(product?.isRestricted ?? false)
          : kAdvanceConfig.enableCart) &&
      product?.isListing != true;

  @override
  Widget renderRentalCartInfo(
    BuildContext context,
    RentalCartInfo? rentalInfo,
  ) {
    final selection = rentalInfo?.selection;
    if (selection == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        selection.format(context),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  @override
  bool get enableInAppPurchase => kInAppPurchaseConfig['enabled'] ?? false;

  @override
  bool hideProductPrice(BuildContext context, Product? product) {
    final disabled = Services().hideProductPrice(context, product);
    if (disabled) return true;

    if (kAdvanceConfig.enableWooSimpleAuction &&
        product?.type == 'auction' &&
        product?.valuePrice == 0) {
      return true;
    }
    return super.hideProductPrice(context, product);
  }

  bool isBookingProduct(CartModel cartModel) {
    var isBooking = false;
    for (var key in cartModel.productsInCart.keys) {
      var productId = Product.cleanProductID(key);
      var product = cartModel.item[productId]!;
      if (product.bookingInfo != null) {
        isBooking = true;
      }
    }
    return isBooking;
  }

  Discount? _makeDiscount(
    Coupons? coupons,
    String couponCode,
    CartModel cartModel,
  ) {
    var coupon = coupons!.coupons.firstWhereOrNull(
      (element) => element.code == couponCode,
    );
    if (coupon != null) {
      final discountValue = coupon.discountType == 'percent'
          ? cartModel.getSubTotal()! * coupon.amount! / 100.0
          : coupon.amount!;
      return Discount(coupon: coupon, discountValue: discountValue);
    }

    return null;
  }

  Future<Discount?> checkValidCoupon(
    BuildContext context,
    String couponCode,
    Coupons? coupons,
  ) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final isBooking = isBookingProduct(cartModel);
    Discount? discount;
    if (isBooking) {
      discount = _makeDiscount(coupons, couponCode, cartModel);
    } else {
      discount = await Coupons.getDiscount(
        cartModel: cartModel,
        couponCode: couponCode,
      );
      if (!ServerConfig().isWooType) {
        discount ??= _makeDiscount(coupons, couponCode, cartModel);
      }
    }

    if (discount?.discountValue != null) {
      await cartModel.updateDiscount(discount: discount);
      return discount;
    }

    return null;
  }

  @override
  Future<void> applyCoupon(
    context, {
    Coupons? coupons,
    String? code,
    Function? success,
    Function? error,
    bool cartChanged = false,
  }) async {
    try {
      final discount = await checkValidCoupon(context, code!, coupons);
      if (discount != null) {
        success?.call(discount);
        return;
      }
    } catch (err) {
      error?.call(err.toString().clearExceptionKey().unescape());
      return;
    }
    error?.call(S.of(context).couponInvalid);
  }

  @override
  Future<void> doCheckout(
    BuildContext context, {
    Function? success,
    Function? error,
    Function? loading,
  }) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    if (kPaymentConfig.enableWebviewCheckout || cartModel.isB2BKingCart()) {
      loading!(true);
      var params = Order().toJson(
        cartModel,
        userModel.user?.id,
        true,
        forWebViewCheckout: true,
      );
      params['token'] = userModel.user?.cookie;
      var url = await Services().api.getCheckoutUrl(
        params,
        Provider.of<AppModel>(context, listen: false).langCode,
      )!;
      loading(false);

      /// Navigate to Webview Checkout
      String? orderId;

      await FluxNavigate.push(
        MaterialPageRoute(
          builder: (ctx) => WebviewCheckout(
            url: url,
            onFinish: (id) async {
              orderId = id;
            },
          ),
        ),
        forceRootNavigator: true,
        context: context,
      );

      if (orderId != null && !kIsWeb) {
        final purchasedOrder = Order(id: orderId, total: cartModel.getTotal())
          ..currencyCode = cartModel.currencyCode;
        Analytics.triggerPurchased(purchasedOrder, context);
        unawaited(cartModel.clearCart());
        if (kPaymentConfig.showNativeCheckoutSuccessScreenForWebview) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WebviewCheckoutSuccessScreen(order: purchasedOrder),
            ),
          );
        }
      }
      return;
    }

    /// return success to navigate to Native payment
    success!();
  }

  @override
  Future<Order?> createOrder(
    BuildContext context, {
    Function? onLoading,
    Function? success,
    Function? error,
    bool paid = false,
    bool cod = false,
    bool bacs = false,
    AdditionalPaymentInfo? additionalPaymentInfo,
  }) async {
    var listOrder = <Map>[];
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = context.read<UserModel>();
    final token = userModel.user?.cookie;

    try {
      final order = await Services().api.createOrder(
        cartModel: cartModel,
        user: userModel,
        paid: paid,
        additionalPaymentInfo: additionalPaymentInfo,
      )!;

      try {
        if (bacs) {
          await Services().api.updateOrder(
            order.id,
            status: 'on-hold',
            token: token,
          );
          order.status = OrderStatus.onHold;
        }
        if ((cod && kPaymentConfig.updateOrderStatus)) {
          await Services().api.updateOrder(
            order.id,
            status: 'processing',
            token: token,
          );
          order.status = OrderStatus.processing;
        }
      } catch (e, trace) {
        printError('Update order after checkout error: $e', trace);
      }

      if (!isLoggedIn) {
        var items = UserBox().orders;
        if (items.isNotEmpty) {
          listOrder = items;
        }
        listOrder.add(order.toOrderJson(cartModel, null));
        UserBox().orders = listOrder;
      }
      success?.call(order);
      return order;
    } catch (e, trace) {
      printError('Create order error: $e', trace);
      error?.call(e.toString());
      return null;
    }
  }

  @override
  void placeOrder(
    BuildContext context, {
    CartModel? cartModel,
    PaymentMethod? paymentMethod,
    Function? onLoading,
    Function? success,
    Function? error,
  }) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    final params = Order().toJson(cartModel!, user?.id, true);
    params['token'] = user?.cookie;

    if (kPaymentConfig.enableHybridPayment) {
      onLoading?.call(true);
      createOrder(
        context,
        onLoading: onLoading,
        success: (Order? order) {
          onLoading?.call(false);
          paymentWithWebview(context, order, onLoading, success, error);
        },
        error: (message) {
          onLoading?.call(false);
          Tools.showSnackBar(ScaffoldMessenger.of(context), message);
        },
      );
      return;
    }

    Provider.of<CartModel>(
      context,
      listen: false,
    ).setPaymentMethod(paymentMethod);

    if (paymentMethod?.id == 'wallet') {
      createOrder(
        context,
        cod: true,
        onLoading: onLoading,
        success: (Order order) async {
          try {
            if (user != null && user.cookie != null) {
              await Provider.of<WalletModel>(
                context,
                listen: false,
              ).processPayment(order.id!, user.cookie!);
            }
          } catch (e, trace) {
            printError(e, trace);
          }
          success?.call(order);
        },
        error: error,
      );
      return;
    }

    if (kCashOnDeliveryConfig
        .getValueList('paymentMethodIds')
        .contains(paymentMethod?.id)) {
      createOrder(
        context,
        cod: true,
        onLoading: onLoading,
        success: (Order order) {
          success!(order);
        },
        error: error,
      );
      return;
    }

    if (kBankTransferConfig
        .getValueList('paymentMethodIds')
        .contains(paymentMethod?.id)) {
      createOrder(
        context,
        bacs: true,
        onLoading: onLoading,
        success: success,
        error: error,
      );
      return;
    }

    if (kWhatsAppOrderConfig
        .getValueList('paymentMethodIds')
        .contains(paymentMethod?.id)) {
      createOrder(
        context,
        onLoading: onLoading,
        success: success,
        error: error,
      );
      return;
    }

    final availableThaiPromptPay =
        kThaiPromptPayConfig
            .getValueList('paymentMethodIds')
            .contains(paymentMethod?.id) &&
        kThaiPromptPayConfig['enabled'] == true;
    if (availableThaiPromptPay) {
      createOrder(
        context,
        bacs: true,
        onLoading: onLoading,
        success: success,
        error: error,
      );
      return;
    }

    checkoutWithWebview(context, params, onLoading, success, error);
  }

  Future<void> paymentWithWebview(
    BuildContext context,
    Order? order,
    Function? onLoading,
    Function? success,
    Function? error,
  ) async {
    try {
      var url = order?.paymentUrl ?? '';
      if (url.isNotEmpty) {
        final cookie = Provider.of<UserModel>(
          context,
          listen: false,
        ).user?.cookie;
        url = url.addWooCookieToUrl(cookie);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebviewCheckout(
              url: url,
              onFinish: (orderId) {
                // Try to use an empty order with orderId to reload data from server
                success?.call(orderId != null ? Order(id: orderId) : order);
              },
              onClose: () {
                error?.call(S.of(context).paymentCancelled);
              },
            ),
          ),
        );
      } else {
        error?.call(S.of(context).cannotGetPaymentURL);
      }
    } catch (e, trace) {
      error?.call(e.toString());
      printError(e, trace);
    }
  }

  Future<void> checkoutWithWebview(
    BuildContext context,
    Map<String, dynamic> params,
    Function? onLoading,
    Function? success,
    Function? error,
  ) async {
    try {
      onLoading!(true);

      var url = await Services().api.getCheckoutUrl(
        params,
        Provider.of<AppModel>(context, listen: false).langCode,
      )!;
      onLoading(false);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebviewCheckout(
            url: url,
            onFinish: (orderId) {
              success!(orderId != null ? Order(id: orderId) : null);
            },
          ),
        ),
      );
    } catch (e, trace) {
      error?.call(e.toString());
      printError(e, trace);
    }
  }

  @override
  Map<String, dynamic>? getPaymentUrl(context) {
    return null;
  }

  @override
  void updateUserInfo({
    User? loggedInUser,
    context,
    required onError,
    onSuccess,
    required currentPassword,
    required userDisplayName,
    userEmail,
    username,
    userNiceName,
    userUrl,
    userPassword,
    userFirstname,
    userLastname,
    userPhone,
  }) {
    var params = {
      'user_id': loggedInUser!.id,
      'display_name': userDisplayName,
      'user_email': userEmail,
      'user_nicename': userNiceName,
      'user_url': userUrl,
    };
    if (!loggedInUser.isSocial! && userPassword!.isNotEmpty) {
      params['user_pass'] = userPassword;
    }
    if (!loggedInUser.isSocial! && currentPassword.isNotEmpty) {
      params['current_pass'] = currentPassword;
    }
    Services().api
        .updateUserInfo(params, loggedInUser.cookie)!
        .then((value) {
          var param = value!['data'] ?? value;
          param['password'] = userPassword;
          onSuccess!(User.fromJson(param));
        })
        .catchError((e) {
          onError(e.toString());
        });
  }

  @override
  Future<void>? onLoadedAppConfig(String? lang, Function(Map?) callback) async {
    /// Get the config from Caching
    if (kAdvanceConfig.isCaching) {
      final configCache = await Services().api.getHomeCache(lang);
      if (configCache != null) {
        callback(configCache);
      }
    }
  }

  Widget renderVariantItem(
    BuildContext context,
    String name,
    String? option, {
    String? imageUrl,
    bool isColor = false,
    String? colorValue,
    AttributeProductCartStyle style = AttributeProductCartStyle.normal,
  }) {
    final color = colorValue?.isNotEmpty ?? false
        ? HexColor(colorValue)
        : HexColor(context.getHexColor(option));
    if (style.isShortStyle) {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return ImageResize(url: imageUrl, height: 15, width: 15);
      }
      if (isColor) {
        return Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValueOpacity(0.3),
            ),
            color: color,
          ),
        );
      }
      return Text(option ?? '', textAlign: TextAlign.end);
    }

    final title = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 50.0, maxWidth: 200),
      child: Text(
        '${name.upperCaseFirstChar()}: ',
        style: style.isColumnStyle
            ? Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              )
            : null,
      ),
    );

    Widget value = const SizedBox();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      value = Align(
        alignment: AlignmentDirectional.centerEnd,
        child: ImageResize(url: imageUrl, height: 15, width: 15),
      );
    } else if (isColor) {
      value = Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Container(
          width: style.isColumnStyle ? 10 : 15,
          height: style.isColumnStyle ? 10 : 15,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValueOpacity(0.3),
            ),
            color: color,
          ),
        ),
      );
    } else {
      value = Text(
        option ?? '',
        textAlign: TextAlign.end,
        style: style.isColumnStyle
            ? Theme.of(context).textTheme.labelMedium
            : null,
      );
    }

    if (style.isColumnStyle) {
      return Row(children: <Widget>[title, value]);
    }

    return Row(
      children: <Widget>[
        Expanded(flex: 3, child: title),
        Expanded(flex: isColor ? 1 : 2, child: value),
      ],
    );
  }

  @override
  Widget renderVariantCartItem(
    BuildContext context,
    Product product,
    variation,
    Map? options, {
    AttributeProductCartStyle style = AttributeProductCartStyle.normal,
  }) {
    var list = <Widget>[];
    if (options != null && options.isNotEmpty) {
      for (var key in options.keys) {
        final attr = product.attributes?.firstWhereOrNull(
          (element) => element.keyAttr == key,
        );
        final attrName = product.getNameAttribute(key);
        final optionName = '${options[key]}';

        final attrType =
            kProductVariantLayout[attr?.cleanSlug ?? attr?.name] ??
            kProductVariantLayout[attr?.name?.toLowerCase()];
        final isColor =
            attr?.isColorType == true ||
            attrType == 'color' ||
            // For backward compatibility
            attrName.toLowerCase() == 'color';

        list.add(
          renderVariantItem(
            context,
            attrName,
            optionName,
            imageUrl: attr?.imageUrls?[optionName],
            isColor: isColor,
            colorValue: attr?.colorValues?[optionName],
            style: style,
          ),
        );

        if (style.isNormalStyle) {
          list.add(const SizedBox(height: 5.0));
        }
      }
    } else {
      for (var att in variation.attributes) {
        final attrType = kProductVariantLayout[att.name?.toLowerCase()];
        final isColor =
            attrType == 'color' ||
            // For backward compatibility
            att.name?.toLowerCase() == 'color';
        list.add(
          renderVariantItem(
            context,
            att.name!,
            att.option,
            isColor: isColor,
            style: style,
          ),
        );
        if (style.isNormalStyle) {
          list.add(const SizedBox(height: 5.0));
        }
      }
    }

    if (style.isShortStyle && list.isNotEmpty) {
      return Wrap(
        children:
            list.expand((element) => [element, const Text(' • ')]).toList()
              ..removeLast(),
      );
    }

    return Column(children: list);
  }

  @override
  Widget renderAddonsOptionsCartItem(
    context,
    List<AddonsOption>? selectedOptions,
  ) {
    if (selectedOptions?.isEmpty ?? true) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        selectedOptions!
            .map(
              (e) => e.type == AddonsType.file_upload
                  ? e.label?.split('/').last
                  : e.label,
            )
            .join(', '),
        style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor),
      ),
    );
  }

  @override
  void loadShippingMethods(context, CartModel cartModel, bool beforehand) {
    //    if (!beforehand) return;
    //    final cartModel = Provider.of<CartModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      final token = context.read<UserModel>().user?.cookie;
      var langCode = Provider.of<AppModel>(context, listen: false).langCode;
      Provider.of<ShippingMethodModel>(
        context,
        listen: false,
      ).getShippingMethods(
        cartModel: cartModel,
        token: token,
        langCode: langCode,
      );
    });
  }

  @override
  Widget renderOrderActionButtons(
    BuildContext context,
    Order order,
    void Function()? cancelOrder,
    void Function()? createRefund,
    void Function(Order? order)? payOrder,
  ) {
    var isOrderRefundable = false;
    if (kPaymentConfig.refundPeriod != null) {
      if (order.createdAt!
          .add(Duration(days: kPaymentConfig.refundPeriod!.toInt()))
          .isAfter(DateTime.now())) {
        isOrderRefundable = true;
      }
    }
    return Row(
      children: <Widget>[
        if ([OrderStatus.pending].contains(order.status) &&
            order.paymentUrl?.isNotEmpty == true)
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  paymentWithWebview(context, order, null, payOrder, null);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green,
                  ),
                  child: Text(
                    S.of(context).payNow.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        if ([
          OrderStatus.processing,
          OrderStatus.onHold,
          OrderStatus.pending,
        ].contains(order.status))
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: cancelOrder,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (order.status!.isCancelled)
                        ? Colors.blueGrey
                        : Colors.red,
                  ),
                  child: Text(
                    S.of(context).cancel.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        if (![
              OrderStatus.canceled,
              OrderStatus.cancelled,
              OrderStatus.refunded,
              OrderStatus.refundRequested,
              OrderStatus.failed,
              OrderStatus.onHold,
              OrderStatus.pending,
            ].contains(order.status) &&
            isOrderRefundable)
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: createRefund,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: order.status == OrderStatus.refunded
                        ? Colors.blueGrey
                        : Colors.lightBlue,
                  ),
                  child: Text(
                    S.of(context).refund.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  String? getPriceItemInCart(
    Product product,
    CartItemMetaData? cartItemMetaData,
    Map<String, dynamic> currencyRate,
    String? currency, {
    int quantity = 1,
  }) {
    if (product.isTopUpProduct()) {
      final defaultCurrency = kCurrencyConfig.defaultCurrency;
      return PriceTools.getPriceProduct(
        product,
        bookingInfo: cartItemMetaData?.bookingInfo,
        currencyRate,
        defaultCurrency?.currencyCode,
        onSale: false,
        quantity: quantity,
      );
    }

    final variation = cartItemMetaData?.variation;
    final isSale = (variation?.id != null)
        ? (variation?.isOnSaleActive ?? false)
        : product.isOnSaleActive;

    if (cartItemMetaData?.rentalInfo != null) {
      final rentalTotal = RentalTools.getCartTotal(
        cartItemMetaData?.rentalInfo,
        quantity,
      );
      return PriceTools.getCurrencyFormatted(
        rentalTotal,
        currencyRate,
        quantity: 1,
        currency: currency,
      );
    }

    final hasAddons = cartItemMetaData?.addonsOptions?.isNotEmpty ?? false;
    final isVariableProduct =
        cartItemMetaData?.variation != null &&
        cartItemMetaData?.variation?.id != null;

    final hasYithAddons =
        cartItemMetaData?.selectedYithOptions?.isNotEmpty ?? false;

    if (hasYithAddons) {
      var basePrice =
          cartItemMetaData?.variation?.valuePrice ?? product.valuePrice;
      var total =
          YithAddonsTools.getSelectedYithOptionsPrice(
            basePrice,
            cartItemMetaData!.selectedYithOptions!,
            quantity,
          ) +
          basePrice * quantity;

      return PriceTools.getCurrencyFormatted(
        total,
        currencyRate,
        quantity: quantity,
        currency: currency,
      );
    }

    if (hasAddons && !isVariableProduct) {
      return PriceTools.getAddsOnPriceProductValue(
        product,
        currencyRate,
        currency,
        selectedOptions: cartItemMetaData?.addonsOptions,
        bookingInfo: cartItemMetaData?.bookingInfo,
        quantity: quantity,
        onSale: isSale,
      );
    }

    if (cartItemMetaData?.selectedTieredPrice != null) {
      return PriceTools.getCurrencyFormatted(
        cartItemMetaData?.selectedTieredPrice?.price,
        currencyRate,
        quantity: quantity,
        currency: currency,
      );
    }

    if (isVariableProduct && variation != null) {
      return PriceTools.getVariantPriceProductValue(
        variation,
        currencyRate,
        currency,
        selectedOptions: cartItemMetaData?.addonsOptions ?? <AddonsOption>[],
        onSale: isSale,
        quantity: quantity,
      );
    }

    return PriceTools.getPriceProduct(
      product,
      bookingInfo: cartItemMetaData?.bookingInfo,
      currencyRate,
      currency,
      quantity: quantity,
      onSale: isSale,
    );
  }

  @override
  Future<List<Country>?> loadCountries() async {
    List<Country>? countries = <Country>[];
    if (kDefaultCountry.isNotEmpty) {
      for (var item in kDefaultCountry) {
        countries.addData(item);
      }
    } else {
      try {
        countries = ListCountry.fromWooJson(SettingsBox().countries).list;
      } catch (err) {
        printLog(err);
      }
    }
    return countries;
  }

  @override
  Future<List<CountryState>> loadStates(Country country) async {
    final items = await Tools.loadStatesByCountry(country.id!);
    var states = <CountryState>[];
    if (items.isNotEmpty) {
      for (var item in items) {
        states.add(CountryState.fromConfig(item));
      }
    } else {
      try {
        final items = await Services().api.getStatesByCountryId(country.id);
        if (items != null && items.isNotEmpty) {
          for (var item in items) {
            states.add(CountryState.fromWooJson(item));
          }
        }
      } catch (e) {
        printLog(e.toString());
      }
    }
    return states;
  }

  @override
  Future<void> resetPassword(BuildContext context, String username) async {
    try {
      final val = await (Provider.of<UserModel>(
        context,
        listen: false,
      ).submitForgotPassword(forgotPwLink: '', data: {'user_login': username}));
      if (val?.isEmpty ?? true) {
        Tools.showSnackBar(
          ScaffoldMessenger.of(context),
          S.of(context).checkConfirmLink,
        );
        Future.delayed(
          const Duration(seconds: 1),
          () => Navigator.of(context).pop(),
        );
      } else {
        Tools.showSnackBar(ScaffoldMessenger.of(context), val);
      }
      return;
    } catch (e) {
      printLog('Unknown Error: $e');
    }
  }

  @override
  Future<bool>? syncCartFromWebsite(
    String? token,
    CartModel cartModel,
    BuildContext context,
  ) async {
    if (kCartDetail.enableSyncCartFromWebsite != true) {
      return false;
    }

    try {
      var items =
          await (Services().api.getCartInfo(token) as Future<List<dynamic>?>);
      if (items != null && items.isNotEmpty) {
        await cartModel.clearCart(isSaveRemote: false);
        for (var item in List<Map<String, dynamic>>.from(items)) {
          final product = Product.jsonParser(item['product']);
          final variation = item['variation'] != null
              ? ProductVariation.fromJson(item['variation'])
              : null;
          final mapAttr = <String, String>{};
          for (var attribute in (variation?.attributes ?? <Attribute>[])) {
            final key = attribute.keyAttr;
            final value = attribute.option;
            if (key != null && value != null) {
              mapAttr[key] = value;
            }
          }
          await cartModel.addProductToCart(
            context: context,
            product: product,
            quantity: num.tryParse('${item['quantity']}')?.toInt() ?? 0,
            cartItemMetaData: CartItemMetaData(
              variation: item['variation'] != null
                  ? ProductVariation.fromJson(item['variation'])
                  : null,
              options: mapAttr,
            ),
            isSaveRemote: false,
          );
        }
        if (cartModel is CartModelWoo) {
          await cartModel.refreshTieredPricesForCartItems(token: token);
        }
        return true;
      }
    } catch (e, t) {
      printError(e, t);
    }

    return false;
  }

  @override
  Future<void>? syncCartToWebsite(CartModel cartModel) {
    if ((kCartDetail.enableSyncCartToWebsite == true) &&
        cartModel.user != null) {
      return Services().api.syncCartToWebsite(cartModel, cartModel.user);
    }
    return null;
  }

  @override
  Future<Product?>? getProductDetail(BuildContext context, Product? product) {
    return Services().api.overrideGetProduct(product!.id);
  }

  @override
  Widget renderRecurringTotals(BuildContext context) {
    return const RecurringTotal();
  }

  @override
  Widget renderPayByWallet(BuildContext context) {
    return Services().renderWalletPayPartialPayment();
  }

  @override
  Widget renderCheckoutWalletInfo(BuildContext context) {
    return Services().renderCheckoutWalletInfo();
  }

  @override
  Future updateOrderAfterCheckout(BuildContext context, Order order) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    final walletModel = Provider.of<WalletModel>(context, listen: false);
    if (cartModel.walletAmount > 0 &&
        userModel.user != null &&
        userModel.user!.cookie != null) {
      await walletModel.partialPayment(order.id!, userModel.user!.cookie!);
    }
  }

  @override
  Widget renderPaymentMethodItem(
    BuildContext context,
    PaymentMethod paymentMethod,
    Function(String? p1) onSelected,
    String? selectedId, {
    bool useDesktopStyle = false,
  }) {
    var isRiskFreeEnabled = paymentMethod.smartCod?.isRiskFreeEnabled == true;
    if (isRiskFreeEnabled) {
      return Services().renderRiskFreeCod(context, selectedId);
    }
    if (paymentMethod.id == 'wallet') {
      return Services().renderWalletPaymentMethodItem(
        paymentMethod,
        onSelected,
        selectedId,
      );
    } else {
      return super.renderPaymentMethodItem(
        context,
        paymentMethod,
        onSelected,
        selectedId,
        useDesktopStyle: useDesktopStyle,
      );
    }
  }

  @override
  Widget reOrderButton(Order order) {
    return ReOrderIndex(order: order);
  }

  @override
  Widget productReviewWidget(
    Product product, {
    bool isStyleExpansion = true,
    bool isShowEmpty = false,
    Widget Function(int)? builderTitle,
  }) {
    return ProductReviewsIndex(
      product: product,
      isStyleExpansion: isStyleExpansion,
      isShowEmpty: isShowEmpty,
      builderTitle: builderTitle,
    );
  }

  @override
  List<OrderByType> get supportedSortByOptions => [
    OrderByType.onSale,
    OrderByType.featured,
    OrderByType.title,
    OrderByType.popularity,
    OrderByType.rating,
    OrderByType.date,
    OrderByType.price,
    OrderByType.menu_order,
    OrderByType.rand,
    OrderByType.relevance,
  ];

  @override
  Widget renderSelectedComponentsCartItem(
    context,
    Map<String, SelectedProductComponent>? selectedComponents,
  ) {
    if (selectedComponents != null) {
      final theme = Theme.of(context);
      final model = Provider.of<AppModel>(context);
      final rates = model.currencyRate;
      var components = <Widget>[];
      for (var item in selectedComponents.values) {
        components.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.component.name ?? '',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.product.name ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'x${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      PriceTools.getCurrencyFormatted(item.getPrice(), rates) ??
                          '',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        if (item.variant != null) {
          components.add(const SizedBox(height: 4));
          components.add(
            Services().widget.renderVariantCartItem(
              context,
              item.product,
              item.variant!,
              null,
              style: AttributeProductCartStyle.short,
            ),
          );
        }
        components.add(const SizedBox(height: 8));
      }
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: components,
        ),
      );
    }
    return super.renderSelectedComponentsCartItem(context, selectedComponents);
  }

  @override
  Widget renderUpdateProfileScreen() {
    return UserUpdateWooScreen();
  }

  @override
  Widget renderYithAddonsOptionsCartItem(
    context,
    Map<String, Map<String, YithAddonsOption>>? selectedYithOptions,
  ) {
    if (selectedYithOptions?.isEmpty ?? true) {
      return const SizedBox();
    }
    var options = <YithAddonsOption>[];
    for (var item in selectedYithOptions!.values) {
      options.addAll(item.values);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        options
            .map((e) => e.inputValue?.toString() ?? e.label ?? '')
            .join(', '),
        style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
