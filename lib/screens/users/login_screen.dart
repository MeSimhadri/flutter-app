import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../../models/index.dart';
import '../../models/user_model.dart';
import '../../modules/sms_login/sms_login.dart';
import '../../services/audio/audio_service.dart';
import '../../services/index.dart';
import '../../services/service_config.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/flux_image.dart';
import '../../widgets/common/login_animation.dart';
import '../../widgets/common/webview.dart';
import '../base_screen.dart';
import 'forgot_password_screen.dart';

typedef LoginSocialFunction = Future<void> Function({
  required Function(User user) success,
  required Function(String) fail,
  BuildContext context,
});

typedef LoginFunction = Future<void> Function({
  required String username,
  required String password,
  required Function(User user) success,
  required Function(String) fail,
});

class LoginScreen extends StatefulWidget {
  final LoginFunction login;
  final LoginSocialFunction loginFB;
  final LoginSocialFunction loginApple;
  final LoginSocialFunction loginGoogle;
  final VoidCallback? loginSms;

  const LoginScreen({
    required this.login,
    required this.loginFB,
    required this.loginApple,
    required this.loginGoogle,
    this.loginSms,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends BaseScreen<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _loginButtonController;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  final usernameNode = FocusNode();
  final passwordNode = FocusNode();

  late var parentContext;
  bool isLoading = false;
  bool isAvailableApple = false;
  bool isActiveAudio = false;

  AudioService get audioPlayerService => injector<AudioService>();

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    if (audioPlayerService.isStickyAudioWidgetActive) {
      isActiveAudio = true;
      audioPlayerService
        ..pause()
        ..updateStateStickyAudioWidget(false);
    }
    try {
      isAvailableApple =
          (await TheAppleSignIn.isAvailable()) || Config().isBuilder;
      setState(() {});
    } catch (e) {
      printLog('[Login] afterFirstLayout error');
    }
  }

  @override
  void dispose() async {
    _loginButtonController.dispose();
    username.dispose();
    password.dispose();
    usernameNode.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  Future _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {
      printLog('[_playAnimation] error');
    }
  }

  Future _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      printLog('[_stopAnimation] error');
    }
  }

  Future _welcomeMessage(user) async {
    final canPop = ModalRoute.of(context)!.canPop;
    if (canPop) {
      // When not required login
      Navigator.of(context).pop();
    } else {
      // When required login
      await Navigator.of(App.fluxStoreNavigatorKey.currentContext!)
          .pushReplacementNamed(RouteList.dashboard);
    }
  }

  void _failMessage(String message) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    if (message.isEmpty) return;

    var _message = message;
    if (kReleaseMode) {
      _message = S.of(context).UserNameInCorrect;
    }

    final snackBar = SnackBar(
      content: Text(S.of(context).warning(_message)),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _loginFacebook(context) async {
    //showLoading();
    await _playAnimation();
    await widget.loginFB(
      success: (user) {
        //hideLoading();
        _stopAnimation();
        _welcomeMessage(user);
      },
      fail: (message) {
        //hideLoading();
        _stopAnimation();
        _failMessage(message);
      },
      context: context,
    );
  }

  void _loginApple(context) async {
    await _playAnimation();
    await widget.loginApple(
        success: (user) {
          _stopAnimation();
          _welcomeMessage(user);
        },
        fail: (message) {
          _stopAnimation();
          _failMessage(message);
        },
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    final appModel = Provider.of<AppModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final themeConfig = appModel.themeConfig;

    var forgetPasswordUrl = Config().forgetPassword;

    Future launchForgetPassworddWebView(String url) async {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              WebView(url: url, title: S.of(context).resetPassword),
          fullscreenDialog: true,
        ),
      );
    }

    void launchForgetPasswordURL(String? url) async {
      if (url != null && url != '') {
        /// show as webview
        await launchForgetPassworddWebView(url);
      } else {
        /// show as native
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
        );
      }
    }

    void _login(context) async {
      if (username.text.isEmpty || password.text.isEmpty) {
        Tools.showSnackBar(Scaffold.of(context), S.of(context).pleaseInput);
      } else {
        await _playAnimation();
        await widget.login(
          username: username.text.trim(),
          password: password.text.trim(),
          success: (user) {
            _stopAnimation();
            _welcomeMessage(user);
          },
          fail: (message) {
            _stopAnimation();
            _failMessage(message);
          },
        );
      }
    }

    void _loginSMS(context) {
      if (widget.loginSms != null) {
        widget.loginSms!();
        return;
      }
      final supportedPlatforms = [
        'wcfm',
        'dokan',
        'delivery',
        'vendorAdmin',
        'woo',
        'wordpress'
      ].contains(serverConfig['type']);
      if (supportedPlatforms &&
          (kAdvanceConfig['EnableNewSMSLogin'] ?? false)) {
        final model = Provider.of<UserModel>(context, listen: false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SMSLoginScreen(
              onSuccess: (user) async {
                await model.saveSMSUser(user);
                Navigator.of(context).pop();
                await _welcomeMessage(user);
              },
            ),
          ),
        );
        return;
      }

      Navigator.of(context).pushNamed(RouteList.loginSMS);
    }

    void _loginGoogle(context) async {
      await _playAnimation();
      await widget.loginGoogle(
          success: (user) {
            //hideLoading();
            _stopAnimation();
            _welcomeMessage(user);
          },
          fail: (message) {
            //hideLoading();
            _stopAnimation();
            _failMessage(message);
          },
          context: context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: AutoHideKeyboard(
          child: Center(
            child: Stack(
              children: [
                Consumer<UserModel>(builder: (context, model, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Container(
                      alignment: Alignment.center,
                      width: screenSize.width /
                          (2 / (screenSize.height / screenSize.width)),
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: AutofillGroup(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                            // const SizedBox(height: 40.0),
                            const SizedBox(
                              // height: 80.0,
                              child: FluxImage(
                                imageUrl: 'assets/images/logo.png',
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0XFF1A83C8)
                                        .withOpacity(0.2),
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                                shadowColor: Colors.blue[800],
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(height: 20.0),
                                    const Text(
                                      'Sign in',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0XFF1A83C8)),
                                    ),
                                    const SizedBox(height: 20.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.black))),
                                        child: CustomTextField(
                                          key: const Key('loginEmailField'),
                                          controller: username,
                                          autofillHints: const [
                                            AutofillHints.email
                                          ],
                                          showCancelIcon: true,
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          textInputAction: TextInputAction.next,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          nextNode: passwordNode,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            labelStyle: const TextStyle(
                                                color: Colors.black),
                                            labelText:
                                                S.of(parentContext).username,
                                            hintText: S
                                                .of(parentContext)
                                                .enterYourEmailOrUsername,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.black))),
                                      child: CustomTextField(
                                        key: const Key('loginPasswordField'),
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
                                        obscureText: true,
                                        showEyeIcon: true,
                                        textInputAction: TextInputAction.done,
                                        controller: password,
                                        focusNode: passwordNode,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          labelStyle: const TextStyle(
                                              color: Colors.black),
                                          labelText:
                                              S.of(parentContext).password,
                                          hintText: S
                                              .of(parentContext)
                                              .enterYourPassword,
                                        ),
                                      ),
                                    ),
                                    if ((kLoginSetting[
                                            'isResetPasswordSupported'] ??
                                        false))
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              launchForgetPasswordURL(
                                                  forgetPasswordUrl);
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: const Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: Text(
                                                'Forgot Password?',
                                                style: TextStyle(
                                                  color: maintabBlue,
                                                  // decoration:
                                                  //     TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (kLoginSetting[
                                            'isResetPasswordSupported'] !=
                                        true)
                                      const SizedBox(height: 50.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      child: StaggerAnimation(
                                        key: const Key('loginSubmitButton'),
                                        titleButton: 'Sign in',
                                        buttonController: _loginButtonController
                                            .view as AnimationController,
                                        onTap: () {
                                          if (!isLoading) {
                                            _login(context);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text('or sign in with'),
                                    const SizedBox(height: 10),
                                    // Stack(
                                    //   alignment: AlignmentDirectional.center,
                                    //   children: <Widget>[
                                    //     // SizedBox(
                                    //     //     height: 50.0,
                                    //     //     width: 200.0,
                                    //     //     child:
                                    //     //         Divider(color: Colors.grey.shade300)),
                                    //     Container(
                                    //         height: 30,
                                    //         width: 40,
                                    //         color: Theme.of(context).backgroundColor),
                                    //     if (kLoginSetting['showFacebook'] ||
                                    //         kLoginSetting['showSMSLogin'] ||
                                    //         kLoginSetting['showGoogleLogin'] ||
                                    //         kLoginSetting['showAppleLogin'])
                                    //       Text(
                                    //         S.of(context).or,
                                    //         style: TextStyle(
                                    //             fontSize: 12,
                                    //             color: Colors.grey.shade400),
                                    //       )
                                    //   ],
                                    // ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        if (kLoginSetting['showAppleLogin'] &&
                                            isAvailableApple)
                                          InkWell(
                                            onTap: () => _loginApple(context),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: Colors.black87,
                                              ),
                                              child: Image.asset(
                                                'assets/icons/logins/apple.png',
                                                width: 26,
                                                height: 26,
                                              ),
                                            ),
                                          ),
                                        if (kLoginSetting['showFacebook'])
                                          InkWell(
                                            onTap: () =>
                                                _loginFacebook(context),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: const Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Icon(
                                                  Icons.facebook,
                                                  color: Color(0xFF1778F2),
                                                  size: 50.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (kLoginSetting['showGoogleLogin'])
                                          InkWell(
                                            onTap: () => _loginGoogle(context),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  'assets/icons/logins/google.png',
                                                  width: 35,
                                                  height: 35,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (kLoginSetting['showSMSLogin'])
                                          InkWell(
                                            onTap: () => _loginSMS(context),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  'assets/icons/logins/sms.png',
                                                  width: 35,
                                                  height: 35,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 30.0),
                                    Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text("Don't have an account?"),
                                            GestureDetector(
                                              onTap: () {
                                                if (kAdvanceConfig[
                                                        'EnableMembershipUltimate'] ==
                                                    true) {
                                                  Navigator.of(context)
                                                      .pushNamed(RouteList
                                                          .memberShipUltimatePlans);
                                                } else {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          RouteList.register);
                                                }
                                              },
                                              child: Text(
                                                ' ${S.of(context).signup}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: maintabBlue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20)
                                  ],
                                ),
                              ),
                            ),
                          ])),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: Container(
          padding: const EdgeInsets.all(50.0),
          child: kLoadingWidget(context),
        ));
      },
    );
  }

  void hideLoading() {
    Navigator.of(context).pop();
  }
}
