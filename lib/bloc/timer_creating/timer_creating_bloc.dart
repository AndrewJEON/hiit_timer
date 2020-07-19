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
    } else if (event is TimerSetCopied) {
      yield* _mapTimerSetCopiedToState(event);
    } else if (event is TimerSetDeleted) {
      yield* _mapTimerSetDeletedToState(event);
    } else if (event is TimerSetMovedUp) {
      yield* _mapTimerSetMovedUpToState(event);
    } else if (event is TimerSetMovedDown) {
      yield* _mapTimerSetMovedDownToState(event);
    } else if (event is TimerSetRepeatCountIncreased) {
      yield* _mapTimerSetRepeatCountIncreasedToState(event);
    } else if (event is TimerSetRepeatCountDecreased) {
      yield* _mapTimerSetRepeatCountDecreasedToState(event);
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

  Stream<TimerCreatingState> _mapTimerSetCopiedToState(
    TimerSetCopied event,
  ) async* {
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)
        ..insert(event.index, state.timerSets[event.index]),
    );
  }

  Stream<TimerCreatingState> _mapTimerSetDeletedToState(
    TimerSetDeleted event,
  ) async* {
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)..removeAt(event.index),
    );
  }

  Stream<TimerCreatingState> _mapTimerSetMovedUpToState(
    TimerSetMovedUp event,
  ) async* {
    final target = state.timerSets[event.index];
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)
        ..removeAt(event.index)
        ..insert(event.index - 1, target),
    );
  }

  Stream<TimerCreatingState> _mapTimerSetMovedDownToState(
    TimerSetMovedDown event,
  ) async* {
    final target = state.timerSets[event.index];
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)
        ..removeAt(event.index)
        ..insert(event.index + 1, target),
    );
  }

  Stream<TimerCreatingState> _mapTimerSetRepeatCountIncreasedToState(
    TimerSetRepeatCountIncreased event,
  ) async* {
    final newTimerSet = state.timerSets[event.index]
        .copyWith(repeatCount: state.timerSets[event.index].repeatCount + 1);
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)
        ..removeAt(event.index)
        ..insert(event.index, newTimerSet),
    );
  }

  Stream<TimerCreatingState> _mapTimerSetRepeatCountDecreasedToState(
    TimerSetRepeatCountDecreased event,
  ) async* {
    final currentRepeatCount = state.timerSets[event.index].repeatCount;
    if (currentRepeatCount > 1) {
      final newTimerSet = state.timerSets[event.index]
          .copyWith(repeatCount: currentRepeatCount - 1);
      yield TimerCreatingState(
        timerSets: List.of(state.timerSets)
          ..removeAt(event.index)
          ..insert(event.index, newTimerSet),
      );
    }
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
