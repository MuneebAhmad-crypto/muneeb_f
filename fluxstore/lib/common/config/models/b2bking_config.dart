enum GuestAccessRestriction {
  none,
  hidePrices,
  replacePricesQuote;

  static GuestAccessRestriction fromString(String? value) {
    switch (value) {
      case 'hide_prices':
        return GuestAccessRestriction.hidePrices;
      case 'replace_prices_quote':
        return GuestAccessRestriction.replacePricesQuote;
      default:
        return GuestAccessRestriction.none;
    }
  }

  String toJson() {
    switch (this) {
      case GuestAccessRestriction.hidePrices:
        return 'hide_prices';
      case GuestAccessRestriction.replacePricesQuote:
        return 'replace_prices_quote';
      case GuestAccessRestriction.none:
        return 'none';
    }
  }
}

class B2BKingConfig {
  final bool enabled;
  final GuestAccessRestriction guestAccessRestriction;

  const B2BKingConfig({
    this.enabled = false,
    this.guestAccessRestriction = GuestAccessRestriction.none,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'guestAccessRestriction': guestAccessRestriction.toJson(),
    };
  }

  factory B2BKingConfig.fromJson(Map map) {
    return B2BKingConfig(
      enabled: (map['enabled'] as bool?) ?? false,
      guestAccessRestriction: GuestAccessRestriction.fromString(
        map['guestAccessRestriction'],
      ),
    );
  }
}
