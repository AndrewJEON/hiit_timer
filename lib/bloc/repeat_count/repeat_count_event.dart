part of 'repeat_count_bloc.dart';

abstract class RepeatCountEvent extends Equatable {
  const RepeatCountEvent();

  @override
  List<Object> get props => [];
}

class RepeatCountInitialized extends RepeatCountEvent {}

class RepeatCountChanged extends RepeatCountEvent {
  final int repeatCount;

  RepeatCountChanged(this.repeatCount);

  @override
  List<Object> get props => [repeatCount];
}
