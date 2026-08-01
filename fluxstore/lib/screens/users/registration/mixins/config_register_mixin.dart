import '../../../../common/config.dart';
import '../../../../services/service_config.dart';

mixin ConfigRegisterMixin {
  bool get showEmailWhenRegister => kAuthConfig.registration.showEmail;
  bool get requireEmailWhenRegister =>
      showEmailWhenRegister && kAuthConfig.registration.requireEmail;
  bool get showFirstNameWhenRegister => kAuthConfig.registration.firstName.show;
  bool get requireFirstNameWhenRegister =>
      showFirstNameWhenRegister && kAuthConfig.registration.firstName.require;
  bool get showLastNameWhenRegister => kAuthConfig.registration.lastName.show;
  bool get requireLastNameWhenRegister =>
      showLastNameWhenRegister && kAuthConfig.registration.lastName.require;
  bool get showPhoneNumberWhenRegister =>
      kAuthConfig.registration.showPhoneNumber;
  bool get requirePhoneNumberWhenRegister =>
      showPhoneNumberWhenRegister &&
      kAuthConfig.registration.requirePhoneNumber;
  bool get showUsernameWhenRegister => kAuthConfig.registration.showUsername;
  bool get requireUsernameWhenRegister =>
      showUsernameWhenRegister && kAuthConfig.registration.requireUsername;
  bool get isVendorRegister =>
      kVendorConfig.vendorRegister && ServerConfig().isVendorType();
  bool get isDeliveryRegister =>
      kVendorConfig.deliveryRegister && ServerConfig().isDeliverySupported;
  bool get isOwnerRegister =>
      kVendorConfig.ownerRegister && ServerConfig().isListeoType;
}
