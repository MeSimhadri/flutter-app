import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    ));
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
  }

  Widget _buildAnimation() {
    switch (widget.animationEffect) {
      case SplashScreenTypeConstants.fadeIn:
        {
          return FadeTransition(
            opacity: _animation,
            child: Center(
              child: SizedBox(
                height: widget.logoSize,
                child: FluxImage(imageUrl: widget.imagePath),
              ),
            ),
          );
        }
      case SplashScreenTypeConstants.zoomIn:
        {
          return ScaleTransition(
            scale: _animation,
            child: Center(
              child: SizedBox(
                height: widget.logoSize,
                child: FluxImage(imageUrl: widget.imagePath),
              ),
            ),
          );
        }
      case SplashScreenTypeConstants.zoomOut:
        {
          return ScaleTransition(
              scale: Tween(begin: 1.5, end: 0.6).animate(CurvedAnimation(
                  parent: _animationController, curve: Curves.easeInCirc)),
              child: Center(
                child: SizedBox(
                  height: widget.logoSize,
                  child: FluxImage(imageUrl: widget.imagePath),
                ),
              ));
        }
      case SplashScreenTypeConstants.topDown:
      default:
        {
          return SizeTransition(
            sizeFactor: _animation,
            child: Center(
              child: SizedBox(
                height: widget.logoSize,
                child: FluxImage(imageUrl: widget.imagePath),
              ),
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildAnimation();
  }
}
