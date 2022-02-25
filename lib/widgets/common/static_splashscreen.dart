import 'package:flutter/material.dart';

import '../../screens/base_screen.dart';
import 'flux_image.dart';

class StaticSplashScreen extends StatefulWidget {
  final String? imagePath;
  final Function? onNextScreen;
  final int duration;

  const StaticSplashScreen({
    this.imagePath,
    key,
    this.onNextScreen,
    this.duration = 2500,
  }) : super(key: key);

  @override
  _StaticSplashScreenState createState() => _StaticSplashScreenState();
}

class _StaticSplashScreenState extends BaseScreen<StaticSplashScreen> {
  @override
  void afterFirstLayout(BuildContext context) {
    Future.delayed(Duration(milliseconds: widget.duration), () {
      widget.onNextScreen!();
//      Navigator.of(context).pushReplacement(
//          MaterialPageRoute(builder: (context) => widget.onNextScreen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: widget.imagePath!.startsWith('http')
            ? FluxImage(
                imageUrl: widget.imagePath!,
                fit: BoxFit.contain,
              )
            : Image.asset(
                widget.imagePath!,
                gaplessPlayback: true,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
