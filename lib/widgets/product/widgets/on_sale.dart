import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/tools/price_tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/product.dart';
import '../../../models/index.dart' show AppModel, Product;
import '../../../modules/dynamic_layout/config/product_config.dart';

class ProductOnSale extends StatelessWidget {
  final Product product;
  final ProductConfig config;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;

  const ProductOnSale({
    Key? key,
    required this.product,
    required this.config,
    this.padding,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? regularPrice = 0.0;
    final currency = Provider.of<AppModel>(context, listen: false).currencyCode;
    var salePercent = 0;

    if (product.regularPrice != null &&
        product.regularPrice!.isNotEmpty &&
        product.regularPrice != '0.0') {
      regularPrice = (double.tryParse(product.regularPrice.toString()));
    }

    /// Calculate the Sale price
    var isSale = (product.onSale ?? false) &&
        PriceTools.getPriceProductValue(product, currency, onSale: true) !=
            PriceTools.getPriceProductValue(product, currency, onSale: false);
    if (isSale && regularPrice != 0) {
      salePercent = (double.parse(product.salePrice!) - regularPrice!) *
          100 ~/
          regularPrice;
    }

    if (isSale &&
        (product.regularPrice?.isNotEmpty ?? false) &&
        regularPrice != null &&
        regularPrice != 0.0 &&
        product.type != 'variable') {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: config.hMargin,
          vertical: config.vMargin / 2,
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: decoration ??
            BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(config.borderRadius ?? 0.0),
                bottomRight: const Radius.circular(12),
              ),
            ),
        child: Text(
          '$salePercent%',
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )
              .apply(fontSizeFactor: 0.9),
        ),
      );
    }

    if (isSale && product.type == 'variable') {
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: config.hMargin,
            vertical: config.vMargin / 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(config.borderRadius ?? 0.0),
              bottomRight: Radius.circular(config.borderRadius ?? 9),
            ),
          ),
          child: Text(
            S.of(context).onSale,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
