import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/model_timer.dart';
import '../../data/models/model_timer_set.dart';
import '../../data/repositories/repository_timer.dart';

part 'timer_creating_event.dart';
part 'timer_creating_state.dart';

class TimerCreatingBloc extends Bloc<TimerCreatingEvent, TimerCreatingState> {
  final TimerRepository repository;

  TimerCreatingBloc(this.repository) : super(TimerCreatingState.initial());

  @override
  Stream<TimerCreatingState> mapEventToState(
    TimerCreatingEvent event,
  ) async* {
    if (event is TimerSaved) {
      await repository.save(state);
    } else if (event is TimerSetAdded) {
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
    } else if (event is TimerAdded) {
      yield* _mapTimerAddedToState(event);
    } else if (event is TimerCopied) {
      yield* _mapTimerCopiedToState(event);
    } else if (event is TimerDeleted) {
      yield* _mapTimerDeletedToState(event);
    } else if (event is TimerMovedUp) {
      yield* _mapTimerMovedUpToState(event);
    } else if (event is TimerMovedDown) {
      yield* _mapTimerMovedDownToState(event);
    } else if (event is TimerDurationChanged) {
      yield* _mapTimerDurationChangedToState(event);
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
    if (event.index > 0) {
      final target = state.timerSets[event.index];
      yield TimerCreatingState(
        timerSets: List.of(state.timerSets)
          ..removeAt(event.index)
          ..insert(event.index - 1, target),
      );
    }
  }

  Stream<TimerCreatingState> _mapTimerSetMovedDownToState(
    TimerSetMovedDown event,
  ) async* {
    if (event.index < state.timerSets.length - 1) {
      final target = state.timerSets[event.index];
      yield TimerCreatingState(
        timerSets: List.of(state.timerSets)
          ..removeAt(event.index)
          ..insert(event.index + 1, target),
      );
    }
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

  Stream<TimerCreatingState> _mapTimerAddedToState(
    TimerAdded event,
  ) async* {
    final newTimerSet = state.timerSets[event.index].copyWith(
      timers: List.of(state.timerSets[event.index].timers)
        ..add(TimerModel.initial()),
    );
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)
        ..removeAt(event.index)
        ..insert(event.index, newTimerSet),
    );
  }

  Stream<TimerCreatingState> _mapTimerCopiedToState(
    TimerCopied event,
  ) async* {
    final newTimerSet = state.timerSets[event.setIndex].copyWith(
      timers: List.of(state.timerSets[event.setIndex].timers)
        ..insert(
          event.index,
          state.timerSets[event.setIndex].timers[event.index],
        ),
    );
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)
        ..removeAt(event.setIndex)
        ..insert(event.setIndex, newTimerSet),
    );
  }

  Stream<TimerCreatingState> _mapTimerDeletedToState(
    TimerDeleted event,
  ) async* {
    final newTimerSet = state.timerSets[event.setIndex].copyWith(
      timers: List.of(state.timerSets[event.setIndex].timers)
        ..removeAt(event.index),
    );
    yield TimerCreatingState(
      timerSets: List.of(state.timerSets)
        ..removeAt(event.setIndex)
        ..insert(event.setIndex, newTimerSet),
    );
  }

  Stream<TimerCreatingState> _mapTimerMovedUpToState(
    TimerMovedUp event,
  ) async* {
    if (event.index > 0) {
      final target = state.timerSets[event.setIndex].timers[event.index];
      final newTimerSet = state.timerSets[event.setIndex].copyWith(
        timers: List.of(state.timerSets[event.setIndex].timers)
          ..removeAt(event.index)
          ..insert(event.index - 1, target),
      );
      yield TimerCreatingState(
        timerSets: List.of(state.timerSets)
          ..removeAt(event.setIndex)
          ..insert(event.setIndex, newTimerSet),
      );
    }
  }

  Stream<TimerCreatingState> _mapTimerMovedDownToState(
    TimerMovedDown event,
  ) async* {
    if (event.index < state.timerSets.length - 1) {
      final target = state.timerSets[event.setIndex].timers[event.index];
      final newTimerSet = state.timerSets[event.setIndex].copyWith(
        timers: List.of(state.timerSets[event.setIndex].timers)
          ..removeAt(event.index)
          ..insert(event.index + 1, target),
      );
      yield TimerCreatingState(
        timerSets: List.of(state.timerSets)
          ..removeAt(event.setIndex)
          ..insert(event.setIndex, newTimerSet),
      );
    }
  }

  Stream<TimerCreatingState> _mapTimerDurationChangedToState(
    TimerDurationChanged event,
  ) async* {
    final newTimer = state.timerSets[event.setIndex].timers[event.index]
        .copyWith(duration: event.duration);
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
