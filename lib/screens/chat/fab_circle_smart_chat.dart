import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/config.dart' as config;
import '../../generated/l10n.dart';
import '../../services/services.dart';
import 'chat_mixin.dart';
import 'fab_circle_menu.dart';

class FabCircleSmartChat extends StatefulWidget {
  final EdgeInsets? margin;
  final List<Map>? options;

  const FabCircleSmartChat({this.margin, this.options});

  @override
  _FabCircleSmartChatState createState() => _FabCircleSmartChatState();
}

class _FabCircleSmartChatState extends State<FabCircleSmartChat>
    with ChatMixin, WidgetsBindingObserver {
  @override
  List<Map> get options => widget.options ?? config.smartChat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  IconButton getIconButton(
    IconData? iconData,
    double iconSize,
    Color iconColor,
    String? appUrl,
    String? imageData,
  ) {
    return IconButton(
      icon: (imageData?.isNotEmpty ?? false)
          ? Image.network(imageData!, width: 35, fit: BoxFit.contain)
          : iconData != null
              ? Icon(
                  iconData,
                  size: iconSize,
                  color: iconColor,
                )
              : const SizedBox(),
      onPressed: () async {
        if (await canLaunch(appUrl!)) {
          if (appUrl.contains('http') && !appUrl.contains('wa.me')) {
            openChat(url: appUrl, context: context);
          } else {
            await launch(appUrl);
          }
          return;
        }
        final snackBar = SnackBar(
          content: Text(
            S.of(context).canNotLaunch,
          ),
          action: SnackBarAction(
            label: S.of(context).undo,
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }

  List<IconButton> getFabIconButton() {
    if (!Services().firebase.isEnabled) {
      options.removeWhere((element) => element.containsKey('firebase'));
    }

    return options
        .map((option) => getIconButton(
              option['iconData'],
              35,
              Theme.of(context).primaryColorLight,
              option['app'],
              option['imageData'],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var list = getFabIconButton();
    if (list.isEmpty) return Container();

    if (list.length == 1) {
      final option = options[0];
      final iconButton = getIconButton(
        option['iconData'],
        28,
        Theme.of(context).primaryColorLight,
        option['app'],
        option['imageData'],
      );
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(
            onPressed: () {},
            heroTag: null,
            backgroundColor: Theme.of(context).primaryColor,
            child: iconButton,
          ),
        ),
      );
    }

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: FabCircularMenu(
        fabOpenIcon: const Icon(Icons.chat, color: Colors.white),
        ringColor: Theme.of(context).primaryColor,
        ringWidth: 100.0,
        ringDiameter: 250.0,
        fabMargin: widget.margin ?? const EdgeInsets.only(bottom: 0),
        options: list,
        child: Container(),
      ),
    );
  }
}
