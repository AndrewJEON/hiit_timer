part of 'preset_bloc.dart';

abstract class PresetEvent extends Equatable {
  final TimerModel timer;

  PresetEvent(this.timer);

  @override
  List<Object> get props => [timer];
}

class PresetInitialized extends PresetEvent {
  PresetInitialized() : super(null);
}

class PresetCopied extends PresetEvent {
  PresetCopied(TimerModel timer) : super(timer);
}

class PresetDeleted extends PresetEvent {
  PresetDeleted(TimerModel timer) : super(timer);
}

class PresetRenamed extends PresetEvent {
  final String newName;

  PresetRenamed(
    TimerModel timer, {
    @required this.newName,
  }) : super(timer);

  @override
  List<Object> get props => [timer, newName];
}

class PresetEdited extends PresetEvent {
  PresetEdited(TimerModel timer) : super(timer);
}

class PresetCreated extends PresetEvent {
  PresetCreated(TimerModel timer) : super(timer);
}
