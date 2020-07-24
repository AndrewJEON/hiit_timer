part of 'timer_select_bloc.dart';

abstract class TimerSelectEvent extends Equatable {
  const TimerSelectEvent();

  @override
  List<Object> get props => [];
}

class TimerSelectInitialized extends TimerSelectEvent {}

class TimerSelected extends TimerSelectEvent {
  final TimerModel timer;

  TimerSelected(this.timer);

  @override
  List<Object> get props => [timer];
}
