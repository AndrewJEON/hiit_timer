import 'package:equatable/equatable.dart';

import 'model_timer_piece.dart';

class TimerSetModel extends Equatable {
  final List<TimerPieceModel> timers;
  final int repeatCount;

  TimerSetModel({
    this.timers,
    this.repeatCount,
  });

  TimerSetModel.initial()
      : timers = [TimerPieceModel.initial()],
        repeatCount = 1;

  TimerSetModel copyWith({
    List<TimerPieceModel> timers,
    int repeatCount,
  }) {
    return TimerSetModel(
      timers: timers ?? this.timers,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }

  TimerSetModel.fromJson(Map<String, dynamic> json)
      : timers =
            json['timers'].map((timer) => TimerPieceModel.fromJson(timer)).toList().cast<TimerPieceModel>(),
        repeatCount = json['repeatCount'];

  Map<String, dynamic> toJson() => {
        'timers': timers.map((timer) => timer.toJson()).toList(),
        'repeatCount': repeatCount,
      };

  @override
  List<Object> get props => [...timers, repeatCount];
}
