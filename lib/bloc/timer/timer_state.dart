part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object> get props => [];
}

class TimerInitial extends TimerState {}

class TimerIdle extends TimerState {
  final TimerModel timer;

  TimerIdle(this.timer);

  @override
  List<Object> get props => [timer];
}

class TimerFailure extends TimerState {
  final String message;

  TimerFailure(this.message);

  TimerFailure.noSavedTimer() : message = 'There\'s no saved timer';

  @override
  List<Object> get props => [message];
}
