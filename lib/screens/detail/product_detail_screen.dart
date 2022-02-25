import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Product, ProductWishListModel;
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../base_screen.dart';
import 'widgets/image_galery.dart';

export 'themes/full_size_image_type.dart';
export 'themes/half_size_image_type.dart';
export 'themes/simple_type.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  final String? id;

  const ProductDetailScreen({this.product, this.id});

  static void showMenu(BuildContext context, Product? product,
      {bool isLoading = false}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  title:
                      Text(S.of(context).myCart, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    FluxNavigate.pushNamed(
                      RouteList.cart,
                      forceRootNavigator: true,
                    );
                  }),
              ListTile(
                  title: Text(S.of(context).showGallery,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return ImageGalery(images: product?.images, index: 0);
                        });
                  }),
              if (!isLoading && product != null)
                ListTile(
                    title: Text(S.of(context).saveToWishList,
                        textAlign: TextAlign.center),
                    onTap: () {
                      Provider.of<ProductWishListModel>(context, listen: false)
                          .addToWishlist(product);
                      Navigator.of(context).pop();
                    }),

              /// Share feature not supported in Strapi.
              if (!Config().isStrapi && !Config().isNotion)
                ListTile(
                    title:
                        Text(S.of(context).share, textAlign: TextAlign.center),
                    onTap: () {
                      Services().firebase.shareDynamicLinkProduct(
                            context: context,
                            itemUrl: product?.permalink,
                          );
                    }),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).cancel,
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends BaseScreen<ProductDetailScreen> {
  Product? product;
  bool isLoading = true;

  @override
  Future<void> afterFirstLayout(BuildContext context) async {}

  @override
  void initState() {
    Future.microtask(() async {
      if (widget.product is Product) {
        /// Get more detail info from product
        setState(() {
          product = widget.product;
        });
        product = await Services().widget.getProductDetail(context, product);
      } else {
        /// Request the product by Product ID which is using for web param
        product = await Services().api.getProduct(widget.id);
      }
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const SizedBox();
    }

    var layoutType = Provider.of<AppModel>(context).productDetailLayout;

    var layout = Services().widget.renderDetailScreen(
          context,
          product!,
          layoutType,
          isLoading,
        );

    return GestureDetector(
      onTap: () {
        var currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: layout,
    );
  }
}
