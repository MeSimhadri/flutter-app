import 'advertisement_item.dart';

class AdvertisementConfig {
  final List<AdvertisementItem> ads;
  final String facebookTestingId;
  final List<String> googleTestingId;
  final bool enable;
  final String adMobAppId;

  AdvertisementConfig copyWith({
    List<AdvertisementItem>? ads,
    String? facebookTestingId,
    List<String>? googleTestingId,
    bool? enable,
    String? adMobAppId,
  }) {
    return AdvertisementConfig(
      enable: enable ?? this.enable,
      googleTestingId: List.from(googleTestingId ?? this.googleTestingId),
      facebookTestingId: facebookTestingId ?? this.facebookTestingId,
      ads: List.from(ads ?? this.ads),
      adMobAppId: adMobAppId ?? this.adMobAppId,
    );
  }

  factory AdvertisementConfig.fromJson(
      {required Map<dynamic, dynamic> adConfig}) {
    // if (adConfig?.isEmpty ?? true) return null;
    List list = adConfig['ads'] ?? [];
    final _ads = list.map((e) => AdvertisementItem.fromJson(e)).toList();
    final _facebookTestingId = adConfig['facebookTestingId'] ?? '';
    final _googleTestingId =
        List<String>.from(adConfig['googleTestingId'] ?? <String>[]);
    final _enable = adConfig['enable'] ?? false;
    final _adMobAppId = adConfig['adMobAppId'] ?? '';
    return AdvertisementConfig(
      ads: _ads,
      facebookTestingId: _facebookTestingId,
      googleTestingId: _googleTestingId,
      enable: _enable,
      adMobAppId: _adMobAppId,
    );
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('enable', enable);
    writeNotNull('facebookTestingId', facebookTestingId);
    writeNotNull('googleTestingId', googleTestingId);
    writeNotNull('ads', ads.map((e) => e.toJson()).toList());
    writeNotNull('adMobAppId', adMobAppId);
    return val;
  }

  const AdvertisementConfig({
    this.ads = const <AdvertisementItem>[],
    this.facebookTestingId = '',
    this.enable = false,
    this.googleTestingId = const <String>[],
    this.adMobAppId = '',
  });
}
