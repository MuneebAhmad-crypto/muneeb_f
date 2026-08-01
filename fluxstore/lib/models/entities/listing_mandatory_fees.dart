import 'dart:convert';

import 'package:inspireui/utils/logs.dart';

class ListingMandatoryFees {
  final List<ListingMandatoryFee> items;

  const ListingMandatoryFees({this.items = const []});

  factory ListingMandatoryFees.fromJson(dynamic json) {
    if (json == null) return const ListingMandatoryFees();

    final parsedItems = <ListingMandatoryFee>[];

    try {
      final feesData = json is String ? jsonDecode(json) : json;
      if (feesData is! List) return const ListingMandatoryFees();

      for (final item in feesData) {
        if (item is! Map) continue;

        final fee = ListingMandatoryFee.fromJson(
          Map<String, dynamic>.from(item),
        );

        if (fee.isValid) {
          parsedItems.add(fee);
        }
      }
    } catch (e, trace) {
      printLog('Error parsing Listeo mandatory fees: $e\n$trace');
    }

    return ListingMandatoryFees(items: parsedItems);
  }

  List<Map<String, dynamic>> toJson() => items.map((e) => e.toJson()).toList();
}

class ListingMandatoryFee {
  final String title;
  final String? price;
  final String? description;

  const ListingMandatoryFee({
    required this.title,
    this.price,
    this.description,
  });

  bool get isValid => price?.isNotEmpty ?? false;

  factory ListingMandatoryFee.fromJson(Map<String, dynamic> json) {
    String? parseString(dynamic value) {
      if (value == null) {
        return null;
      }

      final parsedValue = value.toString().trim();
      return parsedValue.isEmpty ? null : parsedValue;
    }

    return ListingMandatoryFee(
      title: parseString(json['title']) ?? '',
      price: parseString(json['price']),
      description: parseString(json['description']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'price': price,
    'description': description,
  };
}
