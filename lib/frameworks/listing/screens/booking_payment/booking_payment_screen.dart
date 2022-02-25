import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../common/config.dart';
import '../../../../common/tools/tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/user_model.dart';
import '../../../../modules/native_payment/razorpay/services.dart';
import 'booking_payment_method_screen.dart';
import 'booking_payment_model.dart';
import 'payment/paypal/index.dart';
import 'widgets/continue_floating_button.dart';

class BookingPaymentScreen extends StatefulWidget {
  /// Function to refresh the booking history after payment
  final Function? callback;

  const BookingPaymentScreen({Key? key, this.callback}) : super(key: key);

  @override
  _BookingPaymentScreenState createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen>
    with RazorDelegate {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _pageController = PageController();
  List<Widget> lstScreen = [];
  int index = 0;

  @override
  void initState() {
    lstScreen.addAll([
      BookingPaymentMethodScreen(),
    ]);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateBooking() async {
    final model = Provider.of<BookingPaymentModel>(context, listen: false);
    await model.updateBookingStatus(true);
    Navigator.pop(context);
    widget.callback!();
  }

  void _makePayment() {
    final model = Provider.of<BookingPaymentModel>(context, listen: false);
    final paymentMethod = model.lstPaymentMethod[model.index];

    if (isNotBlank(kPaypalConfig['paymentMethodId']) &&
        paymentMethod.id!.contains(kPaypalConfig['paymentMethodId']) &&
        kPaypalConfig['enabled'] == true) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => PaypalPayment2(
            booking: model.booking,
            onFinish: (number) async {
              if (number == null) {
                return;
              } else {
                _updateBooking();
              }
            },
          ),
        ),
      );
    }

    if (isNotBlank(kRazorpayConfig['paymentMethodId']) &&
        paymentMethod.id!.contains(kRazorpayConfig['paymentMethodId']) &&
        kRazorpayConfig['enabled'] == true) {
      final user = Provider.of<UserModel>(context, listen: false).user!;
      final _razorServices = RazorServices(
        amount: model.booking?.price ?? '0',
        keyId: kRazorpayConfig['keyId'],
        delegate: this,
        userInfo: RazorUserInfo(
          email: user.email ?? '',
          fullName: user.fullName,
          phone: user.billing?.phone ?? '',
        ),
      );
      _razorServices.openPayment();
    }
  }

  void _nextPage() {
    if (index < lstScreen.length - 1) {
      index++;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
      return;
    }
    _makePayment();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<BookingPaymentModel>(
      builder: (context, model, _) => Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            key: _scaffoldKey,
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text(S.of(context).paymentMethods),
            ),
            floatingActionButton: ContinueFloatingButton(
              title: S.of(context).continues,
              icon: Icons.arrow_forward_ios,
              onTap: _nextPage,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterFloat,
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: lstScreen,
            ),
          ),
          if (model.state == BookingPaymentModelState.paymentProcessing)
            Container(
              height: size.height,
              width: size.width,
              color: Colors.grey.withOpacity(0.3),
              child: Center(
                child: kLoadingWidget(context),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void handlePaymentFailure(PaymentFailureResponse response) {
    final body = jsonDecode(response.message!);
    if (body['error'] != null &&
        body['error']['reason'] != 'payment_cancelled') {
      Tools.showSnackBar(Scaffold.of(context), body['error']['description']);
    }
  }

  @override
  void handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.paymentId ?? '')));
    _updateBooking();
  }
}
