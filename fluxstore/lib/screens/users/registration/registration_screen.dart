import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:inspireui/widgets/auto_hide_keyboard.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/extensions/string_message_ext.dart';
import '../../../common/tools.dart';
import '../../../common/tools/flash.dart';
import '../../../models/index.dart'
    show AppModel, CartModel, PointModel, User, UserModel;
import '../../../modules/dynamic_layout/helper/helper.dart';
import '../../../modules/vendor_on_boarding/screen_index.dart';
import '../../../routes/flux_navigate.dart';
import '../../../services/service_config.dart';
import '../../../services/services.dart';
import '../../../widgets/auth/social_login_button_row.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../base_screen.dart';
import '../../home/privacy_term_screen.dart';
import '../login/mixins/mixin_animation_button_login.dart';
import '../mixins/base_auth_mixin.dart';
import '../mixins/social_login_mixin.dart';
import '../widgets/separated_or_widget.dart';
import 'mixins/config_register_mixin.dart';
import 'registration_screen_web.dart';

enum RegisterType { customer, vendor, delivery, owner }

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Layout.isDisplayDesktop(context)) {
      return const RegistrationScreenWeb();
    }
    return const RegistrationScreenMobile();
  }
}

class RegistrationScreenMobile extends StatefulWidget {
  const RegistrationScreenMobile();

  @override
  State<RegistrationScreenMobile> createState() =>
      _RegistrationScreenMobileState();
}

