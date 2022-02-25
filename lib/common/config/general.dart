part of '../config.dart';

/// Default app config, it's possible to set as URL
String get kAppConfig => Configurations.appConfig;

/// Ref: https://support.inspireui.com/help-center/articles/3/25/16/google-map-address
/// The Google API Key to support Pick up the Address automatically
/// We recommend to generate both ios and android to restrict by bundle app id
/// The download package is remove these keys, please use your own key
const kGoogleAPIKey = {
  'android': 'AIzaSyDW3uXzZepWBPi-69BIYKyS-xo9NjFSFhQ',
  'ios': 'AIzaSyDW3uXzZepWBPi-69BIYKyS-xo9NjFSFhQ',
  'web': 'AIzaSyDW3uXzZepWBPi-69BIYKyS-xo9NjFSFhQ'
};

/// user for upgrader version of app, remove the comment from lib/check_screens.dart to enable this feature
/// https://tppr.me/5PLpD
const kUpgradeURLConfig = {
  'android':
      'https://play.google.com/store/apps/details?id=com.inspireui.fluxstore',
  'ios': 'https://apps.apple.com/us/app/mstore-flutter/id1469772800'
};

Map get kStoreIdentifier => Configurations.storeIdentifier;

Map get kAdvanceConfig => Configurations.advanceConfig;

DrawerMenuConfig get kDefaultDrawer =>
    DrawerMenuConfig.fromJson(Configurations.defaultDrawer);

List get kDefaultSettings => Configurations.defaultSettings;

Map get kLoginSetting => Configurations.loginSetting;

Map get kOneSignalKey => Configurations.oneSignalKey;

Map<String, GeneralSettingItem> get kSubGeneralSetting =>
    Map<String, GeneralSettingItem>.from(Configurations.subGeneralSetting);

bool get kEnableShoppingCart => kAdvanceConfig['EnableCart'] ?? true;

class LoginSMSConstants {
  static String get countryCodeDefault =>
      Configurations.loginSMSConstants['countryCodeDefault'] ??
      Configurations.countryCodeDefault;

  static String get dialCodeDefault =>
      Configurations.loginSMSConstants['dialCodeDefault'] ??
      Configurations.dialCodeDefault;

  static String get nameDefault =>
      Configurations.loginSMSConstants['nameDefault'] ??
      Configurations.nameDefault;
}

bool get kDefaultDarkTheme => Configurations.defaultDarkTheme;

ThemeConfig get kDarkConfig => ThemeConfig.fromJson(Configurations.darkConfig);

ThemeConfig get kLightConfig =>
    ThemeConfig.fromJson(Configurations.lightConfig);

enum kHeartButtonType { cornerType, squareType }

Map get kSplashScreen => Configurations.splashScreen;

ColorOverrideConfig get colorOverrideConfig => ColorOverrideConfig.fromJson(Configurations.colorOverrideConfig);

ProductFilterColor? get productFilterColor => colorOverrideConfig.productFilterColor;
