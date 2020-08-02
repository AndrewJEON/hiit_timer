import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';

final appId =
    Platform.isAndroid ? 'ca-app-pub-5637953999940373~1509467803' : null;

final interstitialAdUnitId =
    Platform.isAndroid ? 'ca-app-pub-5637953999940373/7580052137' : null;

final interstitialAd = AdmobInterstitial(
  adUnitId: kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : interstitialAdUnitId,
  listener: (event, args) {
    if (event == AdmobAdEvent.closed) {
      interstitialAd.load();
    }
  },
);

Future<void> showInterstitialAd() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult != ConnectivityResult.none) {
    interstitialAd.show();
  }
}
