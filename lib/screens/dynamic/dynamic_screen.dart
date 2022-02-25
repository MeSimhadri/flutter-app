import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../models/app_model.dart';
import '../../modules/dynamic_layout/background/background.dart';
import '../../widgets/home/index.dart';
import '../../widgets/home/wrap_status_bar.dart';
import '../base_screen.dart';
import '../common/app_bar_mixin.dart';

class DynamicScreen extends StatefulWidget {
  final String? previewKey;
  final configs;

  const DynamicScreen({this.configs, this.previewKey});

  @override
  State<StatefulWidget> createState() {
    return DynamicScreenState();
  }
}

class DynamicScreenState extends BaseScreen<DynamicScreen>
    with AutomaticKeepAliveClientMixin<DynamicScreen>, AppBarMixin {
  static BuildContext? homeContext;

  static late BuildContext loadingContext;

  @override
  bool get wantKeepAlive => true;

  StreamSubscription? _sub;
  int? itemId;

  @override
  void dispose() {
    printLog('[Home] dispose');
    _sub?.cancel();
    super.dispose();
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    homeContext = context;
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        loadingContext = context;
        return Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(5.0)),
            padding: const EdgeInsets.all(50.0),
            child: kLoadingWidget(context),
          ),
        );
      },
    );
  }

  static void hideLoading() {
    Navigator.of(loadingContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    printLog('[Dynamic Screen] build');
    return Consumer<AppModel>(
      builder: (context, value, child) {
        if (value.appConfig == null) {
          return kLoadingWidget(context);
        }
        var configs = widget.configs;

        if (configs?.isEmpty ?? true) {
          return const SizedBox();
        }
        var isStickyHeader = value.appConfig!.settings.stickyHeader;

        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Stack(
            children: <Widget>[
              if (configs['Background'] != null)
                isStickyHeader
                    ? SafeArea(
                        child: HomeBackground(
                          config: configs['Background'],
                        ),
                      )
                    : HomeBackground(config: configs['Background']),
              if (configs['HorizonLayout']?.isNotEmpty ?? false)
                HomeLayout(
                    isPinAppBar: isStickyHeader,
                    isShowAppbar:
                        configs['HorizonLayout'][0]['layout'] == 'logo',
                    showNewAppBar: value.appConfig?.appBar
                            ?.shouldShowOn(RouteList.dynamic) ??
                        false,
                    configs: configs),
              const WrapStatusBar(),
            ],
          ),
        );
      },
    );
  }
}
