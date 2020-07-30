import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/foreground_service.dart';
import '../../core/prefs_keys.dart';
import '../../core/service_locator.dart';
import '../../data/models/model_timer.dart';
import '../../data/models/model_timer_piece.dart';
import '../../data/repositories/repository_timer.dart';
import '../repeat_count/repeat_count_bloc.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimerRepository repository;
  final RepeatCountBloc repeatCountBloc;
  final prefs = sl<SharedPreferences>();

  TimerModel _currentTimer;

  TimerModel get currentTimer => _currentTimer;

  TimerBloc({
    this.repository,
    this.repeatCountBloc,
  }) : super(TimerInitial()) {
    add(TimerInitialized());
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
      } else if (event is TimerSelected) {
        yield* _mapTimerSelectedToState(event);
      }
    } catch (e) {
      debugPrint('TimerBloc error: $e');
      yield TimerFailure.unexpected();
    }
  }

  Stream<TimerState> _mapTimerInitializedToState(
    TimerInitialized event,
  ) async* {
    if (prefs.getBool(PrefsKeys.firstOpen) ?? true) {
      _currentTimer = TimerModel.example();
      await repository.save(_currentTimer);
      await repository.saveLatestTimer(_currentTimer);
      prefs.setBool(PrefsKeys.firstOpen, false);
    }
    _currentTimer = await repository.loadLatestTimer();
    if (_currentTimer == null) {
      yield TimerFailure.noSavedTimer();
      return;
    }
    yield TimerReady(
      remainingTime: _currentTimer.timerSets[0].timers[0].duration,
      name: _currentTimer.name,
      tts: _currentTimer.timerSets[0].timers[0].description,
    );
    ForegroundService.platform.setMethodCallHandler((call) async {
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

  Stream<TimerState> _mapTimerStartedToState(
    TimerStarted event,
  ) async* {
    final flattened = _flattenTimer(_currentTimer);
    final times = flattened.map((e) => e.duration.inSeconds).toList();
    final ttses = flattened.map((e) => e.description).toList();
    final repeatCount = repeatCountBloc.state;
    final settings = <String, dynamic>{
      'warning3Remaining': prefs.getBool(PrefsKeys.warning3Remaining) ?? true,
      'vibration': prefs.getBool(PrefsKeys.vibration) ?? false,
    };
    ForegroundService.start(times, ttses, repeatCount, settings);
    yield TimerRunning(
      remainingTime: _currentTimer.timerSets[0].timers[0].duration,
      name: state.name,
      tts: state.tts,
    );
  }

  Stream<TimerState> _mapTimerPausedToState(
    TimerPaused event,
  ) async* {
    ForegroundService.pause();
    yield TimerPause(
      remainingTime: state.remainingTime,
      name: state.name,
      tts: state.tts,
    );
  }

  Stream<TimerState> _mapTimerResumedToState(
    TimerResumed event,
  ) async* {
    ForegroundService.resume();
    yield TimerRunning(
      remainingTime: state.remainingTime,
      name: state.name,
      tts: state.tts,
    );
  }

  Stream<TimerState> _mapTimerResetToState(
    TimerReset event,
  ) async* {
    if (state is TimerRunning || state is TimerPause || state is TimerFinish) {
      ForegroundService.stop();
      yield TimerReady(
        remainingTime: _currentTimer.timerSets[0].timers[0].duration,
        name: _currentTimer.name,
        tts: _currentTimer.timerSets[0].timers[0].description,
      );
    }
  }

  Stream<TimerState> _mapTimerTickedToState(
    TimerTicked event,
  ) async* {
    if (event.remainingTime.inSeconds == -1) {
      yield TimerFinish(
        name: state.name,
        tts: event.tts,
      );
    } else {
      if (event.isRunning) {
        yield TimerRunning(
          remainingTime: event.remainingTime,
          name: state.name,
          tts: event.tts,
        );
      } else {
        yield TimerPause(
          remainingTime: event.remainingTime,
          name: state.name,
          tts: event.tts,
        );
      }
    }
  }

  Stream<TimerState> _mapTimerSelectedToState(
    TimerSelected event,
  ) async* {
    ForegroundService.stop();
    _currentTimer = event.timer;
    if (_currentTimer == null) {
      yield TimerFailure.noSavedTimer();
      return;
    }
    yield TimerReady(
      remainingTime: _currentTimer.timerSets[0].timers[0].duration,
      name: _currentTimer.name,
      tts: _currentTimer.timerSets[0].timers[0].description,
    );
    await repository.saveLatestTimer(event.timer);
  }

  Stream<TimerState> _mapTimerForwardedToState(
    TimerForwarded event,
  ) async* {
    final duration = prefs.getInt(PrefsKeys.forwardDuration) ?? 5;
    ForegroundService.forward(duration);
  }

  Stream<TimerState> _mapTimerRewoundToState(
    TimerRewound event,
  ) async* {
    final duration = prefs.getInt(PrefsKeys.rewindDuration) ?? 5;
    ForegroundService.rewind(duration);
  }
}
