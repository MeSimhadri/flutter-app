import 'package:flutter/material.dart';

import '../config/box_shadow_config.dart';
import '../helper/helper.dart';

class CategoryTextItem extends StatelessWidget {
  final double? size;
  final String? name;
  final double? borderWidth;
  final double? radius;
  final BoxShadowConfig? boxShadow;
  final Function? onTap;
  final double? paddingX;
  final double? paddingY;

  const CategoryTextItem({
    this.size,
    this.name,
    this.borderWidth,
    this.radius,
    this.onTap,
    this.boxShadow,
    this.paddingX,
    this.paddingY,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Helper.formatDouble(paddingY ?? 8.0)!,
          vertical: Helper.formatDouble(paddingX ?? 4.0)!,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight.withOpacity(0.9),
          boxShadow: [
            if (boxShadow != null)
              BoxShadow(
                blurRadius: boxShadow!.blurRadius,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withOpacity(boxShadow!.colorOpacity),
                spreadRadius: boxShadow!.spreadRadius,
                offset: Offset(boxShadow!.x, boxShadow!.y),
              )
          ],
          borderRadius: BorderRadius.circular(radius!),
        ),
        child: Text(
          name ?? '',
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .apply(fontSizeFactor: size ?? 1),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
