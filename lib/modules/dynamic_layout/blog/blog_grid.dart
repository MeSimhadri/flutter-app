import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show Skeleton;
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../common/constants.dart';
import '../../../common/tools/adaptive_tools.dart';
import '../../../routes/flux_navigate.dart';
import '../../../screens/base_screen.dart';
import '../../../screens/blog/index.dart';
import '../../../screens/blog/models/list_blog_model.dart';
import '../../../widgets/blog/blog_grid_item.dart';
import '../helper/header_view.dart';
import '../index.dart' show BlogConfig, HeaderView;

class BlogGrid extends StatefulWidget {
  final BlogConfig? config;

  const BlogGrid({
    Key? key,
    this.config,
  }) : super(key: key);

  @override
  _BlogGridState createState() => _BlogGridState();
}

class _BlogGridState extends BaseScreen<BlogGrid> {
  PageController? pageController;
  final viewportFraction = 0.9;

  @override
  void initState() {
    pageController = PageController(viewportFraction: viewportFraction);
    super.initState();
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  Widget _buildHeader(
    BuildContext context,
    List<Blog>? blogs, {
    double padding = 10,
  }) {
    if (widget.config?.name != null) {
      var showSeeAllLink = widget.config?.layout != 'instagram';
      return HeaderView(
        headerText: widget.config?.name ?? '',
        showSeeAll: showSeeAllLink,
        horizontalMargin: padding,
        callback: () => Navigator.of(context).pushNamed(RouteList.listBlog),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    var _offset = (widget.config?.innerPadding ?? 0.0) + 11;
    if ((widget.config?.hideDate ?? true) &&
        (widget.config?.hideAuthor ?? true) &&
        (widget.config?.hideComment ?? true)) {
      _offset -= 11.0;
    }
    _offset *= 3.0 + 1;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: getValueForScreenType<double>(
          context: context,
          mobile: 334 + _offset,
          tablet: 430 + _offset,
          desktop: screenSize.height * 2 / 3 + _offset,
        ),
      ),
      child: Consumer<ListBlogModel>(builder: (_, model, __) {
        final listBlog = model.blogs?.take(12).toList();
        if (listBlog?.isEmpty ?? true) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.config?.padding ?? 8.0,
            ),
            child: Column(
              children: <Widget>[
                _buildHeader(context, null),
                const Expanded(child: _BlogViewSkeleton()),
                const Expanded(child: _BlogViewSkeleton()),
                const Expanded(child: _BlogViewSkeleton()),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(context, listBlog,
                padding: widget.config?.padding ?? 8.0),
            Container(
              color: widget.config?.backgroundColor != null
                  ? HexColor.fromJson(widget.config?.backgroundColor)
                  : Theme.of(context).cardColor,
              child: SingleChildScrollView(
                padding: widget.config?.padding != null
                    ? EdgeInsets.symmetric(
                        horizontal: widget.config?.padding ?? 16.0)
                    : EdgeInsets.only(
                        left: Directionality.of(context) == TextDirection.ltr
                            ? 15
                            : 48,
                        right: Directionality.of(context) == TextDirection.ltr
                            ? 48
                            : 15,
                      ),
                physics: isDisplayDesktop(context)
                    ? const BouncingScrollPhysics()
                    : const PageScrollPhysics(),
                controller: pageController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children:
                      List.generate((listBlog!.length / 3).ceil(), (index) {
                    final items = listBlog.skip(index * 3).take(3);
                    return SizedBox(
                      width: screenSize.width * viewportFraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: items
                            .map((blog) => BlogGridItem(
                                  config: widget.config as BlogConfig,
                                  blog: blog,
                                  radius: widget.config?.radius ?? 0.0,
                                  background: widget.config?.backgroundColor !=
                                          null
                                      ? HexColor(widget.config?.backgroundColor)
                                      : Colors.transparent,
                                  itemBackgroundColor: widget
                                              .config?.itemBackgroundColor !=
                                          null
                                      ? HexColor(
                                          widget.config?.itemBackgroundColor)
                                      : Colors.transparent,
                                  innerPadding:
                                      widget.config?.innerPadding ?? 0.0,
                                  onTap: () => FluxNavigate.pushNamed(
                                    RouteList.detailBlog,
                                    arguments: BlogDetailArguments(
                                      blog: blog,
                                      listBlog: listBlog.toList(),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _BlogViewSkeleton extends StatelessWidget {
  const _BlogViewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Flexible(
            flex: 4,
            child: Skeleton(),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(
                  width: 200,
                  height: 20,
                ),
                SizedBox(height: 8),
                Skeleton(
                  width: 100,
                  height: 16,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
