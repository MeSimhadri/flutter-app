import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/category_model.dart';
import '../../../widgets/common/flux_image.dart';
import '../config/box_shadow_config.dart';
import '../config/category_item_config.dart';

class CategoryIconItem extends StatelessWidget {
  final double? iconSize;
  final String? name;
  final bool? originalColor;
  final double? borderWidth;
  final double? radius;
  final double spacing;
  final bool? noBackground;
  final BoxShadowConfig? boxShadow;
  final Function? onTap;
  final CategoryItemConfig? itemConfig;
  final double paddingX;
  final double paddingY;
  final double marginX;
  final double marginY;
  final bool? isSelected;

  const CategoryIconItem({
    this.iconSize,
    this.name,
    this.originalColor,
    this.borderWidth,
    this.radius,
    this.spacing = 12.0,
    this.noBackground,
    this.onTap,
    this.itemConfig,
    this.boxShadow,
    this.isSelected,
    required this.paddingX,
    required this.paddingY,
    required this.marginX,
    required this.marginY,
  });

  @override
  Widget build(BuildContext context) {
    final disableBackground =
        ((noBackground ?? false) || (originalColor ?? false));
    final categoryList = Provider.of<CategoryModel>(context).categoryList;

    final id = itemConfig!.category.toString();
    final _name =
        name ?? (categoryList[id] != null ? categoryList[id]!.name : '');
    final image = itemConfig!.image ??
        (categoryList[id] != null ? categoryList[id]!.image : null);

    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
        constraints: BoxConstraints(maxWidth: iconSize! * 1.2),
        decoration: borderWidth != null && borderWidth != 0
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: borderWidth!,
                    color: Colors.black.withOpacity(0.05),
                  ),
                  right: BorderSide(
                    width: borderWidth!,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (image != null)
              Container(
                width: iconSize,
                height: iconSize,
                padding: EdgeInsets.symmetric(
                  horizontal: paddingX,
                  vertical: paddingY,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: marginX,
                  vertical: marginY,
                ),
                decoration: BoxDecoration(
                  color: !disableBackground
                      ? itemConfig!.getBackgroundColor
                      : null,
                  gradient:
                      !disableBackground ? itemConfig!.getGradientColor : null,
                  boxShadow: [
                    if (boxShadow != null)
                      BoxShadow(
                        blurRadius: boxShadow!.blurRadius,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(boxShadow!.colorOpacity),
                        offset: Offset(boxShadow!.x, boxShadow!.y),
                      )
                  ],
                  borderRadius: BorderRadius.circular(radius ?? 10),
                ),
                child: Container(
                  margin: EdgeInsets.all(spacing),
                  child: FluxImage(
                    imageUrl: image,
                    color: (itemConfig!.originalColor ?? true) ||
                            (originalColor ?? true)
                        ? null
                        : itemConfig!.colors!.first,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ),
            if (_name?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                _name!,
                style: Theme.of(context).textTheme.subtitle2,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              if (isSelected != null)
                AnimatedContainer(
                  decoration: BoxDecoration(
                    color: isSelected == true
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  margin: const EdgeInsets.only(
                    top: 4.0,
                  ),
                  height: 4.0,
                  width: 4.0,
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
