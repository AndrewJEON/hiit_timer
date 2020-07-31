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
      theme: theme(context),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData theme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.amber[800],
      accentColor: Colors.amber[800],
      appBarTheme: AppBarTheme(
        color: Colors.transparent,
        elevation: 0
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        )
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
      ),
      popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      )),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
