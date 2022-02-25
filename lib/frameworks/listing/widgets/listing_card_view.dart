import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';
import '../../../models/index.dart';
import '../../../modules/dynamic_layout/config/product_config.dart';
import '../../../routes/flux_navigate.dart';
import '../../../widgets/product/widgets/heart_button.dart';
import 'card/distance_item.dart';
import 'card/name_item.dart';
import 'card/price_item.dart';
import 'card/rating_item.dart';
import 'card/tag_item.dart';

class ListingCardView extends StatelessWidget {
  final Product item;
  final width;
  final height;
  final kSize size;
  final bool disableTap;
  final ProductConfig config;

  const ListingCardView({
    required this.item,
    this.width,
    this.height,
    this.size = kSize.medium,
    this.disableTap = false,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    const padding = 10.0;
    var maxWidth = width - padding;

    void onTapProduct() {
      if (item.imageFeature == '') return;
      Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);      
      FluxNavigate.pushNamed(
        RouteList.productDetail,
        arguments: item,
      );
    }

    Widget renderListingWidget(
        {bool enableCategory = true, bool enableDistance = true}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNotBlank(item.categoryName) && enableCategory) ...[
            Text(
              item.categoryName!.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 6),
          ],
          NameItem(
            item: item,
            hideTitle: config.hideTitle,
          ),
          const SizedBox(height: 6),
          if (enableDistance) DistanceItem(item: item),
          TagItem(
            item: item,
          ),
          const SizedBox(height: 6),
          PriceItem(item: item, config: config),
          const SizedBox(height: 3),
          RatingItem(
            item: item,
            config: config,
          ),
        ],
      );
    }

    if (config.layout == 'list') {
      return InkWell(
        onTap: onTapProduct,
        child: Container(
          color: Theme.of(context).cardColor,
          margin: EdgeInsets.symmetric(
            horizontal: config.hMargin,
            vertical: config.vMargin,
          ),
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: ImageTools.image(
                      url: item.imageFeature ?? '',
                      width: width,
                      size: size,
                      height: height ?? width * 1.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (config.showHeart)
                    Positioned(
                      top: -7,
                      right: -7,
                      child: HeartButton(
                        product: item,
                        size: 18,
                        color: Colors.white,
                      ),
                    )
                ],
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height,
                  ),
                  child: IntrinsicHeight(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8.0, left: 10.0),
                      padding: EdgeInsets.symmetric(
                        horizontal: config.hPadding,
                        vertical: config.vPadding,
                      ),
                      child: renderListingWidget(enableCategory: false),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => disableTap == false ? onTapProduct() : {},
      child: Stack(
        children: <Widget>[
          Container(
            color: Theme.of(context).cardColor,
            constraints: BoxConstraints(maxWidth: width),
            margin: EdgeInsets.symmetric(
              horizontal: config.hMargin,
              vertical: config.vMargin,
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: Stack(
                      children: <Widget>[
                        ImageTools.image(
                          url: item.imageFeature ?? '',
                          width: maxWidth ?? width,
                          size: kSize.medium,
                          isResize: true,
                          height: height ?? width * 1.2,
                          fit: BoxFit.cover,
                        ),
                        if (item.featured == 'on')
                          Container(
                            margin: const EdgeInsets.only(top: 4, left: 4),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .backgroundColor
                                  .withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.stars,
                                  size: 10,
                                  color: Colors.pink,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  S.of(context).featured,
                                  style: const TextStyle(fontSize: 9),
                                )
                              ],
                            ),
                          ),
                        if (disableTap)
                          Positioned(
                            right: 5,
                            top: 5,
                            child: CircleAvatar(
                              backgroundColor: Colors.white54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.open_in_new,
                                  size: 18,
                                ),
                                onPressed: onTapProduct,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 7, bottom: 10, left: 4),
                    padding: EdgeInsets.symmetric(
                      horizontal: config.hPadding,
                      vertical: config.vPadding,
                    ),
                    child: renderListingWidget(
                      enableDistance: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (config.showHeart && !item.isEmptyProduct())
            Positioned(
              top: 0,
              right: 0,
              child: HeartButton(product: item, size: 18),
            )
        ],
      ),
    );
  }
}
