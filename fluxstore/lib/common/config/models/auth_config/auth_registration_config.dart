class AuthRegistrationConfig {
  final AuthRegistrationFieldConfig email;
  final AuthRegistrationFieldConfig firstName;
  final AuthRegistrationFieldConfig lastName;
  final AuthRegistrationFieldConfig phone;
  final AuthRegistrationFieldConfig username;

  const AuthRegistrationConfig({
    this.email = const AuthRegistrationFieldConfig(show: true, require: true),
    this.firstName = const AuthRegistrationFieldConfig(
      show: true,
      require: true,
    ),
    this.lastName = const AuthRegistrationFieldConfig(
      show: true,
      require: true,
    ),
    this.phone = const AuthRegistrationFieldConfig(),
    this.username = const AuthRegistrationFieldConfig(show: true),
  });

  /// If neither email nor username is shown, force email to be visible.
  bool get showEmail {
    if (email.show) return true;
    if (!email.show && !username.show) return true;
    return false;
  }

  bool get showUsername => username.show;

  /// Backward-compatible getters.
  bool get showPhoneNumber => phone.show;
  bool get requirePhoneNumber => phone.require;
  bool get requireUsername => username.require;

  /// If email is force-shown because both email and username are hidden,
  /// it must also be required.
  bool get requireEmail {
    if (!email.show && !username.show) return true;
    return email.require;
  }

  factory AuthRegistrationConfig.fromJson(Map json) {
    return AuthRegistrationConfig(
      email: json['email'] is Map
          ? AuthRegistrationFieldConfig.fromJson(json['email'])
          : const AuthRegistrationFieldConfig(show: true, require: true),
      firstName: json['firstName'] is Map
          ? AuthRegistrationFieldConfig.fromJson(json['firstName'])
          : const AuthRegistrationFieldConfig(show: true, require: true),
      lastName: json['lastName'] is Map
          ? AuthRegistrationFieldConfig.fromJson(json['lastName'])
          : const AuthRegistrationFieldConfig(show: true, require: true),
      phone: json['phone'] is Map
          ? AuthRegistrationFieldConfig.fromJson(json['phone'])
          : const AuthRegistrationFieldConfig(),
      username: json['username'] is Map
          ? AuthRegistrationFieldConfig.fromJson(json['username'])
          : const AuthRegistrationFieldConfig(show: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email.toJson(),
      'firstName': firstName.toJson(),
      'lastName': lastName.toJson(),
      'phone': phone.toJson(),
      'username': username.toJson(),
    };
  }
}

class AuthRegistrationFieldConfig {
  final bool show;
  final bool _require;

  /// If [show] is false, [require] is always false regardless of config.
  bool get require => show && _require;

  const AuthRegistrationFieldConfig({this.show = false, bool require = false})
    : _require = require;

  factory AuthRegistrationFieldConfig.fromJson(Map json) {
    return AuthRegistrationFieldConfig(
      show: bool.tryParse('${json['show']}') ?? false,
      require: bool.tryParse('${json['require']}') ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'show': show, 'require': require};
  }
}
