part of '../config.dart';

/// Ads layout type for Admob and Facebook Ads
enum kAdType {
  googleBanner,
  googleInterstitial,
  googleReward,
  facebookBanner,
  facebookInterstitial,
  facebookNative,
  facebookNativeBanner,
}

Map get kAdConfig => Configurations.adConfig;
