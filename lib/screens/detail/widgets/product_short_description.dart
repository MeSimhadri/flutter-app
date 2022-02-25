import 'package:flutter/material.dart';

import '../../../models/index.dart' show Product;
import '../../../widgets/html/index.dart' as html;

class ProductShortDescription extends StatelessWidget {
  final Product product;

  const ProductShortDescription(this.product);

  @override
  Widget build(BuildContext context) {
    if (product.shortDescription?.isEmpty ?? true) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: html.HtmlWidget(
        product.shortDescription!,
      ),
    );
  }
}
