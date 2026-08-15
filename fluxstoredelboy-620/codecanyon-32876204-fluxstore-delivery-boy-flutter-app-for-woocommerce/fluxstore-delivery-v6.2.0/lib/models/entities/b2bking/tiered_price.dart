class B2BKingTieredPrice {
  const B2BKingTieredPrice({this.quantity = 0, this.discount, this.price});

  final int quantity;
  final double? discount;
  final double? price;

  factory B2BKingTieredPrice.fromJson(Map parsedJson) => B2BKingTieredPrice(
    quantity: int.tryParse('${parsedJson['quantity']}') ?? 0,
    discount: double.tryParse('${parsedJson['discount']}') != null
        ? double.parse('${parsedJson['discount']}')
        : null,
    price: double.tryParse('${parsedJson['price']}') != null
        ? double.parse('${parsedJson['price']}')
        : null,
  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['quantity'] = quantity;
    data['discount'] = discount;
    data['price'] = price;
    return data;
  }
}
