import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fstore/models/entities/product.dart';
import 'package:inspireui/inspireui.dart' show Skeleton;
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/app_model.dart';
import '../../../models/index.dart' show BackDropArguments, Category;
import '../../../models/user_model.dart';
import '../../../modules/dynamic_layout/config/product_config.dart';
import '../../../routes/flux_navigate.dart';
import '../../../services/services.dart';
import '../../../widgets/common/tree_view.dart';
import '../../base_screen.dart';
import '../../index.dart';

class CardCategories extends StatefulWidget {
  static const String type = 'card';

  final List<Category>? categories;

  const CardCategories(this.categories);

  @override
  _StateCardCategories createState() => _StateCardCategories();
}

class _StateCardCategories extends BaseScreen<CardCategories> {
  ScrollController controller = ScrollController();
  late double page;

  @override
  void initState() {
    page = 0.0;
    super.initState();
    getAllListProducts(category: Category.fromJson({'id':1424}));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    controller.addListener(() {
      setState(() {
        page = _getPage(controller.position, screenSize.width * 0.30 + 10);
      });
    });
  }

  bool hasChildren(id) {
    return widget.categories!.where((o) => o.parent == id).toList().isNotEmpty;
  }

  double _getPage(ScrollPosition position, double width) {
    return position.pixels / width;
  }

  List<Category> getSubCategories(id) {
    return widget.categories!.where((o) => o.parent == id).toList();
  }

  void navigateToBackDrop(Category category) {
    FluxNavigate.pushNamed(
      RouteList.backdrop,
      arguments: BackDropArguments(
        cateId: category.id,
        cateName: category.name,
      ),
    );
  }

