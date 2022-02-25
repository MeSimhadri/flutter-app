import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart' show Product, ProductModel, UserModel;
import '../../../services/index.dart';
import '../../../widgets/product/product_bottom_sheet.dart';
import '../../../widgets/product/widgets/heart_button.dart';
import '../../chat/vendor_chat.dart';
import '../product_detail_screen.dart';
import '../widgets/index.dart';
import '../widgets/video_feature.dart';

class SimpleLayout extends StatefulWidget {
  final Product product;
  final bool isLoading;

  const SimpleLayout({required this.product, this.isLoading = false});

  @override
  // ignore: no_logic_in_create_state
  _SimpleLayoutState createState() => _SimpleLayoutState(product: product);
}

class _SimpleLayoutState extends State<SimpleLayout>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late Product product;
  String? selectedUrl;

  bool isVideoSelected = false;

  _SimpleLayoutState({required this.product});

  Map<String, String> mapAttribute = HashMap();
  var _hideController;
  var top = 0.0;

  @override
  void initState() {
    super.initState();
    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(SimpleLayout oldWidget) {
    if (oldWidget.product.type != widget.product.type) {
      setState(() {
        product = widget.product;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Render product default: booking, group, variant, simple, booking
  Widget renderProductInfo() {
    var body;

    if (widget.isLoading == true) {
      body = kLoadingWidget(context);
    } else {
      switch (product.type) {
        case 'appointment':
          return Services().getBookingLayout(product: product);
        case 'booking':
          body = ListingBooking(product);
          break;
        case 'grouped':
          body = GroupedProduct(product);
          break;
        default:
          body = ProductVariant(
            product,
            onSelectVariantImage: (String url) {
              setState(() {
                selectedUrl = url;
                isVideoSelected = false;
              });
            },
          );
      }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthHeight = size.height;

    final userModel = Provider.of<UserModel>(context, listen: false);
    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        bottom: false,
        top: kProductDetail.safeArea,
        child: ChangeNotifierProvider(
          create: (_) => ProductModel(),
          child: Stack(
            children: <Widget>[
              Scaffold(
                floatingActionButton: (!Config().isVendorType() ||
                        !kConfigChat['EnableSmartChat'])
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: VendorChat(
                          user: userModel.user,
                          store: product.store,
                        ),
                      ),
                backgroundColor: Theme.of(context).backgroundColor,
                body: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverAppBar(
                      systemOverlayStyle: SystemUiOverlayStyle.light,
                      backgroundColor: Theme.of(context).backgroundColor,
                      elevation: 1.0,
                      expandedHeight:
                          kIsWeb ? 0 : widthHeight * kProductDetail.height,
                      pinned: true,
                      floating: false,
                      leading: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: kGrey400,
                            ),
                            onPressed: () {
                              Provider.of<ProductModel>(context, listen: false)
                                  .changeProductVariation(null);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        if (widget.isLoading != true)
                          HeartButton(
                            product: product,
                            size: 18.0,
                            color: kGrey400,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: IconButton(
                              icon: const Icon(Icons.more_vert, size: 19),
                              color: kGrey400,
                              onPressed: () => ProductDetailScreen.showMenu(
                                  context, widget.product,
                                  isLoading: widget.isLoading),
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: kIsWeb
                          ? const SizedBox()
                          : _renderSelectedMedia(context, product, size),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          const SizedBox(
                            height: 2,
                          ),
                          ProductGallery(
                            product: product,
                            onSelect: (String url, bool isVideo) {
                              if (mounted) {
                                setState(() {
                                  selectedUrl = url;
                                  isVideoSelected = isVideo;
                                });
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 4.0,
                              left: 15,
                              right: 15,
                            ),
                            child: product.type == 'grouped'
                                ? const SizedBox()
                                : ProductTitle(product),
                          ),
                        ],
                      ),
                    ),
                    if (kEnableShoppingCart) renderProductInfo(),
                    if (!kEnableShoppingCart &&
                        product.shortDescription != null &&
                        product.shortDescription!.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ProductShortDescription(product),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 15.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: Column(
                                children: [
                                  Services().widget.renderVendorInfo(product),
                                  ProductDescription(product),
                                  if (kProductDetail.showProductCategories)
                                    ProductDetailCategories(product),
                                  if (kProductDetail.showProductTags)
                                    ProductTag(product),
                                ],
                              ),
                            ),
                            RelatedProduct(product),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (kEnableShoppingCart)
                Align(
                  alignment: Alignment.bottomRight,
                  child: ExpandingBottomSheet(
                    hideController: _hideController,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderSelectedMedia(
      BuildContext context, Product? product, Size size) {
    /// Render selected video
    if (selectedUrl != null && isVideoSelected) {
      return FeatureVideoPlayer(
        url: selectedUrl!.replaceAll('http://', 'https://'),
        autoPlay: true,
      );
    }

    /// Render selected image from the Gallery
    if (selectedUrl != null &&
        !isVideoSelected &&
        (kProductDetail.showSelectedImageVariant)) {
      return GestureDetector(
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              var images = product?.images ?? <String>[];
              final index = images.indexOf(selectedUrl!);
              if (index == -1) {
                images.insert(0, selectedUrl!);
              }
              return ImageGalery(
                images: images,
                index: index == -1 ? 0 : index,
              );
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: double.parse(kProductDetail.marginTop.toString()),
          ),
          child: ImageTools.image(
            url: selectedUrl,
            fit: BoxFit.contain,
            width: size.width,
            size: kSize.large,
            hidePlaceHolder: true,
            forceWhiteBackground: kProductDetail.forceWhiteBackground,
          ),
        ),
      );
    }

    /// Render default feature image
    return product!.type == 'variable'
        ? VariantImageFeature(product)
        : ImageFeature(product);
  }
}
