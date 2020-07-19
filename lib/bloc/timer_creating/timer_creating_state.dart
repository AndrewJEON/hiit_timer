part of 'timer_creating_bloc.dart';

class TimerCreatingState extends Equatable {
  final List<TimerSetModel> timerSets;

  TimerCreatingState({this.timerSets});

  TimerCreatingState.initial() : timerSets = [TimerSetModel.initial()];

  @override
  List<Object> get props => [...timerSets];
}
