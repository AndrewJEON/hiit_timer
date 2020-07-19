part of 'timer_creating_bloc.dart';

abstract class TimerCreatingEvent extends Equatable {
  const TimerCreatingEvent();

  @override
  List<Object> get props => [];
}

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
