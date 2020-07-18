import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/model_timer_set.dart';

part 'timer_creating_event.dart';
part 'timer_creating_state.dart';

class TimerCreatingBloc extends Bloc<TimerCreatingEvent, TimerCreatingState> {
  TimerCreatingBloc() : super(TimerCreatingState.initial());

  @override
  Stream<TimerCreatingState> mapEventToState(
    TimerCreatingEvent event,
  ) async* {
    if (event is TimerSetAdded) {
      yield* _mapTimerSetAddedToState(event);
    } else if (event is TimerSetDeleted) {
      yield* _mapTimerSetDeletedToState(event);
    }
  }

  Stream<TimerCreatingState> _mapTimerSetAddedToState(
    TimerSetAdded event,
  ) async* {
    final newState = state.copyWith();
    newState.timerSets.add(TimerSetModel.initial());
    yield newState;
  }

  Stream<TimerCreatingState> _mapTimerSetDeletedToState(
    TimerSetDeleted event,
  ) async* {
    final newState = state.copyWith();
    newState.timerSets.removeAt(event.index);
    yield newState;
  }
}
