import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForegroundService {
  static const platform =
      const MethodChannel('com.highutil.interval_timer/timer');

  static Future<void> start(
    List<int> timesInSecond,
    List<String> ttses,
    int repeatCount,
  ) async {
    try {
      await platform.invokeMethod('start', <String, dynamic>{
        'times': timesInSecond,
        'ttses': ttses,
        'repeatCount': repeatCount,
      });
    } on PlatformException catch (e) {
      debugPrint('ForegroundService start error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to start the timer',
        backgroundColor: Colors.black38,
      );
    }
  }

  static Future<void> pause() async {
    try {
      await platform.invokeMethod('pause');
    } on PlatformException catch (e) {
      debugPrint('ForegroundService pause error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to pause the timer',
        backgroundColor: Colors.black38,
      );
    }
  }

  static Future<void> resume() async {
    try {
      await platform.invokeMethod('resume');
    } on PlatformException catch (e) {
      debugPrint('ForegroundService resume error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to resume the timer',
        backgroundColor: Colors.black38,
      );
    }
  }

  static Future<void> stop() async {
    try {
      await platform.invokeMethod('stop');
    } on PlatformException catch (e) {
      debugPrint('ForegroundService stop error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to stop the timer',
        backgroundColor: Colors.black38,
      );
    }
  }
}
