import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/model_timer.dart';
import '../../data/repositories/repository_timer.dart';
import '../timer/timer_bloc.dart';

part 'preset_event.dart';

part 'preset_state.dart';

class PresetBloc extends Bloc<PresetEvent, PresetState> {
  final TimerRepository repository;
  final TimerBloc timerBloc;

  PresetBloc({
    this.repository,
    this.timerBloc,
  }) : super(PresetInitial()) {
    add(PresetInitialized());
  }

  @override
  Stream<PresetState> mapEventToState(
    PresetEvent event,
  ) async* {
    try {
      if (event is PresetInitialized) {
        yield* _mapPresetInitializedToState(event);
      } else if (event is PresetCopied) {
        yield* _mapPresetCopiedToState(event);
      } else if (event is PresetDeleted) {
        yield* _mapPresetDeletedToState(event);
      } else if (event is PresetRenamed) {
        yield* _mapPresetRenamedToState(event);
      } else if (event is PresetEdited) {
        yield* _mapPresetEditedToState(event);
      } else if (event is PresetCreated) {
        yield* _mapPresetCreatedToState(event);
      }
    } catch (e) {
      debugPrint(e);
      yield PresetFailure.unexpected();
    }
  }

  Stream<PresetState> _mapPresetInitializedToState(
    PresetInitialized event,
  ) async* {
    yield PresetLoadInProgress();
    final timers = await repository.load();
    yield PresetSuccess(timers);
  }

  Stream<PresetState> _mapPresetCopiedToState(
    PresetCopied event,
  ) async* {
    var suffix = ' - Copied';
    var suffixIndex = 1;
    while (await repository.isDuplicate(event.timer.name + suffix)) {
      suffixIndex++;
      suffix = ' - Copied$suffixIndex';
    }
    final newTimer = event.timer.copyWith(name: event.timer.name + suffix);
    final newTimers = List.of(state.timers)..add(newTimer);
    yield PresetSuccess(newTimers);
    await repository.save(newTimer);
  }

  Stream<PresetState> _mapPresetDeletedToState(
    PresetDeleted event,
  ) async* {
    final newTimers = List.of(state.timers)
      ..removeWhere((timer) => timer.name == event.timer.name);
    yield PresetSuccess(newTimers);
    await repository.delete(event.timer);
    if (timerBloc.currentTimer.name == event.timer.name) {
      final timers = (await repository.load())
        ..sort((a, b) => a.name.compareTo(b.name));
      if (timers.isNotEmpty) {
        timerBloc.add(TimerSelected(timers[0]));
      } else {
        timerBloc.add(TimerSelected(null));
      }
    }
  }

  Stream<PresetState> _mapPresetRenamedToState(
    PresetRenamed event,
  ) async* {
    final newTimer = event.timer.copyWith(name: event.newName);
    final newTimers = List.of(state.timers)
      ..removeWhere((timer) => timer.name == event.timer.name)
      ..add(newTimer);
    yield PresetSuccess(newTimers);
    if (timerBloc.currentTimer.name == event.timer.name) {
      timerBloc.add(TimerSelected(newTimer));
    }
    await repository.rename(event.timer, newName: event.newName);
  }

  Stream<PresetState> _mapPresetEditedToState(
    PresetEdited event,
  ) async* {
    final newTimers = List.of(state.timers)
      ..removeWhere((timer) => timer.name == event.timer.name)
      ..add(event.timer);
    yield PresetSuccess(newTimers);
    if (timerBloc.currentTimer.name == event.timer.name) {
      timerBloc.add(TimerSelected(event.timer));
    }
    await repository.save(event.timer);
  }

  Stream<PresetState> _mapPresetCreatedToState(
    PresetCreated event,
  ) async* {
    final newTimers = List.of(state.timers)..add(event.timer);
    yield PresetSuccess(newTimers);
    await repository.save(event.timer);
    if (timerBloc.currentTimer == null) {
      timerBloc.add(TimerSelected(event.timer));
    }
  }
}
