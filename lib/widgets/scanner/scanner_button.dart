import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../models/entities/user.dart';
import '../../routes/flux_navigate.dart';
import '../../services/service_config.dart';
import 'scanner.dart';

class ScannerButton extends StatelessWidget {
  final User? user;
  final IconData? customIcon;
  const ScannerButton({Key? key, this.user, this.customIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Config().isWooType) {
      return const SizedBox();
    }
    return IconButton(
        onPressed: () {
          if (isIos || isAndroid) {
            FluxNavigate.push(
                MaterialPageRoute(
                  builder: (_) => Scanner(
                    key: UniqueKey(),
                    user: user,
                  ),
                ),
                forceRootNavigator: true);
          } else {
            FluxNavigate.push(
              MaterialPageRoute(builder: (_) => const FakeBarcodeScreen()),
              forceRootNavigator: true,
            );
          }
        },
        icon: Icon(customIcon ?? Icons.qr_code));
  }
}

class FakeBarcodeScreen extends StatelessWidget {
  const FakeBarcodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: const Center(
        child: Icon(
          Icons.qr_code,
          size: 200.0,
        ),
      ),
    );
  }
}
