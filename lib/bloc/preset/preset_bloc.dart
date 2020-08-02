import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/model_timer.dart';
import '../../data/repositories/repository_timer.dart';
import '../current_timer/current_timer_bloc.dart';

part 'preset_event.dart';
part 'preset_state.dart';

class PresetBloc extends Bloc<PresetEvent, PresetState> {
  final TimerRepository repository;
  final CurrentTimerBloc currentTimerBloc;

  PresetBloc({
    @required this.repository,
    @required this.currentTimerBloc,
  }) : super(PresetLoadInProgress()) {
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
    yield PresetSuccess(timers: timers);
  }

  Stream<PresetState> _mapPresetCopiedToState(
    PresetCopied event,
  ) async* {
    final currentState = state;
    if (currentState is PresetSuccess) {
      var suffix = ' - Copied';
      var suffixIndex = 1;
      while (await repository.isDuplicate(event.targetTimer.name + suffix)) {
        suffixIndex++;
        suffix = ' - Copied$suffixIndex';
      }

      final newTimer =
          event.targetTimer.copyWith(name: event.targetTimer.name + suffix);
      final newTimers = List.of(currentState.timers)..add(newTimer);
      yield PresetSuccess(timers: newTimers);
      await repository.save(newTimer);
    }
  }

  Stream<PresetState> _mapPresetDeletedToState(
    PresetDeleted event,
  ) async* {
    final currentState = state;
    if (currentState is PresetSuccess) {
      final newTimers = List.of(currentState.timers)
        ..removeWhere((timer) => timer == event.targetTimer);
      yield PresetSuccess(timers: newTimers);
      await repository.delete(event.targetTimer);

      final selected = currentTimerBloc.state;
      if (selected == event.targetTimer) {
        final timers = (await repository.load())
          ..sort((a, b) => a.name.compareTo(b.name));
        if (timers.isNotEmpty) {
          currentTimerBloc.add(CurrentTimerSelected(timers[0]));
        } else {
          currentTimerBloc.add(CurrentTimerSelected(null));
        }
      }
    }
  }

  Stream<PresetState> _mapPresetRenamedToState(
    PresetRenamed event,
  ) async* {
    final currentState = state;
    if (currentState is PresetSuccess) {
      final newTimer = event.oldTimer.copyWith(name: event.newName);
      final newTimers = List.of(currentState.timers)
        ..removeWhere((timer) => timer == event.oldTimer)
        ..add(newTimer);
      yield PresetSuccess(timers: newTimers);

      final selected = currentTimerBloc.state;
      if (selected == event.oldTimer) {
        currentTimerBloc.add(CurrentTimerSelected(newTimer));
      }

      await repository.rename(event.oldTimer, newName: event.newName);
    }
  }

  Stream<PresetState> _mapPresetEditedToState(
    PresetEdited event,
  ) async* {
    final currentState = state;
    if (currentState is PresetSuccess) {
      final newTimers = List.of(currentState.timers)
        ..removeWhere((timer) => timer == event.oldTimer)
        ..add(event.newTimer);
      yield PresetSuccess(timers: newTimers);

      final selected = currentTimerBloc.state;
      if (selected == event.oldTimer) {
        currentTimerBloc.add(CurrentTimerSelected(event.newTimer));
      }

      await repository.save(event.newTimer);
    }
  }

  Stream<PresetState> _mapPresetCreatedToState(
    PresetCreated event,
  ) async* {
    final currentState = state;
    if (currentState is PresetSuccess) {
      final newTimers = List.of(currentState.timers)..add(event.newTimer);
      yield PresetSuccess(timers: newTimers);

      if (currentTimerBloc.state == null) {
        currentTimerBloc.add(CurrentTimerSelected(event.newTimer));
      }

      await repository.save(event.newTimer);
    }
  }
}
