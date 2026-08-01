enum AttributeProductCartStyle {
  normal,
  short,
  column;

  bool get isShortStyle => this == AttributeProductCartStyle.short;
  bool get isNormalStyle => this == AttributeProductCartStyle.normal;
  bool get isColumnStyle => this == AttributeProductCartStyle.column;
}

enum OrderSummaryStyle {
  normal,
  webMyCart,
  webCheckoutShippingAddress,
  webCheckoutShippingMethod,
  webCheckoutPayment,
  webCheckoutReview;

  bool get isWeb => [
    OrderSummaryStyle.webMyCart,
    OrderSummaryStyle.webCheckoutShippingAddress,
    OrderSummaryStyle.webCheckoutShippingMethod,
    OrderSummaryStyle.webCheckoutReview,
    OrderSummaryStyle.webCheckoutPayment,
  ].contains(this);

  bool get showShippingFee => [
    OrderSummaryStyle.webCheckoutReview,
    OrderSummaryStyle.webCheckoutPayment,
  ].contains(this);

  bool get enablePlaceOrder =>
      [OrderSummaryStyle.webCheckoutReview].contains(this);

  bool get isWebMyCart => this == OrderSummaryStyle.webMyCart;
  bool get isWebCheckoutPayment => this == OrderSummaryStyle.webCheckoutPayment;
  bool get isWebCheckoutShippingAddress =>
      this == OrderSummaryStyle.webCheckoutShippingAddress;
  bool get isWebCheckoutReview => this == OrderSummaryStyle.webCheckoutReview;
}

enum CartDetailStyle {
  normal,
  style01;

  factory CartDetailStyle.fromString(String? type) {
    return CartDetailStyle.values.firstWhere(
      (style) => style.name == type,
      orElse: () => CartDetailStyle.normal,
    );
  }

  bool get isStyle01 => this == CartDetailStyle.style01;

  bool get isNormal => this == CartDetailStyle.normal;
}

class CartDetail {
  static const _defaultEmptyImage = 'assets/images/leaves.png';
  static const _defaultBoxFit = 'cover';
  static const _defaultMinAllowTotalCartValue = 0;
  static const _defaultMaxAllowQuantity = 100;

  final int minAllowTotalCartValue;
  final int maxAllowQuantity;
  final CartDetailStyle style;
  final String boxFit;

  /// Sync cart data from website to app.
  final bool? enableSyncCartFromWebsite;

  /// Sync cart data from app to website.
  final bool? enableSyncCartToWebsite;

  /// The image to show when the cart is empty.
  final String? emptyImage;

  const CartDetail({
    this.minAllowTotalCartValue = _defaultMinAllowTotalCartValue,
    this.maxAllowQuantity = _defaultMaxAllowQuantity,
    this.style = CartDetailStyle.style01,
    this.boxFit = _defaultBoxFit,
    this.emptyImage = _defaultEmptyImage,
    this.enableSyncCartFromWebsite,
    this.enableSyncCartToWebsite,
  });

  Map<String, dynamic> toJson() => {
    'minAllowTotalCartValue': minAllowTotalCartValue,
    'maxAllowQuantity': maxAllowQuantity,
    'style': style.name,
    'boxFit': boxFit,
    'emptyImage': emptyImage,
    'enableSyncCartFromWebsite': enableSyncCartFromWebsite,
    'enableSyncCartToWebsite': enableSyncCartToWebsite,
  };

  factory CartDetail.fromJson(Map<dynamic, dynamic> json) {
    return CartDetail(
      minAllowTotalCartValue:
          int.tryParse('${json['minAllowTotalCartValue']}') ??
          _defaultMinAllowTotalCartValue,
      maxAllowQuantity:
          int.tryParse('${json['maxAllowQuantity']}') ??
          _defaultMaxAllowQuantity,
      style: CartDetailStyle.fromString(json['style']),
      boxFit: json['boxFit']?.toString() ?? _defaultBoxFit,
      // Use containsKey for backward compatibility: missing key → default image,
      // key present but null/empty → hide image.
      emptyImage: json.containsKey('emptyImage')
          ? json['emptyImage']?.toString()
          : _defaultEmptyImage,
      enableSyncCartFromWebsite: json.containsKey('enableSyncCartFromWebsite')
          ? bool.tryParse('${json['enableSyncCartFromWebsite']}')
          : null,
      enableSyncCartToWebsite: json.containsKey('enableSyncCartToWebsite')
          ? bool.tryParse('${json['enableSyncCartToWebsite']}')
          : null,
    );
  }

  CartDetail copyWith({
    int? minAllowTotalCartValue,
    int? maxAllowQuantity,
    CartDetailStyle? style,
    String? boxFit,
    String? emptyImage,
    bool? enableSyncCartFromWebsite,
    bool? enableSyncCartToWebsite,
  }) {
    return CartDetail(
      minAllowTotalCartValue:
          minAllowTotalCartValue ?? this.minAllowTotalCartValue,
      maxAllowQuantity: maxAllowQuantity ?? this.maxAllowQuantity,
      style: style ?? this.style,
      boxFit: boxFit ?? this.boxFit,
      emptyImage: emptyImage ?? this.emptyImage,
      enableSyncCartFromWebsite:
          enableSyncCartFromWebsite ?? this.enableSyncCartFromWebsite,
      enableSyncCartToWebsite:
          enableSyncCartToWebsite ?? this.enableSyncCartToWebsite,
    );
  }
}
