import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show PlatformError;
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../common/app_bar_mixin.dart';

class WebViewScreen extends StatefulWidget {
  final String? title;
  final String? url;

  const WebViewScreen({
    this.title,
    required this.url,
  });

  @override
  _StateWebViewScreen createState() => _StateWebViewScreen();
}

class _StateWebViewScreen extends State<WebViewScreen> with AppBarMixin {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar(RouteList.page) ? appBarWidget : null,
      body: Column(
        children: [
          AppBar(
            title: Text(widget.title ?? '', style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            backgroundColor: Theme.of(context).backgroundColor,
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: isMobile
                      ? () async {
                          if (await _controller.canGoBack()) {
                            await _controller.goBack();
                          } else {
                            Tools.showSnackBar(Scaffold.of(context),
                                Text(S.of(context).noBackHistoryItem));
                            return;
                          }
                        }
                      : null,
                  child: const Icon(Icons.arrow_back_ios),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: isMobile
                      ? () async {
                          if (await _controller.canGoForward()) {
                            await _controller.goForward();
                          } else {
                            Tools.showSnackBar(Scaffold.of(context),
                                S.of(context).noForwardHistoryItem);
                            return;
                          }
                        }
                      : null,
                  child: const Icon(Icons.arrow_forward_ios),
                ),
              )
            ],
          ),
          Expanded(
            child: (isMobile)
                ? WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: widget.url,
                    onWebViewCreated: (WebViewController controller) {
                      _controller = controller;
                    },
                  )
                : const PlatformError(),
          ),
        ],
      ),
    );
  }
}
