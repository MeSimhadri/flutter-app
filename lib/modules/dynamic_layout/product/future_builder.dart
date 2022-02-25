import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../models/index.dart' show AppModel, Product, RecentModel;
import '../../../models/user_model.dart';
import '../../../services/index.dart';
import '../config/product_config.dart';
import '../helper/helper.dart';
import 'product_empty.dart';

/// Handle the product network request, caching and empty product
class ProductFutureBuilder extends StatefulWidget {
  final ProductConfig config;
  final Function child;
  final Widget? waiting;
  final bool cleanCache;

  const ProductFutureBuilder({
    required this.config,
    this.waiting,
    required this.child,
    this.cleanCache = false,
    Key? key,
  }) : super(key: key);

  @override
  _ProductListLayoutState createState() => _ProductListLayoutState();
}

class _ProductListLayoutState extends State<ProductFutureBuilder> {
  final Services _service = Services();

  late Future<List<Product>?> _getProductLayout;

  final AsyncMemoizer<List<Product>?> _memoizer =
      AsyncMemoizer<List<Product>?>();

  @override
  void initState() {
    /// only create the future once
    _getProductLayout = getProductLayout(context);
    super.initState();
  }

  Future<List<Product>?> getProductLayout(context) {
    return _memoizer.runOnce(
      () {
        // final startTime = DateTime.now();
        if (widget.config.layout == Layout.recentView) {
          return Provider.of<RecentModel>(context, listen: false)
              .getRecentProduct();
        }
        if (widget.config.layout == Layout.saleOff) {
          /// Fetch only onSale products for saleOff layout.
          widget.config.onSale = true;
        }
        final _userId = Provider.of<UserModel>(context, listen: false).user?.id;

        var _result = _service.api.fetchProductsLayout(
          config: widget.config.jsonData,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          userId: _userId,
          refreshCache: widget.cleanCache,
        );
        // printLog('[getProductLayout]', startTime);
        return _result;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentProduct = Provider.of<RecentModel>(context).products;
    final isRecentLayout = widget.config.layout == Layout.recentView;
    final isSaleOffLayout = widget.config.layout == Layout.saleOff;
    if (isRecentLayout && recentProduct.length < 3) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraint) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: FutureBuilder<List<Product>?>(
            future: _getProductLayout,
            builder:
                (BuildContext context, AsyncSnapshot<List<Product>?> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  if (widget.waiting != null) return widget.waiting!;

                  return widget.config.layout == Layout.listTile
                      ? EmptyProductTile(maxWidth: constraint.maxWidth)
                      : widget.config.rows > 1
                          ? EmptyProductGrid(
                              config: widget.config,
                              maxWidth: constraint.maxWidth,
                            )
                          : EmptyProductList(
                              config: widget.config,
                              maxWidth: constraint.maxWidth,
                            );
                case ConnectionState.done:
                default:
                  if (snapshot.hasError || snapshot.data == null) {
                    return const SizedBox();
                  }

                  /// Hide sale off layout when product list is empty.
                  if (snapshot.data!.isEmpty &&
                      isSaleOffLayout &&
                      (kSaleOffProduct['HideEmptySaleOffLayout'] ?? false)) {
                    return const SizedBox();
                  }

                  return widget.child(
                    maxWidth: constraint.maxWidth,
                    products: snapshot.data as List<Product>,
                  );
              }
            },
          ),
        );
      },
    );
  }
}
