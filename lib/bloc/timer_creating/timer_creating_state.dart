part of 'timer_creating_bloc.dart';

class TimerCreatingState extends Equatable {
  final List<TimerSetModel> timerSets;

  TimerCreatingState({this.timerSets});

  TimerCreatingState.initial() : timerSets = [TimerSetModel.initial()];

  TimerCreatingState.fromJson(Map<String, dynamic> json)
      : timerSets = json['timerSets']
            .map((timerSet) => TimerSetModel.fromJson(timerSet))
            .toList()
            .cast<TimerSetModel>();

  Map<String, dynamic> toJson() => {
        'timerSets': timerSets.map((timerSet) => timerSet.toJson()).toList(),
      };

  @override
  List<Object> get props => [...timerSets];
}
