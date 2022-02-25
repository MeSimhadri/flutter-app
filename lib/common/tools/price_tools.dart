import 'package:intl/intl.dart';
import 'package:quiver/strings.dart';

import '../../models/index.dart' show AddonsOption, Product;
import '../config.dart' show kAdvanceConfig;
import '../constants.dart' show printLog;

class PriceTools {
  static String? getAddsOnPriceProductValue(
    Product product,
    List<AddonsOption> selectedOptions,
    Map<String, dynamic> rates,
    String? currency, {
    bool? onSale,
  }) {
    var price = double.tryParse(onSale == true
            ? (isNotBlank(product.salePrice)
                ? product.salePrice!
                : product.price!)
            : product.price!) ??
        0.0;
    price += selectedOptions
        .map((e) => double.tryParse(e.price ?? '0.0') ?? 0.0)
        .reduce((a, b) => a + b);

    return getCurrencyFormatted(price, rates, currency: currency);
  }

  static String? getVariantPriceProductValue(
    product,
    Map<String, dynamic> rates,
    String? currency, {
    bool? onSale,
  }) {
    String? price = onSale == true
        ? (isNotBlank(product.salePrice) ? product.salePrice : product.price)
        : product.price;
    return getCurrencyFormatted(price, rates, currency: currency);
  }

  static String? getPriceProductValue(Product? product, String? currency,
      {bool? onSale}) {
    try {
      var price = onSale == true
          ? (isNotBlank(product!.salePrice)
              ? product.salePrice ?? '0'
              : product.price)
          : (isNotBlank(product!.regularPrice)
              ? product.regularPrice ?? '0'
              : product.price);
      return price;
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
      return '';
    }
  }

  static String? getPriceProduct(
      product, Map<String, dynamic>? rates, String? currency,
      {bool? onSale}) {
    var price = getPriceProductValue(product, currency, onSale: onSale);

    if (price == null || price == '') {
      return '';
    }
    return getCurrencyFormatted(price, rates, currency: currency);
  }

  static String? getCurrencyFormatted(price, Map<String, dynamic>? rates,
      {currency}) {
    Map<String, dynamic> defaultCurrency =
        kAdvanceConfig['DefaultCurrency'] ?? {};

    if (defaultCurrency.isEmpty) {
      return price;
    }

    List currencies = kAdvanceConfig['Currencies'] ?? [];
    var formatCurrency = NumberFormat.currency(
        locale: kAdvanceConfig['DefaultLanguage'],
        name: '',
        decimalDigits: defaultCurrency['decimalDigits'] ?? 0);
    

    try {
      if (currency != null && currencies.isNotEmpty) {
        for (var item in currencies) {
          if ((item as Map)['currencyCode'] == currency ||
              item['currency'] == currency) {
            defaultCurrency = item as Map<String, dynamic>;
          }
        }
      }

      if (rates != null && rates[defaultCurrency['currencyCode']] != null) {
        price = getPriceValueByCurrency(
          price,
          defaultCurrency['currencyCode'],
          rates,
        );
      }

      String? number = '';
      if (price == null) {
        number = '';
      } else if (price is String) {
        final newString = price.replaceAll(RegExp('[^\\d.,]+'), '');
        number = formatCurrency
            .format(newString.isNotEmpty ? double.parse(newString) : 0);
      } else {
        number = formatCurrency.format(price);
      }

      return defaultCurrency['symbolBeforeTheNumber']
          ? defaultCurrency['symbol'] + number
          : number + defaultCurrency['symbol'];
    } catch (err, trace) {
      printLog(trace);
      printLog('getCurrencyFormatted $err');
      return defaultCurrency['symbolBeforeTheNumber']
          ? defaultCurrency['symbol'] + formatCurrency.format(0)
          : formatCurrency.format(0) + defaultCurrency['symbol'];
    }
  }

  static double getPriceValueByCurrency(
      price, String currency, Map<String, dynamic> rates) {
    final _currency = currency.toUpperCase();
    double rate = rates[_currency] ?? 1.0;

    if (price == '' || price == null) {
      return 0;
    }
    return double.parse(price.toString()) * rate;
  }
}
