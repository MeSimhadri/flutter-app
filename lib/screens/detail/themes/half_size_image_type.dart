import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rubber/rubber.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../models/index.dart' show CartModel, Product, ProductModel;
import '../../cart/cart_screen.dart';
import '../product_detail_screen.dart';
import '../widgets/index.dart';

class HalfSizeLayout extends StatefulWidget {
  final Product? product;
  final bool isLoading;

  const HalfSizeLayout({this.product, this.isLoading = false});

  @override
  _HalfSizeLayoutState createState() => _HalfSizeLayoutState();
}

class _HalfSizeLayoutState extends State<HalfSizeLayout>
    with SingleTickerProviderStateMixin {
  Map<String, String> mapAttribute = HashMap();
  late final PageController _pageController = PageController();
  late final RubberAnimationController _controller;
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

  Widget _getLowerLayer({width, height}) {
    final _height = height ?? MediaQuery.of(context).size.height;
    final _width = width ?? MediaQuery.of(context).size.width;
    var totalCart = Provider.of<CartModel>(context).totalCartQuantity;

    return Material(
      child: Stack(
        children: <Widget>[
          if (widget.product?.imageFeature != null)
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
                      widget.product?.imageFeature ?? '',
                      fit: BoxFit.fitHeight,
                    ),
                    for (var i = 1;
                        i < (widget.product?.images.length ?? 0);
                        i++)
                      Image.network(
                        widget.product?.images[i] ?? '',
                        fit: BoxFit.fitHeight,
                      ),
                  ],
                ),
              ),
            ),
          if (widget.product?.imageFeature != null)
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
                    count: widget.product?.images.length ?? 0,
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
              onPressed: () => ProductDetailScreen.showMenu(
                  context, widget.product,
                  isLoading: widget.isLoading),
            ),
          ),
          Positioned(
            top: 30,
            right: 40,
            child: IconButton(
                icon: const Icon(
                  Icons.shopping_cart,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => Scaffold(
                        backgroundColor: Theme.of(context).backgroundColor,
                        body: const CartScreen(isModal: true),
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                }),
          ),
          Positioned(
            top: 36,
            right: 44,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(9),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                totalCart.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getUpperLayer({width}) {
    final _width = width ?? MediaQuery.of(context).size.width;

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
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .backgroundColor
                      .withOpacity(opacityValue),
                  borderRadius: BorderRadius.circular(10.0)),
              child: ChangeNotifierProvider(
                create: (_) => ProductModel(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ProductTitle(widget.product),
                      ProductVariant(widget.product),
                      ProductDescription(widget.product),
                      RelatedProduct(widget.product),
                      const SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
