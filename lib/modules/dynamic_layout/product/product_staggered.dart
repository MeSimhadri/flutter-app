import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../models/index.dart' show Product;
import '../../../widgets/product/product_card_view.dart';
import '../config/product_config.dart';

List<StaggeredTile> _staggeredTiles = const <StaggeredTile>[
  StaggeredTile.count(2, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(3, 2),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(1, 1),
];

class ProductStaggered extends StatelessWidget {
  final List<Product>? products;
  final double width;

  const ProductStaggered({required Key key, this.products, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? _size = width / 3;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.only(left: 15.0),
      height: screenSize.height * 0.8 / (screenSize.height / width),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 3,
        scrollDirection: Axis.horizontal,
        itemCount: products!.length,
        itemBuilder: (context, index) {
          return Center(
            child: ProductCard(
              width: _size * _staggeredTiles[index % 6].mainAxisCellCount!,
              item: products![index],
              hideDetail: true,
              config: ProductConfig.empty(),
            ),
          );
        },
        staggeredTileBuilder: (int index) => _staggeredTiles[index % 6],
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
    );
  }
}
