import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/model_timer.dart';
import '../../data/repositories/repository_timer.dart';
import '../timer/timer_bloc.dart';

part 'timer_select_event.dart';

class TimerSelectBloc extends Bloc<TimerSelectEvent, TimerModel> {
  final TimerRepository repository;
  final TimerBloc timerBloc;

  TimerSelectBloc({
    this.repository,
    this.timerBloc,
  }) : super(null) {
    add(TimerSelectInitialized());
  }

  @override
  Stream<TimerModel> mapEventToState(
    TimerSelectEvent event,
  ) async* {
    if (event is TimerSelectInitialized) {
      final timer = await repository.loadLatestTimer();
      yield timer;
      timerBloc.add(TimerReset(timer: timer));
    } else if (event is TimerSelected) {
      yield event.timer;
      timerBloc.add(TimerReset(timer: event.timer));
      await repository.saveCurrentTimer(event.timer);
    }
  }
}
