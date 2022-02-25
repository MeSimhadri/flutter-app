import 'package:flutter/material.dart';

import '../../../common/config.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Product;
import '../../../services/index.dart';
import '../../../widgets/common/expansion_info.dart';
import 'additional_information.dart';
import 'review.dart';

class ProductDescription extends StatelessWidget {
  final Product? product;

  const ProductDescription(this.product);

  bool get enableBrand => kProductDetail.showBrand;

  bool get enableReview => kProductDetail.enableReview;

  String get brand {
    final brands = product!.infors.where((element) => element.name == 'Brand');
    if (brands.isEmpty) return 'Unknown';
    return brands.first.options?.first ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        if (product!.description != null && product!.description!.isNotEmpty)
          ExpansionInfo(
            title: S.of(context).description,
            expand: true,
            children: <Widget>[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Services()
                    .widget
                    .renderProductDescription(context, product!.description!),
              ),
              const SizedBox(height: 20),
            ],
          ),
        if (enableBrand) ...[
          buildBrand(context),
        ],
        if (enableReview)
          ExpansionInfo(
            title: S.of(context).readReviews,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Reviews(
                  product!.id,
                  allowRating: false,
                ),
              ),
            ],
          ),
        if (product!.infors.isNotEmpty)
          ExpansionInfo(
            expand: true,
            title: S.of(context).additionalInformation,
            children: <Widget>[
              AdditionalInformation(
                listInfo: product!.infors,
              ),
            ],
          ),
      ],
    );
  }

  Widget buildBrand(context) {
    if (brand == 'Unknown') {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).brand,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            brand,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
