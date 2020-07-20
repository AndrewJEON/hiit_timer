import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/model_timer.dart';

class TimerRepository {
  Future<void> save(TimerModel state) async {
    final root = (await getApplicationDocumentsDirectory()).path;
    final timerPath = p.setExtension(p.join(root, 'test'), 'timer');
    final file = File(timerPath);
    await file.writeAsString(jsonEncode(state));
  }

  Future<TimerModel> load() async {
    final root = (await getApplicationDocumentsDirectory()).path;
    final file = File(p.setExtension(p.join(root, 'test'), 'timer'));
    return TimerModel.fromJson(jsonDecode(await file.readAsString()));
  }
}