class _RegistrationScreenMobileState
    extends BaseScreen<RegistrationScreenMobile>
    with ConfigRegisterMixin, BaseAuthMixin, SocialLoginMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _emailController = TextEditingController();

  String? firstName, lastName, emailAddress, username, phoneNumber, password;
  RegisterType? _registerTypeSelected = RegisterType.customer;
  bool isChecked = true;

  bool isPlatformSupported = ![
    ConfigType.bigCommerce,
    ConfigType.notion,
    ConfigType.shopify,
    ConfigType.presta,
    ConfigType.opencart,
    ConfigType.magento,
  ].contains(ServerConfig().type);

  final firstNameNode = FocusNode();
  final lastNameNode = FocusNode();
  final phoneNumberNode = FocusNode();
  final emailNode = FocusNode();
  final passwordNode = FocusNode();
  final usernameNode = FocusNode();

  FocusNode _nextNodeAfter(FocusNode current) {
    final fields = [
      (showFirstNameWhenRegister, firstNameNode),
      (showLastNameWhenRegister, lastNameNode),
      (showPhoneNumberWhenRegister, phoneNumberNode),
      (showUsernameWhenRegister && isPlatformSupported, usernameNode),
      (showEmailWhenRegister, emailNode),
      (true, passwordNode),
    ];
    final index = fields.indexWhere((f) => f.$2 == current);
    for (var i = index + 1; i < fields.length; i++) {
      if (fields[i].$1) return fields[i].$2;
    }
    return passwordNode;
  }

  bool get _isSelectedVendorType =>
      _registerTypeSelected == RegisterType.vendor;
  bool get _isSelectedDeliveryType =>
      _registerTypeSelected == RegisterType.delivery;
  bool get _isSelectedOwnerType => _registerTypeSelected == RegisterType.owner;

  Future<bool> _showDialogUnderApproval() {
    return context.showFluxDialogText(
      title: S.of(context).accountApprovalTitle,
      body: S.of(context).accountIsPendingApproval,
      primaryAction: S.of(context).ok,
    );
  }

  void _welcomeDiaLog(User user) {
    Provider.of<CartModel>(context, listen: false).setUser(user);
    Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
    final model = Provider.of<UserModel>(context, listen: false);

    /// Show VendorOnBoarding.
    if (kVendorConfig.vendorRegister &&
        Provider.of<AppModel>(context, listen: false).isMultiVendor &&
        user.isVender) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => VendorOnBoarding(
            user: user,
            onFinish: () {
              model.getUser();
              var email = user.email;
              _showMessage('${S.of(ctx).welcome} $email!', isError: false);
              var routeFound = false;
              var routeNames = [RouteList.dashboard, RouteList.productDetail];
              Navigator.popUntil(ctx, (route) {
                if (routeNames.any(
                  (element) => route.settings.name?.contains(element) ?? false,
                )) {
                  routeFound = true;
                }
                return routeFound || route.isFirst;
              });

              if (!routeFound) {
                Navigator.of(ctx).pushReplacementNamed(RouteList.dashboard);
              }
            },
          ),
        ),
      );
      return;
    }

    var email = user.email;
    _showMessage('${S.of(context).welcome} $email!', isError: false);
    if (Services().widget.isRequiredLogin) {
      Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
      return;
    }
    var routeFound = false;
    var routeNames = [RouteList.dashboard, RouteList.productDetail];
    Navigator.popUntil(context, (route) {
      if (routeNames.any(
        (element) => route.settings.name?.contains(element) ?? false,
      )) {
        routeFound = true;
      }
      return routeFound || route.isFirst;
    });

    if (!routeFound) {
      Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
    }
  }

  Future<void> _onRegisterSuccess(User user) async {
    if (!user.isVender && _registerTypeSelected == RegisterType.vendor) {
      await _showDialogUnderApproval();
    }
    _welcomeDiaLog(user);
  }

  @override
  void dispose() {
    _emailController.dispose();
    firstNameNode.dispose();
    lastNameNode.dispose();
    emailNode.dispose();
    passwordNode.dispose();
    phoneNumberNode.dispose();
    usernameNode.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool isError = true}) {
    if (!mounted) {
      return;
    }
    FlashHelper.message(
      context,
      message: text.improveMessage(context),
      isError: isError,
    );
  }

  Future<void> _submitRegister({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? emailAddress,
    String? username,
    String? password,
    bool? isVendor,
    bool? isDelivery,
    bool? isOwner,
  }) async {
    // Check internet connection before attempting registration
    if (!await context.checkInternet()) {
      return;
    }
    bool isEmpty(String? value) => value?.trim().isEmpty ?? true;

    final hasEmptyRequiredField =
        (requireFirstNameWhenRegister && isEmpty(firstName)) ||
        (requireLastNameWhenRegister && isEmpty(lastName)) ||
        (requireUsernameWhenRegister &&
            isPlatformSupported &&
            isEmpty(username)) ||
        (requireEmailWhenRegister && isEmpty(emailAddress)) ||
        (requirePhoneNumberWhenRegister && isEmpty(phoneNumber)) ||
        isEmpty(password);

    if (hasEmptyRequiredField) {
      _showMessage(S.of(context).pleaseInputFillAllFields);
    } else if (isChecked == false) {
      _showMessage(S.of(context).pleaseAgreeTerms);
    } else {
      if (emailAddress != null &&
          emailAddress.isNotEmpty &&
          !emailAddress.validateEmail()) {
        _showMessage(S.of(context).errorEmailFormat);
        return;
      }

      if (password == null || password.length < 8) {
        _showMessage(S.of(context).errorPasswordFormat);
        return;
      }

      await Provider.of<UserModel>(context, listen: false).createUser(
        username: username,
        email: emailAddress,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        success: _onRegisterSuccess,
        fail: _showMessage,
        isVendor: isVendor,
        isDelivery: isDelivery,
        isOwner: isOwner,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appModel = Provider.of<AppModel>(context, listen: true);
    final themeConfig = appModel.themeConfig;
    final isShowRegisterOptions =
        isVendorRegister || isDeliveryRegister || isOwnerRegister;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: AutoHideKeyboard(
            child: Consumer<UserModel>(
              builder: (context, model, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 10,
                    ),
                    child: AutofillGroup(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 10.0),
                          Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.8,
                              child: FluxImage(
                                useExtendedImage: false,
                                imageUrl: themeConfig.logo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          if (showFirstNameWhenRegister)
                            CustomTextField(
                              key: const Key('registerFirstNameField'),
                              autofillHints: const [AutofillHints.givenName],
                              onChanged: (value) => firstName = value,
                              textCapitalization: TextCapitalization.words,
                              nextNode: _nextNodeAfter(firstNameNode),
                              showCancelIcon: true,
                              decoration: InputDecoration(
                                labelText: requireFirstNameWhenRegister
                                    ? S.of(context).firstName
                                    : '${S.of(context).firstName} (${S.of(context).optional})',
                                hintText: S.of(context).enterYourFirstName,
                              ),
                            ),
                          if (showFirstNameWhenRegister)
                            const SizedBox(height: 20.0),
                          if (showLastNameWhenRegister)
                            CustomTextField(
                              key: const Key('registerLastNameField'),
                              autofillHints: const [AutofillHints.familyName],
                              focusNode: lastNameNode,
                              nextNode: _nextNodeAfter(lastNameNode),
                              showCancelIcon: true,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) => lastName = value,
                              decoration: InputDecoration(
                                labelText: requireLastNameWhenRegister
                                    ? S.of(context).lastName
                                    : '${S.of(context).lastName} (${S.of(context).optional})',
                                hintText: S.of(context).enterYourLastName,
                              ),
                            ),
                          if (showPhoneNumberWhenRegister) ...[
                            const SizedBox(height: 20.0),
                            CustomTextField(
                              key: const Key('registerPhoneField'),
                              focusNode: phoneNumberNode,
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                              nextNode: _nextNodeAfter(phoneNumberNode),
                              showCancelIcon: true,
                              onChanged: (value) => phoneNumber = value,
                              decoration: InputDecoration(
                                labelText: requirePhoneNumberWhenRegister
                                    ? S.of(context).phone
                                    : '${S.of(context).phone} (${S.of(context).optional})',
                                hintText: S.of(context).enterYourPhoneNumber,
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                          if (showUsernameWhenRegister &&
                              isPlatformSupported) ...[
                            const SizedBox(height: 20.0),
                            CustomTextField(
                              key: const Key('registerUsernameField'),
                              focusNode: usernameNode,
                              autofillHints: const [AutofillHints.username],
                              nextNode: _nextNodeAfter(usernameNode),
                              onChanged: (value) => username = value,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: requireUsernameWhenRegister
                                    ? S.of(context).username
                                    : '${S.of(context).username} (${S.of(context).optional})',
                                hintText: S.of(context).enterYourUsername,
                              ),
                            ),
                          ],
                          if (showEmailWhenRegister) ...[
                            const SizedBox(height: 20.0),
                            CustomTextField(
                              key: const Key('registerEmailField'),
                              focusNode: emailNode,
                              autofillHints: const [AutofillHints.email],
                              nextNode: passwordNode,
                              controller: _emailController,
                              onChanged: (value) => emailAddress = value,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: requireEmailWhenRegister
                                    ? S.of(context).email
                                    : '${S.of(context).email} (${S.of(context).optional})',
                                hintText: S.of(context).enterYourEmail,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20.0),
                          CustomTextField(
                            key: const Key('registerPasswordField'),
                            focusNode: passwordNode,
                            autofillHints: const [AutofillHints.password],
                            showEyeIcon: true,
                            obscureText: true,
                            onChanged: (value) => password = value,
                            decoration: InputDecoration(
                              labelText: S.of(context).password,
                              hintText: S.of(context).enterYourPassword,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          if (isShowRegisterOptions)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: RadioGroup<RegisterType>(
                                groupValue: _registerTypeSelected,
                                onChanged: (RegisterType? value) {
                                  setState(() {
                                    _registerTypeSelected = value;
                                  });
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${S.of(context).registerAs}:',
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    _buildRegisterType(
                                      RegisterType.customer,
                                      S.of(context).customer,
                                    ),
                                    if (isVendorRegister)
                                      _buildRegisterType(
                                        RegisterType.vendor,
                                        S.of(context).vendor,
                                      ),
                                    if (isOwnerRegister)
                                      _buildRegisterType(
                                        RegisterType.owner,
                                        S.of(context).owner,
                                      ),
                                    if (isDeliveryRegister)
                                      _buildRegisterType(
                                        RegisterType.delivery,
                                        S.of(context).deliveryBoy,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          Text.rich(
                            TextSpan(
                              text: S.of(context).bySignup,
                              style: theme.textTheme.bodyLarge,
                              children: [
                                const WidgetSpan(child: SizedBox(width: 4)),
                                TextSpan(
                                  text: S.of(context).agreeWithPrivacy,
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => FluxNavigate.push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PrivacyTermScreen(
                                              showAgreeButton: false,
                                            ),
                                      ),
                                      forceRootNavigator: true,
                                      context: context,
                                    ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24.0),
                          Material(
                            color: theme.primaryColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            elevation: 0,
                            child: MaterialButton(
                              key: const Key('registerSubmitButton'),
                              onPressed: model.loading == true
                                  ? null
                                  : () async {
                                      await _submitRegister(
                                        firstName: firstName,
                                        lastName: lastName,
                                        phoneNumber: phoneNumber,
                                        username: username,
                                        emailAddress: emailAddress,
                                        password: password,
                                        isVendor: _isSelectedVendorType,
                                        isDelivery: _isSelectedDeliveryType,
                                        isOwner: _isSelectedOwnerType,
                                      );
                                    },
                              minWidth: 200.0,
                              elevation: 0.0,
                              height: 42.0,
                              child: Text(
                                model.loading == true
                                    ? S.of(context).loading
                                    : S.of(context).createAnAccount,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (kAuthConfig.showSocialInRegistration &&
                              kAuthConfig.isAnySocialLoginEnabled &&
                              ServerConfig().isSocialLoginSupported) ...[
                            const SeparatedOrWidget(),
                            Center(
                              child: SocialLoginButtonRow(
                                onApplePressed: () => loginWithApple(context),
                                onFacebookPressed: () =>
                                    loginWithFacebook(context),
                                onGooglePressed: () => loginWithGoogle(context),
                                onSmsPressed: () => loginWithSMS(context),
                              ),
                            ),
                          ],
                          Column(
                            children: <Widget>[
                              const SizedBox(height: 30.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 4,
                                children: <Widget>[
                                  Text(S.of(context).alreadyHaveAnAccount),
                                  GestureDetector(
                                    onTap: () {
                                      final canPop = ModalRoute.of(
                                        context,
                                      )!.canPop;
                                      if (canPop) {
                                        Navigator.pop(context);
                                      } else {
                                        NavigateTools.navigateToLogin(
                                          context,
                                          replacement: true,
                                        );
                                      }
                                    },
                                    child: Text(
                                      S.of(context).login,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterType(RegisterType registerType, String label) {
    var description = '';
    switch (registerType) {
      case RegisterType.customer:
        description = ServerConfig().isListeoType
            ? S.of(context).customerRoleDescription
            : '';
        break;
      case RegisterType.owner:
        description = S.of(context).ownerRoleDescription;
        break;
      default:
        description = '';
    }

    return Row(
      children: [
        Radio<RegisterType>(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: registerType,
        ),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        if (description.isNotEmpty)
          InkWell(
            onTap: () => context.showFluxDialogText(
              title: label,
              body: description,
              primaryAction: S.of(context).ok,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Future<void> beforeCallLogin([
    AnimationButtonLoginType type = AnimationButtonLoginType.usernamePassword,
  ]) {
    return Future.value();
  }

  @override
  Future<void> afterCallLogin(
    bool isLoginSuccess, [
    AnimationButtonLoginType type = AnimationButtonLoginType.usernamePassword,
  ]) {
    return Future.value();
  }
}
