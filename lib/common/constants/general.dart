part of '../constants.dart';

/// some constants Local Key
const kLocalKey = {
  'userInfo': 'userInfo',
  'shippingAddress': 'shippingAddress',
  'recentSearches': 'recentSearches',
  'wishlist': 'wishlist',
  'home': 'home',
  'cart': 'cart',
  'countries': 'countries',
  'shopify': 'shopify', // only handle for shopify
  'jwtToken': 'jwtToken'
};

/// check if the environment is web
final bool kIsWeb = UniversalPlatform.isWeb;
final bool isIos = UniversalPlatform.isIOS;
final bool isAndroid = UniversalPlatform.isAndroid;
final bool isMacOS = UniversalPlatform.isMacOS;
final bool isWindow = UniversalPlatform.isWindows;
final bool isFuchsia = UniversalPlatform.isFuchsia;
final bool isMobile = UniversalPlatform.isIOS || UniversalPlatform.isAndroid;
final bool isDesktop = UniversalPlatform.isMacOS || UniversalPlatform.isWindows;

/// constant for Magento payment
const kMagentoPayments = [
  'HyperPay_Amex',
  'HyperPay_ApplePay',
  'HyperPay_Mada',
  'HyperPay_Master',
  'HyperPay_PayPal',
  'HyperPay_SadadNcb',
  'HyperPay_Visa',
  'HyperPay_SadadPayware'
];

const apiPageSize = 20;

///-----FLUXSTORE LISTING-----///
enum BookStatus { booked, unavailable, waiting, confirmed, cancelled, error }

const kSizeLeftMenu = 250.0;

class SettingConstants {
  static const aboutUsUrl = 'https://inspireui.com/about';
}

class SplashScreenTypeConstants {
  static const fadeIn = 'fade-in';
  static const zoomIn = 'zoom-in';
  static const zoomOut = 'zoom-out';
  static const topDown = 'top-down';
  static const rive = 'rive';
  static const flare = 'flare';
  static const static = 'static';
}

/// FluxNews
//Legit roles to access post management at Setting screens.
const addPostAccessibleRoles = ['author', 'administrator'];
