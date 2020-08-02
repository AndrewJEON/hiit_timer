import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../data/models/model_timer.dart';
import '../../data/repositories/repository_timer.dart';

part 'current_timer_event.dart';
part 'current_timer_state.dart';

class CurrentTimerBloc extends Bloc<CurrentTimerEvent, TimerModel> {
  final TimerRepository repository;

  CurrentTimerBloc({
    @required this.repository,
  }) : super(null) {
    add(CurrentTimerInitialized());
  }

  @override
  Stream<TimerModel> mapEventToState(
    CurrentTimerEvent event,
  ) async* {
    if (event is CurrentTimerInitialized) {
      yield await repository.loadLatestTimer();
    } else if (event is CurrentTimerSelected) {
      yield event.timer;
      if (event.timer != null) {
        await repository.saveLatestTimer(event.timer);
      }
    }
  }
}
