part of 'current_timer_bloc.dart';

abstract class CurrentTimerEvent extends Equatable {
  const CurrentTimerEvent();

  @override
  List<Object> get props => [];
}

class CurrentTimerInitialized extends CurrentTimerEvent {}

class CurrentTimerSelected extends CurrentTimerEvent {
  final TimerModel timer;

  CurrentTimerSelected(this.timer);

  @override
  List<Object> get props => [];
}
