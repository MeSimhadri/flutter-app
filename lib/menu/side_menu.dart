import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:inspireui/utils.dart';

import '../common/constants.dart';
import '../common/tools/adaptive_tools.dart';
import '../modules/dynamic_layout/index.dart';
import '../screens/index.dart';
import '../widgets/common/index.dart';

class SideMenu extends StatefulWidget {
  final Widget child;
  final Widget? bottomNavigationBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final String? sideMenuBackground;
  final String? sideMenuBackgroundImage;
  final String? colorFilter;
  final num? filter;
  final ZoomConfig? zoomConfig;
  final Widget drawer;
  const SideMenu({
    required this.child,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.sideMenuBackground,
    this.sideMenuBackgroundImage,
    this.colorFilter,
    this.filter,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
    this.zoomConfig,
    required this.drawer,
  });

  @override
  _StateSideMenu createState() => _StateSideMenu();
}

class _StateSideMenu extends BaseScreen<SideMenu> {
  /// Navigation variable
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey(debugLabel: 'Dashboard');

  StreamSubscription? _subOpenNativeDrawer;
  StreamSubscription? _subCloseNativeDrawer;
  final _drawerController = ZoomDrawerController();
  var _drawerState = ValueNotifier(DrawerState.open);

  bool get enableBackground =>
      widget.backgroundColor != null ||
      widget.sideMenuBackground != null ||
      widget.colorFilter != null ||
      widget.zoomConfig?.backgroundImage != null;

  @override
  void initState() {
    super.initState();
    _subOpenNativeDrawer = eventBus.on<EventOpenNativeDrawer>().listen((event) {
      if (!_scaffoldKey.currentState!.isDrawerOpen) {
        _scaffoldKey.currentState!.openDrawer();
      }
      if (widget.zoomConfig != null) {
        _drawerController.open!();
      }
    });
    eventBus.on<EventDrawerSettings>().listen((event) {
      if (!_scaffoldKey.currentState!.isDrawerOpen) {
        _scaffoldKey.currentState!.openDrawer();
      }
      if (widget.zoomConfig != null) {
        _drawerController.open!();
      }
    });
    _subCloseNativeDrawer =
        eventBus.on<EventCloseNativeDrawer>().listen((event) {
      if (_scaffoldKey.currentState!.isDrawerOpen) {
        _scaffoldKey.currentState!.openEndDrawer();
      }
      if (widget.zoomConfig != null) {
        _drawerController.close!();
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    super.afterFirstLayout(context);

    setState(() {
      _drawerState =
          _drawerController.stateNotifier ?? ValueNotifier(DrawerState.open);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _subOpenNativeDrawer?.cancel();
    _subCloseNativeDrawer?.cancel();
  }

  bool isOpen() {
    if (_drawerController.isOpen != null) {
      return _drawerController.isOpen!();
    }
    return false;
  }

  DrawerStyle getStyle(String value) {
    /// not use Style3,4 of ZoomDrawer
    switch (value) {
      case 'style1':
        return DrawerStyle.Style1;
      case 'style2':
        return DrawerStyle.Style2;
      case 'style3':
        return DrawerStyle.Style5;
      case 'style4':
        return DrawerStyle.Style6;
      case 'style5':
        return DrawerStyle.Style7;
      case 'default':
      default:
        return DrawerStyle.DefaultStyle;
    }
  }

  Widget renderLayout({bool enableDrawer = false}) {
    return Scaffold(
      key: _scaffoldKey,
      // Disable opening the drawer with a swipe gesture.
      drawerEnableOpenDragGesture: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.backgroundColor,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButton: widget.floatingActionButton,
      body: widget.child,
      drawer: !enableDrawer || isDisplayDesktop(context)
          ? null
          : Drawer(
              child: enableBackground
                  ? Stack(
                      children: [
                        if (widget.sideMenuBackground?.isNotEmpty ?? false)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: HexColor(widget.sideMenuBackground),
                          ),
                        if (widget.sideMenuBackgroundImage?.isNotEmpty ?? false)
                          FluxImage(
                            imageUrl: widget.sideMenuBackgroundImage!,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            fit: BoxFit.fill,
                          ),
                        if (widget.colorFilter?.isNotEmpty ?? false)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: HexColor(widget.colorFilter).withOpacity(
                              widget.filter?.toDouble() ?? 0.0,
                            ),
                          ),
                        widget.drawer,
                      ],
                    )
                  : widget.drawer,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.zoomConfig != null) {
      return ValueListenableBuilder<DrawerState>(
        valueListenable: _drawerState,
        builder: (context, value, child) {
          var isOpen = value == DrawerState.open || value == DrawerState.open;
          var zoomConfig = widget.zoomConfig ?? ZoomConfig();
          var backgroundImage =
              widget.sideMenuBackgroundImage ?? zoomConfig.backgroundImage;
          return Stack(
            children: [
              if (widget.sideMenuBackground?.isNotEmpty ?? false)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: HexColor(widget.sideMenuBackground),
                ),
              if (backgroundImage?.isNotEmpty ?? false)
                FluxImage(
                  imageUrl: backgroundImage!,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              if (widget.colorFilter?.isNotEmpty ?? false)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: HexColor(widget.colorFilter).withOpacity(
                    widget.filter?.toDouble() ?? 0.0,
                  ),
                ),
              Material(
                color: Theme.of(context)
                    .backgroundColor
                    .withOpacity(enableBackground ? 0.0 : 1.0),
                child: ZoomDrawer(
                  controller: _drawerController,
                  style: getStyle(zoomConfig.style),
                  showShadow: zoomConfig.enableShadow,
                  angle: zoomConfig.angle.toDouble(),
                  borderRadius: zoomConfig.borderRadius.toDouble(),
                  mainScreenScale: zoomConfig.mainScreenScale.toDouble(),
                  backgroundColor: Theme.of(context).primaryColor,
                  slideWidth:
                      MediaQuery.of(context).size.width * zoomConfig.slideWidth,
                  menuScreen: SizedBox(
                    width: MediaQuery.of(context).size.width *
                            zoomConfig.slideWidth -
                        zoomConfig.slideMargin,
                    child: widget.drawer,
                  ),
                  mainScreen: InkWell(
                    onTap: isOpen
                        ? () {
                            _drawerController.close!();
                          }
                        : null,
                    child: AbsorbPointer(
                      absorbing: isOpen,
                      child: renderLayout(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    return renderLayout(enableDrawer: true);
  }
}
