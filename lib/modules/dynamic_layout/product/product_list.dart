import 'package:flutter/material.dart';

import '../../../models/index.dart' show Product, ProductModel;
import '../../../widgets/common/flux_image.dart';
import '../config/product_config.dart';
import '../helper/header_view.dart';
import '../helper/helper.dart';
import 'future_builder.dart';
import 'product_grid.dart';
import 'product_list_default.dart';
import 'product_list_tile.dart';
import 'product_staggered.dart';

class ProductList extends StatelessWidget {
  final ProductConfig config;
  final bool cleanCache;

  const ProductList({
    required this.config,
    required this.cleanCache,
    Key? key,
  }) : super(key: key);

  bool isShowCountDown() {
    final _isSaleOffLayout = config.layout == Layout.saleOff;
    return config.showCountDown && _isSaleOffLayout;
  }

  int getCountDownDuration(List<Product>? data,
      [bool isSaleOffLayout = false]) {
    if (isShowCountDown() && data!.isNotEmpty) {
      return (DateTime.tryParse(data.first.dateOnSaleTo ?? '')
                  ?.millisecondsSinceEpoch ??
              0) -
          (DateTime.now().millisecondsSinceEpoch);
    }
    return 0;
  }

  Widget getProductLayout({maxWidth, products}) {
    switch (config.layout) {
      case Layout.listTile:
        return ProductListTitle(
          products: products,
          config: config..showCountDown = isShowCountDown(),
        );
      case Layout.staggered:
        return ProductStaggered(
          key: UniqueKey(),
          products: products,
          width: maxWidth,
        );

      default:
        return config.rows > 1
            ? ProductGrid(
                key: UniqueKey(),
                maxWidth: maxWidth,
                products: products,
                config: config..showCountDown = isShowCountDown(),
              )
            : ProductListDefault(
                key: UniqueKey(),
                maxWidth: maxWidth,
                products: products,
                config: config..showCountDown = isShowCountDown(),
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _isRecentLayout = config.layout == Layout.recentView;
    final _isSaleOffLayout = config.layout == Layout.saleOff;

    return ProductFutureBuilder(
      config: config,
      cleanCache: cleanCache,
      child: ({maxWidth, products}) {
        final _duration = getCountDownDuration(products, _isSaleOffLayout);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (config.image != null && config.image != '')
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: FluxImage(
                  imageUrl: config.image!,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            HeaderView(
              headerText: config.name ?? '',
              showSeeAll: _isRecentLayout ? false : true,
              verticalMargin: config.image != null ? 6.0 : 10.0,
              callback: () => ProductModel.showList(
                context: context,
                config: config.jsonData,
                products: products,
                showCountdown: isShowCountDown() && _duration > 0,
                countdownDuration: Duration(milliseconds: _duration),
              ),
              showCountdown: isShowCountDown() && _duration > 0,
              countdownDuration: Duration(milliseconds: _duration),
            ),
            getProductLayout(maxWidth: maxWidth, products: products),
            // : ProductListWidgets(context, products, maxWidth),
          ],
        );
      },
    );
  }
}
