import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../generated/l10n.dart';
import '../../../models/entities/product.dart';
import '../../../widgets/product/product_glass_view.dart';
import '../config/category_config.dart';
import '../config/category_item_config.dart';
import '../config/product_config.dart';
import '../product/future_builder.dart';
import 'category_menu_item.dart';

const _defaultSeparateWidth = 24.0;

class CategoryMenuWithProducts extends StatefulWidget {
  final CategoryConfig config;
  final int crossAxisCount;
  final Function onShowProductList;
  final Map<String?, String?> listCategoryName;

  const CategoryMenuWithProducts({
    required this.onShowProductList,
    required this.listCategoryName,
    required this.config,
    this.crossAxisCount = 5,
    Key? key,
  }) : super(key: key);

  @override
  _CategoryMenuWithProductsState createState() =>
      _CategoryMenuWithProductsState();
}

class _CategoryMenuWithProductsState extends State<CategoryMenuWithProducts> {
  int selectedItemIndex = 0;

  String _getCategoryName({required CategoryItemConfig item}) {
    if (widget.config.hideTitle) {
      return '';
    }

    /// not using the config Title from json
    if (!item.keepDefaultTitle && widget.listCategoryName.isNotEmpty) {
      return widget.listCategoryName[item.category.toString()] ?? '';
    }

    return item.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.items.isEmpty) {
      return const SizedBox();
    }

    var items = <Widget>[];
    final selectedItem = widget.config.items[selectedItemIndex];
    final config = ProductConfig.fromJson(selectedItem.jsonData);

    for (var index = 0; index < widget.config.items.length; index++) {
      final item = widget.config.items[index];
      final _index = index;
      var name = _getCategoryName(item: item);

      items.addAll(
        [
          CategoryMenuItem(
            onTap: () {
              setState(() {
                selectedItemIndex = _index;
              });
            },
            name: name,
            isSelected: _index == selectedItemIndex,
          ),
          if (index != widget.config.items.length - 1)
            ScreenTypeLayout(
              mobile: const SizedBox(width: _defaultSeparateWidth),
              tablet: const SizedBox(width: _defaultSeparateWidth + 12),
              desktop: const SizedBox(width: _defaultSeparateWidth + 24),
            ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 55.0,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: widget.config.marginLeft,
              right: widget.config.marginRight,
              top: widget.config.marginTop,
              bottom: widget.config.marginBottom,
            ),
            itemCount: items.length,
            itemBuilder: (context, int index) {
              return items[index];
            },
          ),
        ),
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          const _padding = 8.0;
          final _leftOffset = widget.config.marginLeft >= _padding
              ? _padding
              : widget.config.marginLeft;
          final _rightOffset = widget.config.marginRight >= _padding
              ? _padding
              : widget.config.marginRight;
          final _list = ((selectedItem.jsonData['data'] ?? []) as List);
          final _productList = _list.map((e) => Product.fromJson(e)).toList();
          final _size = constraints.maxWidth * 0.5;

          if (_list.isEmpty) {
            return ProductFutureBuilder(
              key: UniqueKey(),
              waiting: getProductList(
                productList: [
                  Product.empty('0'),
                ],
                size: _size,
                leftOffset: _leftOffset,
                rightOffset: _rightOffset,
                config: selectedItem,
                padding: _padding,
              ),
              config: config,
              child: ({maxWidth, products}) {
                return getProductList(
                  productList: products,
                  size: _size,
                  leftOffset: _leftOffset,
                  rightOffset: _rightOffset,
                  config: selectedItem,
                  padding: _padding,
                );
              },
            );
          }
          return getProductList(
            productList: _productList,
            size: _size,
            leftOffset: _leftOffset,
            rightOffset: _rightOffset,
            config: selectedItem,
            padding: _padding,
          );
        }),
      ],
    );
  }
}

extension on State<CategoryMenuWithProducts> {
  Widget getProductList({
    required List<Product> productList,
    required double size,
    required double leftOffset,
    required double rightOffset,
    required CategoryItemConfig config,
    required double padding,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 310,
      ),
      height: 300,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: widget.config.marginLeft - leftOffset,
          right: widget.config.marginRight - rightOffset,
          top: widget.config.marginTop,
          bottom: widget.config.marginBottom,
        ),
        itemCount: productList.length,
        itemExtent: size,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final _card = ProductGlass(
            item: productList[index],
            width: size - padding,
            config: ProductConfig.empty()
              ..height = size - padding
              ..imageRatio = 1.0
              ..borderRadius = widget.config.radius
              ..showCartIcon = true,
          );
          if (index == productList.length - 1) {
            return GestureDetector(
              onTap: () {
                widget.onShowProductList(
                  config,
                );
              },
              child: AbsorbPointer(
                absorbing: true,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          widget.config.radius ?? 0.0,
                        ),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ),
                          child: _card,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          S.of(context).seeAll,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _card,
          );
        },
      ),
    );
  }
}
