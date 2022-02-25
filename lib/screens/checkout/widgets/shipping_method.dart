import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../../common/config.dart'
    show kAdvanceConfig, kLoadingWidget, kPaymentConfig;
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/cart/cart_model.dart';
import '../../../models/entities/order_delivery_date.dart';
import '../../../models/shipping_method_model.dart';
import '../../../services/index.dart';
import 'date_time_picker.dart';
import 'delivery_calendar.dart';

class ShippingMethods extends StatefulWidget {
  final Function? onBack;
  final Function? onNext;

  const ShippingMethods({this.onBack, this.onNext});

  @override
  _ShippingMethodsState createState() => _ShippingMethodsState();
}

class _ShippingMethodsState extends State<ShippingMethods> {
  int? selectedIndex = 0;

  ShippingMethodModel get shippingMethodModel =>
      Provider.of<ShippingMethodModel>(context, listen: false);

  CartModel get cartModel => Provider.of<CartModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        final shippingMethod = cartModel.shippingMethod;
        final shippingMethods = shippingMethodModel.shippingMethods;
        if (shippingMethods != null &&
            shippingMethods.isNotEmpty &&
            shippingMethod != null) {
          final index = shippingMethods
              .indexWhere((element) => element.id == shippingMethod.id);
          if (index > -1) {
            setState(() {
              selectedIndex = index;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shippingMethodModel = Provider.of<ShippingMethodModel>(context);
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRates = Provider.of<CartModel>(context).currencyRates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.of(context).shippingMethod,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ListenableProvider.value(
          value: shippingMethodModel,
          child: Consumer<ShippingMethodModel>(
            builder: (context, model, child) {
              if (model.isLoading) {
                return SizedBox(height: 100, child: kLoadingWidget(context));
              }

              if (model.message != null) {
                return SizedBox(
                  height: 100,
                  child: Center(
                      child: Text(model.message!,
                          style: const TextStyle(color: kErrorRed))),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int i = 0; i < model.shippingMethods!.length; i++)
                    Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: i == selectedIndex
                                ? Theme.of(context).primaryColorLight
                                : Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Row(
                              children: <Widget>[
                                Radio(
                                  value: i,
                                  groupValue: selectedIndex,
                                  onChanged: (dynamic i) {
                                    setState(() {
                                      selectedIndex = i;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Services()
                                          .widget
                                          .renderShippingPaymentTitle(context,
                                              model.shippingMethods![i].title!),
                                      const SizedBox(height: 5),
                                      if (model.shippingMethods![i].cost! >
                                              0.0 ||
                                          !isNotBlank(model
                                              .shippingMethods![i].classCost))
                                        Text(
                                          PriceTools.getCurrencyFormatted(
                                              model.shippingMethods![i].cost,
                                              currencyRates,
                                              currency: currency)!,
                                          style: const TextStyle(
                                              fontSize: 14, color: kGrey400),
                                        ),
                                      if (model.shippingMethods![i].cost ==
                                              0.0 &&
                                          isNotBlank(model
                                              .shippingMethods![i].classCost))
                                        Text(
                                          model.shippingMethods![i].classCost!,
                                          style: const TextStyle(
                                              fontSize: 14, color: kGrey400),
                                        )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        i < model.shippingMethods!.length - 1
                            ? const Divider(height: 1)
                            : Container()
                      ],
                    ),
                  const SizedBox(height: 20),
                  buildDeliveryDate(),
                ],
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  onPrimary: Colors.white,
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (shippingMethodModel.shippingMethods?.isNotEmpty ??
                      false) {
                    Provider.of<CartModel>(context, listen: false)
                        .setShippingMethod(shippingMethodModel
                            .shippingMethods![selectedIndex!]);

                    widget.onNext!();
                  }
                },
                child: Text(((kPaymentConfig['EnableReview'] ?? true)
                        ? S.of(context).continueToReview
                        : S.of(context).continueToPayment)
                    .toUpperCase()),
              ),
            ),
          ],
        ),
        if (kPaymentConfig['EnableAddress'])
          Center(
            child: TextButton(
              onPressed: () {
                widget.onBack!();
              },
              child: Text(
                S.of(context).goBackToAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                    color: kGrey400),
              ),
            ),
          )
      ],
    );
  }

  Widget buildDeliveryDate() {
    if (!(kAdvanceConfig['EnableDeliveryDateOnCheckout'] ?? false)) {
      return const SizedBox();
    }

    Widget deliveryWidget = DateTimePicker(
      onChanged: (DateTime datetime) {
        cartModel.selectedDate = OrderDeliveryDate(datetime);
      },
      minimumDate: DateTime.now(),
      initDate: cartModel.selectedDate?.dateTime,
      border: const OutlineInputBorder(),
    );

    if (shippingMethodModel.deliveryDates?.isNotEmpty ?? false) {
      deliveryWidget =
          DeliveryCalendar(dates: shippingMethodModel.deliveryDates!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              right: Tools.isRTL(context) ? 12.0 : 0.0,
              left: !Tools.isRTL(context) ? 12.0 : 0.0),
          child: Text(S.of(context).deliveryDate,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(0.7))),
        ),
        const SizedBox(height: 10),
        deliveryWidget,
        const SizedBox(height: 20),
      ],
    );
  }
}
