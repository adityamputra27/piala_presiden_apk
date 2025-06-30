import 'dart:io';

import 'package:flutter/foundation.dart';

const String debugAndroidBannerAdUnitId =
    "ca-app-pub-3940256099942544/6300978111";
const String debugIOSBannerAdUnitId = "ca-app-pub-3940256099942544/2934735716";

const String prodAndroidBannerAdUnitId =
    "ca-app-pub-8018841107474033/6127514321";

const String debugAndroidInterstitialAdUnitId =
    "ca-app-pub-3940256099942544/1033173712";
const String prodAndroidInterstitialAdUnitId =
    "ca-app-pub-8018841107474033/3501350986";

const String debugIOSInterstitialAdUnitId =
    "ca-app-pub-3940256099942544/4411468910";

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return debugAndroidBannerAdUnitId;
      } else {
        return prodAndroidBannerAdUnitId;
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return debugIOSBannerAdUnitId;
      } else {
        return debugIOSBannerAdUnitId;
      }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return debugAndroidInterstitialAdUnitId;
      } else {
        return prodAndroidInterstitialAdUnitId;
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return debugIOSInterstitialAdUnitId;
      } else {
        return debugIOSInterstitialAdUnitId;
      }
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
