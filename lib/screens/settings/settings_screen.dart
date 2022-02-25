import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:inspireui/icons/icon_picker.dart';
import 'package:inspireui/inspireui.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/config/configuration_utils.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, ProductWishListModel, User, UserModel;
import '../../models/notification_model.dart';
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/common/index.dart';
import '../../widgets/common/webview.dart';
import '../../widgets/general/index.dart';
import '../common/app_bar_mixin.dart';
import '../index.dart';
import '../posts/post_screen.dart';
import '../users/user_point_screen.dart';

const itemPadding = 15.0;

class SettingScreen extends StatefulWidget {
  final List<dynamic>? settings;
  final Map? subGeneralSetting;
  final String? background;
  final Map? drawerIcon;
  final VoidCallback? onLogout;

  const SettingScreen({
    this.onLogout,
    this.settings,
    this.subGeneralSetting,
    this.background,
    this.drawerIcon,
  });

  @override
  SettingScreenState createState() {
    return SettingScreenState();
  }
}

class SettingScreenState extends State<SettingScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SettingScreen>,
        AppBarMixin {
  @override
  bool get wantKeepAlive => true;

  User? get user => Provider.of<UserModel>(context, listen: false).user;
  bool isAbleToPostManagement = false;

  final bannerHigh = 150.0;
  final RateMyApp _rateMyApp = RateMyApp(
      // rate app on store
      minDays: 7,
      minLaunches: 10,
      remindDays: 7,
      remindLaunches: 10,
      googlePlayIdentifier: kStoreIdentifier['android'],
      appStoreIdentifier: kStoreIdentifier['ios']);

  void showRateMyApp() {
    _rateMyApp.showRateDialog(
      context,
      title: S.of(context).rateTheApp,
      // The dialog title.
      message: S.of(context).rateThisAppDescription,
      // The dialog message.
      rateButton: S.of(context).rate.toUpperCase(),
      // The dialog 'rate' button text.
      noButton: S.of(context).noThanks.toUpperCase(),
      // The dialog 'no' button text.
      laterButton: S.of(context).maybeLater.toUpperCase(),
      // The dialog 'later' button text.
      listener: (button) {
        // The button click listener (useful if you want to cancel the click event).
        switch (button) {
          case RateMyAppDialogButton.rate:
            break;
          case RateMyAppDialogButton.later:
            break;
          case RateMyAppDialogButton.no:
            break;
        }

        return true; // Return false if you want to cancel the click event.
      },
      // Set to false if you want to show the native Apple app rating dialog on iOS.
      dialogStyle: const DialogStyle(),
      // Custom dialog styles.
      // Called when the user dismissed the dialog (either by taping outside or by pressing the 'back' button).
      // actionsBuilder: (_) => [], // This one allows you to use your own buttons.
    );
  }

  void checkAddPostRole() {
    for (var legitRole in addPostAccessibleRoles) {
      if (user!.role == legitRole) {
        setState(() {
          isAbleToPostManagement = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (isMobile) {
      if (!kStoreIdentifier['disable']) {
        _rateMyApp.init().then((_) {
          // state of rating the app
          if (_rateMyApp.shouldOpenDialog) {
            showRateMyApp();
          }
        });
      }
    }
  }

  /// Render the Delivery Menu.
  /// Currently support WCFM
  Widget renderDeliveryBoy() {
    var isDelivery = user?.isDeliveryBoy ?? false;

    if (!isDelivery) {
      return const SizedBox();
    }

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          FluxNavigate.push(
            MaterialPageRoute(
              builder: (context) =>
                  Services().widget.getDeliveryScreen(context, user)!,
            ),
            forceRootNavigator: true,
          );
        },
        leading: Icon(
          CupertinoIcons.cube_box,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          S.of(context).deliveryManagement,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  /// Render the Admin Vendor Menu.
  /// Currently support WCFM & Dokan. Will support WooCommerce soon.
  Widget renderVendorAdmin() {
    var isVendor = user?.isVender ?? false;

    if (!isVendor) {
      return const SizedBox();
    }

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          FluxNavigate.pushNamed(
            RouteList.vendorAdmin,
            arguments: user,
            forceRootNavigator: true,
          );
        },
        leading: Icon(
          Icons.dashboard,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          S.of(context).vendorAdmin,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget renderVendorVacation() {
    var isVendor = user?.isVender ?? false;

    if ((kFluxStoreMV.contains(serverConfig['type']) && !isVendor) ||
        serverConfig['type'] != 'wcfm' ||
        !kVendorConfig['DisableNativeStoreManagement']) {
      return const SizedBox();
    }

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          FluxNavigate.push(
            MaterialPageRoute(
              builder: (context) => Services().widget.renderVacationVendor(
                  user!.id!, user!.cookie!,
                  isFromMV: true),
            ),
            forceRootNavigator: true,
          );
        },
        leading: Icon(
          Icons.house,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          S.of(context).storeVacation,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  /// Render the custom profile link via Webview
  /// Example show some special profile on the woocommerce site: wallet, wishlist...
  Widget renderWebViewProfile() {
    if (user == null) {
      return Container();
    }

    var base64Str = EncodeUtils.encodeCookie(user!.cookie!);
    var profileURL = '${serverConfig['url']}/my-account?cookie=$base64Str';

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebView(
                  url: profileURL, title: S.of(context).updateUserInfor),
            ),
          );
        },
        leading: Icon(
          CupertinoIcons.profile_circled,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          S.of(context).updateUserInfor,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.secondary,
          size: 18,
        ),
      ),
    );
  }

  Widget renderItem(value) {
    IconData icon;
    String title;
    Widget trailing;
    Function() onTap;
    var isMultiVendor = kFluxStoreMV.contains(serverConfig['type']);
    var subGeneralSetting = widget.subGeneralSetting != null
        ? ConfigurationUtils.loadSubGeneralSetting(widget.subGeneralSetting!)
        : kSubGeneralSetting;
    var item = subGeneralSetting[value];

    if (value.contains('web')) {
      return GeneralWebWidget(item: item);
    }

    if (value.contains('post-')) {
      return GeneralPostWidget(item: item);
    }

    if (value.contains('title')) {
      return GeneralTitleWidget(item: item, itemPadding: itemPadding);
    }

    if (value.contains('button')) {
      return GeneralButtonWidget(item: item);
    }

    switch (value) {
      case 'products':
        {
          if (!(user != null ? user!.isVender : false) || !isMultiVendor) {
            return const SizedBox();
          }
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          title = S.of(context).myProducts;
          icon = CupertinoIcons.cube_box;
          onTap = () => Navigator.pushNamed(context, RouteList.productSell);
          break;
        }

      case 'chat':
        {
          if (user == null || Config().isListingType || !isMultiVendor) {
            return Container();
          }
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          title = S.of(context).conversations;
          icon = CupertinoIcons.chat_bubble_2;
          onTap = () => Navigator.pushNamed(context, RouteList.listChat);
          break;
        }
      case 'wallet':
        {
          if (user == null || !Config().isWooType) {
            return Container();
          }
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          title = S.of(context).myWallet;
          icon = CupertinoIcons.square_favorites_alt;
          onTap = () => FluxNavigate.pushNamed(
                RouteList.myWallet,
                forceRootNavigator: true,
              );
          break;
        }
      case 'wishlist':
        {
          final wishListCount =
              Provider.of<ProductWishListModel>(context, listen: false)
                  .products
                  .length;
          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (wishListCount > 0)
                Text(
                  '$wishListCount ${S.of(context).items}',
                  style: TextStyle(
                      fontSize: 14, color: Theme.of(context).primaryColor),
                ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600)
            ],
          );

          title = S.of(context).myWishList;
          icon = CupertinoIcons.heart;
          onTap = () => Navigator.of(context).pushNamed(RouteList.wishlist);
          break;
        }
      case 'notifications':
        {
          return Consumer<NotificationModel>(builder: (context, model, child) {
            return Column(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 2.0),
                  elevation: 0,
                  child: SwitchListTile(
                    secondary: Icon(
                      CupertinoIcons.bell,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                    value: model.enable,
                    activeColor: const Color(0xFF0066B4),
                    onChanged: (bool enableNotification) {
                      if (enableNotification) {
                        model.enableNotification();
                      } else {
                        model.disableNotification();
                      }
                    },
                    title: Text(
                      S.of(context).getNotification,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.black12,
                  height: 1.0,
                  indent: 75,
                  //endIndent: 20,
                ),
                if (model.enable) ...[
                  Card(
                    margin: const EdgeInsets.only(bottom: 2.0),
                    elevation: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteList.notify);
                      },
                      child: ListTile(
                        leading: Icon(
                          CupertinoIcons.list_bullet,
                          size: 22,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(S.of(context).listMessages),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: kGrey600,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.black12,
                    height: 1.0,
                    indent: 75,
                    //endIndent: 20,
                  ),
                ],
              ],
            );
          });
        }
      case 'language':
        {
          icon = CupertinoIcons.globe;
          title = S.of(context).language;
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          onTap = () => Navigator.of(context).pushNamed(RouteList.language);
          break;
        }
      case 'currencies':
        {
          if (Config().isListingType) {
            return Container();
          }
          icon = CupertinoIcons.money_dollar_circle;
          title = S.of(context).currencies;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.of(context).pushNamed(RouteList.currencies);
          break;
        }
      case 'darkTheme':
        {
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 2.0),
                elevation: 0,
                child: SwitchListTile(
                  secondary: Icon(
                    Provider.of<AppModel>(context).darkTheme
                        ? CupertinoIcons.sun_min
                        : CupertinoIcons.moon,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  value: Provider.of<AppModel>(context).darkTheme,
                  activeColor: const Color(0xFF0066B4),
                  onChanged: (bool value) {
                    if (value) {
                      Provider.of<AppModel>(context, listen: false)
                          .updateTheme(true);
                    } else {
                      Provider.of<AppModel>(context, listen: false)
                          .updateTheme(false);
                    }
                  },
                  title: Text(
                    S.of(context).darkTheme,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black12,
                height: 1.0,
                indent: 75,
                //endIndent: 20,
              ),
            ],
          );
        }
      case 'order':
        {
          final storage = LocalStorage('data_order');
          var items = storage.getItem('orders');
          if (user == null && items == null) {
            return Container();
          }
          if (Config().isListingType) {
            return const SizedBox();
          }
          icon = CupertinoIcons.time;
          title = S.of(context).orderHistory;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {
            final user = Provider.of<UserModel>(context, listen: false).user;
            FluxNavigate.pushNamed(
              RouteList.orders,
              arguments: user,
            );
          };
          break;
        }
      case 'point':
        {
          if (!(kAdvanceConfig['EnablePointReward'] == true && user != null)) {
            return const SizedBox();
          }
          if (Config().isListingType) {
            return const SizedBox();
          }
          icon = CupertinoIcons.bag_badge_plus;
          title = S.of(context).myPoints;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPointScreen(),
                ),
              );
          break;
        }
      case 'rating':
        {
          icon = CupertinoIcons.star;
          title = S.of(context).rateTheApp;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = showRateMyApp;
          break;
        }
      case 'privacy':
        {
          icon = CupertinoIcons.doc_text;
          title = S.of(context).agreeWithPrivacy;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {
            final privacy = subGeneralSetting['privacy'];
            final pageId =
                privacy?.pageId ?? kAdvanceConfig['PrivacyPoliciesPageId'];
            String? pageUrl =
                privacy?.webUrl ?? kAdvanceConfig['PrivacyPoliciesPageUrl'];
            if (pageId != null && (privacy?.webUrl?.isEmpty ?? true)) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostScreen(
                        pageId: pageId,
                        pageTitle: S.of(context).agreeWithPrivacy),
                  ));
              return;
            }
            if (pageUrl?.isNotEmpty ?? false) {
              ///Display multiple languages WebView
              var locale =
                  Provider.of<AppModel>(context, listen: false).langCode;
              if (pageUrl != null && locale != null) {
                pageUrl += '?lang=$locale';
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebView(
                    url: pageUrl,
                    title: S.of(context).agreeWithPrivacy,
                  ),
                ),
              );
            }
          };
          break;
        }
      case 'about':
        {
          icon = CupertinoIcons.info;
          title = S.of(context).aboutUs;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {
            final about = subGeneralSetting['about'];
            final aboutUrl = about?.webUrl ?? SettingConstants.aboutUsUrl;

            if (kIsWeb) {
              return Tools.launchURL(aboutUrl);
            }
            return FluxNavigate.push(
              MaterialPageRoute(
                builder: (context) =>
                    WebView(url: aboutUrl, title: S.of(context).aboutUs),
              ),
              forceRootNavigator: true,
            );
          };
          break;
        }
      case 'post':
        {
          if (user != null) {
            trailing = const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: kGrey600,
            );
            title = S.of(context).postManagement;
            icon = CupertinoIcons.chat_bubble_2;
            onTap = () {
              Navigator.of(context).pushNamed(RouteList.postManagement);
            };
          } else {
            return const SizedBox();
          }

          break;
        }
      default:
        {
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          icon = Icons.error;
          title = S.of(context).dataEmpty;
          onTap = () {};
        }
    }
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 2.0),
          elevation: 0,
          child: ListTile(
            leading: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
        const Divider(
          color: Colors.black12,
          height: 1.0,
          indent: 75,
          //endIndent: 20,
        ),
      ],
    );
  }

  Widget renderDrawerIcon() {
    var icon = Icons.blur_on;
    if (widget.drawerIcon != null) {
      icon = iconPicker(
              widget.drawerIcon!['icon'], widget.drawerIcon!['fontFamily']) ??
          Icons.blur_on;
    }
    return Icon(
      icon,
      color: Colors.white70,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var settings = widget.settings ?? kDefaultSettings;
    var background = widget.background ?? kProfileBackground;
    const textStyle = TextStyle(fontSize: 16);

    final appBar = (showAppBar(RouteList.profile))
        ? sliverAppBarWidget
        : SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              icon: renderDrawerIcon(),
              onPressed: () => NavigateTools.onTapOpenDrawerMenu(context),
            ),
            expandedHeight: bannerHigh,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                S.of(context).settings,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              background: FluxImage(
                imageUrl: background,
                fit: BoxFit.cover,
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListenableProvider.value(
        value: Provider.of<UserModel>(context),
        child: Consumer<UserModel>(builder: (context, model, child) {
          final user = model.user;
          final loggedIn = model.loggedIn;
          return CustomScrollView(
            slivers: <Widget>[
              appBar,
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10.0),
                          if (user != null && user.name != null)
                            ListTile(
                              leading: (user.picture?.isNotEmpty ?? false)
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.picture!),
                                    )
                                  : const Icon(Icons.face),
                              title: Text(
                                user.name!.replaceAll('fluxstore', ''),
                                style: textStyle,
                              ),
                            ),
                          if (user != null &&
                              user.email != null &&
                              user.email!.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: Text(
                                user.email!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          if (user != null && !Config().isWordPress)
                            Card(
                              color: Theme.of(context).backgroundColor,
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                leading: Icon(
                                  Icons.portrait,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 25,
                                ),
                                title: Text(
                                  S.of(context).updateUserInfor,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: kGrey600,
                                ),
                                onTap: () {
                                  FluxNavigate.pushNamed(
                                    RouteList.updateUser,
                                    forceRootNavigator: true,
                                  );
                                },
                              ),
                            ),
                          if (user == null)
                            Card(
                              color: Theme.of(context).backgroundColor,
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  if (!loggedIn) {
                                    Navigator.of(
                                      App.fluxStoreNavigatorKey.currentContext!,
                                    ).pushNamed(RouteList.login);
                                    return;
                                  }
                                  Provider.of<UserModel>(context, listen: false)
                                      .logout();
                                  if (kLoginSetting['IsRequiredLogin'] ??
                                      false) {
                                    Navigator.of(
                                      App.fluxStoreNavigatorKey.currentContext!,
                                    ).pushNamedAndRemoveUntil(
                                      RouteList.login,
                                      (route) => false,
                                    );
                                  }
                                },
                                leading: const Icon(Icons.person),
                                title: Text(
                                  loggedIn
                                      ? S.of(context).logout
                                      : S.of(context).login,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: kGrey600),
                              ),
                            ),
                          if (user != null)
                            Card(
                              color: Theme.of(context).backgroundColor,
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  Provider.of<CartModel>(context, listen: false)
                                      .clearAddress();
                                  Provider.of<UserModel>(context, listen: false)
                                      .logout();
                                  if (kLoginSetting['IsRequiredLogin'] ??
                                      false) {
                                    Navigator.of(App.fluxStoreNavigatorKey
                                            .currentContext!)
                                        .pushNamedAndRemoveUntil(
                                      RouteList.login,
                                      (route) => false,
                                    );
                                  }
                                },
                                leading: Icon(
                                  Icons.logout,
                                  size: 20,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),

                                // Image.asset(
                                //   'assets/icons/profile/icon-logout.png',
                                //   width: 24,
                                //   color: Theme.of(context).colorScheme.secondary,
                                // ),
                                title: Text(
                                  S.of(context).logout,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: kGrey600),
                              ),
                            ),
                          const SizedBox(height: 30.0),
                          Text(
                            S.of(context).generalSetting,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10.0),
                          renderVendorAdmin(),

                          /// Render some extra menu for Vendor.
                          /// Currently support WCFM & Dokan. Will support WooCommerce soon.
                          if (kFluxStoreMV.contains(serverConfig['type']) &&
                              (user?.isVender ?? false)) ...[
                            Services().widget.renderVendorOrder(context),
                            renderVendorVacation(),
                          ],

                          renderDeliveryBoy(),

                          /// Render custom Wallet feature
                          // renderWebViewProfile(),

                          /// render some extra menu for Listing
                          if (user != null && Config().isListingType) ...[
                            Services().widget.renderNewListing(context),
                            Services().widget.renderBookingHistory(context),
                          ],

                          const SizedBox(height: 10.0),
                          if (user != null)
                            const Divider(
                              color: Colors.black12,
                              height: 1.0,
                              indent: 75,
                              //endIndent: 20,
                            ),
                        ],
                      ),
                    ),

                    /// render list of dynamic menu
                    /// this could be manage from the Fluxbuilder
                    ...List.generate(
                      settings.length,
                      (index) {
                        var item = settings[index];
                        var isTitle = item.contains('title');
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isTitle ? 0.0 : itemPadding),
                          child: renderItem(item),
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
