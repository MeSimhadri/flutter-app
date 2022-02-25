import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_custom.dart';
import 'package:intl/date_symbols.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localizations/src/utils/date_localizations.dart'
    as util;
import 'package:intl/intl.dart' as intl;
import 'datetime/index.dart';
import 'material_ku.dart';

const kCustomizeSupportedLanguages = ['ku'];

class SubMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SubMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kCustomizeSupportedLanguages.contains(locale.languageCode);

  static final Map<Locale, Future<MaterialLocalizations>> _loadedTranslations =
      <Locale, Future<MaterialLocalizations>>{};

  GlobalMaterialLocalizations? getCustomizeTranslation(
    Locale locale,
    intl.DateFormat fullYearFormat,
    intl.DateFormat compactDateFormat,
    intl.DateFormat shortDateFormat,
    intl.DateFormat mediumDateFormat,
    intl.DateFormat longDateFormat,
    intl.DateFormat yearMonthFormat,
    intl.DateFormat shortMonthDayFormat,
    intl.NumberFormat decimalFormat,
    intl.NumberFormat twoDigitZeroPaddedFormat,
  ) {
    switch (locale.languageCode) {
      case 'ku':
        return MaterialLocalizationKu(
            fullYearFormat: fullYearFormat,
            compactDateFormat: compactDateFormat,
            shortDateFormat: shortDateFormat,
            mediumDateFormat: mediumDateFormat,
            longDateFormat: longDateFormat,
            yearMonthFormat: yearMonthFormat,
            shortMonthDayFormat: shortMonthDayFormat,
            decimalFormat: decimalFormat,
            twoDigitZeroPaddedFormat: twoDigitZeroPaddedFormat);
    }
    assert(false,
        'getCustomizeTranslation() called for unsupported locale "$locale"');
    return null;
  }

  dynamic? datePatterms(Locale locale) {
    switch (locale.languageCode) {
      case 'ku':
        return kuLocaleDatePatterns;
      default:
    }
  }

  DateSymbols? dateSymbols(Locale locale) {
    switch (locale.languageCode) {
      case 'ku':
        return kuDateSymbols;
      default:
    }
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    assert(isSupported(locale));
    return _loadedTranslations.putIfAbsent(locale, () {
      util.loadDateIntlDataIfNotLoaded();

      final localeName = intl.Intl.canonicalizedLocale(locale.toString());
      assert(
        locale.toString() == localeName,
        'Flutter does not support the non-standard locale form $locale (which '
        'might be $localeName',
      );

      initializeDateFormattingCustom(
        locale: localeName,
        patterns: datePatterms(locale)!,
        symbols: dateSymbols(locale)!,
      );

      return SynchronousFuture<MaterialLocalizations>(getCustomizeTranslation(
        locale,
        intl.DateFormat('y', localeName),
        intl.DateFormat('yMd', localeName),
        intl.DateFormat('yMMMd', localeName),
        intl.DateFormat('EEE, MMM d', localeName),
        intl.DateFormat('EEEE, MMMM d, y', localeName),
        intl.DateFormat('MMMM y', localeName),
        intl.DateFormat('MMMM y', localeName),
        intl.NumberFormat('#,##0.###', 'en_US'),
        intl.NumberFormat('00', 'en_US'),
      )!);
    });
  }

  @override
  bool shouldReload(SubMaterialLocalizationsDelegate old) => false;

  @override
  String toString() =>
      'GlobalCusomizeLocalizations.delegate(${kCustomizeSupportedLanguages.length} locales)';
}
