import 'package:flutter/material.dart';

import '../../../services/index.dart';
import '../config/product_config.dart';
import '../helper/custom_physic.dart';
import '../helper/helper.dart';

class ProductGrid extends StatelessWidget {
  final products;
  final maxWidth;
  final ProductConfig config;

  const ProductGrid({
    required Key key,
    required this.products,
    required this.maxWidth,
    required this.config,
  }) : super(key: key);

  double getGridRatio() {
    switch (config.layout) {
      case Layout.twoColumn:
        return 1.5;
      case Layout.threeColumn:
      default:
        return 1.7;
    }
  }

  double getHeightRatio() {
    switch (config.layout) {
      case Layout.twoColumn:
        return 1.7;
      case Layout.threeColumn:
      default:
        return 1.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (products == null) {
      return const SizedBox();
    }
    var _ratioProductImage = config.imageRatio;
    const padding = 12.0;
    var width = maxWidth - padding;
    var _rows = config.rows;
    var _productHeight = Layout.buildProductHeight(
      layout: config.layout,
      defaultHeight: maxWidth,
    );

    return Container(
      color: Theme.of(context).backgroundColor,
      padding: const EdgeInsets.only(left: padding),
      height: _rows * _productHeight * getHeightRatio(),
      child: GridView.count(
        childAspectRatio: _ratioProductImage * getGridRatio(),
        scrollDirection: Axis.horizontal,
        physics: config.isSnapping ?? false
            ? CustomScrollPhysic(
                width: Layout.buildProductWidth(
                    screenWidth: width / _ratioProductImage, layout: config.layout))
            : const ScrollPhysics(),
        crossAxisCount: _rows,
        children: List.generate(products.length, (i) {
          return Services().widget.renderProductCardView(
                item: products[i],
                width: Layout.buildProductWidth(
                    screenWidth: width, layout: config.layout),
                maxWidth: Layout.buildProductMaxWidth(layout: config.layout),
                height: _productHeight,
                ratioProductImage: _ratioProductImage,
                config: config,
              );
        }),
      ),
    );
  }
}
