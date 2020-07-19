part of 'timer_creating_bloc.dart';

abstract class TimerCreatingEvent extends Equatable {
  const TimerCreatingEvent();

  @override
  List<Object> get props => [];
}

class TimerSetAdded extends TimerCreatingEvent {}

class TimerSetDeleted extends TimerCreatingEvent {
  final int index;

  TimerSetDeleted(this.index);

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
