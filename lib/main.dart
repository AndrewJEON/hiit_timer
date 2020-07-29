import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/preset/preset_bloc.dart';
import 'bloc/repeat_count/repeat_count_bloc.dart';
import 'bloc/timer/timer_bloc.dart';
import 'core/service_locator.dart';
import 'data/repositories/repository_timer.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  final repeatCountBloc = RepeatCountBloc();
  final timerBloc = TimerBloc(
    repository: sl<TimerRepository>(),
    repeatCountBloc: repeatCountBloc,
  );
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => repeatCountBloc,
      ),
      BlocProvider(
        create: (context) => timerBloc,
      ),
      BlocProvider(
        create: (context) => PresetBloc(
          repository: sl<TimerRepository>(),
          timerBloc: timerBloc,
        ),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interval Timer',
      theme: theme(),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData theme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
