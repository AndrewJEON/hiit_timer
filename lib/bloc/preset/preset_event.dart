part of 'preset_bloc.dart';

abstract class PresetEvent extends Equatable {
  const PresetEvent();

  @override
  List<Object> get props => [];
}

class PresetInitialized extends PresetEvent {}

class PresetCopied extends PresetEvent {
  final TimerModel targetTimer;

  PresetCopied(this.targetTimer);

  @override
  List<Object> get props => [targetTimer];
}

class PresetDeleted extends PresetEvent {
  final TimerModel targetTimer;

  PresetDeleted(this.targetTimer);

  @override
  List<Object> get props => [targetTimer];
}

class PresetRenamed extends PresetEvent {
  final TimerModel oldTimer;
  final String newName;

  PresetRenamed({
    @required this.oldTimer,
    @required this.newName,
  });

  @override
  List<Object> get props => [oldTimer, newName];
}

class PresetEdited extends PresetEvent {
  final TimerModel oldTimer;
  final TimerModel newTimer;

  PresetEdited({
    @required this.oldTimer,
    @required this.newTimer,
  });

  @override
  List<Object> get props => [oldTimer, newTimer];
}

class PresetCreated extends PresetEvent {
  final TimerModel newTimer;

  PresetCreated(this.newTimer);

  @override
  List<Object> get props => [newTimer];
}
