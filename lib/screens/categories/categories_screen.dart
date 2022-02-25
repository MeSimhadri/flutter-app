import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../menu/appbar.dart';
import '../../models/index.dart' show AppModel, Category, CategoryModel;
import '../../modules/dynamic_layout/config/app_config.dart';
import '../../services/index.dart';
import 'layouts/column.dart';
import 'layouts/grid.dart';
import 'layouts/side_menu.dart';
import 'layouts/side_menu_with_sub.dart';
import 'layouts/sub.dart';

class CategoriesScreen extends StatefulWidget {
  final bool showSearch;

  const CategoriesScreen({
    Key? key,
    this.showSearch = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late FocusNode _focus;
  bool isVisibleSearch = false;
  String? searchText;
  var textController = TextEditingController();

  late Animation<double> animation;
  late AnimationController controller;

  AppBarConfig? get appBar =>
      context.select((AppModel model) => model.appConfig?.appBar);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {});
    });

    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus && animation.value == 0) {
      controller.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context);
    final appModel = Provider.of<AppModel>(context);

    return Scaffold(
      appBar: (appBar?.shouldShowOn(RouteList.category) ?? false)
          ? AppBar(
              titleSpacing: 0,
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).backgroundColor,
              title: FluxAppBar(),
            )
          : null,
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return kLoadingWidget(context);
            }

            if (value.categories == null) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(S.of(context).dataEmpty),
              );
            }

            var categories = value.categories;

            return SafeArea(
              bottom: false,
              child: [
                GridCategory.type,
                ColumnCategories.type,
                SideMenuCategories.type,
                SubCategories.type,
                SideMenuSubCategories.type
              ].contains(appModel.categoryLayout)
                  ? Column(
                      children: <Widget>[
                        renderHeader(),
                        Expanded(
                          child: renderCategories(
                              categories, appModel.categoryLayout),
                        )
                      ],
                    )
                  : ListView(
                      children: <Widget>[
                        renderHeader(),
                        renderCategories(categories, appModel.categoryLayout)
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget renderHeader() {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, bottom: 10, right: 10),
                child: Text(
                  S.of(context).category,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (widget.showSearch)
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.6),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteList.categorySearch);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderCategories(List<Category>? categories, String layout) {
    return Services().widget.renderCategoryLayout(categories, layout);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
