import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../../menu/maintab_delegate.dart';
import '../../models/index.dart' show BackDropArguments, CartModel, Product;
import '../../routes/flux_navigate.dart';
import '../../screens/cart/widgets/coupon_list.dart';
import '../../screens/detail/product_detail_screen.dart';
import '../../screens/index.dart';
import '../../services/index.dart';
import '../../services/services.dart';
import '../../widgets/blog/banner/blog_list_view.dart';
import '../../widgets/common/webview.dart';
import '../constants.dart';
import '../tools.dart';

class NavigateTools {
  static Future onTapNavigateOptions(
      {BuildContext? context,
      required Map config,
      List<Product>? products}) async {
    /// support to show the product detail
    if (config['product'] != null) {
      /// for pre-load the product detail
      final _service = Services();
      var product = await _service.api.getProduct(config['product']);

      return Navigator.push(
          context!,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                ProductDetailScreen(product: product),
            fullscreenDialog: true,
          ));
    }
    if (config['tab'] != null) {
      return MainTabControlDelegate.getInstance().changeTab(config['tab']);
    }
    if (config['screen'] != null) {
      return Navigator.of(context!).pushNamed(config['screen']);
    }

    /// Launch the URL from external
    if (config['url_launch'] != null) {
      await launch(config['url_launch']);
    }

    /// support to show blog detail
    if (config['blog'] != null) {
      final id = config['blog'].toString();
      return Navigator.of(context!).pushNamed(
        RouteList.detailBlog,
        arguments: BlogDetailArguments(id: id),
      );
    }

    /// support to show blog category
    if (config['blog_category'] != null) {
      return Navigator.push(
        context!,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              BlogListView(id: config['blog_category'].toString()),
          fullscreenDialog: true,
        ),
      );
    }

    if (config['coupon'] != null) {
      return Navigator.of(context!).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => CouponList(
            couponCode: config['coupon'].toString(),
            onSelect: (String couponCode) async {
              final _sharedPrefs = await SharedPreferences.getInstance();

              await _sharedPrefs.setString('saved_coupon', couponCode);
              Provider.of<CartModel>(context, listen: false).loadSavedCoupon();

              Tools.showSnackBar(Scaffold.of(context),
                  S.of(context).couponHasBeenSavedSuccessfully);
            },
          ),
        ),
      );
    }

    /// Navigate to vendor store on Banner Image
    if (config['vendor'] != null) {
      await Navigator.of(context!).push(
        MaterialPageRoute(
          builder: (context) =>
              Services().widget.renderVendorScreen(config['vendor']),
        ),
      );
      return;
    }

    /// support to show the post detail
    if (config['url'] != null) {
      await Navigator.push(
        context!,
        MaterialPageRoute(
          builder: (context) => WebView(
              url: config['url'],
            ),
        ),
      );
    } else {
      /// For static image
      if (config['category'] == null &&
          config['tag'] == null &&
          products == null &&
          config['location'] == null) {
        return;
      }

      /// Default navigate to show the list products
      await FluxNavigate.pushNamed(
        RouteList.backdrop,
        arguments: BackDropArguments(
          config: config,
          data: products,
        ),
      );
    }
  }

  static void onTapOpenDrawerMenu(BuildContext context) {
    eventBus.fire(const EventDrawerSettings());
    if (isDisplayDesktop(context)) {
      eventBus.fire(const EventSwitchStateCustomDrawer());
    } else {
      eventBus.fire(const EventOpenNativeDrawer());
    }
  }

  static void navigateHome(BuildContext context) {
    navigateToRootTab(context, RouteList.home);
  }

  static void navigateToRootTab(BuildContext context, String name) {
    Navigator.popUntil(context, (route) => route.isFirst);
    MainTabControlDelegate.getInstance().changeTab(name);
  }
}
