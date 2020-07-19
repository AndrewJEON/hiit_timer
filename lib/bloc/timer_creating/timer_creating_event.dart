part of 'timer_creating_bloc.dart';

abstract class TimerCreatingEvent extends Equatable {
  const TimerCreatingEvent();

  @override
  List<Object> get props => [];
}

class TimerSaved extends TimerCreatingEvent {}

class TimerSetAdded extends TimerCreatingEvent {}

class TimerSetCopied extends TimerCreatingEvent {
  final int index;

  TimerSetCopied(this.index);

  @override
  List<Object> get props => [index];
}

class TimerSetDeleted extends TimerCreatingEvent {
  final int index;

  TimerSetDeleted(this.index);

  @override
  List<Object> get props => [index];
}

class TimerSetMovedUp extends TimerCreatingEvent {
  final int index;

  TimerSetMovedUp(this.index);

  @override
  List<Object> get props => [index];
}

class TimerSetMovedDown extends TimerCreatingEvent {
  final int index;

  TimerSetMovedDown(this.index);

  @override
  List<Object> get props => [index];
}

class TimerSetRepeatCountIncreased extends TimerCreatingEvent {
  final int index;

  TimerSetRepeatCountIncreased(this.index);

  @override
  List<Object> get props => [index];
}

class TimerSetRepeatCountDecreased extends TimerCreatingEvent {
  final int index;

  TimerSetRepeatCountDecreased(this.index);

  @override
  List<Object> get props => [index];
}

class TimerAdded extends TimerCreatingEvent {
  final int index;

  TimerAdded(this.index);

  @override
  List<Object> get props => [index];
}

class TimerCopied extends TimerCreatingEvent {
  final int setIndex;
  final int index;

  TimerCopied({
    this.setIndex,
    this.index,
  });

  @override
  List<Object> get props => [setIndex, index];
}

class TimerDeleted extends TimerCreatingEvent {
  final int setIndex;
  final int index;

  TimerDeleted({
    this.setIndex,
    this.index,
  });

  @override
  List<Object> get props => [setIndex, index];
}

class TimerMovedUp extends TimerCreatingEvent {
  final int setIndex;
  final int index;

  TimerMovedUp({
    this.setIndex,
    this.index,
  });

  @override
  List<Object> get props => [setIndex, index];
}

class TimerMovedDown extends TimerCreatingEvent {
  final int setIndex;
  final int index;

  TimerMovedDown({
    this.setIndex,
    this.index,
  });

  @override
  List<Object> get props => [setIndex, index];
}

class TimerDurationChanged extends TimerCreatingEvent {
  final Duration duration;
  final int setIndex;
  final int index;

  TimerDurationChanged({
    this.duration,
    this.setIndex,
    this.index,
  });

  @override
  List<Object> get props => [duration, setIndex, index];
}

class TimerDescriptionChanged extends TimerCreatingEvent {
  final String description;
  final int setIndex;
  final int index;

  TimerDescriptionChanged({
    this.description,
    this.setIndex,
    this.index,
  });

  @override
  List<Object> get props => [description, setIndex, index];
}
