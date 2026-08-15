import 'auth_enums.dart';

class AuthProvidersConfig {
  final AuthAppleConfig apple;
  final AuthGoogleConfig google;
  final AuthFacebookConfig facebook;
  final AuthSmsConfig sms;

  const AuthProvidersConfig({
    this.apple = const AuthAppleConfig(),
    this.google = const AuthGoogleConfig(),
    this.facebook = const AuthFacebookConfig(),
    this.sms = const AuthSmsConfig(),
  });

  factory AuthProvidersConfig.fromJson(Map json) {
    return AuthProvidersConfig(
      apple: json['apple'] is Map
          ? AuthAppleConfig.fromJson(json['apple'])
          : const AuthAppleConfig(),
      google: json['google'] is Map
          ? AuthGoogleConfig.fromJson(json['google'])
          : const AuthGoogleConfig(),
      facebook: json['facebook'] is Map
          ? AuthFacebookConfig.fromJson(json['facebook'])
          : const AuthFacebookConfig(),
      sms: json['sms'] is Map
          ? AuthSmsConfig.fromJson(json['sms'])
          : const AuthSmsConfig(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apple': apple.toJson(),
      'google': google.toJson(),
      'facebook': facebook.toJson(),
      'sms': sms.toJson(),
    };
  }
}

class AuthAppleConfig {
  final bool enable;
  final String? iOSBundleId;
  final String? teamId;

  const AuthAppleConfig({this.enable = false, this.iOSBundleId, this.teamId});

  factory AuthAppleConfig.fromJson(Map json) {
    return AuthAppleConfig(
      enable: bool.tryParse('${json['enable']}') ?? false,
      iOSBundleId: json['iOSBundleId'],
      teamId: json['teamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'enable': enable, 'iOSBundleId': iOSBundleId, 'teamId': teamId};
  }
}

class AuthGoogleConfig {
  final bool enable;

  const AuthGoogleConfig({this.enable = false});

  factory AuthGoogleConfig.fromJson(Map json) {
    return AuthGoogleConfig(
      enable: bool.tryParse('${json['enable']}') ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'enable': enable};
}

class AuthFacebookConfig {
  final bool enable;
  final String appId;
  final String protocolScheme;
  final String clientToken;

  const AuthFacebookConfig({
    this.enable = false,
    this.appId = '',
    this.protocolScheme = '',
    this.clientToken = '',
  });

  factory AuthFacebookConfig.fromJson(Map json) {
    return AuthFacebookConfig(
      enable: bool.tryParse('${json['enable']}') ?? false,
      appId: json['appId'] ?? '',
      protocolScheme: json['protocolScheme'] ?? '',
      clientToken: json['clientToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': enable,
      'appId': appId,
      'protocolScheme': protocolScheme,
      'clientToken': clientToken,
    };
  }
}

class AuthSmsConfig {
  final bool enable;
  final bool useNewVersion;
  final AuthSmsDefaultCountry defaultCountry;
  final DigitsConfig digits;

  const AuthSmsConfig({
    this.enable = false,
    this.useNewVersion = true,
    this.defaultCountry = const AuthSmsDefaultCountry(),
    this.digits = const DigitsConfig(),
  });

  factory AuthSmsConfig.fromJson(Map json) {
    return AuthSmsConfig(
      enable: bool.tryParse('${json['enable']}') ?? false,
      useNewVersion: bool.tryParse('${json['useNewVersion']}') ?? true,
      defaultCountry: json['defaultCountry'] is Map
          ? AuthSmsDefaultCountry.fromJson(json['defaultCountry'])
          : const AuthSmsDefaultCountry(),
      digits: json['digits'] is Map
          ? DigitsConfig.fromJson(json['digits'])
          : const DigitsConfig(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': enable,
      'useNewVersion': useNewVersion,
      'defaultCountry': defaultCountry.toJson(),
      'digits': digits.toJson(),
    };
  }
}

class AuthSmsDefaultCountry {
  final String countryCode;
  final String dialCode;
  final String name;

  const AuthSmsDefaultCountry({
    this.countryCode = 'US',
    this.dialCode = '+1',
    this.name = 'United States',
  });

  factory AuthSmsDefaultCountry.fromJson(Map json) {
    return AuthSmsDefaultCountry(
      countryCode: (json['countryCode'] as String?)?.isNotEmpty == true
          ? json['countryCode']
          : 'US',
      dialCode: (json['dialCode'] as String?)?.isNotEmpty == true
          ? json['dialCode']
          : '+1',
      name: (json['name'] as String?)?.isNotEmpty == true
          ? json['name']
          : 'United States',
    );
  }

  Map<String, dynamic> toJson() {
    return {'countryCode': countryCode, 'dialCode': dialCode, 'name': name};
  }
}

class DigitsConfig {
  final bool enable;
  final DigitsVerifyMethod verifyMethod;

  const DigitsConfig({
    this.enable = false,
    this.verifyMethod = DigitsVerifyMethod.sms,
  });

  factory DigitsConfig.fromJson(Map json) {
    return DigitsConfig(
      enable: bool.tryParse('${json['enable']}') ?? false,
      verifyMethod: DigitsVerifyMethod.fromString(json['verifyMethod']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'enable': enable, 'verifyMethod': verifyMethod.name};
  }
}
