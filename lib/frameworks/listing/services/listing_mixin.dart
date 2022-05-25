import '../../../services/service_config.dart';
import '../index.dart';
import 'listing_service.dart';

mixin ListingMixin on ConfigMixin {
  @override
  void configListing(appConfig) {
    api = ListingService(
      domain: appConfig['url'],
      blogDomain: appConfig['blog'],
      consumerKey: appConfig['consumerKey'] ??
          'ck_0e7d6d841d5d0c952e92d827abb529674f25f8f5',
      consumerSecret: appConfig['consumerSecret'] ??
          'cs_7811cbea91c2ff24999627fc1d61a1371d6a918f',
      type: appConfig['type'],
    );
    widget = ListingWidget();
  }
}
