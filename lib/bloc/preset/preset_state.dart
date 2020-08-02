part of 'preset_bloc.dart';

abstract class PresetState extends Equatable {
  @override
  List<Object> get props => [];
}

class PresetLoadInProgress extends PresetState {}

class PresetSuccess extends PresetState {
  final List<TimerModel> timers;

  PresetSuccess({
    @required this.timers,
  });

  @override
  List<Object> get props => [...timers];
}

class PresetFailure extends PresetState {
  final String message;

  PresetFailure.unexpected() : message = 'Oops! Something went wrong';
}
