import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/admob_ads.dart';
import '../../core/prefs_keys.dart';
import '../../core/service_locator.dart';
import '../../data/models/model_timer.dart';
import '../../data/models/model_timer_piece.dart';
import '../../data/repositories/repository_timer.dart';
import '../current_timer/current_timer_bloc.dart';
import '../repeat_count/repeat_count_bloc.dart';

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  static const platform =
      const MethodChannel('com.tabata_timer.hiit_timer/timer');

  final TimerRepository repository;
  final CurrentTimerBloc currentTimerBloc;
  final RepeatCountBloc repeatCountBloc;
  final prefs = sl<SharedPreferences>();

  TimerBloc({
    @required this.repository,
    @required this.currentTimerBloc,
    @required this.repeatCountBloc,
  }) : super(TimerLoadInProgress()) {
    currentTimerBloc.listen((currentTimer) {
      add(TimerInitialized(currentTimer));
    });
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'tick':
          final data = call.arguments as Map;
          add(TimerTicked(
            remainingTime: Duration(seconds: data["remainingTime"]),
            isRunning: data["isRunning"],
            tts: data["tts"],
          ));
          return true;
          break;
        default:
          return false;
          break;
      }
    });
  }

  List<TimerPieceModel> _flattenTimer(TimerModel timer) {
    final flattenedTimer = <TimerPieceModel>[];
    for (final timerSet in timer.timerSets) {
      for (var i = 0; i < timerSet.repeatCount; i++) {
        for (final timer in timerSet.timers) {
          flattenedTimer.add(timer);
        }
      }
    }
    return flattenedTimer;
  }

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    try {
      if (event is TimerInitialized) {
        yield* _mapTimerInitializedToState(event);
      } else if (event is TimerStarted) {
        yield* _mapTimerStartedToState(event);
      } else if (event is TimerPaused) {
        yield* _mapTimerPausedToState(event);
      } else if (event is TimerResumed) {
        yield* _mapTimerResumedToState(event);
      } else if (event is TimerReset) {
        yield* _mapTimerResetToState(event);
      } else if (event is TimerTicked) {
        yield* _mapTimerTickedToState(event);
      } else if (event is TimerForwarded) {
        yield* _mapTimerForwardedToState(event);
      } else if (event is TimerRewound) {
        yield* _mapTimerRewoundToState(event);
      }
    } catch (e) {
      debugPrint('TimerBloc error: $e');
      yield TimerFailure.unexpected();
    }
  }

  Stream<TimerState> _mapTimerInitializedToState(
    TimerInitialized event,
  ) async* {
    if (state is! TimerRunning &&
        state is! TimerPause &&
        state is! TimerFinish) {
      if (event.timer != null) {
        yield TimerReady(
          remainingTime: event.timer.timerSets[0].timers[0].duration,
          tts: event.timer.timerSets[0].timers[0].tts,
        );
      } else {
        yield TimerFailure.noSavedTimer();
      }
    } else {
      showInterstitialAd();
    }
  }

  Stream<TimerState> _mapTimerStartedToState(
    TimerStarted event,
  ) async* {
    final selected = currentTimerBloc.state;
    final flattened = _flattenTimer(selected);
    final times = flattened.map((e) => e.duration.inSeconds).toList();
    final ttses = flattened.map((e) => e.tts).toList();
    final repeatCount = repeatCountBloc.state;
    final settings = <String, dynamic>{
      'vibration': prefs.getBool(PrefsKeys.vibration) ?? false,
      'warning3Remaining': prefs.getBool(PrefsKeys.warning3Remaining) ?? true,
    };
    try {
      await platform.invokeMethod('start', <String, dynamic>{
        'times': times,
        'ttses': ttses,
        'repeatCount': repeatCount,
        'settings': settings,
      });
    } on PlatformException catch (e) {
      debugPrint('ForegroundService start error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to start the timer',
        backgroundColor: Colors.grey[500],
      );
    }
    yield TimerRunning(
      remainingTime: selected.timerSets[0].timers[0].duration,
      tts: selected.timerSets[0].timers[0].tts,
    );
  }

  Stream<TimerState> _mapTimerPausedToState(
    TimerPaused event,
  ) async* {
    try {
      await platform.invokeMethod('pause');
    } on PlatformException catch (e) {
      debugPrint('ForegroundService pause error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to pause the timer',
        backgroundColor: Colors.black38,
      );
    }
    yield TimerPause(
      remainingTime: state.remainingTime,
      tts: state.tts,
    );
  }

  Stream<TimerState> _mapTimerResumedToState(
    TimerResumed event,
  ) async* {
    try {
      await platform.invokeMethod('resume');
    } on PlatformException catch (e) {
      debugPrint('ForegroundService resume error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to resume the timer',
        backgroundColor: Colors.black38,
      );
    }
    yield TimerRunning(
      remainingTime: state.remainingTime,
      tts: state.tts,
    );
  }

  Stream<TimerState> _mapTimerResetToState(
    TimerReset event,
  ) async* {
    if (state is TimerRunning || state is TimerPause || state is TimerFinish) {
      try {
        await platform.invokeMethod('stop');
      } on PlatformException catch (e) {
        debugPrint('ForegroundService stop error: $e');
        Fluttertoast.showToast(
          msg: 'Failed to stop the timer',
          backgroundColor: Colors.black38,
        );
      }

      final selected = currentTimerBloc.state;
      yield TimerReady(
        remainingTime: selected.timerSets[0].timers[0].duration,
        tts: selected.timerSets[0].timers[0].tts,
      );
    }
  }

  Stream<TimerState> _mapTimerTickedToState(
    TimerTicked event,
  ) async* {
    if (event.remainingTime.inSeconds == -1) {
      yield TimerFinish(
        tts: event.tts,
      );
    } else {
      if (event.isRunning) {
        yield TimerRunning(
          remainingTime: event.remainingTime,
          tts: event.tts,
        );
      } else {
        yield TimerPause(
          remainingTime: event.remainingTime,
          tts: event.tts,
        );
      }
    }
  }

  Stream<TimerState> _mapTimerForwardedToState(
    TimerForwarded event,
  ) async* {
    final duration = prefs.getInt(PrefsKeys.forwardDuration) ?? 5;
    try {
      await platform.invokeMethod('forward', <String, dynamic>{
        "forwardDuration": duration,
      });
    } on PlatformException catch (e) {
      debugPrint('ForegroundService forward error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to forward the timer',
        backgroundColor: Colors.black38,
      );
    }
  }

  Stream<TimerState> _mapTimerRewoundToState(
    TimerRewound event,
  ) async* {
    final duration = prefs.getInt(PrefsKeys.rewindDuration) ?? 5;
    try {
      await platform.invokeMethod('rewind', <String, dynamic>{
        "rewindDuration": duration,
      });
    } on PlatformException catch (e) {
      debugPrint('ForegroundService rewind error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to rewind the timer',
        backgroundColor: Colors.black38,
      );
    }
  }
}
