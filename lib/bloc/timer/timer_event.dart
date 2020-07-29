part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerInitialized extends TimerEvent {}

class TimerStarted extends TimerEvent {}

class TimerPaused extends TimerEvent {}

class TimerResumed extends TimerEvent {}

class TimerReset extends TimerEvent {}

class TimerTicked extends TimerEvent {
  final Duration remainingTime;
  final String timerState;

  TimerTicked({
    @required this.remainingTime,
    @required this.timerState,
  });

  @override
  List<Object> get props => [remainingTime, timerState];
}

class TimerSelected extends TimerEvent {
  final TimerModel timer;

  TimerSelected(this.timer);

  @override
  List<Object> get props => [timer];
}
