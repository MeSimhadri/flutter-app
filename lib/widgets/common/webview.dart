import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as flutter;

import '../../common/constants.dart';
import '../html/index.dart';
import 'webview_window.dart';

class WebView extends StatefulWidget {
  final String? url;
  final String? title;
  final AppBar? appBar;

  const WebView({Key? key, this.title, required this.url, this.appBar})
      : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  bool isLoading = true;
  String html = '';
  late flutter.WebViewController _controller;

  @override
  void initState() {
    if (isMacOS) {
      httpGet(widget.url.toString().toUri()!).then((response) {
        setState(() {
          html = response.body;
        });
      });
    }

    if (isAndroid) flutter.WebView.platform = flutter.SurfaceAndroidWebView();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isMacOS) {
      return Scaffold(
        appBar: widget.appBar ??
            AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              elevation: 0.0,
              title: Center(
                child: Text(
                  widget.title ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        body: SingleChildScrollView(
          child: HtmlWidget(html),
        ),
      );
    }

    if (isWindow) {
      return WebViewWindow(url: widget.url!, title: widget.title);
    }

    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0.0,
            title: Text(
              widget.title ?? '',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async{
                  var value = await _controller.canGoBack();
                  if(value){
                    await _controller.goBack();
                  }else{
                    Navigator.of(context).pop();
                  }
                }),
          ),
      body: Builder(builder: (BuildContext context) {
        return flutter.WebView(
          initialUrl: widget.url!,
          javascriptMode: flutter.JavascriptMode.unrestricted,
          onWebViewCreated: ( webViewController) {
            _controller = webViewController;
          },
          gestureNavigationEnabled: true,
        );
      }),
    );
  }
}
