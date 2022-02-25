import 'package:flutter/material.dart';
import '../../tools/tools.dart';

const defaultIcon = 'news';
const defaultIconFontFamily = 'CupertinoIcons';
const defaultId = 'web-12'; //web, post, title

class GeneralSettingItem {
  String id = defaultId;
  String title = '';
  String icon = defaultIcon;
  String iconFontFamily = defaultIconFontFamily;
  int? pageId;
  String? webUrl;
  double? fontSize;
  String? titleColor;
  Offset? verticalPadding;
  bool enableDivider = false;
  bool requiredLogin = false;
  bool webViewMode = false;
  String buttonAlignment = 'centerLeft';
  List<GeneralButton> buttons = [];

  GeneralSettingItem({
    this.id = defaultId,
    this.title = '',
    this.icon = defaultIcon,
    this.iconFontFamily = defaultIconFontFamily,
    this.pageId,
    this.webUrl,
    this.fontSize,
    this.titleColor,
    this.verticalPadding,
    this.enableDivider = false,
    this.requiredLogin = false,
    this.webViewMode = false,
    this.buttonAlignment = 'centerLeft',
    this.buttons = const [],
  });

  GeneralSettingItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? defaultId;
    title = json['title'] ?? '';
    icon = json['icon'] ?? defaultIcon;
    iconFontFamily = json['iconFontFamily'] ?? defaultIconFontFamily;
    pageId =
        json['pageId'] != null ? int.tryParse(json['pageId'].toString()) : null;
    webUrl = json['webUrl'];
    fontSize = json['fontSize'] != null
        ? double.tryParse(json['fontSize'].toString())
        : null;
    titleColor = json['titleColor'];
    verticalPadding = json['verticalPadding'] != null
        ? Offset(
            double.tryParse((json['verticalPadding']['x']).toString()) ?? 0.0,
            double.tryParse((json['verticalPadding']['y']).toString()) ?? 0.0)
        : null;
    enableDivider = json['enableDivider'] ?? false;
    requiredLogin = json['requiredLogin'] ?? false;
    webViewMode = json['webViewMode'] ?? false;
    buttonAlignment = json['buttonAlignment'] ?? 'centerLeft';
    if (json['buttons'] != null) {
      for (var item in json['buttons']) {
        buttons.add(GeneralButton.fromJson(item));
      }
    }
  }

  Map<String, dynamic> toJson() {
    var json = Map<String, dynamic>.from({
      'id': id,
      'title': title,
      'icon': icon,
      'iconFontFamily': iconFontFamily
    });
    if (pageId != null) json['pageId'] = pageId;
    if (webUrl != null) json['webUrl'] = webUrl;
    if (fontSize != null) json['fontSize'] = fontSize;
    if (titleColor != null) json['titleColor'] = titleColor;
    if (verticalPadding != null) {
      json['verticalPadding'] = {
        'x': verticalPadding?.dx,
        'y': verticalPadding?.dy,
      };
    }
    if (enableDivider) json['enableDivider'] = enableDivider;
    if (webViewMode) json['webViewMode'] = webViewMode;
    if (requiredLogin) json['requiredLogin'] = requiredLogin;
    json['buttonAlignment'] = buttonAlignment;
    var jsonButtons = [];
    for (var item in buttons) {
      jsonButtons.add(item.toJson());
    }
    json['buttons'] = jsonButtons;
    return json;
  }
}

class GeneralButton {
  String? image;
  num width = 40;
  num height = 40;
  num radius = 0;
  num marginLeft = 5.0;
  num marginRight = 5.0;
  String? webUrl;

  GeneralButton({
    this.image,
    this.width = 40,
    this.height = 40,
    this.radius = 0,
    this.marginLeft = 5.0,
    this.marginRight = 5.0,
    this.webUrl,
  });

  GeneralButton.fromJson(dynamic json) {
    image = json['image'];
    width = json['width'] ?? 40.0;
    height = json['height'] ?? 40.0;
    radius = json['radius'] ?? 0.0;
    marginLeft = json['marginLeft'] ?? 5.0;
    marginRight = json['marginRight'] ?? 5.0;
    webUrl = json['webUrl'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['image'] = image;
    map['width'] = width;
    map['radius'] = radius;
    map['marginLeft'] = marginLeft;
    map['marginRight'] = marginRight;
    map['height'] = height;
    map['webUrl'] = webUrl;
    map.removeWhere((key, value) => value == null);
    return map;
  }
}

extension ExtensionGeneralSettingItem on GeneralSettingItem {
  AlignmentGeometry get displayButtonAlignment => Tools.getAlignment(buttonAlignment);
}