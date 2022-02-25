import 'package:flutter/material.dart';
import 'package:inspireui/utils/colors.dart';

import '../config/background_config.dart';

class HomeBackground extends StatelessWidget {
  final BackgroundConfig? config;

  const HomeBackground({required this.config});

  @override
  Widget build(BuildContext context) {
    if (config == null) {
      return Container();
    }

    if (config!.image == null && config!.color != null) {
      return Container(
        color: HexColor(config!.color),
        height: MediaQuery.of(context).size.height * config!.height,
      );
    }

    if (config!.image == null) {
      return const SizedBox();
    }

    return Container(
      height: MediaQuery.of(context).size.height * config!.height,
      decoration: BoxDecoration(
        color: config!.color != null
            ? HexColor(config!.color)
            : Theme.of(context).primaryColor,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(config!.image!),
        ),
      ),
    );
  }
}
