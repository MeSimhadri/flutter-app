import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_base.dart';
import '../../models/entities/product.dart';
import '../../models/entities/product_variation.dart';
import '../../models/recent_product_model.dart';
import '../../routes/flux_navigate.dart';
import '../../services/service_config.dart';
import 'dialog_add_to_cart.dart';

mixin ActionButtonMixin {
  void onTapProduct(context, {required Product product}) {
    if (product.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(product);
    FluxNavigate.pushNamed(
      RouteList.productDetail,
      arguments: product,
    );
  }

  void _showFlashNotification(Product? product, String message, context) {
    if (message.isNotEmpty) {
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        persistent: !Config().isBuilder,
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).errorColor,
            controller: controller,
            behavior: FlashBehavior.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              content: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );
    } else {
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        persistent: !Config().isBuilder,
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).primaryColor,
            controller: controller,
            behavior: FlashBehavior.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              title: Text(
                product!.name!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
              content: Text(
                S.of(context).addToCartSucessfully,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void addToCart(
    BuildContext context, {
    int quantity = 1,
    bool enableBottomAddToCart = false,
    required Product product,
  }) {
    final String Function({
      dynamic context,
      dynamic isSaveLocal,
      Function notify,
      Map<String, dynamic> options,
      Product? product,
      int quantity,
      ProductVariation variation,
    }) addProductToCart =
        Provider.of<CartModel>(context, listen: false).addProductToCart;
    if (enableBottomAddToCart) {
      DialogAddToCart.show(context, product: product, quantity: quantity);
    } else {
      var message = addProductToCart(
        product: product,
        context: context,
        quantity: quantity,
      );
      _showFlashNotification(product, message, context);
    }
  }

  void updateQuantity({
    required Product product,
    required int quantity,
    required BuildContext context,
  }) =>
      Provider.of<CartModel>(context, listen: false)
          .updateQuantity(product, product.id!, quantity);
}
