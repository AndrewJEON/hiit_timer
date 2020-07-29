part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final Duration remainingTime;

  TimerState(this.remainingTime);

  @override
  List<Object> get props => [remainingTime];
}

class TimerInitial extends TimerState {
  TimerInitial() : super(null);
}

class TimerReady extends TimerState {
  TimerReady(Duration remainingTime) : super(remainingTime);
}

class TimerRunning extends TimerState {
  TimerRunning(Duration remainingTime) : super(remainingTime);
}

class TimerPause extends TimerState {
  TimerPause(Duration remainingTime) : super(remainingTime);
}

class TimerFinish extends TimerState {
  TimerFinish() : super(Duration.zero);
}

class TimerFailure extends TimerState {
  final String message;

  TimerFailure.unexpected()
      : message = 'Oops!\nSomething unexpected error has been occurred',
        super(null);

  TimerFailure.noSavedTimer()
      : message = 'There\'s no saved timer',
        super(null);
}
