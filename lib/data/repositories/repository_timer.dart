import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../bloc/timer_creating/timer_creating_bloc.dart';

class TimerRepository {
  Future<void> save(TimerCreatingState state) async {
    final root = (await getApplicationDocumentsDirectory()).path;
    final timerPath = p.setExtension(p.join(root, 'test'), 'timer');
    final file = File(timerPath);
    await file.writeAsString(jsonEncode(state));
  }

  Future<TimerCreatingState> load() async {
    final root = (await getApplicationDocumentsDirectory()).path;
    final file = File(p.setExtension(p.join(root, 'test'), 'timer'));
    return TimerCreatingState.fromJson(jsonDecode(await file.readAsString()));
  }
}
