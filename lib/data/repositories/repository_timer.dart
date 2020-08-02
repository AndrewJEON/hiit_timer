import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/prefs_keys.dart';
import '../../core/service_locator.dart';
import '../models/model_timer.dart';

class TimerRepository {
  static const timerExtension = '.timer';

  final prefs = sl<SharedPreferences>();
  final timerDir = sl<Directory>();

  Future<void> save(TimerModel timer) async {
    final timerPath =
        p.setExtension(p.join(timerDir.path, timer.name), timerExtension);
    final file = File(timerPath);
    await file.writeAsString(jsonEncode(timer));
  }

  Future<List<TimerModel>> load() async {
    final files =
        timerDir.list().where((entity) => entity is File).cast<File>();
    final timers = <TimerModel>[];
    await for (final file in files) {
      if (p.extension(file.path) == timerExtension) {
        final jsonString = await file.readAsString();
        final name = p.basenameWithoutExtension(file.path);
        final timer = TimerModel.fromJson(jsonDecode(jsonString), name);
        timers.add(timer);
      }
    }
    return timers;
  }

  Future<void> delete(TimerModel timer) async {
    final timerPath =
        p.setExtension(p.join(timerDir.path, timer.name), timerExtension);
    await File(timerPath).delete();
  }

  Future<void> rename(TimerModel timer, {String newName}) async {
    final timerPath =
        p.setExtension(p.join(timerDir.path, timer.name), timerExtension);
    final newTimerPath =
        p.setExtension(p.join(timerDir.path, newName), timerExtension);
    await File(timerPath).rename(newTimerPath);
  }

  Future<TimerModel> loadLatestTimer() async {
    if (prefs.getBool(PrefsKeys.firstOpen) ?? true) {
      final example = TimerModel.example();
      await save(example);
      await saveLatestTimer(example);
      prefs.setBool(PrefsKeys.firstOpen, false);
      return TimerModel.example();
    }

    final name = prefs.getString(PrefsKeys.latestTimerKey);
    final files =
        timerDir.list().where((entity) => entity is File).cast<File>();
    await for (final file in files) {
      if (p.basenameWithoutExtension(file.path) == name) {
        final jsonString = await file.readAsString();
        final name = p.basenameWithoutExtension(file.path);
        return TimerModel.fromJson(jsonDecode(jsonString), name);
      }
    }
    return null;
  }

  Future<void> saveLatestTimer(TimerModel timer) async {
    prefs.setString(PrefsKeys.latestTimerKey, timer.name);
  }

  Future<bool> isDuplicate(String name) async {
    final files =
        timerDir.list().where((entity) => entity is File).cast<File>();
    await for (final file in files) {
      if (p.basenameWithoutExtension(file.path) == name) {
        return true;
      }
    }
    return false;
  }
}
