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

  @override
  List<Object> get props => [...timers, repeatCount];
}
