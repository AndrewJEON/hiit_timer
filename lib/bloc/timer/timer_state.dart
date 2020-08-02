part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final Duration remainingTime;
  final String tts;

  TimerState({
    this.remainingTime,
    this.tts,
  });

  @override
  List<Object> get props => [remainingTime, tts];
}

class TimerLoadInProgress extends TimerState {}

class TimerReady extends TimerState {
  TimerReady({
    Duration remainingTime,
    String tts,
  }) : super(
          remainingTime: remainingTime,
          tts: tts,
        );
}

class TimerRunning extends TimerState {
  TimerRunning({
    Duration remainingTime,
    String tts,
  }) : super(
          remainingTime: remainingTime,
          tts: tts,
        );
}

class TimerPause extends TimerState {
  TimerPause({
    Duration remainingTime,
    String tts,
  }) : super(
          remainingTime: remainingTime,
          tts: tts,
        );
}

class TimerFinish extends TimerState {
  TimerFinish({
    String tts,
  }) : super(tts: tts);
}

class TimerFailure extends TimerState {
  final String message;

  TimerFailure.unexpected()
      : message = 'Oops!\nSomething unexpected error has been occurred';

  TimerFailure.noSavedTimer() : message = 'There\'s no saved timer';
}
