import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/current_timer/current_timer_bloc.dart';
import 'bloc/preset/preset_bloc.dart';
import 'bloc/repeat_count/repeat_count_bloc.dart';
import 'bloc/timer/timer_bloc.dart';
import 'core/admob_ads.dart';
import 'core/service_locator.dart';
import 'data/repositories/repository_timer.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  Admob.initialize(testDeviceIds: ['6AD57F922642FD63F774D9F1A84879B2']);
  interstitialAd.load();
  await initServiceLocator();
  final currentTimerBloc = CurrentTimerBloc(repository: sl<TimerRepository>());
  final repeatCountBloc = RepeatCountBloc();
  final timerBloc = TimerBloc(
    repository: sl<TimerRepository>(),
    currentTimerBloc: currentTimerBloc,
    repeatCountBloc: repeatCountBloc,
  );
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => currentTimerBloc),
      BlocProvider(create: (context) => repeatCountBloc),
      BlocProvider(create: (context) => timerBloc),
      BlocProvider(
          create: (context) => PresetBloc(
                repository: sl<TimerRepository>(),
                currentTimerBloc: currentTimerBloc,
              )),
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
      primaryColor: Color(0xff5859e4),
      accentColor: Color(0xff5859e4),
      appBarTheme: AppBarTheme(
        color: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
              headline6: Theme.of(context).textTheme.headline6.copyWith(
                    color: Colors.black,
                  ),
            ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      )),
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
