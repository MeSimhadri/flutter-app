import 'package:intl/date_symbols.dart';


const kuLocaleDatePatterns = {
  'd': 'd', // DAY
  'E': 'EEE', // ABBR_WEEKDAY
  'EEEE': 'EEEE', // WEEKDAY
  'LLL': 'LLL', // ABBR_STANDALONE_MONTH
  'LLLL': 'LLLL', // STANDALONE_MONTH
  'M': 'L', // NUM_MONTH
  'Md': 'M/d', // NUM_MONTH_DAY
  'MEd': 'EEE, M/d', // NUM_MONTH_WEEKDAY_DAY
  'MMM': 'LLL', // ABBR_MONTH
  'MMMd': 'MMM d', // ABBR_MONTH_DAY
  'MMMEd': 'EEE, MMM d', // ABBR_MONTH_WEEKDAY_DAY
  'MMMM': 'LLLL', // MONTH
  'MMMMd': 'MMMM d', // MONTH_DAY
  'MMMMEEEEd': 'EEEE, MMMM d', // MONTH_WEEKDAY_DAY
  'QQQ': 'QQQ', // ABBR_QUARTER
  'QQQQ': 'QQQQ', // QUARTER
  'y': 'y', // YEAR
  'yM': 'M/y', // YEAR_NUM_MONTH
  'yMd': 'M/d/y', // YEAR_NUM_MONTH_DAY
  'yMEd': 'EEE, M/d/y', // YEAR_NUM_MONTH_WEEKDAY_DAY
  'yMMM': 'MMM y', // YEAR_ABBR_MONTH
  'yMMMd': 'MMM d, y', // YEAR_ABBR_MONTH_DAY
  'yMMMEd': 'EEE, MMM d, y', // YEAR_ABBR_MONTH_WEEKDAY_DAY
  'yMMMM': 'MMMM y', // YEAR_MONTH
  'yMMMMd': 'MMMM d, y', // YEAR_MONTH_DAY
  'yMMMMEEEEd': 'EEEE, MMMM d, y', // YEAR_MONTH_WEEKDAY_DAY
  'yQQQ': 'QQQ y', // YEAR_ABBR_QUARTER
  'yQQQQ': 'QQQQ y', // YEAR_QUARTER
  'H': 'HH', // HOUR24
  'Hm': 'HH:mm', // HOUR24_MINUTE
  'Hms': 'HH:mm:ss', // HOUR24_MINUTE_SECOND
  'j': 'h a', // HOUR
  'jm': 'h:mm a', // HOUR_MINUTE
  'jms': 'h:mm:ss a', // HOUR_MINUTE_SECOND
  'jmv': 'h:mm a v', // HOUR_MINUTE_GENERIC_TZ
  'jmz': 'h:mm a z', // HOUR_MINUTETZ
  'jz': 'h a z', // HOURGENERIC_TZ
  'm': 'm', // MINUTE
  'ms': 'mm:ss', // MINUTE_SECOND
  's': 's', // SECOND
  'v': 'v', // ABBR_GENERIC_TZ
  'z': 'z', // ABBR_SPECIFIC_TZ
  'zzzz': 'zzzz', // SPECIFIC_TZ
  'ZZZZ': 'ZZZZ' // ABBR_UTC_TZ
};

final kuDateSymbols = DateSymbols(
    NAME: 'ku',
    ERAS: const ['BC', 'AD'],
    ERANAMES: const ['Before Christ', 'Anno Domini'],
    NARROWMONTHS: const [
      'J',
      'F',
      'M',
      'A',
      'M',
      'J',
      'J',
      'A',
      'S',
      'O',
      'N',
      'D'
    ],
    STANDALONENARROWMONTHS: const [
      'J',
      'F',
      'M',
      'A',
      'M',
      'J',
      'J',
      'A',
      'S',
      'O',
      'N',
      'D'
    ],
    MONTHS: const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ],
    STANDALONEMONTHS: const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ],
    SHORTMONTHS: const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ],
    STANDALONESHORTMONTHS: const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ],
    WEEKDAYS: const [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ],
    STANDALONEWEEKDAYS: const [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ],
    SHORTWEEKDAYS: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    STANDALONESHORTWEEKDAYS: const [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat'
    ],
    NARROWWEEKDAYS: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    STANDALONENARROWWEEKDAYS: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    SHORTQUARTERS: const ['Q1', 'Q2', 'Q3', 'Q4'],
    QUARTERS: const [
      '1st quarter',
      '2nd quarter',
      '3rd quarter',
      '4th quarter'
    ],
    AMPMS: const ['AM', 'PM'],
    DATEFORMATS: const ['EEEE, MMMM d, y', 'MMMM d, y', 'MMM d, y', 'M/d/yy'],
    TIMEFORMATS: const ['h:mm:ss a zzzz', 'h:mm:ss a z', 'h:mm:ss a', 'h:mm a'],
    FIRSTDAYOFWEEK: 6,
    WEEKENDRANGE: const [5, 6],
    FIRSTWEEKCUTOFFDAY: 5,
    DATETIMEFORMATS: const [
      '{1} \'at\' {0}',
      '{1} \'at\' {0}',
      '{1}, {0}',
      '{1}, {0}'
    ]);
