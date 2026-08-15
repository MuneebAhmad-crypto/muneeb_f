import 'package:flatten/controllers/my_controller.dart';
import 'package:flatten/helpers/services/auth_service.dart';
import 'package:flatten/helpers/widgets/my_form_validator.dart';
import 'package:flatten/helpers/widgets/my_validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword = false, loading = false;

  final String _dummyEmail = "flatten@flutx.com";
  final String _dummyPassword = "1234567";

  @override
  void onInit() {
    super.onInit();
    basicValidator.addField('email',
        required: true,
        label: "Email",
        validators: [MyEmailValidator()],
        controller: TextEditingController(text: _dummyEmail));

    basicValidator.addField('password',
        required: true,
        label: "Password",
        validators: [MyLengthValidator(min: 6, max: 10)],
        controller: TextEditingController(text: _dummyPassword));
  }

  // UI
  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  // Services
  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await AuthService.loginUser(basicValidator.getData());
      if (errors != null) {
        basicValidator.addErrors(errors);
        basicValidator.validateForm();
        basicValidator.clearErrors();
      } else {
        String nextUrl =
            Uri.parse(ModalRoute.of(Get.context!)?.settings.name ?? "")
                    .queryParameters['next'] ??
                "/dashboard";
        Get.toNamed(
          nextUrl,
        );
      }
      loading = false;
      update();
    }
  }

  // Navigation
  void goToForgotPassword() {
    Get.toNamed('/auth/forgot_password');
  }

  void gotoRegister() {
    Get.toNamed('/auth/register');
  }
}
