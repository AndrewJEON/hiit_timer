import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/repository_timer.dart';

final sl = GetIt.I;

Future<void> initServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  final appDocDir = await getApplicationDocumentsDirectory();
  final timerDir = Directory(p.join(appDocDir.path, 'timers'));
  if (!await timerDir.exists()) {
    await timerDir.create();
  }

  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => timerDir);

  sl.registerLazySingleton(() => TimerRepository());
}
