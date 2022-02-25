import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../screens/base_screen.dart';
import 'animated_splash.dart';
import 'flare_splash_screen.dart';
import 'rive_splashscreen.dart';
import 'static_splashscreen.dart';

class SplashScreenIndex extends StatelessWidget {
  final Function actionDone;
  final String splashScreenType;
  final String imageUrl;
  final int duration;

  const SplashScreenIndex({
    Key? key,
    required this.actionDone,
    required this.imageUrl,
    this.splashScreenType = SplashScreenTypeConstants.static,
    this.duration = 2000,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kSplashScreen['enable'] ?? true) {
      switch (splashScreenType) {
        case SplashScreenTypeConstants.rive:
          var animationName = kSplashScreen['animationName'];
          return RiveSplashScreen(
            onSuccess: actionDone,
            imageUrl: imageUrl,
            animationName: animationName,
            duration: duration,
          );
        case SplashScreenTypeConstants.flare:
          return SplashScreen.navigate(
            name: imageUrl,
            startAnimation: kSplashScreen['animationName'],
            backgroundColor: Colors.white,
            next: actionDone,
            until: () => Future.delayed(Duration(milliseconds: duration)),
          );
        case SplashScreenTypeConstants.fadeIn:
        case SplashScreenTypeConstants.topDown:
        case SplashScreenTypeConstants.zoomIn:
        case SplashScreenTypeConstants.zoomOut:
          return AnimatedSplash(
            imagePath: imageUrl,
            animationEffect: splashScreenType,
            next: actionDone,
            duration: duration,
          );
        case SplashScreenTypeConstants.static:
        default:
          return StaticSplashScreen(
            imagePath: imageUrl,
            onNextScreen: actionDone,
            duration: duration,
          );
      }
    } else {
      return _EmptySplashScreen(
        onNextScreen: actionDone,
      );
    }
  }
}

class _EmptySplashScreen extends StatefulWidget {
  final Function? onNextScreen;
  const _EmptySplashScreen({Key? key, this.onNextScreen}) : super(key: key);

  @override
  _EmptySplashScreenState createState() => _EmptySplashScreenState();
}

class _EmptySplashScreenState extends BaseScreen<_EmptySplashScreen> {
  @override
  void afterFirstLayout(BuildContext context) {
    widget.onNextScreen!();
  }

  @override
  Widget build(BuildContext context) {
    return kLoadingWidget(context);
  }
}
