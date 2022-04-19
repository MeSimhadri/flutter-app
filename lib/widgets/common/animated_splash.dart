import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fstore/models/app_model.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../screens/base_screen.dart';
import 'flux_image.dart';

class AnimatedSplash extends StatelessWidget {
  const AnimatedSplash({
    Key? key,
    required this.next,
    required this.imagePath,
    this.animationEffect = 'fade-in',
    this.logoSize,
    this.duration = 1000,
  }) : super(key: key);

  final Function? next;
  final String imagePath;
  final int duration;
  final String animationEffect;
  final double? logoSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _AnimatedSplashChild(
        next: next,
        imagePath: imagePath,
        duration: duration,
        animationEffect: animationEffect,
        logoSize: logoSize,
      ),
    );
  }
}

class _AnimatedSplashChild extends StatefulWidget {
  final Function? next;
  final String imagePath;
  final int duration;
  final String animationEffect;
  final double? logoSize;

  const _AnimatedSplashChild({
    required this.next,
    required this.imagePath,
    required this.animationEffect,
    this.logoSize,
    this.duration = 1000,
  });

  @override
  __AnimatedSplashStateChild createState() => __AnimatedSplashStateChild();
}

class __AnimatedSplashStateChild extends BaseScreen<_AnimatedSplashChild>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _slidecontroller;
  late Animation<Offset> _slideanimation;
  // late AnimationController _secondslidecontroller;
  late Animation<Offset> _secondslideanimation; 
  bool isVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController.reset();
    _animationController.forward();
    _slidecontroller.reset();
    _slidecontroller.forward();
    // _secondslidecontroller.reset();
    // _secondslidecontroller.forward();
  }

  @override
  void initState() {
    super.initState();
    _slidecontroller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    // _secondslidecontroller = AnimationController(
    //   duration: const Duration(seconds: 5),
    //   vsync: this,
    // );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3
          // widget.duration
          ),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    ));
    _secondslideanimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      // parent: _secondslidecontroller,
      curve: Interval(0.6, 1.0, curve: Curves.linear),
    ));
    // _secondslidecontroller.forward();
    Future.delayed(const Duration(milliseconds: 3000)).then((value) {
      isVisible = true;
      setState(() {});

      _slideanimation = Tween<Offset>(
        begin: const Offset(-0.1, 0.0),
        end: const Offset(0.5, 0.0),
      ).animate(CurvedAnimation(
        parent: _slidecontroller,
        curve: Curves.linear,
      ));
    });

    _slidecontroller.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1500)).then(
          (value) {
            widget.next?.call();
          },
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.reset();
    _animationController.dispose();
    _slidecontroller.reset();
    _slidecontroller.forward();
    // _secondslidecontroller.reset();
    // _secondslidecontroller.forward();
  }

  Widget _buildAnimation() {
      final appModel = Provider.of<AppModel>(context);
       final themeConfig = appModel.themeConfig;
    // switch (widget.animationEffect) {
    //   case SplashScreenTypeConstants.fadeIn:
    //     {
    //       return FadeTransition(
    //         opacity: _animation,
    //         child: Center(
    //           child: SizedBox(
    //             height: widget.logoSize,
    //             child: FluxImage(imageUrl: widget.imagePath),
    //           ),
    //         ),
    //       );
    //     }
    //   case SplashScreenTypeConstants.zoomIn:
    //     {
    //       return ScaleTransition(
    //         scale: _animation,
    //         child: Center(
    //           child: SizedBox(
    //             height: widget.logoSize,
    //             child: FluxImage(imageUrl: widget.imagePath),
    //           ),
    //         ),
    //       );
    //     }
    //   case SplashScreenTypeConstants.zoomOut:
    //     {
    //       return ScaleTransition(
    //           scale: Tween(begin: 1.5, end: 0.6).animate(CurvedAnimation(
    //               parent: _animationController, curve: Curves.easeInCirc)),
    //           child: Center(
    //             child: SizedBox(
    //               height: widget.logoSize,
    //               child: FluxImage(imageUrl: widget.imagePath),
    //             ),
    //           ));
    //     }
    //   case SplashScreenTypeConstants.topDown:
    //   default:
    //     {
    //       return SizeTransition(
    //         sizeFactor: _animation,
    //         child: Center(
    //           child: SizedBox(
    //             height: widget.logoSize,
    //             child: FluxImage(imageUrl: widget.imagePath),
    //           ),
    //         ),
    //       );
    //     }
    // }

    return Stack(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isVisible)
          Center(
            child: SlideTransition(
              position: _slideanimation,
              child: Image.asset('assets/images/textlogo.png'),
            ),
          ),
        // if (isVisible)
        //   Center(
        //     child:
        // SlideTransition(
        //       position: _secondslideanimation,
        //       child: Image.asset(
        //         'assets/images/smallheader.png',
        //         // scale: 0.3,
        //       ),
        //     ),
        //   ),
        // if (isVisible)
        Center(
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: 0.25).animate(
              CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(0.0, 0.5, curve: Curves.easeInCirc)),
            ),
            child: SlideTransition(
              position: _secondslideanimation,
              child: Image.asset(
                'assets/images/headerlogo.png',
                // scale: 0.3,
              ),
            ),
            // SizedBox(
            //   // height: widget.logoSize,
            //   child: FluxImage(imageUrl: 'assets/images/headerlogo.png'
            //       //  widget.imagePath
            //       ),
            // ),
          ),
        )
      ],

      // )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAnimation();
  }
}
