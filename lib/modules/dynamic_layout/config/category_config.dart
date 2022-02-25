import '../helper/helper.dart';
import 'box_shadow_config.dart';
import 'category_item_config.dart';
import 'item_size_config.dart';

/// type : 'icon'
/// hideTitle : false
/// originalColor : false
/// noBackground : false
/// wrap : false
/// size : 1.0
/// columns : 3
/// radius : 50.0
/// border : 1.0
/// shadow : 15.0
/// boxShadow : {'blurRadius':10.0,'colorOpacity':0.1,'spreadRadius':10.0,'x':0,'y':0}
/// layout : 'category'
/// marginLeft : 10.0
/// marginRight : 10.0
/// marginTop : 10.0
/// marginBottom : 10.0
/// items : [{'originalColor':false,'colors':['#3CC2BF','#3CC2BF'],'image':'https://user-images.githubusercontent.com/1459805/62820029-2e679f00-bb88-11e9-80de-fdf115cfd942.png','tag':'58','category':'58'}]

class CategoryConfig {
  String? type;
  String? layout;

  bool hideTitle = false;
  bool originalColor = false;
  bool showShortDescription = false;
  bool? noBackground;
  bool wrap = false;

  /// type double
  double? size;
  int? columns;
  double? radius;
  double spacing = 12.0;
  double? height;
  double? border;
  double? shadow;
  double marginLeft = 0.0;
  double marginRight = 10.0;
  double marginTop = 0.0;
  double marginBottom = 0.0;
  double paddingX = 0.0;
  double paddingY = 0.0;
  double marginX = 0.0;
  double marginY = 0.0;

  /// other type
  ItemSizeConfig? itemSize;
  BoxShadowConfig? boxShadow;
  List<CategoryItemConfig> items = [];

  CategoryConfig(
      {this.type,
      this.hideTitle = false,
      this.originalColor = false,
      this.showShortDescription = false,
      this.noBackground,
      this.wrap = false,
      this.size,
      this.columns,
      this.radius,
      this.spacing = 12.0,
      this.height,
      this.border,
      this.shadow,
      this.boxShadow,
      this.layout,
      this.marginLeft = 0.0,
      this.marginRight = 10.0,
      this.marginTop = 0.0,
      this.marginBottom = 0.0,
      this.paddingX = 0.0,
      this.paddingY = 0.0,
      this.marginX = 0.0,
      this.marginY = 0.0,
      required this.items});

  CategoryConfig.fromJson(dynamic json) {
    type = json['type'];
    layout = json['layout'];

    noBackground = json['noBackground'] ?? false;
    hideTitle = json['hideTitle'] ?? false;
    showShortDescription = json['showShortDescription'] ?? false;

    originalColor = json['originalColor'] ?? false;
    wrap = json['wrap'] ?? false;
    boxShadow = json['boxShadow'] != null
        ? BoxShadowConfig.fromJson(json['boxShadow'])
        : null;
    itemSize = json['itemSize'] != null
        ? ItemSizeConfig.fromJson(json['itemSize'])
        : null;

    /// spacing
    shadow = Helper.formatDouble(json['shadow']);
    border = Helper.formatDouble(json['border']) ?? 0.0;
    size = Helper.formatDouble(json['size']);
    columns = json['columns'];
    radius = Helper.formatDouble(json['radius']);
    spacing = Helper.formatDouble(json['spacing']) ?? 12.0;
    height = Helper.formatDouble(json['height']);
    marginLeft = Helper.formatDouble(json['marginLeft']) ?? 15.0;
    marginRight = Helper.formatDouble(json['marginRight']) ?? 15.0;
    marginTop = Helper.formatDouble(json['marginTop']) ?? 10.0;
    marginBottom = Helper.formatDouble(json['marginBottom']) ?? 10.0;
    paddingX = Helper.formatDouble(json['paddingX']) ?? 0.0;
    paddingY = Helper.formatDouble(json['paddingY']) ?? 0.0;
    marginX = Helper.formatDouble(json['marginX']) ?? 0.0;
    marginY = Helper.formatDouble(json['marginY']) ?? 0.0;

    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items.add(CategoryItemConfig.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['type'] = type;
    map['hideTitle'] = hideTitle;
    map['originalColor'] = originalColor;
    map['noBackground'] = noBackground;
    map['showShortDescription'] = showShortDescription;
    map['wrap'] = wrap;
    map['size'] = size;
    map['columns'] = columns;
    map['radius'] = radius;
    map['spacing'] = spacing;
    map['border'] = border;
    map['shadow'] = shadow;
    if (boxShadow != null) {
      map['boxShadow'] = boxShadow?.toJson();
    }
    map['layout'] = layout;
    map['marginLeft'] = marginLeft;
    map['marginRight'] = marginRight;
    map['marginTop'] = marginTop;
    map['marginBottom'] = marginBottom;
    return map;
  }
}
