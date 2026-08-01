import '../../../../services/service_config.dart';
import 'auth_enums.dart';
import 'auth_providers_config.dart';
import 'auth_registration_config.dart';

export 'auth_enums.dart';
export 'auth_providers_config.dart';
export 'auth_registration_config.dart';

/// Unified authentication configuration.
/// Replaces the scattered loginSetting, loginSMSConstants, and auth-related
/// fields in advanceConfig.
class AuthConfig {
  final bool _enable;
  final bool isRequired;
  final bool enableRegister;
  final bool isResetPasswordSupported;
  final AuthMethod defaultMethod;
  final AuthRegistrationConfig registration;
  final AuthProvidersConfig providers;
  final bool showSocialInRegistration;
  final bool showContinueAsGuestInLogin;

  /// Login cannot be disabled on platforms requiring authentication.
  bool get enable => ServerConfig().isSupportHideAuthenticate ? _enable : true;

  bool get isAnySocialLoginEnabled =>
      providers.facebook.enable ||
      providers.sms.enable ||
      providers.google.enable ||
      providers.apple.enable;

  // ── Computed getters for backward compatibility ──

  bool get smsLoginAsDefault => defaultMethod == AuthMethod.sms;

  bool get enableDigitsMobileLogin => providers.sms.digits.enable;

  bool get enableNewSMSLogin => providers.sms.useNewVersion;

  bool get enableDigitsMobileFirebase =>
      providers.sms.digits.enable &&
      providers.sms.digits.verifyMethod == DigitsVerifyMethod.firebase;

  bool get enableDigitsMobileWhatsApp =>
      providers.sms.digits.enable &&
      providers.sms.digits.verifyMethod == DigitsVerifyMethod.whatsapp;

  const AuthConfig({
    bool enable = true,
    this.isRequired = false,
    this.enableRegister = true,
    this.isResetPasswordSupported = false,
    this.defaultMethod = AuthMethod.emailPassword,
    this.registration = const AuthRegistrationConfig(),
    this.providers = const AuthProvidersConfig(),
    this.showSocialInRegistration = false,
    this.showContinueAsGuestInLogin = false,
  }) : _enable = enable;

  factory AuthConfig.fromJson(Map json) {
    return AuthConfig(
      enable: bool.tryParse('${json['enable']}') ?? true,
      isRequired: bool.tryParse('${json['isRequired']}') ?? false,
      enableRegister: bool.tryParse('${json['enableRegister']}') ?? true,
      isResetPasswordSupported:
          bool.tryParse('${json['isResetPasswordSupported']}') ?? false,
      defaultMethod: AuthMethod.fromString(json['defaultMethod']),
      registration: json['registration'] is Map
          ? AuthRegistrationConfig.fromJson(json['registration'])
          : const AuthRegistrationConfig(),
      providers: json['providers'] is Map
          ? AuthProvidersConfig.fromJson(json['providers'])
          : const AuthProvidersConfig(),
      showSocialInRegistration:
          bool.tryParse('${json['showSocialInRegistration']}') ?? false,
      showContinueAsGuestInLogin:
          bool.tryParse('${json['showContinueAsGuestInLogin']}') ?? false,
    );
  }

