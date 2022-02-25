part of '../config.dart';

class DefaultConfig {
  static String environment = '';
  static String appName = '';
  static bool enableRemoteConfigFirebase = false;
  static bool enableCrashAnalytics = false;
  static String defaultLanguage = '';
  static String baseUrl = '';
  static Map serverConfig = {};
  static String appConfig = '';
  static bool defaultDarkTheme = false;
  static String countryCodeDefault = 'VN';
  static String dialCodeDefault = '+84';
  static String nameDefault = 'Vietnam';
  static Map advanceConfig = {
    'symbol': '\$',
    'decimalDigits': 2,
    'symbolBeforeTheNumber': true,
    'currency': 'USD',
    'currencyCode': 'usd',
    'smallestUnitRate': 100,
  };
  static Map storeIdentifier = {};
  static Map defaultDrawer = {};
  static List defaultSettings = [];
  static Map loginSetting = {};
  static Map oneSignalKey = {};
  static List onBoardingData = [
    {
      'title': 'Welcome to FluxStore',
      'image': 'assets/images/fogg-delivery-1.png',
      'desc': 'Fluxstore is on the way to serve you. '
    },
    {
      'title': 'Connect Surrounding World',
      'image': 'assets/images/fogg-uploading-1.png',
      'desc':
          'See all things happening around you just by a click in your phone. Fast, convenient and clean.'
    },
    {
      'title': "Let's Get Started",
      'image': 'assets/images/fogg-order-completed.png',
      'desc': "Waiting no more, let's see what we get!"
    }
  ];
  static List vendorOnBoardingData = [
    {
      'title': 'Welcome aboard',
      'image': 'assets/images/searching.png',
      'desc': 'Just a few more steps to become our vendor'
    },
    {
      'title': 'Let\'s Get Started',
      'image': 'assets/images/manage.png',
      'desc': 'Good Luck for great beginnings.'
    }
  ];

  static Map productDetail = {};
  static Map blogDetail = {
    'showComment': true,
    'showHeart': true,
    'showSharing': true,
    'enableAudioSupport': false,
  };
  static Map productVariantLayout = {};
  static Map adConfig = {
    'enable': false,
    'facebookTestingId': '',
    'googleTestingId': [],
    'ads': [
      {
        'type': 'banner',
        'provider': 'google',
        'iosId': 'ca-app-pub-3940256099942544/2934735716',
        'androidId': 'ca-app-pub-3940256099942544/6300978111',
        'showOnScreens': [],
        'hideOnScreens': [
          'category',
        ],
        // 'waitingTimeToDisplay': 8,
      },
      {
        'type': 'banner',
        'provider': 'google',
        'iosId': 'ca-app-pub-2101182411274198/5418791562',
        'androidId': 'ca-app-pub-2101182411274198/4052745095',
        'showOnScreens': ['home', 'search', 'product-detail'],
        'hideOnScreens': [],
      },
      {
        'type': 'interstitial',
        'provider': 'google',
        'iosId': 'ca-app-pub-3940256099942544/4411468910',
        'androidId': 'ca-app-pub-3940256099942544/4411468910',
        // 'showOnScreens': ['profile'],
        'hideOnScreens': [],
        // 'waitingTimeToDisplay': 8,
      },
      {
        'type': 'reward',
        'provider': 'google',
        'iosId': 'ca-app-pub-3940256099942544/1712485313',
        'androidId': 'ca-app-pub-3940256099942544/4411468910',
        // 'showOnScreens': ['cart'],
        'hideOnScreens': [],
        // 'waitingTimeToDisplay': 8,
      },
      {
        'type': 'banner',
        'provider': 'facebook',
        'iosId': 'IMG_16_9_APP_INSTALL#430258564493822_876131259906548',
        'androidId': 'IMG_16_9_APP_INSTALL#430258564493822_489007588618919',
        'showOnScreens': ['home'],
        'hideOnScreens': [],
        // 'waitingTimeToDisplay': 8,
      },
      {
        'type': 'interstitial',
        'provider': 'facebook',
        'iosId': '430258564493822_489092398610438',
        'androidId': 'IMG_16_9_APP_INSTALL#430258564493822_489092398610438',
        // 'showOnScreens': ['profile'],
        'hideOnScreens': [],
        // 'waitingTimeToDisplay': 8,
      },
    ]
  };
  static Map firebaseDynamicLinkConfig = {
    'isEnabled': true,
    // Domain is the domain name for your product.
    // Let’s assume here that your product domain is “example.com”.
    // Then you have to mention the domain name as : https://example.page.link.
    'uriPrefix': 'https://fluxstoreinspireui.page.link',
    //The link your app will open
    'link': 'https://mstore.io/',
    //----------* Android Setting *----------//
    'androidPackageName': 'com.inspireui.fluxstore',
    'androidAppMinimumVersion': 1,
    //----------* iOS Setting *----------//
    'iOSBundleId': 'com.inspireui.mstore.flutter',
    'iOSAppMinimumVersion': '1.0.1',
    'iOSAppStoreId': '1469772800'
  };
  static List<Map> languagesInfo = <Map>[];
  static List<String> unsupportedLanguages = <String>[];
  static Map paymentConfig = {};
  static Map payments = {};
  static Map stripeConfig = {};
  static Map paypalConfig = {};
  static Map razorpayConfig = {};
  static Map tapConfig = {};
  static Map payTmConfig = {'paymentMethodId': 'paytm',
    'merchantId': 'your-merchant-id',
    'production': false,
    'enabled': false};
  static Map mercadoPagoConfig = {};
  static Map afterShip = {};
  static Map productAddons = {};
  static Map cartDetail = {};
  static Map productVariantLanguage = {};
  static int excludedCategory = 311;
  static Map saleOffProduct = {};
  static bool notStrictVisibleVariant = true;
  static Map configChat = {};
  static List<Map> smartChat = [];
  static String adminEmail = '';
  static String adminName = '';
  static Map vendorConfig = {};
  static Map? loadingIcon;
  static Map productCard = {};
  static String? cardFit;
  static List defaultCountryShipping = [
    {
      'name': 'Vietnam',
      'iosCode': 'VN',
      'icon': 'https://cdn.britannica.com/41/4041-004-A06CBD63/Flag-Vietnam.jpg'
    },
    {
      'name': 'India',
      'iosCode': 'IN',
      'icon':
          'https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/1200px-Flag_of_India.svg.png'
    },
    {'name': 'Austria', 'iosCode': 'AT', 'icon': ''}
  ];
  static Map loginSMSConstants = {};
  static Map darkConfig = {};
  static Map lightConfig = {};
  static String version = '2.2.0';

  static Map orderDelivery = {
    'enable': false,
  };
  static Map subGeneralSetting = {};
  static Map splashScreen = {
    'enable': true,
    'type': 'flare',
    'image': 'assets/images/splashscreen.flr',
    'animationName': 'fluxstore',
    'duration': 2000,
  };
  static Map colorOverrideConfig = {};
}
