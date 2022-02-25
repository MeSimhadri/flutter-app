import 'package:flutter/cupertino.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'
    as core;
import 'package:fwfh_cached_network_image/fwfh_cached_network_image.dart';
import 'package:fwfh_chewie/fwfh_chewie.dart';
import 'package:fwfh_svg/fwfh_svg.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:fwfh_webview/fwfh_webview.dart';

class HtmlWidget extends StatelessWidget {
  final String html;
  final TextStyle? textStyle;

  const HtmlWidget(this.html, {Key? key, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return core.HtmlWidget(
      html,
      textStyle: textStyle,
      factoryBuilder: () => MyWidgetFactory(),
    );
  }
}

class MyWidgetFactory extends core.WidgetFactory
    with
        WebViewFactory,
        CachedNetworkImageFactory,
        UrlLauncherFactory,
        ChewieFactory,
        SvgFactory {
  @override
  bool get webViewMediaPlaybackAlwaysAllow => true;
}
