import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/config.dart' as config;
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel;
import 'change_language_mixin.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen();

  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> with ChangeLanguage {
  final isRequiredLogin = config.kLoginSetting['IsRequiredLogin'];
  int page = 0;

  List<Slide> getSlides(List<dynamic> data) {
    final slides = <Slide>[];

    Widget renderLoginWidget(String imagePath) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Image.asset(
            imagePath,
            fit: BoxFit.fitWidth,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    var prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seen', true);
                    await Navigator.pushReplacementNamed(
                        context, RouteList.login);
                  },
                  child: Text(
                    S.of(context).signIn,
                    style: const TextStyle(
                      color: kTeal400,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                const Text(
                  '    |    ',
                  style: TextStyle(color: kTeal400, fontSize: 20.0),
                ),
                GestureDetector(
                  onTap: () async {
                    var prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seen', true);
                    await Navigator.pushReplacementNamed(
                        context, RouteList.register);
                  },
                  child: Text(
                    S.of(context).signUp,
                    style: const TextStyle(
                      color: kTeal400,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    for (var i = 0; i < data.length; i++) {
      var slide = Slide(
        title: data[i]['title'],
        description: data[i]['desc'],
        marginTitle: const EdgeInsets.only(
          top: 125.0,
          bottom: 50.0,
        ),
        maxLineTextDescription: 2,
        styleTitle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: kGrey900,
        ),
        backgroundColor: Colors.white,
        marginDescription: const EdgeInsets.fromLTRB(20.0, 75.0, 20.0, 0),
        styleDescription: const TextStyle(
          fontSize: 15.0,
          color: kGrey600,
        ),
        foregroundImageFit: BoxFit.fitWidth,
      );

      if (i == 2) {
        slide.centerWidget = renderLoginWidget(data[i]['image']);
      } else {
        slide.pathImage = data[i]['image'];
      }
      slides.add(slide);
    }
    return slides;
  }

  void onTapDone() async {
    if (isRequiredLogin) {
      return;
    }
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);
    await Navigator.pushReplacementNamed(context, RouteList.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final data = config.onBoardingData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Consumer<AppModel>(builder: (context, _, __) {
            return Container(
              key: UniqueKey(),
              child: IntroSlider(
                slides: getSlides(data),
                renderSkipBtn: Text(
                  S.of(context).skip,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                renderDoneBtn: Text(
                  isRequiredLogin ? '' : S.of(context).done,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                renderPrevBtn: Text(
                  S.of(context).prev,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                renderNextBtn: Text(
                  S.of(context).next,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                showDoneBtn: !isRequiredLogin,
                onDonePress: onTapDone,
              ),
            );
          }),
          iconLanguage(),
        ],
      ),
    );
  }
}
