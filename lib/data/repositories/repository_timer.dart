import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

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
    final files = timerDir.list().where((entity) => entity is File).cast<File>();
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

  Future<TimerModel> loadLatestTimer() async {
    final name = prefs.getString('latest_timer');
    final files = timerDir.list().where((entity) => entity is File).cast<File>();
    await for(final file in files) {
      if(p.basenameWithoutExtension(file.path) == name) {
        final jsonString = await file.readAsString();
        final name = p.basenameWithoutExtension(file.path);
        return TimerModel.fromJson(jsonDecode(jsonString), name);
      }
    }
    return null;
  }

  Future<void> saveCurrentTimer(TimerModel timer) async {
    prefs.setString('latest_timer', timer.name);
  }
}
