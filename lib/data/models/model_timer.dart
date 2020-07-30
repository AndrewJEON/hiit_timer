import 'package:equatable/equatable.dart';

import 'model_timer_piece.dart';
import 'model_timer_set.dart';

class TimerModel extends Equatable {
  final String name;
  final List<TimerSetModel> timerSets;

  TimerModel({this.name, this.timerSets});

  TimerModel.initial()
      : name = '',
        timerSets = [TimerSetModel.initial()];

  TimerModel.example()
      : name = 'Example',
        timerSets = [
          TimerSetModel(
            timers: [
              TimerPieceModel(
                duration: Duration(seconds: 5),
                description: 'Ready',
              ),
            ],
            repeatCount: 1,
          ),
          TimerSetModel(
            timers: [
              TimerPieceModel(
                duration: Duration(seconds: 20),
                description: 'Work',
              ),
              TimerPieceModel(
                duration: Duration(seconds: 5),
                description: 'Rest',
              ),
            ],
            repeatCount: 3,
          ),
        ];

  TimerModel.fromJson(Map<String, dynamic> json, String name)
      : name = name,
        timerSets = json['timerSets']
            .map((timerSet) => TimerSetModel.fromJson(timerSet))
            .toList()
            .cast<TimerSetModel>();

  Map<String, dynamic> toJson() => {
        'timerSets': timerSets.map((timerSet) => timerSet.toJson()).toList(),
      };

  TimerModel copyWith({
    String name,
    List<TimerSetModel> timerSets,
  }) {
    return TimerModel(
      name: name ?? this.name,
      timerSets: timerSets ?? this.timerSets,
    );
  }

  @override
  List<Object> get props => [name, ...timerSets];
}
