import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../common/tools/biometrics_tools.dart';
import '../../../data/boxes.dart';
import '../../../models/index.dart';
import '../../../modules/dynamic_layout/helper/helper.dart';
import '../../../services/index.dart';
import '../../../widgets/auth/social_login_button_row.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/login_animation.dart';
import '../../base_screen.dart';
import '../mixins/base_auth_mixin.dart';
import '../mixins/social_login_mixin.dart';
import '../widgets/separated_or_widget.dart';
import 'login_screen_web.dart';
import 'mixins/login_mixin.dart';
import 'mixins/mixin_animation_button_login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.showGuestButton});

  final bool showGuestButton;

  @override
  Widget build(BuildContext context) {
    if (Layout.isDisplayDesktop(context)) {
      return LoginScreenWeb(showGuestButton: showGuestButton);
    }
    return LoginScreenMobile(showGuestButton: showGuestButton);
  }
}

class LoginScreenMobile extends StatefulWidget {
  const LoginScreenMobile({super.key, required this.showGuestButton});

  final bool showGuestButton;

  @override
  BaseScreen<LoginScreenMobile> createState() => _LoginPageState();
}

class _LoginPageState extends BaseScreen<LoginScreenMobile>
    with
        TickerProviderStateMixin,
        AnimationButtonLoginMixin,
        BaseAuthMixin,
        LoginMixin,
        SocialLoginMixin {
  late BuildContext _parentContext;

  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  Future _biometricsLogin(BuildContext context) async {
    var didAuth = await BiometricsTools.instance.localAuth(context);
    if (didAuth) {
      usernameCtrl.text = BiometricsBox().username ?? '';
      passwordCtrl.text = BiometricsBox().password ?? '';
      _onTapLogin();
    }
  }

  void _onTapLogin() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    runLogin(context);
  }

  void _onClosed() {
    Navigator.of(
      App.fluxStoreNavigatorKey.currentContext!,
    ).pushReplacementNamed(RouteList.dashboard);
  }

  @override
  TextEditingController passwordCtrl = TextEditingController();

  @override
  TextEditingController usernameCtrl = TextEditingController();

  @override
  Future<void> beforeCallLogin([
    AnimationButtonLoginType type = AnimationButtonLoginType.usernamePassword,
  ]) => playAnimation(type);

  @override
  Future<void> afterCallLogin(
    bool isLoginSuccess, [
    AnimationButtonLoginType type = AnimationButtonLoginType.usernamePassword,
  ]) => stopAnimation(type);

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _parentContext = context;
    final appModel = Provider.of<AppModel>(context);
    final screenSize = MediaQuery.sizeOf(context);

    final themeConfig = appModel.themeConfig;
    final forgetPasswordUrl =
        appModel.appConfig?.forgetPassword ?? ServerConfig().forgetPassword;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.0,
        actions:
            !Services().widget.isRequiredLogin &&
                !ModalRoute.of(context)!.canPop
            ? [
                IconButton(
                  onPressed: _onClosed,
                  icon: const Icon(Icons.close, size: 25),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: AutoHideKeyboard(
          child: IgnorePointer(
            ignoring: isLoading,
            child: Center(
              child: Consumer<UserModel>(
                builder: (context, model, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    alignment: Alignment.center,
                    width:
                        screenSize.width /
                        (2 / (screenSize.height / screenSize.width)),
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: AutofillGroup(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: FractionallySizedBox(
                              widthFactor: 0.8,
                              child: FluxImage(
                                imageUrl: themeConfig.logo,
                                fit: BoxFit.contain,
                                useExtendedImage: false,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 20.0),
                                  CustomTextField(
                                    key: const Key('loginEmailField'),
                                    controller: usernameCtrl,
                                    autofillHints: const [AutofillHints.email],
                                    showCancelIcon: true,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.emailAddress,
                                    nextNode: _usernameFocusNode,
                                    decoration: InputDecoration(
                                      labelText: S.of(_parentContext).username,
                                      hintText: S
                                          .of(_parentContext)
                                          .enterYourEmailOrUsername,
                                    ),
                                  ),
                                  CustomTextField(
                                    key: const Key('loginPasswordField'),
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    obscureText: true,
                                    showEyeIcon: true,
                                    textInputAction: TextInputAction.done,
                                    controller: passwordCtrl,
                                    focusNode: _passwordFocusNode,
                                    decoration: InputDecoration(
                                      labelText: S.of(_parentContext).password,
                                      hintText: S
                                          .of(_parentContext)
                                          .enterYourPassword,
                                    ),
                                  ),
                                  if (kAuthConfig.isResetPasswordSupported)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          launchForgetPasswordURL(
                                            forgetPasswordUrl,
                                          );
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            S.of(context).resetPassword,
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!kAuthConfig.isResetPasswordSupported)
                                    const SizedBox(height: 50.0),
                                  StaggerAnimation(
                                    key: const Key('loginSubmitButton'),
                                    titleButton: S.of(context).signIn,
                                    buttonController:
                                        loginButtonController.view
                                            as AnimationController,
                                    onTap: () =>
                                        isLoading ? null : _onTapLogin(),
                                  ),
                                  if (BiometricsTools.instance.isLoginSupported)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: IconButton(
                                        iconSize: 50,
                                        onPressed: () =>
                                            _biometricsLogin(context),
                                        icon: const Icon(
                                          Icons.fingerprint_outlined,
                                        ),
                                      ),
                                    ),
                                  if (shopifyCustomerAccountConfig.enabled) ...[
                                    const SeparatedOrWidget(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: StaggerAnimation(
                                        titleButton: S
                                            .of(context)
                                            .signInWithEmail,
                                        buttonController:
                                            loginEmailButtonController.view
                                                as AnimationController,
                                        onTap: () => isLoading
                                            ? null
                                            : loginWithCustomerAccountShopify(
                                                context,
                                              ),
                                      ),
                                    ),
                                  ],
                                  if (kAuthConfig.isAnySocialLoginEnabled &&
                                      ServerConfig()
                                          .isSocialLoginSupported) ...[
                                    const SeparatedOrWidget(),
                                    SocialLoginButtonRow(
                                      onApplePressed: () =>
                                          loginWithApple(context),
                                      onFacebookPressed: () =>
                                          loginWithFacebook(context),
                                      onGooglePressed: () =>
                                          loginWithGoogle(context),
                                      onSmsPressed: () => loginWithSMS(context),
                                    ),
                                  ],
                                  if (kAuthConfig.enableRegister)
                                    Column(
                                      children: <Widget>[
                                        const SizedBox(height: 30.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          spacing: 4,
                                          children: <Widget>[
                                            Text(S.of(context).dontHaveAccount),
                                            GestureDetector(
                                              onTap: () {
                                                NavigateTools.navigateRegister(
                                                  context,
                                                );
                                              },
                                              child: Text(
                                                S.of(context).signup,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  if (kAuthConfig.showContinueAsGuestInLogin &&
                                      widget.showGuestButton) ...[
                                    const SeparatedOrWidget(),
                                    GestureDetector(
                                      onTap: () {
                                        var routeFound = false;
                                        var routeNames = [
                                          RouteList.dashboard,
                                          RouteList.productDetail,
                                        ];
                                        Navigator.popUntil(context, (route) {
                                          if (routeNames.any(
                                            (element) =>
                                                route.settings.name?.contains(
                                                  element,
                                                ) ??
                                                false,
                                          )) {
                                            routeFound = true;
                                          }
                                          return routeFound || route.isFirst;
                                        });

                                        if (!routeFound) {
                                          Navigator.of(
                                            context,
                                          ).pushReplacementNamed(
                                            RouteList.dashboard,
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 320,
                                        height: 50,
                                        alignment: FractionalOffset.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(25.0),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          S.of(context).continueAsGuest,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 0.3,
                                          ),
                                          softWrap: true,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
