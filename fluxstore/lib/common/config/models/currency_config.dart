import 'package:collection/collection.dart';
import 'package:flux_ui/flux_ui.dart';

class CurrencyConfig {
  /// The currency code of the default currency (e.g. "USD", "VND").
  /// When null, the first item in [currencies] is used as the default.
  final String? defaultCurrencyCode;

  final List<Currency> currencies;

  /// Enable WOOCS (WooCommerce Currency Switcher) plugin integration.
  final bool enableWOOCSCurrencySwitcher;

  const CurrencyConfig({
    this.defaultCurrencyCode,
    this.currencies = const [],
    this.enableWOOCSCurrencySwitcher = false,
  });

  /// Returns the default [Currency] by matching [defaultCurrencyCode] against
  /// [currencies], falling back to the first currency in the list.
  Currency? get defaultCurrency {
    if (defaultCurrencyCode != null) {
      final code = defaultCurrencyCode!.toUpperCase();
      return currencies.firstWhereOrNull(
        (c) => c.currencyCode.toUpperCase() == code,
      );
    }
    return currencies.firstOrNull;
  }

  /// Parse from the new nested `currencyConfig` JSON format.
  factory CurrencyConfig.fromJson(Map<dynamic, dynamic> json) {
    return CurrencyConfig(
      defaultCurrencyCode: json['defaultCurrencyCode']?.toString(),
      currencies: <Currency>[
        ...((json['currencies'] is List ? json['currencies'] : []) as List).map(
          (e) => Currency.fromJson(e),
        ),
      ],
      enableWOOCSCurrencySwitcher:
          bool.tryParse('${json['enableWOOCSCurrencySwitcher']}') ?? false,
    );
  }

  /// Parse from the legacy flat `advanceConfig` JSON keys.
  /// Supports backward compatibility with the old [AdvancedConfig] format.
  factory CurrencyConfig.fromAdvanceConfigJson(Map<dynamic, dynamic> json) {
    final defaultCurrencyMap = json['DefaultCurrency'];
    String? defaultCurrencyCode;
    if (defaultCurrencyMap is Map && defaultCurrencyMap.isNotEmpty) {
      defaultCurrencyCode = (defaultCurrencyMap['currencyCode'] as String?)
          ?.toUpperCase();
    }

    return CurrencyConfig(
      defaultCurrencyCode: defaultCurrencyCode,
      currencies: <Currency>[
        ...((json['Currencies'] is List
                    ? json['Currencies']
                    : [
                        {
                          'symbol': '\$',
                          'decimalDigits': 2,
                          'symbolBeforeTheNumber': true,
                          'currency': 'USD',
                          'currencyCode': 'USD',
                        },
                        {
                          'symbol': '₹',
                          'decimalDigits': 0,
                          'symbolBeforeTheNumber': true,
                          'currency': 'INR',
                          'currencyCode': 'INR',
                        },
                        {
                          'symbol': 'đ',
                          'decimalDigits': 2,
                          'symbolBeforeTheNumber': false,
                          'currency': 'VND',
                          'currencyCode': 'VND',
                        },
                        {
                          'symbol': '€',
                          'decimalDigits': 2,
                          'symbolBeforeTheNumber': true,
                          'currency': 'EUR',
                          'currencyCode': 'EUR',
                        },
                        {
                          'symbol': '£',
                          'decimalDigits': 2,
                          'symbolBeforeTheNumber': true,
                          'currency': 'Pound sterling',
                          'currencyCode': 'GBP',
                        },
                        {
                          'symbol': 'AR\$',
                          'decimalDigits': 2,
                          'symbolBeforeTheNumber': true,
                          'currency': 'ARS',
                          'currencyCode': 'ARS',
                        },
                      ])
                as List)
            .map((e) => Currency.fromJson(e)),
      ],
      enableWOOCSCurrencySwitcher:
          bool.tryParse('${json['EnableWOOCSCurrencySwitcher']}') ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'defaultCurrencyCode': defaultCurrencyCode,
    'currencies': currencies.map((e) => e.toJson()).toList(),
    'enableWOOCSCurrencySwitcher': enableWOOCSCurrencySwitcher,
  };

  CurrencyConfig copyWith({
    String? defaultCurrencyCode,
    List<Currency>? currencies,
    bool? enableWOOCSCurrencySwitcher,
  }) {
    return CurrencyConfig(
      defaultCurrencyCode: defaultCurrencyCode ?? this.defaultCurrencyCode,
      currencies: currencies ?? this.currencies,
      enableWOOCSCurrencySwitcher:
          enableWOOCSCurrencySwitcher ?? this.enableWOOCSCurrencySwitcher,
    );
  }
}
