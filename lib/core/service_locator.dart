import 'package:get_it/get_it.dart';

import '../data/repositories/repository_timer.dart';

final sl = GetIt.I;

Future<void> initServiceLocator() async {
  sl.registerLazySingleton(() => TimerRepository());
}