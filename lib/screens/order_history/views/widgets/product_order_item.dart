import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../common/constants.dart';
import '../../../../common/tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/store_delivery_date.dart';
import '../../../../models/index.dart';
import '../../../../services/index.dart';
import '../../../../widgets/html/index.dart';
import '../../../detail/widgets/review.dart';
import '../../../index.dart';

class ProductOrderItem extends StatefulWidget {
  final String orderId;
  final OrderStatus orderStatus;
  final ProductItem product;
  final List<StoreDeliveryDate>? storeDeliveryDates;

  /// For prestashop.
  final int index;

  const ProductOrderItem({
    required this.orderId,
    required this.orderStatus,
    required this.product,
    this.storeDeliveryDates,
    this.index = 0,
  });

  @override
  _StateProductOrderItem createState() => _StateProductOrderItem();
}

class _StateProductOrderItem extends BaseScreen<ProductOrderItem> {
  Product? product;
  late String imageFeatured = kDefaultImage;
  bool isLoading = true;

  @override
  void afterFirstLayout(BuildContext context) async {
    super.afterFirstLayout(context);

    if (widget.product.featuredImage == null) {
      var _product = await Services().api.getProduct(
            widget.product.productId,
          );
      if (_product != null) {
        setState(() {
          product = _product;
          imageFeatured = product!.imageFeature ?? kDefaultImage;
        });
      }
    } else {
      setState(() {
        imageFeatured = widget.product.featuredImage ?? kDefaultImage;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void navigateToProductDetail() async {
    if (product == null) {
      final _product =
          await Services().api.getProduct(widget.product.productId);
      setState(() {
        product = _product;
      });
    }
    await Navigator.of(context).pushNamed(
      RouteList.productDetail,
      arguments: product,
    );
  }

  Widget _buildItemDesc(String title, String content) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 3.0,
        vertical: 3.0,
      ),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 8,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          Text(
            content,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: false);
    final currency = appModel.currency;
    final currencyRate = appModel.currencyRate;
    final _addonsOptions = (widget.product.addonsOptions ?? '')
        .split(', ')
        .map(Tools.getFileNameFromUrl)
        .join(', ');

    var _deliveryDate;
    if (widget.storeDeliveryDates != null &&
        widget.storeDeliveryDates!.isNotEmpty) {
      var _storeIndex = widget.storeDeliveryDates!
          .indexWhere((element) => element.storeId == widget.product.storeId);

      if (_storeIndex != -1) {
        _deliveryDate = widget.storeDeliveryDates![_storeIndex].displayDDate;
      }
    }

    return Column(
      children: [
        GestureDetector(
          onTap: navigateToProductDetail,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'image-' + widget.orderId + widget.product.productId!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.withOpacity(0.2),
                    child: isLoading
                        ? const Skeleton(
                            width: 80,
                            height: 80,
                          )
                        : ImageTools.image(
                            url: imageFeatured,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name!,
                      style: Theme.of(context).textTheme.subtitle1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            S
                                .of(context)
                                .qtyTotal(widget.product.quantity ?? ''),
                          ),
                        ),
                        if (widget.orderStatus == OrderStatus.completed)
                          if (!kPaymentConfig['EnableShipping'] ||
                              !kPaymentConfig['EnableAddress'])
                            DownloadButton(widget.product.productId),
                      ],
                    ),
                    if (widget.product.addonsOptions?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: HtmlWidget(
                          _addonsOptions,
                        ),
                      ),
                    if (widget.product.prodOptions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ProductOptions(
                            prodOptions: widget.product.prodOptions),
                      ),
                    if (widget.product.storeName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          widget.product.storeName ?? '',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// Review for completed order only.
        if (widget.orderStatus == OrderStatus.completed)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Reviews(
              widget.product.productId,
              showYourRatingOnly: true,
            ),
          ),
        const SizedBox(height: 5),
        _buildItemDesc(
            S.of(context).itemTotal,
            PriceTools.getCurrencyFormatted(
              widget.product.total,
              currencyRate,
              currency: currency,
            )!),
        if (_deliveryDate != null) ...[
          const SizedBox(height: 2),
          _buildItemDesc(S.of(context).deliveryDate, _deliveryDate),
        ],

        const SizedBox(height: 10),
      ],
    );
  }
}

class DownloadButton extends StatefulWidget {
  final String? id;

  const DownloadButton(this.id);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final services = Services();
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
      onPressed: isLoading
          ? null
          : () async {
              try {
                setState(() {
                  isLoading = true;
                });

                var product = await services.api.getProduct(widget.id);
                setState(() {
                  isLoading = false;
                });

                if (product?.files?.isEmpty ?? true) {
                  throw Exception(S.of(context).noFileToDownload);
                }

                await Tools.launchURL(product!.files!.first!);
              } catch (err) {
                Tools.showSnackBar(Scaffold.of(context), '$err');
              } finally {
                if (isLoading) {
                  setState(() {
                    isLoading = false;
                  });
                }
              }
            },
      icon: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ),
            )
          : Icon(
              Icons.file_download,
              color: Theme.of(context).primaryColor,
            ),
      label: Text(
        S.of(context).download,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class ProductOptions extends StatelessWidget {
  final List<Map<String, dynamic>?> prodOptions;

  const ProductOptions({required this.prodOptions});

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    for (var option in prodOptions) {
      list.add(Row(
        children: [
          HtmlWidget(option!['name'] + ':'),
          const SizedBox(width: 10.0),
          Text(option['value']),
        ],
      ));
      list.add(const SizedBox(
        height: 5.0,
      ));
    }
    return Column(children: list);
  }
}
