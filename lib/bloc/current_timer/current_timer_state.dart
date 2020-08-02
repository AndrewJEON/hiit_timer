part of 'current_timer_bloc.dart';

abstract class CurrentTimerState extends Equatable {
  const CurrentTimerState();

  @override
  List<Object> get props => [];
}

class CurrentTimerLoadInProgress extends CurrentTimerState {}

class CurrentTimerSuccess extends CurrentTimerState {
  final TimerModel timer;

  CurrentTimerSuccess(this.timer);

  @override
  List<Object> get props => [timer];
}

class CurrentTimerFailure extends CurrentTimerState {
  final String message;

  CurrentTimerFailure.noCurrentTimer() : message = 'No Selected Timer';

  CurrentTimerFailure.unexpected() : message = 'Oops! Something went wrong';
}
