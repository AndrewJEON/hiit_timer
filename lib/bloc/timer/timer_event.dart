part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerInitialized extends TimerEvent {
  final TimerModel timer;

  TimerInitialized(this.timer);

  @override
  List<Object> get props => [timer];
}

class TimerStarted extends TimerEvent {}

class TimerPaused extends TimerEvent {}

class TimerResumed extends TimerEvent {}

class TimerReset extends TimerEvent {}

class TimerTicked extends TimerEvent {
  final Duration remainingTime;
  final bool isRunning;
  final String tts;

  TimerTicked({
    @required this.remainingTime,
    @required this.isRunning,
    @required this.tts,
  });

  @override
  List<Object> get props => [remainingTime, isRunning, tts];
}

class TimerForwarded extends TimerEvent {}

class TimerRewound extends TimerEvent {}
