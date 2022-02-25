import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

enum DisplayType {
  desktop,
  tablet,
  mobile,
}

const _desktopBreakpointWstH = 1024.0; // Width is smaller than Height
const _desktopBreakpointWgtH = 700.0; // Width is greater than Height

DisplayType displayTypeOf(BuildContext context) {
  if ((MediaQuery.of(context).size.width < MediaQuery.of(context).size.height &&
          MediaQuery.of(context).size.width <= _desktopBreakpointWstH) ||
      (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height &&
          MediaQuery.of(context).size.width <= _desktopBreakpointWgtH)) {
    return DisplayType.mobile;
  } else {
    return DisplayType.desktop;
  }
}

bool isDisplayDesktop(BuildContext context) {
  final deviceType = getDeviceType(MediaQuery.of(context).size);
  return deviceType == DeviceScreenType.desktop ||
      (deviceType == DeviceScreenType.tablet &&
          MediaQuery.of(context).orientation == Orientation.landscape);
}

bool isBigScreen(BuildContext context) {
  return MediaQuery.of(context).size.width >= 768;
}
