import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../../models/user_model.dart';
import '../../services/services.dart';
import '../../widgets/common/flux_image.dart';
import '../../widgets/common/login_animation.dart';
import 'verify.dart';

class LoginSMSScreen extends StatefulWidget {
  const LoginSMSScreen();

  @override
  _LoginSMSState createState() => _LoginSMSState();
}

class _LoginSMSState extends State<LoginSMSScreen>
    with TickerProviderStateMixin {
  late AnimationController _loginButtonController;
  final TextEditingController _controller = TextEditingController(text: '');

  CountryCode? countryCode;
  String? phoneNumber;
  String? _phone;
  bool isLoading = false;

  late final _verifySuccessStream;

  @override
  void initState() {
    super.initState();
    _verifySuccessStream = Services().firebase.getFirebaseStream();

    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _phone = '';

    if (LoginSMSConstants.dialCodeDefault.isNotEmpty) {
      countryCode = CountryCode.fromDialCode(LoginSMSConstants.dialCodeDefault);
    } else if (LoginSMSConstants.countryCodeDefault.isNotEmpty) {
      countryCode =
          CountryCode.fromCountryCode(LoginSMSConstants.countryCodeDefault);
    } else {
      countryCode = CountryCode(
        code: LoginSMSConstants.countryCodeDefault,
        dialCode: LoginSMSConstants.dialCodeDefault,
        name: LoginSMSConstants.nameDefault,
      );
    }

    _controller.addListener(() {
      if (_controller.text != _phone && _controller.text != '') {
        _phone = _controller.text;
        onPhoneNumberChange(
          _phone,
          '${countryCode!.dialCode}$_phone',
          countryCode!.code,
        );
      }
    });
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
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

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text('⚠️: $message'),
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

  void onPhoneNumberChange(
    String? number,
    String internationalizedPhoneNumber,
    String? isoCode,
  ) {
    if (internationalizedPhoneNumber.isNotEmpty) {
      phoneNumber = internationalizedPhoneNumber;
    } else {
      phoneNumber = null;
    }
  }

  Future<void> _loginSMS(context) async {
    if (phoneNumber == null) {
      Tools.showSnackBar(Scaffold.of(context), S.of(context).pleaseInput);
    } else {
      await _playAnimation();

      Future autoRetrieve(String verId) {
        return _stopAnimation();
      }

      Future smsCodeSent(String verId, [int? forceCodeResend]) {
        _stopAnimation();
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCode(
              verId: verId,
              phoneNumber: phoneNumber,
              verifySuccessStream: _verifySuccessStream.stream,
            ),
          ),
        );
      }

      final verifiedSuccess = _verifySuccessStream.add;

      void verifyFailed(exception) {
        _stopAnimation();
        _failMessage(exception.message, context);
      }

      Services().firebase.verifyPhoneNumber(
            phoneNumber: phoneNumber!,
            codeAutoRetrievalTimeout: autoRetrieve,
            codeSent: smsCodeSent,
            verificationCompleted: verifiedSuccess,
            verificationFailed: verifyFailed,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: true);
    final themeConfig = appModel.themeConfig;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushNamed(RouteList.home);
            }
          },
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(
            children: [
              ListenableProvider.value(
                value: Provider.of<UserModel>(context),
                child: Consumer<UserModel>(
                  builder: (context, model, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 80.0),
                          Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 40.0,
                                    child:
                                        FluxImage(imageUrl: themeConfig.logo),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 120.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CountryCodePicker(
                                onChanged: (country) {
                                  setState(() {
                                    countryCode = country;
                                  });
                                },
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: countryCode!.code,
                                //Get the country information relevant to the initial selection
                                onInit: (code) {
                                  countryCode = code;
                                },
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                dialogBackgroundColor:
                                    Theme.of(context).dialogBackgroundColor,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                      labelText: S.of(context).phone),
                                  keyboardType: TextInputType.phone,
                                  controller: _controller,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 60),
                          StaggerAnimation(
                            titleButton: S.of(context).sendSMSCode,
                            buttonController: _loginButtonController.view
                                as AnimationController,
                            onTap: () {
                              if (!isLoading) {
                                _loginSMS(context);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
