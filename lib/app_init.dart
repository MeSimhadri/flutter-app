import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'models/index.dart'
    show
        AppModel,
        CategoryModel,
        FilterAttributeModel,
        FilterTagModel,
        ListingLocationModel,
        TagModel;
import 'modules/dynamic_layout/config/app_config.dart';
import 'screens/base_screen.dart';
import 'screens/blog/models/list_blog_model.dart';
import 'services/dependency_injection.dart';
import 'services/index.dart';
import 'widgets/common/splash_screen.dart';

class AppInit extends StatefulWidget {
  const AppInit();

  @override
  _AppInitState createState() => _AppInitState();
}

class _AppInitState extends BaseScreen<AppInit> {
  bool isFirstSeen = false;
  bool isLoggedIn = false;
  bool hasLoadedData = false;
  bool hasLoadedSplash = false;

  late AppConfig? appConfig;

  /// check if the screen is already seen At the first time
  bool checkFirstSeen() {
    /// Ignore if OnBoardOnlyShowFirstTime is set to true.
    if (kAdvanceConfig['OnBoardOnlyShowFirstTime'] == false) {
      return false;
    }

    final _seen =
        injector<SharedPreferences>().getBool(LocalStorageKey.seen) ?? false;
    return _seen;
  }

  /// Check if the App is Login
  bool checkLogin() {
    final hasLogin =
        injector<SharedPreferences>().getBool(LocalStorageKey.loggedIn);
    return hasLogin ?? false;
  }

  Future<void> loadInitData() async {
    try {
      printLog('[AppState] Init Data 💫');
      isFirstSeen = checkFirstSeen();
      isLoggedIn = checkLogin();

      /// set the server config at first loading
      /// Load App model config
      if (Config().isBuilder) {
        Services().setAppConfig(serverConfig);
      }
      appConfig =
          await Provider.of<AppModel>(context, listen: false).loadAppConfig();

      Future.delayed(Duration.zero, () {

        /// Load more Category/Blog/Attribute Model beforehand
        final lang = Provider.of<AppModel>(context, listen: false).langCode;

        /// Request Categories
        Provider.of<CategoryModel>(context, listen: false).getCategories(
          lang: lang,
          sortingList: Provider.of<AppModel>(context, listen: false).categories,
          categoryLayout:
              Provider.of<AppModel>(context, listen: false).categoryLayout,
        );
        hasLoadedData = true;
        if (hasLoadedSplash) {
          goToNextScreen();
        }
      });

      /// Request more Async data which is not use on home screen
      Future.delayed(
        Duration.zero,
        () {
          Provider.of<TagModel>(context, listen: false).getTags();

          Provider.of<ListBlogModel>(context, listen: false).getBlogs();

          Provider.of<FilterTagModel>(context, listen: false).getFilterTags();

          Provider.of<FilterAttributeModel>(context, listen: false)
              .getFilterAttributes();

          Provider.of<AppModel>(context, listen: false).loadCurrency();

          if (Config().isListingType) {
            Provider.of<ListingLocationModel>(context, listen: false)
                .getLocations();
          }

          /// init Facebook & Google Ads
          Services()
              .advertisement
              .initAdvertise(context.read<AppModel>().advertisement);
        },
      );

      printLog('[AppState] InitData Finish');
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  void goToNextScreen() {
    if (!isFirstSeen && !kIsWeb && appConfig != null) {
      if (onBoardingData.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(RouteList.onBoarding);
        return;
      }
    }

    if (kLoginSetting['IsRequiredLogin'] && !isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(RouteList.login);
      return;
    }

    Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
  }

  void checkToShowNextScreen() {
    /// If the config was load complete then navigate to Dashboard
    hasLoadedSplash = true;
    if (hasLoadedData) {
      goToNextScreen();
      return;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await loadInitData();
  }

  @override
  Widget build(BuildContext context) {
    var splashScreenType = kSplashScreen['type'];
    dynamic splashScreenImage = kSplashScreen['image'];
    var duration = kSplashScreen['duration'] ?? 2000;
    return SplashScreenIndex(
      imageUrl: splashScreenImage,
      splashScreenType: splashScreenType,
      actionDone: checkToShowNextScreen,
      duration: duration,
    );
  }
}