  /// Build AuthConfig from legacy scattered configs for backward compatibility.
  factory AuthConfig.fromLegacy({
    required Map loginSetting,
    required Map loginSMSConstants,
    required Map advanceConfig,
  }) {
    // Determine defaultMethod from legacy booleans
    AuthMethod defaultMethod;
    if (bool.tryParse('${advanceConfig['EnableDigitsMobileLogin']}') ?? false) {
      defaultMethod = AuthMethod.digits;
    } else if (bool.tryParse('${loginSetting['smsLoginAsDefault']}') ?? false) {
      defaultMethod = AuthMethod.sms;
    } else {
      defaultMethod = AuthMethod.emailPassword;
    }

    // Determine digits verifyMethod from legacy booleans
    DigitsVerifyMethod digitsVerifyMethod;
    if (bool.tryParse('${advanceConfig['EnableDigitsMobileWhatsApp']}') ??
        false) {
      digitsVerifyMethod = DigitsVerifyMethod.whatsapp;
    } else if (bool.tryParse(
          '${advanceConfig['EnableDigitsMobileFirebase']}',
        ) ??
        false) {
      digitsVerifyMethod = DigitsVerifyMethod.firebase;
    } else {
      digitsVerifyMethod = DigitsVerifyMethod.sms;
    }

    return AuthConfig(
      enable: bool.tryParse('${loginSetting['enable']}') ?? true,
      isRequired: bool.tryParse('${loginSetting['IsRequiredLogin']}') ?? false,
      enableRegister:
          bool.tryParse('${loginSetting['enableRegister']}') ?? true,
      isResetPasswordSupported:
          bool.tryParse('${loginSetting['isResetPasswordSupported']}') ?? false,
      defaultMethod: defaultMethod,
      registration: AuthRegistrationConfig(
        email: AuthRegistrationFieldConfig(
          show:
              bool.tryParse('${loginSetting['showEmailWhenRegister']}') ?? true,
          require:
              bool.tryParse('${loginSetting['requireEmailWhenRegister']}') ??
              true,
        ),
        firstName: AuthRegistrationFieldConfig(
          show:
              bool.tryParse('${loginSetting['showFirstNameWhenRegister']}') ??
              true,
          require:
              bool.tryParse(
                '${loginSetting['requireFirstNameWhenRegister']}',
              ) ??
              true,
        ),
        lastName: AuthRegistrationFieldConfig(
          show:
              bool.tryParse('${loginSetting['showLastNameWhenRegister']}') ??
              true,
          require:
              bool.tryParse('${loginSetting['requireLastNameWhenRegister']}') ??
              true,
        ),
        phone: AuthRegistrationFieldConfig(
          show:
              bool.tryParse('${loginSetting['showPhoneNumberWhenRegister']}') ??
              false,
          require:
              bool.tryParse(
                '${loginSetting['requirePhoneNumberWhenRegister']}',
              ) ??
              false,
        ),
        username: AuthRegistrationFieldConfig(
          show:
              bool.tryParse('${loginSetting['showUsernameWhenRegister']}') ??
              true,
          require:
              bool.tryParse('${loginSetting['requireUsernameWhenRegister']}') ??
              false,
        ),
      ),
      providers: AuthProvidersConfig(
        apple: AuthAppleConfig(
          enable: bool.tryParse('${loginSetting['showAppleLogin']}') ?? false,
          iOSBundleId:
              loginSetting['appleLoginSetting']?['iOSBundleId'] as String?,
          teamId:
              loginSetting['appleLoginSetting']?['appleAccountTeamID']
                  as String?,
        ),
        google: AuthGoogleConfig(
          enable: bool.tryParse('${loginSetting['showGoogleLogin']}') ?? false,
        ),
        facebook: AuthFacebookConfig(
          enable: bool.tryParse('${loginSetting['showFacebook']}') ?? false,
          appId: loginSetting['facebookAppId'] ?? '',
          protocolScheme: loginSetting['facebookLoginProtocolScheme'] ?? '',
          clientToken: loginSetting['facebookClientToken'] ?? '',
        ),
        sms: AuthSmsConfig(
          enable: bool.tryParse('${loginSetting['showSMSLogin']}') ?? false,
          useNewVersion:
              bool.tryParse('${advanceConfig['EnableNewSMSLogin']}') ?? true,
          defaultCountry: AuthSmsDefaultCountry(
            countryCode: loginSMSConstants['countryCodeDefault'] ?? '',
            dialCode: loginSMSConstants['dialCodeDefault'] ?? '',
            name: loginSMSConstants['nameDefault'] ?? '',
          ),
          digits: DigitsConfig(
            enable:
                bool.tryParse('${advanceConfig['EnableDigitsMobileLogin']}') ??
                false,
            verifyMethod: digitsVerifyMethod,
          ),
        ),
      ),
      showSocialInRegistration:
          bool.tryParse('${loginSetting['showSocialInRegistration']}') ?? false,
      showContinueAsGuestInLogin:
          bool.tryParse('${loginSetting['showContinueAsGuestInLogin']}') ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': _enable,
      'isRequired': isRequired,
      'enableRegister': enableRegister,
      'isResetPasswordSupported': isResetPasswordSupported,
      'defaultMethod': defaultMethod.name,
      'registration': registration.toJson(),
      'providers': providers.toJson(),
      'showSocialInRegistration': showSocialInRegistration,
      'showContinueAsGuestInLogin': showContinueAsGuestInLogin,
    };
  }
}
