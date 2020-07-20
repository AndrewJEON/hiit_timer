import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/model_timer.dart';
import '../../data/repositories/repository_timer.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimerRepository repository;

  TimerBloc(this.repository) : super(TimerInitial()) {
    add(TimerInitialized());
  }

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is TimerInitialized) {
      yield* _mapTimerInitializedToState(event);
    } else if (event is TimerSelected) {
      yield* _mapTimerSelectedToState(event);
    }
  }

  Stream<TimerState> _mapTimerInitializedToState(
    TimerInitialized event,
  ) async* {
    try {
      final timer = await repository.loadLatestTimer();
      if (timer != null) {
        yield TimerIdle(timer);
      } else {
        yield TimerFailure.noSavedTimer();
      }
    } catch (e) {
      yield TimerFailure('Oops! Something went wrong');
    }
  }

  Stream<TimerState> _mapTimerSelectedToState(
    TimerSelected event,
  ) async* {
    try {
      await repository.saveCurrentTimer(event.timer);
      yield TimerIdle(event.timer);
    } catch (e) {
      yield TimerFailure('Oops! Something went wrong');
    }
  }
}
