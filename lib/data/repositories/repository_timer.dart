import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/model_timer.dart';

class TimerRepository {
  static const timerExtension = '.timer';

  Future<void> save(TimerModel timer) async {
    final rootPath = (await getApplicationDocumentsDirectory()).path;
    final timerPath =
        p.setExtension(p.join(rootPath, timer.name), timerExtension);
    final file = File(timerPath);
    await file.writeAsString(jsonEncode(timer));
  }

  Future<List<TimerModel>> load() async {
    final rootDir = await getApplicationDocumentsDirectory();
    final files = rootDir.list().where((entity) => entity is File).cast<File>();
    final timers = <TimerModel>[];
    await for (final file in files) {
      if (p.extension(file.path) == timerExtension) {
        final jsonString = await file.readAsString();
        final name = p.basename(file.path);
        final timer = TimerModel.fromJson(jsonDecode(jsonString), name);
        timers.add(timer);
      }
    }
    return timers;
  }
}
