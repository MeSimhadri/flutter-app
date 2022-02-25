import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../models/app_model.dart';
import '../../modules/dynamic_layout/index.dart';
import '../../services/index.dart';
import '../../widgets/home/index.dart';
import '../../widgets/home/preview_reload.dart';
import '../../widgets/home/wrap_status_bar.dart';
import '../base_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends BaseScreen<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    printLog('[Home] dispose');
    super.dispose();
  }

  @override
  void initState() {
    printLog('[Home] initState');
    super.initState();
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    /// init dynamic link
    if (!kIsWeb) {
      Services().firebase.initDynamicLinkService(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    printLog('[Home] build');
    return Consumer<AppModel>(
      builder: (context, value, child) {
        if (value.appConfig == null) {
          return kLoadingWidget(context);
        }

        return PreviewReload(
          configs: value.appConfig!.jsonData,
          builder: (json) {
            var isStickyHeader = value.appConfig!.settings.stickyHeader;
            var appConfig = AppConfig.fromJson(json);
            final horizontalLayoutList = List.from(json['HorizonLayout']);
            final isShowAppbar = horizontalLayoutList.isNotEmpty &&
                horizontalLayoutList.first['layout'] == 'logo';
            return Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: Stack(
                children: <Widget>[
                  if (appConfig.background != null)
                    isStickyHeader
                        ? SafeArea(
                            child: HomeBackground(config: appConfig.background),
                          )
                        : HomeBackground(config: appConfig.background),
                  HomeLayout(
                    isPinAppBar: isStickyHeader,
                    isShowAppbar: isShowAppbar,
                    showNewAppBar:
                        appConfig.appBar?.shouldShowOn(RouteList.home) ?? false,
                    configs: json,
                    key: UniqueKey(),
                  ),
                  if (Config().isBuilder) const WrapStatusBar(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
