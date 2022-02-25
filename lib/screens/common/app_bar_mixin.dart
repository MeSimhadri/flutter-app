import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../menu/index.dart' show FluxAppBar;
import '../../models/index.dart' show AppModel;
import '../../modules/dynamic_layout/index.dart' show AppBarConfig;

mixin AppBarMixin<T extends StatefulWidget> on State<T> {
  AppBarConfig? get appBar =>
      context.select((AppModel model) => model.appConfig?.appBar);

  bool showAppBar(String routeName) {
    return appBar?.shouldShowOn(routeName) ?? false;
  }

  AppBar get appBarWidget => AppBar(
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).backgroundColor,
        title: FluxAppBar(),
      );

  SliverAppBar get sliverAppBarWidget => SliverAppBar(
        snap: true,
        pinned: true,
        floating: true,
        titleSpacing: 0,
        elevation: 0,
        forceElevated: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).backgroundColor,
        title: FluxAppBar(),
      );
}
