import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rubber/rubber.dart';
import 'package:share/share.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../common/config.dart';
import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/index.dart';
import '../../../../models/index.dart';
import '../../../../widgets/common/expansion_info.dart';
import '../product_description.dart';
import '../product_map.dart';
import '../product_related.dart';
import '../product_taxonomies.dart';
import '../product_title_short.dart';
import '../review.dart';

class ListingHalfSizeLayout extends StatefulWidget {
  final Product product;

  const ListingHalfSizeLayout({required this.product});

  @override
  _HalfSizeLayoutState createState() => _HalfSizeLayoutState();
}

class _HalfSizeLayoutState extends State<ListingHalfSizeLayout>
    with SingleTickerProviderStateMixin {
  Map<String, String> mapAttribute = HashMap();
  late final RubberAnimationController _controller;
  late final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  var top = 0.0;
  var opacityValue = 0.9;

  @override
  void initState() {
    _controller = RubberAnimationController(
        vsync: this,
        initialValue: 0.5,
        lowerBoundValue: AnimationControllerValue(percentage: 0.15),
        halfBoundValue: AnimationControllerValue(percentage: 0.5),
        upperBoundValue: AnimationControllerValue(percentage: 0.9),
        duration: const Duration(milliseconds: 200));
    _controller.animationState.addListener(_stateListener);
    super.initState();
  }

  void _stateListener() {
    setState(() {
      opacityValue =
          _controller.animationState.value == AnimationState.collapsed
              ? 0.3
              : 0.9;
    });
  }

  void showOptions(context) {
    var wishlist =
        Provider.of<ProductWishListModel>(context, listen: false).products;
    final isExist =
        wishlist.indexWhere((item) => item.id == widget.product.id) != -1;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  title: Text(
                      isExist
                          ? S.of(context).removeFromWishList
                          : S.of(context).saveToWishList,
                      textAlign: TextAlign.center),
                  onTap: () {
                    if (isExist) {
                      Provider.of<ProductWishListModel>(context, listen: false)
                          .removeToWishlist(widget.product);
                    } else {
                      Provider.of<ProductWishListModel>(context, listen: false)
                          .addToWishlist(widget.product);
                    }

                    Navigator.of(context).pop();
                  }),
              ListTile(
                  title: Text(S.of(context).share, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(widget.product.permalink!);
                  }),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                title: Text(
                  S.of(context).cancel,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }

  Widget _getLowerLayer({double? width, double? height}) {
    final _height = height ?? MediaQuery.of(context).size.height;
    final _width = width ?? MediaQuery.of(context).size.width;

    return Material(
      child: Stack(
        children: <Widget>[
          if (widget.product.imageFeature != null)
            Positioned(
              top: 0,
              child: SizedBox(
                width: _width,
                height: _height,
                child: PageView(
                  allowImplicitScrolling: true,
                  controller: _pageController,
                  children: [
                    Image.network(
                      widget.product.imageFeature ?? '',
                      fit: BoxFit.fitHeight,
                    ),
                    for (var i = 1; i < (widget.product.images.length); i++)
                      Image.network(
                        widget.product.images[i],
                        fit: BoxFit.fitHeight,
                      ),
                  ],
                ),
              ),
            ),
          if (widget.product.imageFeature != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black45,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: widget.product.images.length,
                    effect: const ScrollingDotsEffect(
                      dotWidth: 5.0,
                      dotHeight: 5.0,
                      spacing: 15.0,
                      fixedCenter: true,
                      dotColor: Colors.black45,
                      activeDotColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                ),
                onPressed: () {
                  Provider.of<ProductModel>(context, listen: false)
                      .changeProductVariation(null);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => showOptions(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getReviews() {
    return [
      ExpansionInfo(
        expand: true,
        title: S.of(context).readReviews,
        children: <Widget>[
          Reviews(int.parse(widget.product.id!)),
        ],
      ),
    ];
  }

  Widget _getUpperLayer({double? width}) {
    final _width = width ?? MediaQuery.of(context).size.width;

    return Consumer2<AppModel, UserModel>(
        builder: (context, valueApp, valueUser, child) {
      return Material(
        color: Colors.transparent,
        child: Container(
          width: _width,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, offset: Offset(0, -2), blurRadius: 20),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .backgroundColor
                        .withOpacity(opacityValue),
                    borderRadius: BorderRadius.circular(10.0)),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ProductTitleShort(
                          product: widget.product, user: valueUser.user),
                      if (widget.product.description != '')
                        ProductDescription(
                          product: widget.product,
                        ),
                      ProductTaxonomies(
                        product: widget.product,
                        title: S.of(context).features,
                        type: DataMapping().kTaxonomies['features'],
                      ),
                      ProductMap(
                        product: widget.product,
                      ),
                      if (kProductDetail.enableReview) ...getReviews(),
                      ProductRelated(
                        product: widget.product,
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RubberBottomSheet(
          lowerLayer: _getLowerLayer(
              width: constraints.maxWidth, height: constraints.maxHeight),
          upperLayer: _getUpperLayer(width: constraints.maxWidth),
          animationController: _controller,
          scrollController: _scrollController,
        );
      },
    );
  }
}
