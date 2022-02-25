import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../services/service_config.dart';

class Layout {
  static const String columns = 'columns';
  static const String twoColumn = 'twoColumn';
  static const String threeColumn = 'threeColumn';
  static const String fourColumn = 'fourColumn';
  static const String recentView = 'recentView';
  static const String saleOff = 'saleOff';
  static const String card = 'card';
  static const String listTile = 'listTile';
  static const String staggered = 'staggered';

  static bool isDisplayDesktop(BuildContext context) {
    final deviceType = getDeviceType(MediaQuery.of(context).size);
    return deviceType == DeviceScreenType.desktop ||
        (deviceType == DeviceScreenType.tablet &&
            MediaQuery.of(context).orientation == Orientation.landscape);
  }

  static double buildProductWidth({layout, screenWidth}) {
    switch (layout) {
      case twoColumn:
        return screenWidth * 0.5;
      case threeColumn:
        return screenWidth / 3;
      case fourColumn:
        return screenWidth / 4;
      case recentView:
        return screenWidth * 0.35;
      case saleOff:
        return screenWidth * 0.35;
      case card:
      case listTile:
      default:
        return screenWidth - 10;
    }
  }

  static double buildProductMaxWidth({layout}) {
    switch (layout) {
      case twoColumn:
        return 300;
      case threeColumn:
        return 200;
      case fourColumn:
        return 150;
      case recentView:
        return 200;
      case saleOff:
        return 200;
      case card:
      case listTile:
      default:
        return 400;
    }
  }

  static double buildProductHeight({layout, defaultHeight}) {
    switch (layout) {
      case Layout.twoColumn:
      case Layout.threeColumn:
      case Layout.fourColumn:
      case Layout.recentView:
      case Layout.saleOff:
        return 200;
      case Layout.card:
      case Layout.listTile:
      default:
        return defaultHeight;
    }
  }
}

class Helper {
  /// Convert String to double
  static double? formatDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null || value == '') {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    return double.tryParse(value) ?? defaultValue;
  }

  /// Convert String to int
  static int? formatInt([dynamic value = '0', int defaultValue = 0]) {
    if (value == null || value == '') {
      return defaultValue;
    }

    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static BoxFit boxFit(String? fit) {
    switch (fit) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'scaleDown':
        return BoxFit.scaleDown;
      case 'cover':
        return BoxFit.cover;
      default:
        return BoxFit.fitWidth;
    }
  }

  /// check tablet screen
  static bool isTablet(MediaQueryData query) {
    if (Config().isBuilder) {
      return false;
    }

    if (kIsWeb) {
      return true;
    }

    if (UniversalPlatform.isWindows || UniversalPlatform.isMacOS) {
      return false;
    }

    var size = query.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    var isTablet = diagonal > 1100.0;
    return isTablet;
  }
}
