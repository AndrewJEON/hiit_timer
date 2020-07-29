part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final Duration remainingTime;
  final String name;
  final String tts;

  TimerState({
    this.remainingTime,
    this.name,
    this.tts,
  });

  @override
  List<Object> get props => [remainingTime, name, tts];
}

class TimerInitial extends TimerState {
  TimerInitial();
}

class TimerReady extends TimerState {
  TimerReady({
    Duration remainingTime,
    String name,
    String tts,
  }) : super(
          remainingTime: remainingTime,
          name: name,
          tts: tts,
        );
}

class TimerRunning extends TimerState {
  TimerRunning({
    Duration remainingTime,
    String name,
    String tts,
  }) : super(
          remainingTime: remainingTime,
          name: name,
          tts: tts,
        );
}

class TimerPause extends TimerState {
  TimerPause({
    Duration remainingTime,
    String name,
    String tts,
  }) : super(
          remainingTime: remainingTime,
          name: name,
          tts: tts,
        );
}

class TimerFinish extends TimerState {
  TimerFinish({
    String name,
    String tts,
  }) : super(
          name: name,
          tts: tts,
        );
}

class TimerFailure extends TimerState {
  final String message;

  TimerFailure.unexpected()
      : message = 'Oops!\nSomething unexpected error has been occurred';

  TimerFailure.noSavedTimer() : message = 'There\'s no saved timer';
}
