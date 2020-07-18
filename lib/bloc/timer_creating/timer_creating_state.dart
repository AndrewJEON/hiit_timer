part of 'timer_creating_bloc.dart';

class TimerCreatingState extends Equatable {
  final List<TimerSetModel> timerSets;

  TimerCreatingState({this.timerSets});

  TimerCreatingState.initial() : timerSets = [TimerSetModel.initial()];

  TimerCreatingState copyWith({
    List<TimerSetModel> timerSets,
  }) {
    return TimerCreatingState(
      timerSets: timerSets ?? List.of(this.timerSets),
    );
  }

  @override
  List<Object> get props => [...timerSets];
}
