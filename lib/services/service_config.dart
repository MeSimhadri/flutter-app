import 'package:flutter/cupertino.dart';
import 'package:inspireui/utils/logs.dart';

import '../frameworks/frameworks.dart';
import '../models/booking/booking_model.dart';
import '../models/cart/cart_model.dart';
import '../models/entities/product.dart';
import '../models/index.dart';
import 'audio/audio_service.dart';
import 'base_services.dart';
import 'wordpress/blognews_api.dart';

enum ConfigType {
  opencart,
  magento,
  shopify,
  presta,
  strapi,
  dokan,
  wcfm,
  listeo,
  listpro,
  mylisting,
  vendorAdmin,
  wordpress,
  delivery,
  woo,
  notion,
}

extension ConfigTypeExtension on ConfigType {
  String get typeName {
    return toString().replaceFirst('ConfigType.', '');
  }
}

class Config {
  ConfigType? type;
  String? url;
  String? blog;
  String? consumerKey;
  String? consumerSecret;
  String? forgetPassword;
  String? accessToken;
  bool? isCacheImage;
  bool isBuilder = false;

  static final Config _instance = Config._internal();

  factory Config() => _instance;

  String get typeName => (type == null ? 'woo' : type!.typeName);

  Config._internal();

  bool get isListingType {
    return [
      ConfigType.listeo,
      ConfigType.listpro,
      ConfigType.mylisting,
    ].contains(type);
  }

  bool get isWooType {
    return [
      ConfigType.listeo,
      ConfigType.listpro,
      ConfigType.mylisting,
      ConfigType.dokan,
      ConfigType.wcfm,
      ConfigType.woo,
    ].contains(type);
  }

  bool get isStrapi {
    return typeName == 'strapi';
  }

  bool get isNotion {
    return typeName == 'notion';
  }

  bool get isShopify => typeName == 'shopify';

  bool get isWordPress {
    return typeName == 'wordpress';
  }

  bool isVendorManagerType() {
    return ConfigType.vendorAdmin == type;
  }

  bool isVendorType() {
    return typeName == 'wcfm' || typeName == 'dokan';
  }

  void setConfig(config) {
    type = ConfigType.values.firstWhere(
      (element) => element.typeName == config['type'],
      orElse: () => ConfigType.woo,
    );
    url = config['url'];
    blog = config['blog'];
    consumerKey = config['consumerKey'];
    consumerSecret = config['consumerSecret'];
    forgetPassword = config['forgetPassword'];
    accessToken = config['accessToken'];
    isCacheImage = config['isCacheImage'];
    isBuilder = config['isBuilder'] ?? false;
  }
}

mixin ConfigMixin {
  late BaseServices api;
  late BaseFrameworks widget;
  BlogNewsApi? blogApi;

  /// mock services for FluxBuilder
  void configBase({
    required BaseServices apiServices,
    required appConfig,
    required widgetServices,
  }) {
    setAppConfig(appConfig);
    api = apiServices;
    widget = widgetServices;
  }

  void configOpencart(appConfig) {}

  void configMagento(appConfig) {}

  void configShopify(appConfig) {}

  void configPrestashop(appConfig) {}

  void configTrapi(appConfig) {}

  void configDokan(appConfig) {}

  void configWCFM(appConfig) {}

  void configWoo(appConfig) {}

  void configListing(appConfig) {}

  void configVendorAdmin(appConfig) {}

  void configWordPress(appConfig) {}

  void configDelivery(appConfig) {}

  void configNotion(appConfig) {}

  void setAppConfig(appConfig) {
    Config().setConfig(appConfig);
    CartInject().init(appConfig);

    printLog('[🌍appConfig] ${appConfig['type']} $appConfig');

    switch (appConfig['type']) {
      case 'opencart':
        configOpencart(appConfig);
        break;
      case 'magento':
        configMagento(appConfig);
        break;
      case 'shopify':
        configShopify(appConfig);
        break;
      case 'presta':
        configPrestashop(appConfig);
        break;
      case 'strapi':
        configTrapi(appConfig);
        break;
      case 'dokan':
        configDokan(appConfig);
        break;
      case 'wcfm':
        configWCFM(appConfig);
        break;
      case 'listeo':
        configListing(appConfig);
        break;
      case 'listpro':
        configListing(appConfig);
        break;
      case 'mylisting':
        configListing(appConfig);
        break;
      case 'vendorAdmin':
        configVendorAdmin(appConfig);
        break;
      case 'delivery':
        configDelivery(appConfig);
        break;
      case 'wordpress':
        configWordPress(appConfig);
        break;
      case 'notion':
        configNotion(appConfig);
        break;
      case 'woo':
      default:
        configWoo(appConfig);
        break;
    }
  }

  /// Empty Widget feature
  Widget getBookingLayout(
          {required Product product, Function(BookingModel)? onCallBack}) =>
      const SizedBox();

  /// get Empty Vendor app
  Widget getVendorAdminApp({languageCode, user, isFromMV}) => const SizedBox();

  /// get Empty Delivery app
  Widget getDeliveryApp({languageCode, user, isFromMV}) => const SizedBox();

  dynamic getVendorRoute(settings) => {};

  /// Empty Module Audio
  Widget getAudioWidget() => const SizedBox();

  AudioService getAudioService() => AudioServiceEmpty();

  void playMediaItem(BuildContext context, MediaItem mediaItem) {}

  void addMediaItemToPlaylist(BuildContext context, MediaItem mediaItem) {}

  void addBlogAudioToPlaylist(BuildContext context, Blog blog) {}

  Widget renderAudioPlaylistScreen() => const SizedBox();

  Widget getAudioBlogCard(
    Blog blog, {
    ValueChanged<Blog>? addAll,
    ValueChanged<MediaItem>? addItem,
    ValueChanged<MediaItem>? playItem,
  }) =>
      const SizedBox();

  Widget renderWalletPayPartialPayment() => const SizedBox();
  Widget renderCheckoutWalletInfo() => const SizedBox();
  Widget renderWalletPaymentMethodItem(PaymentMethod paymentMethod,
          Function(String? p1) onSelected, String? selectedId) =>
      const SizedBox();
  dynamic getWalletRoutesWithSettings(RouteSettings settings) => {};
  dynamic getWalletTransaction(String cookie) => null;
}
