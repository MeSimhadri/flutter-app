import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rubber/rubber.dart';
import 'package:share/share.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/index.dart';
import '../../../../models/index.dart';
import '../product_title_short.dart';

class ListingFullSizeLayout extends StatefulWidget {
  final Product product;

  const ListingFullSizeLayout({required this.product});

  @override
  _FullSizeLayoutState createState() => _FullSizeLayoutState();
}

class _FullSizeLayoutState extends State<ListingFullSizeLayout>
    with SingleTickerProviderStateMixin {
  Map<String, String> mapAttribute = HashMap();
  late final RubberAnimationController _controller;
  late final PageController _pageController = PageController();
  final _dampingValue = DampingRatio.MEDIUM_BOUNCY;
  final _stiffnessValue = Stiffness.HIGH;
  var top = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = RubberAnimationController(
        vsync: this,
        lowerBoundValue: AnimationControllerValue(pixel: 140),
        upperBoundValue: AnimationControllerValue(percentage: 0.6),
        springDescription: SpringDescription.withDampingRatio(
            mass: 1, stiffness: _stiffnessValue, ratio: _dampingValue),
        duration: const Duration(milliseconds: 300));
    super.initState();
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
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _getUpperLayer({double? width}) {
    final _height = MediaQuery.of(context).size.height;
    final _width = width ?? MediaQuery.of(context).size.width;
    return Consumer2<AppModel, UserModel>(
        builder: (context, valueApp, valueUser, child) {
      return Material(
        color: Colors.transparent,
        child: Container(
          width: _width * 0.78,
          height: _height * 0.55,
          margin: EdgeInsets.only(left: _width * 0.2),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10.0)),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ProductTitleShort(
                          product: widget.product, user: valueUser.user),
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
        );
      },
    );
  }
}
