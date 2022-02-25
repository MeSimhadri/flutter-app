import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../models/entities/index.dart';
import '../../models/order/order.dart';
import 'widgets/re_order_button.dart';
import 'widgets/re_order_item_list.dart';

class ReOrderIndex extends StatelessWidget {
  final Order order;

  const ReOrderIndex({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _reOrder() async {
      final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
          ),
          child: ReOrderItemList(
            lineItems: order.lineItems,
          ),
        ),
      );

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).yourOrderHasBeenAdded),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    return InkWell(
      onTap: _reOrder,
      borderRadius: BorderRadius.circular(16.0),
      child: const ReOrderButton(),
    );
  }
}
