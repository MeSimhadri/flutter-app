import 'package:flutter/material.dart';
import 'package:inspireui/widgets/expandable/expansion_widget.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../common/tools/adaptive_tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, BlogModel, FilterAttributeModel, ProductModel;
import '../../services/service_config.dart';
import 'filter_option_item.dart';
import 'filters/category_menu.dart';
import 'filters/listing_menu.dart';
import 'filters/tag_menu.dart';

class BackdropMenu extends StatefulWidget {
  final Function({
    dynamic minPrice,
    dynamic maxPrice,
    String? categoryId,
    String? categoryName,
    String? tagId,
    dynamic attribute,
    dynamic currentSelectedTerms,
    dynamic listingLocationId,
  })? onFilter;
  final String? categoryId;
  final String? tagId;
  final String? listingLocationId;
  final bool showCategory;
  final bool showPrice;
  final bool isUseBlog;

  const BackdropMenu({
    Key? key,
    this.onFilter,
    this.categoryId,
    this.tagId,
    this.showCategory = true,
    this.showPrice = true,
    this.isUseBlog = false,
    this.listingLocationId,
  }) : super(key: key);

  @override
  _BackdropMenuState createState() => _BackdropMenuState();
}

class _BackdropMenuState extends State<BackdropMenu> {
  double mixPrice = 0.0;
  double maxPrice = 0.0;
  String? currentSlug;
  int currentSelectedAttr = -1;
  String? _categoryId = '-1';
  String? _tagId = '-1';

  String? get currency => Provider.of<AppModel>(context).currency;
  Map<String, dynamic> get currencyRate =>
      Provider.of<AppModel>(context, listen: false).currencyRate;
  String get selectLayout =>
      Provider.of<AppModel>(context, listen: false).productListLayout;
  FilterAttributeModel get filterAttr =>
      Provider.of<FilterAttributeModel>(context, listen: false);

  String? get categoryId =>
      _categoryId ??
      Provider.of<ProductModel>(context, listen: false).categoryId;
  String? get tagId =>
      _tagId ??
      Provider.of<ProductModel>(context, listen: false).tagId.toString();

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId;
    _tagId = widget.tagId;

