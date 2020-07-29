import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../core/foreground_service.dart';
import '../../data/models/model_timer.dart';
import '../../data/models/model_timer_piece.dart';
import '../../data/repositories/repository_timer.dart';
import '../repeat_count/repeat_count_bloc.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimerRepository repository;
  final RepeatCountBloc repeatCountBloc;

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
    _currentTimer = await repository.loadLatestTimer();
    if (_currentTimer == null) {
      yield TimerFailure.noSavedTimer();
      return;
    }
    yield TimerReady(_currentTimer.timerSets[0].timers[0].duration);
    ForegroundService.platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'tick':
          final data = call.arguments as Map;
          add(TimerTicked(
            remainingTime: Duration(seconds: data["remainingTime"]),
            timerState: data["timerState"],
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
    ForegroundService.start(times, ttses, repeatCount);
    yield TimerRunning(_currentTimer.timerSets[0].timers[0].duration);
  }

  Stream<TimerState> _mapTimerPausedToState(
    TimerPaused event,
  ) async* {
    ForegroundService.pause();
    yield TimerPause(state.remainingTime);
  }

  Stream<TimerState> _mapTimerResumedToState(
    TimerResumed event,
  ) async* {
    ForegroundService.resume();
    yield TimerRunning(state.remainingTime);
  }

  Stream<TimerState> _mapTimerResetToState(
    TimerReset event,
  ) async* {
    ForegroundService.stop();
    yield TimerReady(_currentTimer.timerSets[0].timers[0].duration);
  }

  Stream<TimerState> _mapTimerTickedToState(
    TimerTicked event,
  ) async* {
    if (event.remainingTime.inSeconds == -1) {
      yield TimerFinish();
    } else {
      if (event.timerState == "STATE_RUNNING") {
        yield TimerRunning(event.remainingTime);
      } else {
        yield TimerPause(event.remainingTime);
      }
    }
  }

  Stream<TimerState> _mapTimerSelectedToState(
    TimerSelected event,
  ) async* {
    ForegroundService.stop();
    _currentTimer = event.timer;
    yield TimerReady(_currentTimer.timerSets[0].timers[0].duration);
  }
}
