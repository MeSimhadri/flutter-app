import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/config.dart';
import '../../services/index.dart';
import '../base_screen.dart';
// import 'payment_webview_plugin.dart';

const enableWebviewFlutter = true;

class PaymentWebview extends StatefulWidget {
  final String? url;
  final Function? onFinish;
  final Function? onClose;

  const PaymentWebview({this.onFinish, this.onClose, this.url});

  @override
  State<StatefulWidget> createState() {
    return PaymentWebviewState();
  }
}

class PaymentWebviewState extends BaseScreen<PaymentWebview> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    var checkoutMap = <dynamic, dynamic>{
      'url': '',
      'headers': <String, String>{}
    };

    if (widget.url != null) {
      checkoutMap['url'] = widget.url;
    } else {
      final paymentInfo = Services().widget.getPaymentUrl(context)!;
      checkoutMap['url'] = paymentInfo['url'];
      if (paymentInfo['headers'] != null) {
        checkoutMap['headers'] =
            Map<String, String>.from(paymentInfo['headers']);
      }
    }

    // // Enable webview payment plugin
    /// make sure to import 'payment_webview_plugin.dart';
    // return PaymentWebviewPlugin(
    //   url: checkoutMap['url'],
    //   headers: checkoutMap['headers'],
    //   onClose: widget.onClose,
    //   onFinish: widget.onFinish,
    // );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onFinish!(null);
              Navigator.of(context).pop();

              if (widget.onClose != null) {
                widget.onClose!();
              }
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: checkoutMap['url'],
            onProgress: (progress) {
              if (progress == 100) {
                setState(() {
                  selectedIndex = 0;
                });
              }
            },
            onPageFinished: (url) {
              if (url.contains('/order-received/')) {
                final items = url.split('/order-received/');
                if (items.length > 1) {
                  final number = items[1].split('/')[0];
                  widget.onFinish!(number);
                  Navigator.of(context).pop();
                }
              }
              if (url.contains('checkout/success')) {
                widget.onFinish!('0');
                Navigator.of(context).pop();
              }

              // shopify url final checkout
              if (url.contains('thank_you')) {
                widget.onFinish!('0');
                Navigator.of(context).pop();
              }

              if (url.contains('/member-login/')) {
                widget.onFinish!('0');
                Navigator.of(context).pop();
              }
            },
          ),
          Center(
            child: kLoadingWidget(context),
          )
        ],
      ),
    );
  }
}
