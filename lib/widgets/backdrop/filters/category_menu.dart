import 'package:flutter/material.dart';
import 'package:inspireui/widgets/expandable/expansion_widget.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show BlogModel, Category, CategoryModel, ProductModel;
import '../../common/tree_view.dart';
import 'category_item.dart';

class CategoryMenu extends StatefulWidget {
  final Function(Category category) onFilter;
  final bool isUseBlog;

  const CategoryMenu({
    Key? key,
    required this.onFilter,
    this.isUseBlog = false,
  }) : super(key: key);

  @override
  State<CategoryMenu> createState() => _CategoryTreeState();
}

class _CategoryTreeState extends State<CategoryMenu> {
  CategoryModel get category => Provider.of<CategoryModel>(context);
  String? get categoryId => Provider.of<ProductModel>(context).categoryId;

  bool? hasChildren(categories, id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category>? getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }

  List<Widget> _getCategoryItems(
    List<Category> categories, {
    String? id,
    required Function onFilter,
    int level = 1,
  }) {
    return [
      for (var category in getSubCategories(categories, id)!) ...[
        Parent(
          parent: CategoryItem(
            category,
            hasChild: hasChildren(categories, category.id),
            isSelected: category.id == categoryId,
            onTap: () => onFilter(category),
            level: level,
          ),
          childList: ChildList(
            children: [
              if (hasChildren(categories, category.id)!)
                CategoryItem(
                  category,
                  isParent: true,
                  isSelected: category.id == categoryId,
                  onTap: () => onFilter(category),
                  level: level + 1,
                ),
              ..._getCategoryItems(
                categories,
                id: category.id,
                onFilter: widget.onFilter,
                level: level + 1,
              )
            ],
          ),
        )
      ],
    ];
  }

  Widget getTreeView({required List<Category> categories}) {
    final rootCategories =
        categories.where((item) => item.parent == '0').toList();

    return TreeView(
      parentList: [
        for (var item in rootCategories)
          Parent(
            parent: CategoryItem(
              item,
              hasChild: hasChildren(categories, item.id),
              isSelected: item.id == categoryId,
              onTap: () => widget.onFilter(item),
            ),
            childList: ChildList(
              children: [
                if (hasChildren(categories, item.id)!)
                  CategoryItem(
                    item,
                    isParent: true,
                    isSelected: item.id == categoryId,
                    onTap: () => widget.onFilter(item),
                    level: 2,
                  ),
                ..._getCategoryItems(
                  categories,
                  id: item.id,
                  onFilter: widget.onFilter,
                  level: 2,
                )
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionWidget(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 25,
        bottom: 10,
      ),
      title: Text(
        S.of(context).byCategory.toUpperCase(),
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.only(top: 5.0, bottom: 10),
          decoration: const BoxDecoration(
            color: Colors.white12,
          ),
          child: widget.isUseBlog
              ? Selector<BlogModel, List<Category>>(
                  builder: (context, categories, child) => getTreeView(
                    categories: categories,
                  ),
                  selector: (_, model) => model.categories,
                )
              : Selector<CategoryModel, List<Category>>(
                  builder: (context, categories, child) => getTreeView(
                    categories: categories,
                  ),
                  selector: (_, model) => model.categories ?? [],
                ),
        ),
      ],
    );
  }
}
