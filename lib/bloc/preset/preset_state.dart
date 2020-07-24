part of 'preset_bloc.dart';

abstract class PresetState extends Equatable {
  final List<TimerModel> timers;

  PresetState(this.timers);

  @override
  List<Object> get props => [timers];
}

class PresetInitial extends PresetState {
  PresetInitial() : super(null);
}

class PresetLoadInProgress extends PresetState {
  PresetLoadInProgress() : super(null);
}

class PresetSuccess extends PresetState {
  PresetSuccess(List<TimerModel> timers) : super(timers);
}

class PresetFailure extends PresetState {
  final String message;

  PresetFailure.unexpected()
      : message = 'Oops! Something went wrong',
        super(null);
}