  Widget getChildCategoryList(category) {
    return ChildList(
      children: [
        GestureDetector(
          onTap: () => navigateToBackDrop(category),
          child: SubItem(
            category,
            seeAll: S.of(context).seeAll,
          ),
        ),
        for (var category in getSubCategories(category.id))
          Parent(
            callback: (isSelected) {
              if (getSubCategories(category.id).isEmpty) {
                navigateToBackDrop(category);
              }
            },
            parent: SubItem(category),
            childList: ChildList(
              children: [
                for (var cate in getSubCategories(category.id))
                  Parent(
                    callback: (isSelected) {
                      if (getSubCategories(cate.id).isEmpty) {
                        FluxNavigate.pushNamed(
                          RouteList.backdrop,
                          arguments: BackDropArguments(
                            cateId: cate.id,
                            cateName: cate.name,
                          ),
                        );
                      }
                    },
                    parent: SubItem(cate, level: 1),
                    childList: ChildList(
                      children: [
                        for (var _cate in getSubCategories(cate.id))
                          Parent(
                            callback: (isSelected) {
                              FluxNavigate.pushNamed(
                                RouteList.backdrop,
                                arguments: BackDropArguments(
                                  cateId: _cate.id,
                                  cateName: _cate.name,
                                ),
                              );
                            },
                            parent: SubItem(_cate, level: 2),
                            childList: const ChildList(children: []),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget categoryWidget(
      {required Category category,
      required Function onPressed,
      required Color color}) {
    var image = 'assets/categories/others icon.png';
    if (category.name!.toLowerCase().contains('camping')) {
      image = 'assets/categories/tent_icon.png';
    } else if (category.name!.toLowerCase().contains('events')) {
      image = 'assets/categories/Events Icon.png';
    } else if (category.name!.toLowerCase().contains('fitness')) {
      image = 'assets/categories/Fitness Icon.png';
    } else if (category.name!.toLowerCase().contains('water sports')) {
      image = 'assets/categories/WaterSports Icon.png';
    } else if (category.name!.toLowerCase().contains('escape house')) {
      image = 'assets/categories/escape house-42.png';
    } else if (category.name!.toLowerCase().contains('yacht')) {
      image = 'assets/categories/yacht icon.png';
    }
    return InkWell(
      onTap: () {
        onPressed();
        // FluxNavigate.pushNamed(
        //   RouteList.backdrop,
        //   arguments: BackDropArguments(
        //     cateId: category.id,
        //     cateName: category.name,
        //   ),
        // );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        // width: 80,
        // height: 80,
        // decoration: BoxDecoration(
        //     color: Colors.grey[200],
        //     borderRadius: BorderRadius.circular(6),
        //     border: Border.all(color: Colors.grey[300]!, width: 2)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              width: 40,
              height: 40,
              color: color,
            ),
            const SizedBox(width: 10),
            Text(
              category.name ?? '',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }

  bool loading = true;
  Map<String, dynamic> productMap = <String, dynamic>{};
  Future<void> getAllListProducts({
    minPrice,
    maxPrice,
    orderBy,
    order,
    lang,
    page = 1,
    required category,
  }) async {
    var _service = Services();
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    try {
      setState(() {
        loading = true;
      });
      List<dynamic>? productList = [];
      if (productMap[category.id.toString()] != null) {
        productList = productMap[category.id.toString()];
      } else {
        productList = await _service.api.fetchProductsByCategory(
          categoryId: category.id,
          minPrice: minPrice,
          maxPrice: maxPrice,
          orderBy: orderBy,
          order: order,
          lang: lang,
          page: page,
          userId: _userId,
        );
      }
      productMap.update(category.id.toString(), (value) => productList,
          ifAbsent: () => productList);
      productController.add(productList);
      setState(() {
        loading = false;
      });
    } catch (e) {
      productController.add([]);
      setState(() {
        loading = false;
      });
    }
  }

  int selectedIndex = 0;
  BackDropArguments selectedBackdrop =
      BackDropArguments(cateId: 1424, cateName: 'Camping');
  final ScrollController _controller = ScrollController();
  final StreamController productController = StreamController<List<Product>?>();
  @override
  Widget build(BuildContext context) {
    var _categories =
        widget.categories!.where((item) => item.parent == '0').toList();
    print(_categories.first.id);
    print(_categories.first.name);
    if (_categories.isEmpty) {
      _categories = widget.categories!;
    }

    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.vertical,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 4,
              child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return categoryWidget(
                          category: _categories[index],
                          onPressed: () {
                            selectedIndex = index;
                            getAllListProducts(
                                category: _categories[index],
                                lang: Provider.of<AppModel>(context, listen: false)
                                    .langCode);
                            selectedBackdrop = BackDropArguments(
                                brandId: _categories[index].id,
                                cateName: _categories[index].name);
                            setState(() {});
                          },
                          color:
                              selectedIndex == index ? maintabBlue : Colors.grey);
                    }),
          ),
          Expanded(
              flex: 7,
              child: StreamBuilder(
                stream: productController.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  return MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (loading) {
                        // return StaggeredGridView.countBuilder(
                        //   crossAxisCount: 4,
                        //   padding: EdgeInsets.symmetric(
                        //     horizontal: widget.config.hPadding,
                        //     vertical: widget.config.vPadding,
                        //   ),
                        //   key: categories.isNotEmpty
                        //       ? Key(categories[position].id.toString())
                        //       : UniqueKey(),
                        //   shrinkWrap: true,
                        //   controller: _controller,
                        //   itemCount: 4,
                        //   itemBuilder: (context, value) {
                        //     return Services().widget.renderProductCardView(
                        //           item: Product.empty(value.toString()),
                        //           width: MediaQuery.of(context).size.width / 2,
                        //           config: widget.config,
                        //         );
                        //   },
                        //   staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
                        // );
                      }
                      if (snapshot.hasData && snapshot.data.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: GridView.builder(
                            shrinkWrap: true,
                            cacheExtent: 1000,
                            controller: _controller,
                            itemCount: snapshot.data.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 0, 
                              mainAxisSpacing: 6.0,
                              childAspectRatio: 0.57,
                            ),
                            itemBuilder: (context, index) =>
                                Services().widget.renderProductCardView(
                                      item: snapshot.data[index],
                                      width: constraints.maxWidth / 2,
                                      config: ProductConfig.fromJson({}),
                                    ),
                          ),
                        );
                      }
                      return SizedBox(
                        height: MediaQuery.of(context).size.width / 2,
                        child: Center(
                          child: Text(S.of(context).noProduct),
                        ),
                      );
                    }),
                  );
                },
              )
              //  Column(
              //   children: [
              //     TreeView(
              //       parentList: List.generate(
              //         _categories.length,
              //         (index) {
              //           return Parent(
              //             parent: _CategoryCardItem(
              //               _categories[index],
              //               hasChildren: hasChildren(_categories[index].id),
              //               offset: page - index,
              //             ),
              //             childList: getChildCategoryList(_categories[index])
              //                 as ChildList,
              //           );
              //         },
              //       ),
              //     ),
              //     const SizedBox(height: 100)
              //   ],
              // ),
              ),
        ],
      ),
    );
  }
}

