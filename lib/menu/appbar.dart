import 'package:flutter/material.dart';
import 'package:inspireui/icons/icon_picker.dart' deferred as defer_icon;
import 'package:inspireui/widgets/deferred_widget.dart';
import 'package:inspireui/widgets/platform_error/platform_error.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../generated/l10n.dart';
import '../models/app_model.dart';
import '../models/index.dart';
import '../modules/dynamic_layout/config/app_config.dart';
import '../modules/dynamic_layout/helper/helper.dart';
import '../routes/flux_navigate.dart';
import '../widgets/common/index.dart';
import '../widgets/common/place_picker.dart';

class FluxAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _FluxAppBarState createState() => _FluxAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FluxAppBarState extends State<FluxAppBar> {
  AppBarConfig? get appBar =>
      Provider.of<AppModel>(context, listen: false).appConfig!.appBar;

  Address? currentAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => afterFirstLayout(context));
  }

  void afterFirstLayout(BuildContext context) {
    if (!(appBar?.toJson().toString().contains('location') ?? false)) {
      return;
    }
    Future.microtask(
      () async {
        final addressValue =
            await Provider.of<CartModel>(context, listen: false).getAddress();
        if (addressValue != null) {
          setState(() {
            currentAddress = addressValue;
          });
        } else {
          var user = Provider.of<UserModel>(context, listen: false).user;
          setState(() {
            currentAddress =
                Address(country: kPaymentConfig['DefaultCountryISOCode']);
            if (kPaymentConfig['DefaultStateISOCode'] != null) {
              currentAddress!.state = kPaymentConfig['DefaultStateISOCode'];
            }
            if (user != null) {
              currentAddress!.firstName = user.firstName;
              currentAddress!.lastName = user.lastName;
              currentAddress!.email = user.email;
            }
          });
        }
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (appBar == null || (appBar?.items?.isEmpty ?? true)) {
      return const SizedBox();
    }

    return SizedBox(
      height: widget.preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: appBar?.items?.map(
              (AppBarItemConfig item) {
                Widget widget;
                switch (item.type) {
                  case 'space':
                    return const Spacer();
                  case 'location':
                    widget = Container(
                      height: this.widget.preferredSize.height,
                      padding: EdgeInsets.only(
                        left: item.paddingLeft.toDouble(),
                        right: item.paddingRight.toDouble(),
                        top: item.paddingTop.toDouble(),
                        bottom: item.paddingBottom.toDouble(),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (!item.hideTitle)
                            Row(
                              children: [
                                const SizedBox(width: 4.0),
                                Text(
                                  item.title ?? S.of(context).selectAddress,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 16.0,
                                ),
                                const Spacer(),
                              ],
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              DeferredWidget(
                                defer_icon.loadLibrary,
                                () => Icon(
                                  defer_icon.iconPicker(
                                    item.icon!,
                                    item.fontFamily!,
                                  ),
                                  size: item.iconSize.toDouble(),
                                  color: item.iconColor != null
                                      ? HexColor(item.iconColor)
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  currentAddress?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                    break;
                  case 'text':
                    widget = Container(
                      alignment: Tools.getAlignment(
                        item.alignment,
                        defaultValue: Alignment.center,
                      ),
                      height: this.widget.preferredSize.height,
                      padding: EdgeInsets.only(
                        left: item.paddingLeft.toDouble(),
                        right: item.paddingRight.toDouble(),
                        top: item.paddingTop.toDouble(),
                        bottom: item.paddingBottom.toDouble(),
                      ),
                      child: Text(
                        item.title ?? '',
                        style: TextStyle(
                          fontSize: Helper.formatDouble(item.fontSize),
                          fontWeight: Tools.getFontWeight(
                            item.fontWeight,
                            defaultValue: FontWeight.w300,
                          ),
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(
                                  Helper.formatDouble(item.textOpacity) ?? 0.5),
                        ),
                      ),
                    );
                    break;
                  case 'search':
                    widget = Padding(
                      padding: EdgeInsets.only(
                        left: item.paddingLeft.toDouble(),
                        right: item.paddingRight.toDouble(),
                        top: item.paddingTop.toDouble(),
                        bottom: item.paddingBottom.toDouble(),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          DeferredWidget(
                            defer_icon.loadLibrary,
                            () => Icon(
                              defer_icon.iconPicker(
                                item.icon!,
                                item.fontFamily!,
                              ),
                              size: item.iconSize.toDouble(),
                              color: item.iconColor != null
                                  ? HexColor(item.iconColor)
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            width: 4.0,
                            height: this.widget.preferredSize.height,
                          ),
                          if (!item.hideTitle)
                            Text(
                              item.title ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(
                                    fontSize:
                                        Helper.formatDouble(item.fontSize),
                                    fontWeight: Tools.getFontWeight(
                                      item.fontWeight,
                                      defaultValue: FontWeight.w300,
                                    ),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(Helper.formatDouble(
                                                item.textOpacity) ??
                                            0.5),
                                  ),
                            ),
                        ],
                      ),
                    );
                    break;
                  case 'icon':
                    widget = SizedBox(
                      height: item.size.toDouble(),
                      width: item.size.toDouble(),
                      child: IconButton(
                        color: item.iconColor != null
                            ? HexColor(item.iconColor)
                            : Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.9),
                        iconSize: item.iconSize.toDouble(),
                        padding: EdgeInsets.only(
                          left: item.paddingLeft.toDouble(),
                          right: item.paddingRight.toDouble(),
                          top: item.paddingTop.toDouble(),
                          bottom: item.paddingBottom.toDouble(),
                        ),
                        icon: DeferredWidget(
                          defer_icon.loadLibrary,
                          () => Icon(
                            defer_icon.iconPicker(
                              item.icon!,
                              item.fontFamily!,
                            ),
                          ),
                        ),
                        onPressed: () => handleItemAction(item),
                      ),
                    );
                    break;
                  case 'image':
                    widget = Padding(
                      padding: EdgeInsets.only(
                        left: item.paddingLeft.toDouble(),
                        right: item.paddingRight.toDouble(),
                        top: item.paddingTop.toDouble(),
                        bottom: item.paddingBottom.toDouble(),
                      ),
                      child: InkWell(
                        onTap: () => handleItemAction(item),
                        child: FluxImage(
                          imageUrl: item.image!,
                          width: item.width?.toDouble(),
                          height: item.height?.toDouble(),
                          fit: ImageTools.boxFit(item.imageBoxFit),
                          color: item.imageColor != null
                              ? HexColor(item.imageColor)
                              : null,
                        ),
                      ),
                    );
                    break;
                  default:
                    return const SizedBox();
                }

                /// Add badge number.
                if (item.type == 'icon' &&
                    ['cart', 'notification'].contains(item.action)) {
                  var badgeCount = 0;
                  if (item.action == 'notification') {
                    badgeCount =
                        Provider.of<NotificationModel>(context).unreadCount;
                  }
                  if (item.action == 'cart') {
                    badgeCount =
                        Provider.of<CartModel>(context).totalCartQuantity;
                  }

                  widget = Stack(
                    children: [
                      widget,
                      if (badgeCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  );
                }

                /// Add margin & background.
                widget = Container(
                  decoration: BoxDecoration(
                    color: item.backgroundColor != null
                        ? HexColor(item.backgroundColor)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(item.radius.toDouble()),
                  ),
                  margin: EdgeInsets.only(
                    left: item.marginLeft.toDouble(),
                    right: item.marginRight.toDouble(),
                    top: item.marginTop.toDouble(),
                    bottom: item.marginBottom.toDouble(),
                  ),
                  child: widget,
                );

                /// Handle expanded widget.
                if (['search', 'text', 'location'].contains(item.type)) {
                  widget = Expanded(
                    child: GestureDetector(
                      onTap: () => handleItemAction(item),
                      child: widget,
                    ),
                  );
                }

                return widget;
              },
            ).toList() ??
            [],
      ),
    );
  }

  void handleItemAction(AppBarItemConfig item) {
    switch (item.action) {
      case 'home':
        NavigateTools.navigateHome(context);
        break;
      case 'menu':
        NavigateTools.onTapOpenDrawerMenu(context);
        break;
      case 'search':
        FluxNavigate.pushNamed(RouteList.homeSearch);
        break;
      case 'cart':
        FluxNavigate.pushNamed(RouteList.cart);
        break;
      case 'location':
        handleSelectAddress(context);
        break;
      case 'wishlist':
        FluxNavigate.pushNamed(RouteList.wishlist);
        break;
      case 'notification':
        FluxNavigate.pushNamed(RouteList.notify);
        break;
      default:
    }
  }

  void handleSelectAddress(BuildContext context) async {
    var result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => isDesktop
            ? const PlatformError()
            : PlacePicker(
                kIsWeb
                    ? kGoogleAPIKey['web']
                    : isIos
                        ? kGoogleAPIKey['ios']
                        : kGoogleAPIKey['android'],
              ),
      ),
    );

    final address = Address();

    if (result != null) {
      address.country = result.country;
      address.street = result.street;
      address.state = result.addressState;
      address.city = result.city;
      address.zipCode = result.zip;
      address.mapUrl =
          'https://maps.google.com/maps?q=${result.latLng.latitude},${result.latLng.longitude}&output=embed';

      setState(() {
        currentAddress = address;
      });

      Provider.of<CartModel>(context, listen: false).setAddress(address);
    }
  }
}
