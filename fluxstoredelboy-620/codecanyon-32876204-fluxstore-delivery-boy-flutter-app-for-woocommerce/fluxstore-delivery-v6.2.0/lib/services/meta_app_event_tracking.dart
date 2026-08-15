import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/entities/blog.dart';
import '../../models/entities/product.dart';
import '../../models/order/order.dart';
import '../../modules/analytics/abstract_analytic_trigger.dart';
import '../models/app_model.dart';
import '../models/product_model.dart';

class MetaAppEventTracking extends AbstractAnalyticTrigger {
  final facebookAppEvents = FacebookAppEvents();

  String _resolveCurrencyCode(BuildContext? context) {
    if (context == null) {
      return '';
    }

    final appModel = context.read<AppModel>();
    return (appModel.currencyCode ?? appModel.currency ?? '').toUpperCase();
  }

  @override
  void onLogin(String? method) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_login',
      parameters: {'method': method},
    );
  }

  @override
  void onRegister(String? method) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_complete_registration',
      parameters: {'method': method},
    );
  }

  @override
  void addToWishList(Product value) {
    facebookAppEvents.logAddToWishlist(
      id: value.id,
      type: 'product',
      price: double.tryParse(value.price ?? '') ?? 0.0,
      currency: '',
    );
  }

  @override
  void onAddToCart(Product value, int? quantity, BuildContext? context) {
    final currencyCode = _resolveCurrencyCode(context);
    facebookAppEvents.logAddToCart(
      id: value.id,
      type: 'product',
      price: double.tryParse(value.price ?? '') ?? 0.0,
      currency: currencyCode,
    );
  }

  @override
  void onCreateRefund(Order value) {
    facebookAppEvents.logEvent(
      name: 'order_refunded',
      parameters: {'order_id': value.id, 'order_total': value.total},
    );
  }

  @override
  void onPurchased(Order value, BuildContext? context) {
    final currencyCode = (value.currencyCode?.isNotEmpty ?? false)
        ? value.currencyCode!.toUpperCase()
        : _resolveCurrencyCode(context);
    final amount = value.total ?? 0.0;
    facebookAppEvents.logPurchase(
      parameters: {
        'order_id': value.id,
        'total': amount,
        'currency': currencyCode,
      },
      amount: amount,
      currency: currencyCode,
    );
  }

  @override
  void onRemoveProductFromCart(
    Product value,
    int? quantity,
    BuildContext? context,
  ) {
    facebookAppEvents.logEvent(
      name: 'remove_cart_item',
      parameters: {
        'product_id': value.id,
        'product_name': value.name,
        'quantity': quantity,
      },
    );
  }

  @override
  void onTapProduct(Product value, String? itemListId, String? itemListName) {
    // Keep tap interaction separate from ViewContent to avoid duplicated
    // view counts when a product detail screen is opened.
    facebookAppEvents.logEvent(
      name: 'tap_product',
      parameters: {
        'product_id': value.id,
        'product_name': value.name,
        'item_list_id': itemListId,
        'item_list_name': itemListName,
      },
    );
  }

  @override
  void onViewListProduct(List<Product> value, BuildContext? context) {
    String? itemListId;
    String? itemListName;
    if (context != null) {
      final model = context.read<ProductModel>();
      itemListId = model.categoryIds?.join(',') ?? model.tagIds?.join(',');
      itemListName = model.categoryName;
    }
    facebookAppEvents.logViewContent(
      type: 'view_product_list',
      content: {'category_name': itemListName, 'category_ids': itemListId},
    );
  }

  @override
  void onViewCart(Map value, BuildContext? context) {
    facebookAppEvents.logViewContent(
      type: 'view_cart',
      content: Map<String, dynamic>.from(value),
    );
  }

  @override
  void onViewProduct(Product value, BuildContext? context) {
    facebookAppEvents.logViewContent(
      id: value.id,
      type: 'view_product',
      price: double.tryParse(value.price ?? '') ?? 0.0,
      content: {'product_name': value.name},
    );
  }

  @override
  void onBeginCheckout(BuildContext context) {
    facebookAppEvents.logEvent(name: 'fb_mobile_initiated_checkout');
  }

  @override
  void onAddPaymentInfo(String? value, BuildContext? context) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_payment_info',
      parameters: {'value': value},
    );
  }

  @override
  void onAddShippingInfo(String? value, BuildContext? context) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_shipping_info',
      parameters: {'value': value},
    );
  }

  @override
  void onTapBlog(Blog value) {
    facebookAppEvents.logEvent(
      name: 'tap_blog',
      parameters: {'blog_id': value.id, 'blog_title': value.title},
    );
  }

  @override
  void onAddBlogToWishList(Blog value) {
    facebookAppEvents.logEvent(
      name: 'add_blog_to_wishlist',
      parameters: {'blog_id': value.id, 'blog_title': value.title},
    );
  }

  @override
  void onSearchProduct(String value, bool isEmpty, BuildContext? context) {
    facebookAppEvents.logEvent(
      name: 'search_products',
      parameters: {'keyword': value},
    );
  }

  @override
  void onSelectPromotion(String? promotionId, String? promotionName) {
    facebookAppEvents.logEvent(
      name: 'select_promotion',
      parameters: {
        'promotion_id': promotionId,
        'promotion_name': promotionName,
      },
    );
  }
}
