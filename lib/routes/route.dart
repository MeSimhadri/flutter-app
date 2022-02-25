import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show AutoHideKeyboard, StoryWidget;
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../menu/maintab.dart';
import '../models/brand_model.dart';
import '../models/index.dart'
    show
        AppModel,
        BackDropArguments,
        BlogModel,
        Product,
        ProductModel,
        SearchModel,
        User,
        UserModel;
import '../modules/dynamic_layout/config/app_config.dart';
// import '../modules/membership_ultimate/route.dart';
import '../screens/brand/brand_backdrop.dart';
import '../screens/index.dart';
import '../screens/order_history/index.dart';
import '../screens/pages/static_page.dart';
import '../screens/user_update/user_update_screen.dart';
import '../screens/user_update/user_update_woo_screen.dart';
import '../services/index.dart';

export 'route_observer.dart';

class Routes {
  static Map<String, WidgetBuilder> getAll() => _routes;

  static final Map<String, WidgetBuilder> _routes = {
    RouteList.dashboard: (context) => MainTabs(audioService: injector.get()),
    RouteList.register: (context) => const RegistrationScreen(),
    RouteList.login: (context) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      return LoginScreen(
        login: userModel.login,
        loginFB: userModel.loginFB,
        loginApple: userModel.loginApple,
        loginGoogle: userModel.loginGoogle,
      );
    },
    RouteList.loginSMS: (context) => const LoginSMSScreen(),
    RouteList.products: (context) => const ProductsScreen(),
    RouteList.wishlist: (context) => Services().widget.renderWishListScreen(),
    RouteList.notify: (context) => NotificationScreen(),
    RouteList.language: (context) => LanguageScreen(),
    RouteList.currencies: (context) => CurrenciesScreen(),
    RouteList.category: (context) => const CategoriesScreen(),
    RouteList.audioPlaylist: (context) =>
        Services().renderAudioPlaylistScreen(),
    // AudioPlaylistScreen(audioService: injector.get()),
    RouteList.search: (context) => ChangeNotifierProvider(
          create: (_) => SearchModel(),
          child: const SearchScreen(),
        ),
    RouteList.updateUser: (context) {
      if (Config().isWooType) {
        return UserUpdateWooScreen();
      }
      return UserUpdateScreen();
    },
  };

  static Route getRouteGenerate(RouteSettings settings) {
    var routingData = settings.name!.getRoutingData;

    printLog('[🧬Builder RouteGenerate] ${routingData.route}');

    switch (routingData.route) {
      case RouteList.backdrop:
        final arguments = settings.arguments;
        if (arguments is BackDropArguments) {
          final config = arguments.config;

          var isWordpressBlog;

          // Brand Back Drop
          if (arguments.brandId != null) {
            final routeSetting = settings.copyWith(name: RouteList.brand);
            return _buildRoute(routeSetting, (context) {
              final brandId = arguments.brandId;
              final brandName = arguments.brandName;
              final brandImg = arguments.brandImg;
              final config = arguments.config;
              final brandModel =
                  Provider.of<BrandModel>(context, listen: false);

              if (brandId != null) {
                brandModel.fetchProductsByBrand(
                  brandId: brandId,
                  brandName: brandName,
                  brandImg: brandImg,
                );
              }

              brandModel.setProductList(<Product>[]); //clear old products
              brandModel.getProductList(
                brandId: brandId,
                page: 1,
                lang: Provider.of<AppModel>(context, listen: false).langCode,
              );
              return BrandPage(
                brandId: brandId,
                config: config,
              );
            });
          }

          if (config != null && !Config().isWordPress) {
            /// Navigate from "See All" in dynamic_blog
            isWordpressBlog = config['type'] == 'blog';
          } else {
            isWordpressBlog = Config().isWordPress;
          }

          /// is Wordpress Blog list
          /// That mean support backdrop, category, etc
          if (isWordpressBlog) {
            final routeSetting = settings.copyWith(name: RouteList.blogs);
            return _buildRoute(routeSetting, (context) {
              final cateId = arguments.cateId;
              final cateName = arguments.cateName;
              final blogs = arguments.data as List<Blog>?;
              final config = arguments.config;
              var categoryId = cateId ?? config?['category'];

              var categoryName = cateName ?? config?['name'];
              final blogModel = Provider.of<BlogModel>(context, listen: false);

              if (categoryId != null) {
                blogModel.fetchBlogsByCategory(
                  categoryId: categoryId,
                  categoryName: categoryName,
                );
              }

              // for caching current blogs list
              if (blogs != null) {
                blogModel.setBlogNewsList(blogs);
                return BlogsPage(blogs: blogs, categoryId: categoryId);
              }

              blogModel.setBlogsList(<Blog>[]); //clear old products
              blogModel.getBlogsList(
                categoryId: categoryId,
                page: 1,
                lang: Provider.of<AppModel>(context, listen: false).langCode,
              );
              return BlogsPage(blogs: blogs ?? [], categoryId: categoryId);
            });
          }

          // Woo
          final routeSetting = settings.copyWith(name: RouteList.products);
          return _buildRoute(routeSetting, (context) {
            final cateId = arguments.cateId;
            final cateName = arguments.cateName;
            final tag = arguments.tag;
            final products = arguments.data as List<Product>?;
            final config = arguments.config;
            final showCountdown = arguments.showCountdown;
            final countdownDuration = arguments.countdownDuration;
            try {
              var categoryId = cateId ?? config?['category']?.toString();
              var categoryName = cateName ?? config?['name']?.toString();
              var listingLocationId = config?['location']?.toString();
              final bool? onSale = config?['onSale'];
              final bool? configCountdown =
                  config?['showCountDown'] ?? kSaleOffProduct['ShowCountDown'];

              var tagId = tag ?? config?['tag']?.toString();
              final productModel =
                  Provider.of<ProductModel>(context, listen: false);

              if (kIsWeb || isDisplayDesktop(context)) {
                eventBus.fire(const EventCloseCustomDrawer());
              } else {
                eventBus.fire(const EventCloseNativeDrawer());
              }

              if (productModel.categoryId != categoryId) {
                productModel.setProductsList([]);
              }
              // for fetching beforehand
              if (categoryId != null || listingLocationId != null) {
                productModel.fetchProductsByCategory(
                  categoryId: categoryId,
                  categoryName: categoryName,
                  listingLocationId: listingLocationId,
                );
              } else {
                productModel.setCategoryName(null);
              }

              /// for caching current products list from HomeCache
              if (products != null && products.isNotEmpty) {
                productModel.setProductsList(products);

                return ProductsScreen(
                  products: products,
                  categoryId: categoryId,
                  tagId: tagId,
                  onSale: onSale,
                  listingLocation: listingLocationId,
                  title:
                      (onSale ?? false) && showCountdown ? categoryName : null,
                  showCountdown:
                      configCountdown! && (onSale ?? false) && showCountdown,
                  countdownDuration: countdownDuration,
                );
              }

              /// clear old products
              productModel.updateTagId(
                  tagId: config != null ? config['tag'] : null);

              return ProductsScreen(
                products: products ?? [],
                categoryId: categoryId,
                tagId: tagId,
                onSale: onSale,
                title: (onSale ?? false) && showCountdown ? categoryName : null,
                showCountdown:
                    configCountdown! && (onSale ?? false) && showCountdown,
                countdownDuration: countdownDuration,
                listingLocation: listingLocationId,
              );
            } catch (e, trace) {
              printLog(e.toString());
              printLog(trace.toString());
              return const ProductsScreen();
            }
          });
        }
        return _errorRoute();
      case RouteList.homeSearch:
        return _buildRouteFade(
          settings,
          Services().widget.renderHomeSearchScreen(),
        );

      case RouteList.productDetail:
        Product? product;

        /// The product detail is product
        if (settings.arguments is Product) {
          product = settings.arguments as Product?;
          return _buildRoute(
            settings,
            (_) => ProductDetailScreen(product: product, id: product!.id),
          );
        }

        /// The product detail is ID
        var productId = routingData.getPram('id');
        if (productId != null) {
          return _buildRoute(
            settings,
            (_) => ProductDetailScreen(id: productId),
          );
        }
        return _errorRoute();
      case RouteList.category:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => CategoriesScreen(
              key: const Key('category'),
              showSearch: data.jsonData['showSearch'] ?? true,
            ),
          );
        }
        return _errorRoute();
      case RouteList.categorySearch:
        return _buildRouteFade(
          settings,
          const CategorySearch(),
        );
      case RouteList.detailBlog:
        final arguments = settings.arguments;
        if (arguments is BlogDetailArguments) {
          return _buildRoute(
            settings,
            (_) => BlogDetailScreen(
              blog: arguments.blog,
              id: arguments.id,
              listBlog: arguments.listBlog,
            ),
          );
        }
        return _errorRoute();
      case RouteList.orderDetail:
        final orderHistoryModel = settings.arguments;
        if (orderHistoryModel is OrderHistoryDetailModel) {
          return _buildRoute(
            settings,
            (_) {
              return ChangeNotifierProvider<OrderHistoryDetailModel>.value(
                value: orderHistoryModel,
                child: const OrderHistoryDetailScreen(),
              );
            },
          );
        }
        return _errorRoute();
      case RouteList.orders:
        final user = settings.arguments;
        return _buildRoute(
          settings,
          (_) => ChangeNotifierProvider<ListOrderHistoryModel>(
            create: (context) => ListOrderHistoryModel(
              repository: ListOrderRepository(
                  user: user == null ? User() : user as User),
            ),
            child: ListOrderHistoryScreen(),
          ),
        );
      case RouteList.search:
        return _buildRoute(
          settings,
          (_) => AutoHideKeyboard(
            child: Services().widget.renderSearchScreen(),
          ),
        );
      case RouteList.profile:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => SettingScreen(
              settings: data.jsonData['settings'],
              subGeneralSetting: data.jsonData['subGeneralSetting'],
              background: data.jsonData['background'],
              drawerIcon: data.jsonData['drawerIcon'],
            ),
          );
        }
        return _errorRoute();
      // No usage on this Route found
      // case RouteList.blog:
      //   final data = settings.arguments;
      //   if (data is Map) {
      //     return _buildRoute(
      //       settings,
      //       (_) => HorizontalSliderList(config: data as Map<String, dynamic>?),
      //     );
      //   }
      // return _errorRoute();
      case RouteList.listBlog:
        return _buildRoute(
          settings,
          (_) => ListBlogScreen(),
        );
      case RouteList.page:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => WebViewScreen(
              title: data.jsonData['title'],
              url: data.jsonData['url'],
            ),
          );
        }
        return _errorRoute();
      case RouteList.html:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => StaticSite(data: data.jsonData['data']),
          );
        }
        return _errorRoute();
      case RouteList.static:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => StaticPage(
              data: data.jsonData['data'],
            ),
          );
        }
        return _errorRoute();
      case RouteList.postScreen:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (_) => PostScreen(
              pageId: int.parse(data.jsonData['pageId'].toString()),
              pageTitle: data.jsonData['pageTitle'],
              isLocatedInTabbar: true,
            ),
          );
        }
        return _errorRoute();
      case RouteList.story:
        final data = settings.arguments;
        if (data is Map) {
          return _buildRoute(
            settings,
            (context) => StoryWidget(
              config: data as Map<String, dynamic>,
              isFullScreen: true,
              onTapStoryText: (cfg) {
                NavigateTools.onTapNavigateOptions(
                    context: context, config: cfg);
              },
            ),
          );
        }
        return _errorRoute();
      case RouteList.vendors:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (context) =>
                Services().widget.renderVendorCategoriesScreen(data.jsonData),
          );
        }
        return _errorRoute();
      case RouteList.map:
        return _buildRoute(
          settings,
          (context) => Services().widget.renderMapScreen(),
        );
      case RouteList.vendorDashboard:
        return _buildRoute(
          settings,
          (context) => Services().widget.renderVendorDashBoard(),
        );
      case RouteList.vendorAdmin:
        final data = settings.arguments;
        if (data is User) {
          return _buildRoute(
              settings,
              (context) =>
                  Services().widget.getAdminVendorScreen(context, data));
        }
        return _errorRoute();
      case RouteList.delivery:

        /// If the app needs to call this route, then it definitely is from MV.
        return _buildRoute(
          settings,
          (context) => Services().widget.renderDelivery(isFromMV: true),
        );
      case RouteList.dynamic:
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return _buildRoute(
            settings,
            (context) => DynamicScreen(
                configs: data.jsonData['configs'], previewKey: data.key),
          );
        }
        return _errorRoute(data.toString());
      case RouteList.home:
        return _buildRoute(
          settings,
          (context) => const HomeScreen(),
        );
      case RouteList.onBoarding:
        return _buildRoute(
          settings,
          (context) => const OnBoardScreen(),
        );
      case RouteList.cart:
        final cartArgument = settings.arguments;
        if (cartArgument is CartScreenArgument) {
          return _buildRoute(
            settings,
            (context) => CartScreen(
              isBuyNow: cartArgument.isBuyNow,
              isModal: cartArgument.isModal,
            ),
            fullscreenDialog: true,
          );
        }
        return _buildRoute(
          settings,
          (context) => const CartScreen(),
        );
      case RouteList.postManagement:
        return _buildRoute(
          settings,
          (context) => Services().widget.renderPostManagementScreen(),
        );
      case RouteList.checkout:
        final argument = settings.arguments;
        if (argument is CheckoutArgument) {
          return _buildRoute(
            settings,
            (context) => Checkout(isModal: argument.isModal),
          );
        }
        return _errorRoute();
      default:
        final allRoutes = {
          ...getAll(),
          // ...MembershipUltimateRoute.getRoutesWithSettings(settings)
          //...Services().getWalletRoutesWithSettings(settings)
        };
        if (allRoutes.containsKey(settings.name)) {
          return _buildRoute(
            settings,
            allRoutes[settings.name!]!,
          );
        }

        if (Config().isVendorType()) {
          return _buildRoute(settings, Services().getVendorRoute(settings));
        }
        return _errorRoute();
    }
  }

  static WidgetBuilder? getRouteByName(String name) {
    if (_routes.containsKey(name) == false) {
      return _routes[RouteList.login];
    }
    return _routes[name];
  }

  static Route _errorRoute([String message = 'Page not founds']) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(message),
        ),
      );
    });
  }

  static PageRouteBuilder _buildRouteFade(
    RouteSettings settings,
    Widget builder,
  ) {
    return _FadedTransitionRoute(
      settings: settings,
      widget: builder,
    );
  }

  static MaterialPageRoute _buildRoute(
      RouteSettings settings, WidgetBuilder builder,
      {bool fullscreenDialog = false}) {
    return MaterialPageRoute(
      settings: settings,
      builder: builder,
      fullscreenDialog: fullscreenDialog,
    );
  }
}

class _FadedTransitionRoute extends PageRouteBuilder {
  final Widget? widget;
  @override
  final RouteSettings settings;

  _FadedTransitionRoute({this.widget, required this.settings})
      : super(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget!;
          },
          transitionDuration: const Duration(milliseconds: 100),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        );
}
