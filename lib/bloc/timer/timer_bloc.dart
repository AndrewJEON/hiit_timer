import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../data/models/model_timer.dart';
import '../../data/models/model_timer_piece.dart';
import '../../data/repositories/repository_timer.dart';
import '../repeat_count/repeat_count_bloc.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimerRepository repository;
  final RepeatCountBloc repeatCountBloc;

  StreamSubscription<int> _tickerSubscription;
  List<TimerPieceModel> _currentTimer;
  int _index = 0;
  int _repeatCount;

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

  Stream<int> _tick({int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
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
      }
    } catch (e) {
      debugPrint('TimerBloc error: $e');
      yield TimerFailure.unexpected();
    }
  }

  @override
  Future<void> close() async {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapTimerInitializedToState(
    TimerInitialized event,
  ) async* {
    final latestTimer = await repository.loadLatestTimer();
    _repeatCount = repeatCountBloc.state;
    if (latestTimer != null) {
      _currentTimer = _flattenTimer(latestTimer);
      yield TimerReady(remainingTime: _currentTimer[_index = 0].duration);
    } else {
      yield TimerFailure.noSavedTimer();
    }
  }

  Stream<TimerState> _mapTimerStartedToState(
    TimerStarted event,
  ) async* {
    _repeatCount = repeatCountBloc.state;
    final remainingTime = _currentTimer[_index = 0].duration;
    yield TimerRunning(remainingTime: remainingTime);
    _tickerSubscription?.cancel();
    _tickerSubscription = _tick(ticks: remainingTime.inSeconds).listen(
      (remainingTime) {
        add(TimerTicked(remainingTime: Duration(seconds: remainingTime)));
      },
    );
  }

  Stream<TimerState> _mapTimerPausedToState(
    TimerPaused event,
  ) async* {
    final currentState = state;
    if (currentState is TimerRunning) {
      _tickerSubscription?.pause();
      yield TimerPause(remainingTime: currentState.remainingTime);
    }
  }

  Stream<TimerState> _mapTimerResumedToState(
    TimerResumed event,
  ) async* {
    final currentState = state;
    if (currentState is TimerPause) {
      _tickerSubscription?.resume();
      yield TimerRunning(remainingTime: currentState.remainingTime);
    }
  }

  Stream<TimerState> _mapTimerResetToState(
    TimerReset event,
  ) async* {
    _tickerSubscription?.cancel();
    if (event.timer != null) {
      _currentTimer = _flattenTimer(event.timer);
    }
    yield TimerReady(remainingTime: _currentTimer[_index = 0].duration);
  }

  Stream<TimerState> _mapTimerTickedToState(
    TimerTicked event,
  ) async* {
    if (event.remainingTime.inSeconds > 0) {
      yield TimerRunning(remainingTime: event.remainingTime);
    } else {
      if (_index < _currentTimer.length - 1) {
        final remainingTime = _currentTimer[++_index].duration;
        yield TimerRunning(remainingTime: remainingTime);
        _tickerSubscription?.cancel();
        _tickerSubscription = _tick(ticks: remainingTime.inSeconds).listen(
          (remainingTime) {
            add(TimerTicked(remainingTime: Duration(seconds: remainingTime)));
          },
        );
      } else {
        if (_repeatCount > 1) {
          _repeatCount--;
          final remainingTime = _currentTimer[_index = 0].duration;
          yield TimerRunning(remainingTime: remainingTime);
          _tickerSubscription?.cancel();
          _tickerSubscription = _tick(ticks: remainingTime.inSeconds).listen(
            (remainingTime) {
              add(TimerTicked(remainingTime: Duration(seconds: remainingTime)));
            },
          );
        } else if (_repeatCount == -1) {
          final remainingTime = _currentTimer[_index = 0].duration;
          yield TimerRunning(remainingTime: remainingTime);
          _tickerSubscription?.cancel();
          _tickerSubscription = _tick(ticks: remainingTime.inSeconds).listen(
            (remainingTime) {
              add(TimerTicked(remainingTime: Duration(seconds: remainingTime)));
            },
          );
        } else {
          yield TimerFinish();
        }
      }
    }
  }
}