class _CategoryCardItem extends StatelessWidget {
  final Category category;
  final bool hasChildren;
  final offset;

  const _CategoryCardItem(this.category,
      {this.hasChildren = false, this.offset});

  /// Render category Image support caching on ios/android
  /// also fix loading on Web
  Widget renderCategoryImage(maxWidth) {
    final image = category.image ?? '';
    if (image.isEmpty) return const SizedBox();

    var imageProxy = '$kImageProxy${maxWidth}x,q30/';

    if (image.contains('http') && kIsWeb) {
      return FadeInImage.memoryNetwork(
        image: '$imageProxy$image',
        fit: BoxFit.cover,
        width: maxWidth,
        height: maxWidth * 0.35,
        placeholder: kTransparentImage,
      );
    }

    return image.contains('http')
        ? CachedNetworkImage(
            imageUrl: category.image!,
            fit: BoxFit.cover,
            alignment: Alignment(
              0.0,
              (offset >= -1 && offset <= 1)
                  ? offset
                  : (offset > 0)
                      ? 1.0
                      : -1.0,
            ),
            // fadeInCurve: Curves.easeIn,
            errorWidget: (context, url, error) => const SizedBox(),
            imageBuilder:
                (BuildContext context, ImageProvider<dynamic> imageProvider) {
              return Image(
                width: maxWidth,
                image: imageProvider as ImageProvider<Object>,
                fit: BoxFit.cover,
              );
            },
            placeholder: (context, url) => Skeleton(
              width: maxWidth,
              height: maxWidth * 0.35,
            ),
          )
        : Image.asset(
            category.image!,
            fit: BoxFit.cover,
            width: maxWidth,
            height: maxWidth * 0.35,
            alignment: Alignment(
              0.0,
              (offset >= -1 && offset <= 1)
                  ? offset
                  : (offset > 0)
                      ? 1.0
                      : -1.0,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    print(category.id);
    print(category.name);
    print('__________________________________________');
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: hasChildren
          ? null
          : () {
              FluxNavigate.pushNamed(
                RouteList.backdrop,
                arguments: BackDropArguments(
                  cateId: category.id,
                  cateName: category.name,
                ),
              );
            },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxWidth * 0.35,
            padding: const EdgeInsets.only(left: 10, right: 10),
            margin: const EdgeInsets.only(bottom: 10),
            child: Stack(
              children: <Widget>[
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                    child: renderCategoryImage(constraints.maxWidth)),
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth * 0.35,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.3),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: SizedBox(
                    width: constraints.maxWidth /
                        (2 / (screenSize.height / constraints.maxWidth)),
                    height: constraints.maxWidth * 0.35,
                    child: Center(
                      child: Text(
                        category.name?.toUpperCase() ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SubItem extends StatelessWidget {
  final Category category;
  final String seeAll;
  final int level;

  const SubItem(this.category, {this.seeAll = '', this.level = 0});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 0.5,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withOpacity(level == 0 && seeAll == '' ? 0.2 : 0),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 15.0),
              for (int i = 1; i <= level; i++)
                Container(
                  width: 20.0,
                  margin: const EdgeInsets.only(top: 8.0, right: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1.5,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  seeAll != '' ? seeAll : category.name!,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
              Text(
                S.of(context).nItems(category.totalProduct.toString()),
                style: TextStyle(
                    fontSize: 14, color: Theme.of(context).primaryColor),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  FluxNavigate.pushNamed(
                    RouteList.backdrop,
                    arguments: BackDropArguments(
                      cateId: category.id,
                      cateName: category.name,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
