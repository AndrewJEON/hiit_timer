import 'package:equatable/equatable.dart';

import 'model_timer.dart';

class TimerSetModel extends Equatable {
  final List<TimerModel> timers;
  final int repeatCount;

  TimerSetModel({
    this.timers,
    this.repeatCount,
  });

  TimerSetModel.initial()
      : timers = [TimerModel.initial()],
        repeatCount = 1;

  TimerSetModel copyWith({
    List<TimerModel> timers,
    int repeatCount,
  }) {
    return TimerSetModel(
      timers: timers ?? this.timers,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }

  @override
  List<Object> get props => [...timers, repeatCount];
}
