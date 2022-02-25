import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/utils.dart' show printLog;
import 'package:share/share.dart';

import '../../common/config.dart';
import '../../common/constants.dart' show RouteList, printLog;
import '../../models/entities/back_drop_arguments.dart';
import '../../models/entities/store_arguments.dart';
import '../../routes/flux_navigate.dart';
import '../../screens/blog/views/blog_detail_screen.dart';
import '../../services/index.dart';

class DynamicLinkService {
  final _service = Services();

  DynamicLinkParameters dynamicLinkParameters({required String url}) {
    return DynamicLinkParameters(
      uriPrefix: firebaseDynamicLinkConfig['uriPrefix'],
      link: Uri.parse(url),
      androidParameters: AndroidParameters(
        packageName: firebaseDynamicLinkConfig['androidPackageName'],
        minimumVersion: firebaseDynamicLinkConfig['androidAppMinimumVersion'],
      ),
      iosParameters: IosParameters(
        bundleId: firebaseDynamicLinkConfig['iOSBundleId'],
        minimumVersion: firebaseDynamicLinkConfig['iOSAppMinimumVersion'],
        appStoreId: firebaseDynamicLinkConfig['iOSAppStoreId'],
      ),
    );
  }

  Future<Uri> generateFirebaseDynamicLink(DynamicLinkParameters params) async {
    if (firebaseDynamicLinkConfig['shortDynamicLinkEnable'] ?? false) {
      final shortDynamicLink = await params.buildShortLink();
      return shortDynamicLink.shortUrl;
    } else {
      return await params.buildUrl();
    }
  }

  static void initDynamicLinks(BuildContext context) async {
    // A listener for link callbacks when the app is in background calling
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final deepLink = dynamicLink?.link;

      if (deepLink != null) {
        printLog('[firebase-dynamic-link] onLink: $deepLink');
        await handleDynamicLink(deepLink.toString(), context);
      }
    }, onError: (OnLinkErrorException e) async {
      printLog('[firebase-dynamic-link] error: ${e.message}');
    });
    // the getInitialLink() gets the link that opened the app (or null if it was not opened via a dynamic link)
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    final deepLink = data?.link;

    if (deepLink != null) {
      printLog('[firebase-dynamic-link] getInitialLink: $deepLink');
      await handleDynamicLink(deepLink.toString(), context);
    }
  }

  //Navigate to ProductDetail screen by entering productURL
  static Future<void> handleDynamicLink(
      String url, BuildContext context) async {
    try {
      /// PRODUCT CASE
      if (url.contains('/product/')) {
        /// Note: the deepLink URL will look like: https://mstore.io/product/stitch-detail-tunic-dress/
        final product = await Services().api.getProductByPermalink(url);
        if (product != null) {
          await FluxNavigate.pushNamed(
            RouteList.productDetail,
            arguments: product,
          );
        }

        /// PRODUCT CATEGORY CASE
      } else if (url.contains('/product-category/')) {
        final category =
            await Services().api.getProductCategoryByPermalink(url);
        if (category != null) {
          await FluxNavigate.pushNamed(
            RouteList.backdrop,
            arguments: BackDropArguments(
              cateId: category.id,
              cateName: category.name,
            ),
          );
        }

        /// VENDOR CASE
      } else if (url.contains('/store/')) {
        final vendor = await Services().api.getStoreByPermalink(url);
        if (vendor != null) {
          await Navigator.pushNamed(
            context,
            RouteList.storeDetail,
            arguments: StoreDetailArgument(store: vendor),
          );
        }
      } else {
        var blog = await Services().api.getBlogByPermalink(url);
        if (blog != null) {
          await FluxNavigate.pushNamed(
            RouteList.detailBlog,
            arguments: BlogDetailArguments(
              blog: blog,
            ),
          );
        }
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dynamic Link error: ${err.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// share product link that contains Dynamic link
  void shareProductLink({
    required String productUrl,
  }) async {
    var productParams = dynamicLinkParameters(url: productUrl);
    var firebaseDynamicLink = await generateFirebaseDynamicLink(productParams);
    printLog('[firebase-dynamic-link] $firebaseDynamicLink');
    await Share.share(
      firebaseDynamicLink.toString(),
    );
  }

  Future<String> generateProductCategoryUrl(dynamic productCategoryId) async {
    final cate = await _service.api
        .getProductCategoryById(categoryId: productCategoryId);
    var url;
    if (cate != null) {
      url = serverConfig['url'] + '/product-category/' + cate.slug;
    }
    return url;
  }
}
