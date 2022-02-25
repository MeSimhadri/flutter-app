import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
class ReOrderButton extends StatelessWidget {
  const ReOrderButton({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          S.of(context).reOrder,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      );
  }
}