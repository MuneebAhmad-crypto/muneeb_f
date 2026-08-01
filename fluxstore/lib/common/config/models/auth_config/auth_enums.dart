/// The default authentication method.
enum AuthMethod {
  emailPassword,
  sms,
  digits;

  static AuthMethod fromString(String? value) {
    return AuthMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AuthMethod.emailPassword,
    );
  }
}

/// The verification method for Digits mobile login.
enum DigitsVerifyMethod {
  sms,
  firebase,
  whatsapp;

  static DigitsVerifyMethod fromString(String? value) {
    return DigitsVerifyMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DigitsVerifyMethod.sms,
    );
  }
}
