import 'package:equatable/equatable.dart';

import 'model_timer_set.dart';

class TimerModel extends Equatable {
  final String name;
  final List<TimerSetModel> timerSets;

  TimerModel({this.name, this.timerSets});

  TimerModel.initial()
      : name = '',
        timerSets = [TimerSetModel.initial()];

  TimerModel.fromJson(Map<String, dynamic> json, String name)
      : name = name,
        timerSets = json['timerSets']
            .map((timerSet) => TimerSetModel.fromJson(timerSet))
            .toList()
            .cast<TimerSetModel>();

  Map<String, dynamic> toJson() => {
        'timerSets': timerSets.map((timerSet) => timerSet.toJson()).toList(),
      };

  @override
  List<Object> get props => [name, ...timerSets];
}