    /// Support loading Blog Category inside Woo/Vendor config
    if (widget.isUseBlog) {
      Provider.of<BlogModel>(context, listen: false).getCategoryList();

      /// enable if using Tag, otherwise disable to save performance
      // Provider.of<BlogModel>(context, listen: false).getTagList();
    }
  }

  void _onFilter({
    String? categoryId,
    String? categoryName,
    String? tagId,
    listingLocationId,
  }) =>
      widget.onFilter!(
        minPrice: mixPrice,
        maxPrice: maxPrice,
        categoryId: categoryId,
        categoryName: categoryName ?? '',
        tagId: tagId,
        attribute: currentSlug,
        currentSelectedTerms:
            Provider.of<FilterAttributeModel>(context, listen: false)
                .lstCurrentSelectedTerms,
        listingLocationId: listingLocationId ??
            Provider.of<ProductModel>(context, listen: false).listingLocationId,
      );

  List<Widget> renderLayout() {
    return [
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          S.of(context).layout.toUpperCase(),
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      const SizedBox(height: 5.0),

      /// render layout
      Wrap(
        children: <Widget>[
          const SizedBox(width: 8),
          for (var item
              in Config().isWordPress ? kBlogListLayout : kProductListLayout)
            Tooltip(
              message: item['layout']!,
              child: GestureDetector(
                onTap: () => Provider.of<AppModel>(context, listen: false)
                    .updateProductListLayout(item['layout']),
                child: Container(
                  width: 50,
                  height: 46,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: selectLayout == item['layout']
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context)
                              .primaryColorLight
                              .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(9.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      item['image']!,
                      color: selectLayout == item['layout']
                          ? Theme.of(context).primaryColor
                          : Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            )
        ],
      )
    ];
  }

  Widget renderPriceSlider() {
    return ExpansionWidget(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 25,
        bottom: 10,
      ),
      title: Text(
        S.of(context).byPrice.toUpperCase(),
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (mixPrice != 0 || maxPrice != 0) ...[
              Text(
                PriceTools.getCurrencyFormatted(mixPrice, currencyRate,
                    currency: currency)!,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                ' - ',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ],
            Text(
              PriceTools.getCurrencyFormatted(maxPrice, currencyRate,
                  currency: currency)!,
              style: Theme.of(context).textTheme.headline6,
            )
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(kSliderActiveColor),
            inactiveTrackColor: const Color(kSliderInactiveColor),
            activeTickMarkColor: Colors.white70,
            inactiveTickMarkColor: Theme.of(context).colorScheme.secondary,
            overlayColor: Colors.white12,
            thumbColor: const Color(kSliderActiveColor),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: RangeSlider(
            min: 0.0,
            max: kMaxPriceFilter,
            divisions: kFilterDivision,
            values: RangeValues(mixPrice, maxPrice),
            onChanged: (RangeValues values) {
              setState(() {
                mixPrice = values.start;
                maxPrice = values.end;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget renderAttributes() {
    return ListenableProvider.value(
      value: filterAttr,
      child: Consumer<FilterAttributeModel>(
        builder: (context, value, child) {
          if (value.lstProductAttribute != null &&
              value.lstProductAttribute!.isNotEmpty) {
            var list = List<Widget>.generate(
              value.lstProductAttribute!.length,
              (index) {
                return FilterOptionItem(
                  enabled: !value.isLoading,
                  onTap: () {
                    currentSelectedAttr = index;

                    currentSlug = value.lstProductAttribute![index].slug;
                    value.getAttr(id: value.lstProductAttribute![index].id);
                  },
                  title: value.lstProductAttribute![index].name!.toUpperCase(),
                  isValid: currentSelectedAttr != -1,
                  selected: currentSelectedAttr == index,
                );
              },
            );
            return ExpansionWidget(
              initiallyExpanded: false,
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 25,
                bottom: 10,
              ),
              title: Text(
                S.of(context).attributes.toUpperCase(),
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                        left: 10.0,
                      ),
                      constraints: BoxConstraints(
                        maxHeight: list.length > 4 ? 130 : 100,
                      ),
                      child: GridView.count(
                        scrollDirection: Axis.horizontal,
                        childAspectRatio: 0.4,
                        shrinkWrap: true,
                        crossAxisCount: list.length > 4 ? 2 : 1,
                        children: list,
                      ),
                    ),
                    value.isLoading
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              width: 25.0,
                              height: 25.0,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2.0),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: currentSelectedAttr == -1
                                ? Container()
                                : Wrap(
                                    children: List.generate(
                                      value.lstCurrentAttr.length,
                                      (index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: FilterChip(
                                            selectedColor:
                                                Theme.of(context).primaryColor,
                                            backgroundColor: Theme.of(context)
                                                .primaryColorLight
                                                .withOpacity(0.3),
                                            label: Text(value
                                                .lstCurrentAttr[index].name!),
                                            selected: value
                                                .lstCurrentSelectedTerms[index],
                                            onSelected: (val) {
                                              value.updateAttributeSelectedItem(
                                                  index, val);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                  ],
                )
              ],
            );
          }
          return Container();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isDisplayDesktop(context))
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      if (isDisplayDesktop(context)) {
                        eventBus.fire(const EventOpenCustomDrawer());
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        size: 22, color: Colors.white70),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    Config().isWordPress
                        ? context.select((BlogModel _) => _.categoryName) ??
                            S.of(context).blog
                        : S.of(context).products,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

          ...renderLayout(),

          if (widget.showCategory)
            CategoryMenu(
              isUseBlog: widget.isUseBlog,
              onFilter: (category) => _onFilter(
                categoryId: category.id,
                categoryName: category.name,
              ),
            ),

          if (Config().isListingType) BackDropListingMenu(onFilter: _onFilter),

          if (!Config().isListingType &&
              Config().type != ConfigType.shopify &&
              widget.showPrice) ...[
            renderPriceSlider(),
            renderAttributes(),
          ],

          /// filter by tags
          widget.isUseBlog ? const SizedBox() : const BackDropTagMenu(),

          /// render Apply button
          if (!Config().isListingType)
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonTheme(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          primary: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                        ),
                        onPressed: () => _onFilter(
                          categoryId: categoryId,
                          tagId: tagId,
                        ),
                        child: Text(
                          S.of(context).apply,
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}
