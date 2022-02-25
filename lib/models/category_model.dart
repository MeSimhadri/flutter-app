import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../common/constants.dart';
import '../services/index.dart';
import 'entities/category.dart';

class CategoryModel with ChangeNotifier {
  final Services _service = Services();

  List<Category>? _categories = [];
  List<Category>? get categories => _categories;

  Map<String?, Category> categoryList = {};

  bool isLoading = false;
  List<Category>? allCategories;
  String? message;

  /// Format the Category List and assign the List by Category ID
  void sortCategoryList(
      {List<Category>? categoryList,
      dynamic sortingList,
      String? categoryLayout}) {
    var _categoryList = <String?, Category>{};
    var result = categoryList;

    if (sortingList != null) {
      var categories = <Category>[];
      var _subCategories = <Category>[];
      var isParent = true;
      for (var category in sortingList) {
        var item = categoryList!.firstWhereOrNull(
            (Category cat) => cat.id.toString() == category.toString());
        if (item != null) {
          if (item.parent != '0') {
            isParent = false;
          }
          categories.add(item);
        }
      }
      if (!['column', 'grid', 'subCategories'].contains(categoryLayout)) {
        for (var category in categoryList!) {
          var item =
              categories.firstWhereOrNull((cat) => cat.id == category.id);
          if (item == null && isParent && category.parent != '0') {
            _subCategories.add(category);
          }
        }
      }
      result = [...categories, ..._subCategories];
    }

    for (var cat in result!) {
      _categoryList[cat.id] = cat;
    }
    this.categoryList = _categoryList;
    _categories = result;
    notifyListeners();
  }

  Future<void> getCategories({lang, sortingList, categoryLayout}) async {
    try {
      printLog('[Category] getCategories');
      isLoading = true;
      notifyListeners();
      allCategories = await _service.api.getCategories(lang: lang);
      message = null;

      sortCategoryList(
          categoryList: allCategories,
          sortingList: sortingList,
          categoryLayout: categoryLayout);
      isLoading = false;
      notifyListeners();
    } catch (err, _) {
      isLoading = false;
      message = 'There is an issue with the app during request the data, '
              'please contact admin for fixing the issues ' +
          err.toString();
      //notifyListeners();
    }
  }

  /// Prase category list from json Object
  static List<Category> parseCategoryList(response) {
    var categories = <Category>[];
    if (response is Map && isNotBlank(response['message'])) {
      throw Exception(response['message']);
    } else {
      for (var item in response) {
        if (item['slug'] != 'uncategorized') {
          categories.add(Category.fromJson(item));
        }
      }
      return categories;
    }
  }
}
