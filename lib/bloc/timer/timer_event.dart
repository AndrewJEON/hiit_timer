part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerInitialized extends TimerEvent {}

class TimerSelected extends TimerEvent {
  final TimerModel timer;

  TimerSelected(this.timer);

  @override
  List<Object> get props => [timer];
}
