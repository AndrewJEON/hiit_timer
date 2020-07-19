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
    } else if (event is TimerDescriptionChanged) {
      yield* _mapTimerDescriptionChangedToState(event);
    }
  }

  Stream<TimerCreatingState> _mapTimerSetAddedToState(
    TimerSetAdded event,
  ) async* {
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)..add(TimerSetModel.initial()),
    );
  }

  Stream<TimerCreatingState> _mapTimerSetDeletedToState(
    TimerSetDeleted event,
  ) async* {
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)..removeAt(event.index),
    );
  }

  Stream<TimerCreatingState> _mapTimerDescriptionChangedToState(
    TimerDescriptionChanged event,
  ) async* {
    final newTimer = state.timerSets[event.setIndex].timers[event.index]
        .copyWith(description: event.description);
    final newTimerSet = state.timerSets[event.setIndex].copyWith(
      timers: List.of(state.timerSets[event.setIndex].timers)
        ..removeAt(event.index)
        ..insert(event.index, newTimer),
    );
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)
        ..removeAt(event.setIndex)
        ..insert(event.setIndex, newTimerSet),
    );
  }
}
