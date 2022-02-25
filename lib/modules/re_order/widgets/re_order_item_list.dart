import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/booking/booking_model.dart';
import '../../../models/cart/cart_model.dart';
import '../../../models/entities/index.dart';
import '../../../services/services.dart';

class ReOrderItemList extends StatefulWidget {
  final List<ProductItem> lineItems;
  const ReOrderItemList({Key? key, required this.lineItems}) : super(key: key);

  @override
  State<ReOrderItemList> createState() => _ReOrderItemListState();
}

class _ReOrderItemListState extends State<ReOrderItemList> {
  List<String> _errorMessages = [];
  List<BookingModel?> _bookingProducts = [];
  final _pageController = PageController();
  int _currentIndex = 0;
  @override
  void initState() {
    _errorMessages = List.generate(widget.lineItems.length, (index) => '');
    _bookingProducts = List.generate(widget.lineItems.length, (index) => null);
    super.initState();
  }

  void _selectDatesTapped(int index) {
    _pageController.jumpToPage(1);
    _currentIndex = index;
  }

  void _setBookingInfo(BookingModel bookingInfo) {
    _bookingProducts[_currentIndex] = bookingInfo;
    _pageController.jumpToPage(0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
              onTap: Navigator.of(context).pop,
              child: Text(
                S.of(context).cancel,
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).buttonTheme.colorScheme!.primary),
              )),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Flexible(
          child: PageView(
            controller: _pageController,
            children: [
              Column(
                children: [
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var _addonsOptions =
                            (widget.lineItems[index].addonsOptions ?? '')
                                .split(', ')
                                .map(Tools.getFileNameFromUrl)
                                .join(', ');

                        final _isBookingType =
                            widget.lineItems[index].product!.type ==
                                'appointment';
                        final _isBookingSet = _bookingProducts[index] != null;

                        if (_isBookingType) {
                          if (!_isBookingSet) {
                            _addonsOptions = '';
                          } else {
                            _addonsOptions =
                                '${_bookingProducts[index]!.month}/${_bookingProducts[index]!.day}/${_bookingProducts[index]!.year} ${DateFormat('jm', 'en').format(_bookingProducts[index]!.timeStart!)}';
                          }
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 120,
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey.withOpacity(0.2),
                                        child: ImageTools.image(
                                          url: widget
                                              .lineItems[index].featuredImage,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.lineItems[index].name ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  fontWeight: FontWeight.w700),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(
                                          S.of(context).qtyTotal(widget
                                              .lineItems[index].quantity!),
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(fontSize: 12.0),
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        if (_isBookingType)
                                          Flexible(
                                            child: GestureDetector(
                                              onTap: () {
                                                _selectDatesTapped(index);
                                              },
                                              child: Text(
                                                _isBookingSet
                                                    ? _addonsOptions
                                                    : S.of(context).selectDates,
                                                maxLines: 2,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                        fontSize: 12.0,
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                              ),
                                            ),
                                          ),
                                        if (!_isBookingType)
                                          Flexible(
                                            child: Text(
                                              _addonsOptions,
                                              maxLines: 2,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(fontSize: 12.0),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_errorMessages[index].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: _errorMessages[index] == 'added'
                                    ? Text(
                                        S.of(context).added,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                color: Colors.green,
                                                fontSize: 10.0),
                                      )
                                    : Text(
                                        _errorMessages[index],
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                color: Colors.red,
                                                fontSize: 10.0),
                                      ),
                              ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: widget.lineItems.length),
                  InkWell(
                    onTap: _addToCart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 5.0),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        S.of(context).confirm,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.lineItems[_currentIndex].product!.type ==
                  'appointment')
                CustomScrollView(
                  slivers: [
                    Services().getBookingLayout(
                        product: widget.lineItems[_currentIndex].product!,
                        onCallBack: _setBookingInfo)
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  ProductItem _addSelectedAddOnOptions(ProductItem productItem) {
    try {
      final _addonsOptions = (productItem.addonsOptions ?? '').split(', ');
      final _product = productItem.product;
      if (_product?.addOns != null &&
          _product!.addOns != null &&
          _product.addOns!.isNotEmpty) {
        _product.selectedOptions = [];

        for (var option in _addonsOptions) {
          var isSet = false;
          for (var addon in _product.addOns!) {
            final index = _product.selectedOptions!.indexWhere((element) {
              return element.fieldName == addon.fieldName;
            });
            if (index == -1) {
              final addonIndex = addon.options
                  ?.indexWhere((element) => element.label == option);
              if (addonIndex != null && addonIndex != -1) {
                _product.selectedOptions!.add(addon.options![addonIndex]);
                isSet = true;
              } else {
                final _addonsOption = AddonsOption.fromJson({
                  'parent': addon.name,
                  'label': Tools.getFileNameFromUrl(option),
                  'field_name': addon.fieldName,
                  'type': addon.type,
                  'display': addon.display,
                  'price': addon.price,
                });
                _product.selectedOptions!.add(_addonsOption);
                isSet = true;
              }
            }
            if (isSet) {
              break;
            }
          }
        }
        productItem.product = _product;
      }
      return productItem;
    } catch (e) {
      printLog(e);
    }
    return productItem;
  }

  Future<void> _addToCart() async {
    final _cartModel = Provider.of<CartModel>(context, listen: false);
    var _hasError = false;
    for (var i = 0; i < widget.lineItems.length; i++) {
      if (_errorMessages[i] == 'added') {
        continue;
      }
      final _productItem = _addSelectedAddOnOptions(widget.lineItems[i]);
      final product = _productItem.product!;
      ProductVariation? variation;
      var options = <String, dynamic>{};
      if (product.type == 'variable') {
        final addonsOptions = widget.lineItems[i].addonsOptions
                ?.split(',')
                .map((e) => e.trim()) ??
            [];

        variation = await Services().api.getVariationProduct(
            _productItem.product!.id, _productItem.variationId);

        for (var item in product.attributes ?? []) {
          for (var option in item.options ?? []) {
            if (addonsOptions.contains(option['name'].toLowerCase().trim())) {
              options[item.name] = option['name'];
              variation!.attributes.add(Attribute(
                  id: int.parse(
                    item.id.toString(),
                  ),
                  name: item.slug,
                  option: option['slug']));
              break;
            }
          }
        }
      }

      if (product.type == 'appointment' && _bookingProducts[i] == null) {
        _errorMessages[i] = S.of(context).pleaseSelectADate;
        _hasError = true;
        continue;
      }

      final message = _cartModel.addProductToCart(
        context: context,
        product: product,
        quantity: _productItem.quantity,
        variation: variation,
        options: options,
      );

      if (message.isNotEmpty) {
        _errorMessages[i] = message;
        _hasError = true;
        continue;
      }
      _errorMessages[i] = 'added';
    }
    if (!_hasError) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {});
  }
}
