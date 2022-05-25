import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, PointModel, User, UserModel;
import '../../modules/vendor_on_boarding/screen_index.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/flux_image.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen();

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // final _auth = firebase_auth.FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();

  String? firstName, lastName, emailAddress, phoneNumber, password;
  bool? isVendor = false;
  bool isChecked = false;

  final bool showPhoneNumberWhenRegister =
      kLoginSetting['showPhoneNumberWhenRegister'] ?? false;
  final bool requirePhoneNumberWhenRegister =
      kLoginSetting['requirePhoneNumberWhenRegister'] ?? false;

  final firstNameNode = FocusNode();
  final lastNameNode = FocusNode();
  final phoneNumberNode = FocusNode();
  final emailNode = FocusNode();
  final passwordNode = FocusNode();

  void _welcomeDiaLog(User user) {
    Provider.of<CartModel>(context, listen: false).setUser(user);
    Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
    final model = Provider.of<UserModel>(context, listen: false);

    /// Show VendorOnBoarding.
    if (kVendorConfig['VendorRegister'] == true &&
        Provider.of<AppModel>(context, listen: false).vendorType ==
            VendorType.multi &&
        user.isVender) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => VendorOnBoarding(
            user: user,
            onFinish: () {
              model.getUser();
              var email = user.email;
              _snackBar(S.of(ctx).welcome + ' $email!');
              var routeFound = false;
              var routeNames = [RouteList.dashboard, RouteList.productDetail];
              Navigator.popUntil(ctx, (route) {
                if (routeNames.any((element) =>
                    route.settings.name?.contains(element) ?? false)) {
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
    _snackBar(S.of(context).welcome + ' $email!');
    if (kLoginSetting['IsRequiredLogin'] ?? false) {
      Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
      return;
    }
    var routeFound = false;
    var routeNames = [RouteList.dashboard, RouteList.productDetail];
    Navigator.popUntil(context, (route) {
      if (routeNames
          .any((element) => route.settings.name?.contains(element) ?? false)) {
        routeFound = true;
      }
      return routeFound || route.isFirst;
    });

    if (!routeFound) {
      Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    firstNameNode.dispose();
    lastNameNode.dispose();
    emailNode.dispose();
    passwordNode.dispose();
    phoneNumberNode.dispose();
    super.dispose();
  }

  void _snackBar(String text) {
    if (mounted) {
      final snackBar = SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: S.of(context).close,
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      // ignore: deprecated_member_use
      _scaffoldKey.currentState!.showSnackBar(snackBar);
    }
  }

  Future<void> _submitRegister({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? emailAddress,
    String? password,
    bool? isVendor,
  }) async {
    if (firstName == null ||
        lastName == null ||
        emailAddress == null ||
        password == null ||
        (showPhoneNumberWhenRegister &&
            requirePhoneNumberWhenRegister &&
            phoneNumber == null)) {
      _snackBar(S.of(context).pleaseInputFillAllFields);
    } else if (isChecked == false) {
      _snackBar(S.of(context).pleaseAgreeTerms);
    } else {
      final emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

      if (!emailValid.hasMatch(emailAddress)) {
        _snackBar(S.of(context).errorEmailFormat);
        return;
      }

      if (password.length < 8) {
        _snackBar(S.of(context).errorPasswordFormat);
        return;
      }

      await Provider.of<UserModel>(context, listen: false).createUser(
        username: emailAddress,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        success: _welcomeDiaLog,
        fail: _snackBar,
        isVendor: isVendor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: true);
    final themeConfig = appModel.themeConfig;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Tools.hideKeyboard(context),
          child: ListenableProvider.value(
            value: Provider.of<UserModel>(context),
            child: Consumer<UserModel>(
              builder: (context, value, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: AutofillGroup(
                      child: Column(
                        children: [
                          const FluxImage(
                            imageUrl: 'assets/images/logo.png',
                            // width: MediaQuery.of(context).size.width / 2,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0XFF1A83C8).withOpacity(0.2),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  // const SizedBox(height: 10.0),
                                  // Center(
                                  //   child: FluxImage(
                                  //     imageUrl: themeConfig.logo,
                                  //     width: MediaQuery.of(context).size.width / 2,
                                  //     fit: BoxFit.contain,
                                  //   ),
                                  // ),
                                  const SizedBox(height: 20.0),
                                  const Text(
                                    'Sign up',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0XFF1A83C8)),
                                  ),
                                  const SizedBox(height: 20.0),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black))),
                                    child: CustomTextField(
                                      key: const Key('registerFirstNameField'),
                                      autofillHints: const [
                                        AutofillHints.givenName
                                      ],
                                      onChanged: (value) => firstName = value,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      nextNode: lastNameNode,
                                      showCancelIcon: true,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                        labelText: S.of(context).firstName,
                                        hintText:
                                            S.of(context).enterYourFirstName,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black))),
                                    child: CustomTextField(
                                      key: const Key('registerLastNameField'),
                                      autofillHints: const [
                                        AutofillHints.familyName
                                      ],
                                      focusNode: lastNameNode,
                                      nextNode: showPhoneNumberWhenRegister
                                          ? phoneNumberNode
                                          : emailNode,
                                      showCancelIcon: true,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onChanged: (value) => lastName = value,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                        labelText: S.of(context).lastName,
                                        hintText:
                                            S.of(context).enterYourLastName,
                                      ),
                                    ),
                                  ),
                                  if (showPhoneNumberWhenRegister)
                                    const SizedBox(height: 20.0),
                                  if (showPhoneNumberWhenRegister)
                                    CustomTextField(
                                      key: const Key('registerPhoneField'),
                                      focusNode: phoneNumberNode,
                                      autofillHints: const [
                                        AutofillHints.telephoneNumber
                                      ],
                                      nextNode: emailNode,
                                      showCancelIcon: true,
                                      onChanged: (value) => phoneNumber = value,
                                      decoration: InputDecoration(
                                        labelText: S.of(context).phone,
                                        hintText:
                                            S.of(context).enterYourPhoneNumber,
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black))),
                                    child: CustomTextField(
                                      key: const Key('registerEmailField'),
                                      focusNode: emailNode,
                                      autofillHints: const [
                                        AutofillHints.email
                                      ],
                                      nextNode: passwordNode,
                                      controller: _emailController,
                                      onChanged: (value) =>
                                          emailAddress = value,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          labelStyle: const TextStyle(
                                              color: Colors.black),
                                          labelText:
                                              S.of(context).enterYourEmail),
                                      hintText: S.of(context).enterYourEmail,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black))),
                                    child: CustomTextField(
                                      key: const Key('registerPasswordField'),
                                      focusNode: passwordNode,
                                      autofillHints: const [
                                        AutofillHints.password
                                      ],
                                      showEyeIcon: true,
                                      obscureText: true,
                                      onChanged: (value) => password = value,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                        labelText:
                                            S.of(context).enterYourPassword,
                                        hintText:
                                            S.of(context).enterYourPassword,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  if (kVendorConfig['VendorRegister'] == true &&
                                      Provider.of<AppModel>(context,
                                                  listen: false)
                                              .vendorType ==
                                          VendorType.multi)
                                    Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: isVendor,
                                          activeColor:
                                              Theme.of(context).primaryColor,
                                          checkColor: Colors.white,
                                          onChanged: (value) {
                                            setState(() {
                                              isVendor = value;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              isVendor = !isVendor!;
                                              setState(() {});
                                            },
                                            child: Text(
                                              S.of(context).registerAsVendor,
                                              maxLines: 2,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  // Row(
                                  //   children: <Widget>[
                                  //     Checkbox(
                                  //       key: const Key('registerConfirmCheckbox'),
                                  //       value: isChecked,
                                  //       activeColor:
                                  //           Theme.of(context).primaryColor,
                                  //       checkColor: Colors.white,
                                  //       onChanged: (value) {
                                  //         isChecked = !isChecked;
                                  //         setState(() {});
                                  //       },
                                  //     ),
                                  //     InkWell(
                                  //       onTap: () {
                                  //         isChecked = !isChecked;
                                  //         setState(() {});
                                  //       },
                                  //       child: Text(
                                  //         S.of(context).iwantToCreateAccount,
                                  //         style: Theme.of(context)
                                  //             .textTheme
                                  //             .bodyText1,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  InkWell(
                                    onTap: () {
                                      isChecked = !isChecked;
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: isChecked,
                                          activeColor: maintabBlue,
                                          checkColor: Colors.white,
                                          onChanged: (value) {
                                            isChecked = !isChecked;
                                            setState(() {});
                                          },
                                        ),
                                        Expanded(
                                          child: RichText(
                                            maxLines: 2,
                                            text: TextSpan(
                                              text: S.of(context).iAgree,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                              children: <TextSpan>[
                                                const TextSpan(text: ' '),
                                                TextSpan(
                                                  text: 'Terms & Conditions',
                                                  // text: S
                                                  //     .of(context)
                                                  //     .agreeWithPrivacy,
                                                  style: const TextStyle(
                                                      color: maintabBlue,
                                                      decoration: TextDecoration
                                                          .underline),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () =>
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PrivacyScreen(),
                                                              ),
                                                            ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 30),
                                    child: Material(
                                      color: maintabBlue,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25.0)),
                                      elevation: 0,
                                      child: MaterialButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        key: const Key('registerSubmitButton'),
                                        onPressed: value.loading == true
                                            ? null
                                            : () async {
                                                await _submitRegister(
                                                  firstName: firstName,
                                                  lastName: lastName,
                                                  phoneNumber: phoneNumber,
                                                  emailAddress: emailAddress,
                                                  password: password,
                                                  isVendor: isVendor,
                                                );
                                              },
                                        minWidth: double.infinity,
                                        elevation: 0.0,
                                        height: 42.0,
                                        child: Text(
                                          value.loading == true
                                              ? S.of(context).loading
                                              : 'Sign up',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  InkWell(
                                    onTap: () {
                                      final canPop =
                                          ModalRoute.of(context)!.canPop;
                                      if (canPop) {
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                RouteList.login);
                                      }
                                    },
                                    child: const Text(
                                      'Already have an account?',
                                      style: TextStyle(
                                        color: maintabBlue,
                                        // decoration: TextDecoration.underline,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       vertical: 10.0),
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.center,
                                  //     children: <Widget>[
                                  //       Text(
                                  //         S.of(context).or + ' ',
                                  //         style: const TextStyle(
                                  //             color: Colors.black45),
                                  //       ),
                                  //       InkWell(
                                  //         onTap: () {
                                  //           final canPop =
                                  //               ModalRoute.of(context)!.canPop;
                                  //           if (canPop) {
                                  //             Navigator.pop(context);
                                  //           } else {
                                  //             Navigator.of(context)
                                  //                 .pushReplacementNamed(
                                  //                     RouteList.login);
                                  //           }
                                  //         },
                                  //         child: Text(
                                  //           S.of(context).loginToYourAccount,
                                  //           style: TextStyle(
                                  //             color:
                                  //                 Theme.of(context).primaryColor,
                                  //             decoration:
                                  //                 TextDecoration.underline,
                                  //             fontSize: 15,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
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
}

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          S.of(context).agreeWithPrivacy,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            S.of(context).privacyTerms,
            style: const TextStyle(fontSize: 16.0, height: 1.4),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
