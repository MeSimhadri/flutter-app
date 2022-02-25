import 'package:flutter/material.dart';

import '../../../common/theme/colors.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Product;
import '../../../modules/dynamic_layout/config/product_config.dart';

class StockStatus extends StatelessWidget {
  final Product product;
  final ProductConfig config;

  const StockStatus({
    Key? key,
    required this.product,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (config.showStockStatus) {
      if (product.backOrdered) {
        return Text(
          S.of(context).backOrder,
          style: const TextStyle(
            color: kColorBackOrder,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        );
      }

      if (product.inStock != null && !product.isEmptyProduct()) {
        return Text(
          product.inStock! ? S.of(context).inStock : S.of(context).outOfStock,
          style: TextStyle(
            color: product.inStock! ? kColorInStock : kColorOutOfStock,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        );
      }
    }
    return const SizedBox();
  }
}
