import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/preset/preset_bloc.dart';
import '../../../bloc/timer/timer_bloc.dart';
import '../../../bloc/timer_creating/timer_creating_bloc.dart';
import '../../../core/service_locator.dart';
import '../../../data/models/model_timer.dart';
import '../../../data/repositories/repository_timer.dart';
import '../../pages/page_timer_creating.dart';
import '../dialogs/dialog_timer_name.dart';
import '../dialogs/dialog_warning.dart';

class PresetOptions {
  static const copy = 'Copy';
  static const delete = 'Delete';
  static const rename = 'Rename';
  static const edit = 'Edit';
  static const all = [copy, delete, rename, edit];
}

class PresetsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text('Cancel'),
            ),
            createNewTimerButton(context),
          ],
        ),
        Expanded(
          child: BlocBuilder<PresetBloc, PresetState>(
            builder: (context, state) {
              if (state is PresetInitial) {
                return Container();
              } else if (state is PresetLoadInProgress) {
                return Center(child: CircularProgressIndicator());
              } else if (state is PresetSuccess) {
                if (state.timers.isEmpty) {
                  return Center(child: Text('No Saved Timer'));
                } else {
                  final sorted = state.timers
                    ..sort((a, b) => a.name.compareTo(b.name));
                  return ListView.builder(
                    itemCount: sorted.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context, sorted[i]);
                        },
                        leading: Icon(Icons.timer),
                        title: Text(sorted[i].name),
                        trailing: options(context, sorted[i]),
                        selected:
                            sorted[i] == context.bloc<TimerBloc>().currentTimer,
                      );
                    },
                  );
                }
              } else if (state is PresetFailure) {
                return Center(child: Text(state.message));
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget createNewTimerButton(BuildContext context) {
    return FlatButton.icon(
      onPressed: () async {
        final timer = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => TimerCreatingBloc(
                sl<TimerRepository>(),
              ),
              child: TimerCreatingPage(),
            ),
          ),
        );
        if (timer != null) {
          context.bloc<PresetBloc>().add(PresetCreated(timer));
        }
      },
      icon: Icon(Icons.add),
      label: Text('New Timer'),
      textColor: Theme.of(context).primaryColor,
    );
  }

  Widget options(BuildContext context, TimerModel timer) {
    return PopupMenuButton(
      onSelected: (value) async {
        switch (value) {
          case PresetOptions.copy:
            context.bloc<PresetBloc>().add(PresetCopied(timer));
            break;
          case PresetOptions.delete:
            final delete = await DeleteDialog.show(context);
            if (delete ?? false) {
              context.bloc<PresetBloc>().add(PresetDeleted(timer));
            }
            break;
          case PresetOptions.rename:
            final newName =
                await TimerNameDialog.show(context, currentName: timer.name);
            if (newName != null) {
              context
                  .bloc<PresetBloc>()
                  .add(PresetRenamed(timer, newName: newName));
            }
            break;
          case PresetOptions.edit:
            final edited = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => TimerCreatingBloc(
                    sl<TimerRepository>(),
                    timer: timer,
                  ),
                  child: TimerCreatingPage(timer: timer),
                ),
              ),
            );
            if (edited != null) {
              context.bloc<PresetBloc>().add(PresetEdited(edited));
            }
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          for (final option in PresetOptions.all)
            PopupMenuItem(
              value: option,
              child: Text(option),
            ),
        ];
      },
    );
  }

  static Future<TimerModel> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return PresetsBottomSheet();
      },
    );
  }
}
