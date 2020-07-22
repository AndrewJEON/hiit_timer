part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final Duration remainingTime;
  final int repeatCount;

  TimerState({
    this.remainingTime,
    this.repeatCount,
  });

  @override
  List<Object> get props => [remainingTime, repeatCount];
}

class TimerInitial extends TimerState {
  TimerInitial();
}

class TimerReady extends TimerState {
  TimerReady({
    Duration remainingTime,
    int repeatCount,
  }) : super(
          remainingTime: remainingTime,
          repeatCount: repeatCount,
        );
}

class TimerRunning extends TimerState {
  TimerRunning({
    Duration remainingTime,
    int repeatCount,
  }) : super(
          remainingTime: remainingTime,
          repeatCount: repeatCount,
        );
}

class TimerPause extends TimerState {
  TimerPause({
    Duration remainingTime,
    int repeatCount,
  }) : super(
          remainingTime: remainingTime,
          repeatCount: repeatCount,
        );
}

class TimerFinish extends TimerState {
  TimerFinish({
    Duration remainingTime,
    int repeatCount,
  }) : super(
          remainingTime: Duration.zero,
          repeatCount: repeatCount,
        );
}

class TimerFailure extends TimerState {
  final String message;

  TimerFailure.unexpected()
      : message = 'Oops!\nSomething unexpected error has been occurred';

  TimerFailure.noSavedTimer() : message = 'There\'s no saved timer';
}
