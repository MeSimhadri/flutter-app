import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/index.dart' show Product;
import '../../modules/dynamic_layout/config/product_config.dart';
import 'action_button_mixin.dart';
import 'index.dart'
    show
        CartIcon,
        HeartButton,
        ProductImage,
        ProductOnSale,
        ProductPricing,
        ProductTitle;

class ProductGlass extends StatelessWidget with ActionButtonMixin {
  final Product item;
  final double? width;
  final double? maxWidth;
  final offset;
  final ProductConfig config;
  const ProductGlass({
    required this.item,
    this.width,
    this.maxWidth,
    this.offset,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    Widget _productImage = Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius:
              BorderRadius.circular(((config.borderRadius ?? 3) * 0.7)),
          child: Stack(
            children: [
              ProductImage(
                width: width!,
                product: item,
                config: config,
                ratioProductImage: config.imageRatio,
                offset: offset,
                onTapProduct: () => onTapProduct(context, product: item),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: ProductOnSale(
                  product: item,
                  config: config,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(config.borderRadius ?? 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget _productInfo = Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ProductTitle(product: item, hide: config.hideTitle),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: ProductPricing(product: item, hide: config.hidePrice),
            ),
            CartIcon(
              config: config,
              quantity: 1,
              product: item,
            ),
          ],
        )
      ],
    );

    return GestureDetector(
      onTap: () => onTapProduct(context, product: item),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth ?? width!),
            margin: EdgeInsets.symmetric(
              horizontal: config.hMargin,
              vertical: config.vMargin,
            ),
            width: width!,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(config.borderRadius ?? 3),
              child: Container(
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      Theme.of(context).cardColor,
                      Theme.of(context).primaryColor.withOpacity(0.5),
                      Theme.of(context).backgroundColor,
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Container(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _productImage,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (config.borderRadius ?? 6) * 0.25,
                        ),
                        child: _productInfo,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (config.showHeart && !item.isEmptyProduct())
            Positioned(
              top: 5,
              right: 5,
              child: HeartButton(product: item, size: 18),
            )
        ],
      ),
    );
  }
}
