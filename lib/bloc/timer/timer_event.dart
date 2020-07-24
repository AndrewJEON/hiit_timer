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

class TimerReset extends TimerEvent {
  final TimerModel timer;

  TimerReset({this.timer});

  @override
  List<Object> get props => [timer];
}

class TimerTicked extends TimerEvent {
  final Duration remainingTime;

  TimerTicked({@required this.remainingTime});

  @override
  List<Object> get props => [remainingTime];
}
