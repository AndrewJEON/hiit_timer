import 'package:equatable/equatable.dart';

import 'model_timer_set.dart';

class TimerModel extends Equatable {
  final List<TimerSetModel> timerSets;

  TimerModel({this.timerSets});

  TimerModel.initial() : timerSets = [TimerSetModel.initial()];

  TimerModel.fromJson(Map<String, dynamic> json)
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
