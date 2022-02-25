import '../../tools.dart';

class ProductDetailConfig {
  late final double height;
  late final double marginTop;
  late final bool safeArea;
  late final bool showVideo;
  late final int showThumbnailAtLeast;
  late final String layout;
  late final double borderRadius;
  late final bool showSelectedImageVariant;
  late final bool forceWhiteBackground;
  late final bool autoSelectFirstAttribute;
  late final bool enableReview;
  late final double attributeImagesSize;
  late final bool showSku;
  late final bool showStockQuantity;
  late final bool showProductCategories;
  late final bool showProductTags;
  late final bool hideInvalidAttributes;
  late final bool autoPlayGallery;
  late final bool allowMultiple;
  late final bool showBrand;
  late final bool showQuantityInList;
  late final bool showAddToCartInSearchResult;
  late final num productListItemHeight;

  ProductDetailConfig({
    required this.height,
    required this.marginTop,
    required this.safeArea,
    required this.showVideo,
    required this.showThumbnailAtLeast,
    required this.layout,
    required this.borderRadius,
    required this.showSelectedImageVariant,
    required this.forceWhiteBackground,
    required this.autoSelectFirstAttribute,
    required this.enableReview,
    required this.attributeImagesSize,
    required this.showSku,
    required this.showStockQuantity,
    required this.showProductCategories,
    required this.showProductTags,
    required this.hideInvalidAttributes,
    required this.autoPlayGallery,
    required this.allowMultiple,
    required this.showBrand,
    required this.showQuantityInList,
    required this.showAddToCartInSearchResult,
    required this.productListItemHeight,
  });

  ProductDetailConfig.fromJson(Map config) {
    height = Tools.formatDouble(config['height']) ?? 0.4;
    marginTop = Tools.formatDouble(config['marginTop']) ?? 0.0;
    safeArea = config['safeArea'] ?? false;
    showVideo = config['showVideo'] ?? true;
    showThumbnailAtLeast = config['showThumbnailAtLeast'] ?? 1;
    layout = config['layout'] ?? 'simpleType';
    borderRadius = Tools.formatDouble(config['borderRadius']) ?? 3.0;
    showSelectedImageVariant = config['ShowSelectedImageVariant'] ?? true;
    forceWhiteBackground = config['ForceWhiteBackground'] ?? false;
    autoSelectFirstAttribute = config['AutoSelectFirstAttribute'] ?? true;
    enableReview = config['enableReview'] ?? false;
    attributeImagesSize =
        Tools.formatDouble(config['attributeImagesSize']) ?? 50.0;
    showSku = config['showSku'] ?? true;
    showStockQuantity = config['showStockQuantity'] ?? true;
    showProductCategories = config['showProductCategories'] ?? true;
    showProductTags = config['showProductTags'] ?? true;
    hideInvalidAttributes = config['hideInvalidAttributes'] ?? false;
    autoPlayGallery = config['autoPlayGallery'] ?? false;
    allowMultiple = config['allowMultiple'] ?? false;
    showBrand = config['showBrand'] ?? false;
    showQuantityInList = config['showQuantityInList'] ?? false;
    showAddToCartInSearchResult =
        config['showAddToCartInSearchResult'] ?? false;
    productListItemHeight = config['productListItemHeight'] ?? 125;
  }

  ProductDetailConfig copyWith({
    double? height,
    double? marginTop,
    bool? safeArea,
    bool? showVideo,
    int? showThumbnailAtLeast,
    String? layout,
    double? borderRadius,
    bool? showSelectedImageVariant,
    bool? forceWhiteBackground,
    bool? autoSelectFirstAttribute,
    bool? enableReview,
    double? attributeImagesSize,
    bool? showSku,
    bool? showStockQuantity,
    bool? showProductCategories,
    bool? showProductTags,
    bool? hideInvalidAttributes,
    bool? autoPlayGallery,
    bool? allowMultiple,
    bool? showBrand,
    bool? showQuantityInList,
    bool? showAddToCartInSearchResult,
    num? productListItemHeight,
  }) {
    return ProductDetailConfig(
      height: height ?? this.height,
      marginTop: marginTop ?? this.marginTop,
      safeArea: safeArea ?? this.safeArea,
      showVideo: showVideo ?? this.showVideo,
      showThumbnailAtLeast: showThumbnailAtLeast ?? this.showThumbnailAtLeast,
      layout: layout ?? this.layout,
      borderRadius: borderRadius ?? this.borderRadius,
      showSelectedImageVariant:
          showSelectedImageVariant ?? this.showSelectedImageVariant,
      forceWhiteBackground: forceWhiteBackground ?? this.forceWhiteBackground,
      autoSelectFirstAttribute:
          autoSelectFirstAttribute ?? this.autoSelectFirstAttribute,
      enableReview: enableReview ?? this.enableReview,
      attributeImagesSize: attributeImagesSize ?? this.attributeImagesSize,
      showSku: showSku ?? this.showSku,
      showStockQuantity: showStockQuantity ?? this.showStockQuantity,
      showProductCategories:
          showProductCategories ?? this.showProductCategories,
      showProductTags: showProductTags ?? this.showProductTags,
      hideInvalidAttributes:
          hideInvalidAttributes ?? this.hideInvalidAttributes,
      autoPlayGallery: autoPlayGallery ?? this.autoPlayGallery,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      showBrand: showBrand ?? this.showBrand,
      showQuantityInList: showQuantityInList ?? this.showQuantityInList,
      showAddToCartInSearchResult:
          showAddToCartInSearchResult ?? this.showAddToCartInSearchResult,
      productListItemHeight:
          productListItemHeight ?? this.productListItemHeight,
    );
  }

  Map toJSon() {
    return {
      'height': height,
      'marginTop': marginTop,
      'safeArea': safeArea,
      'showVideo': showVideo,
      'showThumbnailAtLeast': showThumbnailAtLeast,
      'layout': layout,
      'borderRadius': borderRadius,
      'ShowSelectedImageVariant': showSelectedImageVariant,
      'ForceWhiteBackground': forceWhiteBackground,
      'AutoSelectFirstAttribute': autoSelectFirstAttribute,
      'enableReview': enableReview,
      'attributeImagesSize': attributeImagesSize,
      'showSku': showSku,
      'showStockQuantity': showStockQuantity,
      'showProductCategories': showProductCategories,
      'showProductTags': showProductTags,
      'hideInvalidAttributes': hideInvalidAttributes,
      'autoPlayGallery': autoPlayGallery,
      'allowMultiple': allowMultiple,
      'showBrand': showBrand,
      'showQuantityInList': showQuantityInList,
      'showAddToCartInSearchResult': showAddToCartInSearchResult,
      'productListItemHeight': productListItemHeight,
    };
  }
}
