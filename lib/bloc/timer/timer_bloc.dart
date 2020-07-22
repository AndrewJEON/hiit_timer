import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../data/models/model_timer.dart';
import '../../data/models/model_timer_piece.dart';
import '../../data/repositories/repository_timer.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimerRepository repository;

  StreamSubscription<int> _tickerSubscription;
  List<TimerPieceModel> _currentTimer;
  int _index = 0;
  int _repeatCount;

  TimerBloc(this.repository) : super(TimerInitial()) {
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
      } else if (event is TimerSelected) {
        yield* _mapTimerSelectedToState(event);
      } else if (event is TimerRepeatCountChanged) {
        yield* _mapTimerRepeatCountChangedToState(event);
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
    _repeatCount = await repository.loadRepeatCount();
    if (latestTimer != null) {
      _currentTimer = _flattenTimer(latestTimer);
      yield TimerReady(
        remainingTime: _currentTimer[_index = 0].duration,
        repeatCount: _repeatCount,
      );
    } else {
      yield TimerFailure.noSavedTimer();
    }
  }

  Stream<TimerState> _mapTimerStartedToState(
    TimerStarted event,
  ) async* {
    _repeatCount = state.repeatCount;
    final remainingTime = _currentTimer[_index = 0].duration;
    yield TimerRunning(
      remainingTime: remainingTime,
      repeatCount: state.repeatCount,
    );
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
      yield TimerPause(
        remainingTime: currentState.remainingTime,
        repeatCount: state.repeatCount,
      );
    }
  }

  Stream<TimerState> _mapTimerResumedToState(
    TimerResumed event,
  ) async* {
    final currentState = state;
    if (currentState is TimerPause) {
      _tickerSubscription?.resume();
      yield TimerRunning(
        remainingTime: currentState.remainingTime,
        repeatCount: state.repeatCount,
      );
    }
  }

  Stream<TimerState> _mapTimerResetToState(
    TimerReset event,
  ) async* {
    _tickerSubscription?.cancel();
    yield TimerReady(
      remainingTime: _currentTimer[_index = 0].duration,
      repeatCount: state.repeatCount,
    );
  }

  Stream<TimerState> _mapTimerTickedToState(
    TimerTicked event,
  ) async* {
    if (event.remainingTime.inSeconds > 0) {
      yield TimerRunning(
        remainingTime: event.remainingTime,
        repeatCount: state.repeatCount,
      );
    } else {
      if (_index < _currentTimer.length - 1) {
        final remainingTime = _currentTimer[++_index].duration;
        yield TimerRunning(
          remainingTime: remainingTime,
          repeatCount: state.repeatCount,
        );
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
          yield TimerRunning(
            remainingTime: remainingTime,
            repeatCount: state.repeatCount,
          );
          _tickerSubscription?.cancel();
          _tickerSubscription = _tick(ticks: remainingTime.inSeconds).listen(
            (remainingTime) {
              add(TimerTicked(remainingTime: Duration(seconds: remainingTime)));
            },
          );
        } else {
          yield TimerFinish(repeatCount: state.repeatCount);
        }
      }
    }
  }

  Stream<TimerState> _mapTimerSelectedToState(
    TimerSelected event,
  ) async* {
    _tickerSubscription?.cancel();
    await repository.saveCurrentTimer(event.timer);
    _currentTimer = _flattenTimer(event.timer);
    yield TimerReady(
      remainingTime: _currentTimer[_index = 0].duration,
      repeatCount: state.repeatCount,
    );
  }

  Stream<TimerState> _mapTimerRepeatCountChangedToState(
    TimerRepeatCountChanged event,
  ) async* {
    if (event.repeatCount >= -1) {
      await repository
          .saveRepeatCount(event.repeatCount == 0 ? 1 : event.repeatCount);
      yield TimerReady(
        remainingTime: _currentTimer[_index = 0].duration,
        repeatCount: event.repeatCount == 0 ? 1 : event.repeatCount,
      );
    }
  }
}
