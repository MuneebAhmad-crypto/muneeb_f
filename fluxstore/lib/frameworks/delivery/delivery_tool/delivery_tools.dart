import 'package:country_pickers/country_pickers.dart';

import '../../../models/entities/address.dart';

class DeliveryTools {
  static String formatAddress(Address address) {
    return [
      address.apartment,
      address.block,
      address.street,
      address.city,
      address.state,
      address.zipCode,
      getCountryName(address.country),
    ].where((p) => p?.trim().isNotEmpty ?? false).join(', ');
  }

  /// Convert country ISO code to full name
  static String getCountryName(String? countryIsoCode) {
    if (countryIsoCode == null || countryIsoCode.isEmpty) return '';
    try {
      return CountryPickerUtils.getCountryByIsoCode(countryIsoCode).name;
    } catch (e) {
      return countryIsoCode;
    }
  }
}
