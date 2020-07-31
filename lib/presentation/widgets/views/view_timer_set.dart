import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../bloc/timer_creating/timer_creating_bloc.dart';
import '../../../data/models/model_timer.dart';
import '../../../data/models/model_timer_set.dart';
import 'view_timer.dart';

class TimerSetOptions {
  static const copy = 'Copy';
  static const delete = 'Delete';
  static const moveUp = 'Move Up';
  static const moveDown = 'Move Down';
  static const all = [copy, delete, moveUp, moveDown];
}

class TimerSetView extends StatelessWidget {
  final TimerSetModel timerSet;
  final int index;

  const TimerSetView({
    Key key,
    @required this.timerSet,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                repeatCount(context),
                options(context),
              ],
            ),
          ),
          Divider(height: 0),
          SizedBox(height: 16),
          BlocBuilder<TimerCreatingBloc, TimerModel>(
            buildWhen: (previous, current) {
              try {
                if (previous.timerSets[index].timers.length !=
                    current.timerSets[index].timers.length) {
                  return true;
                } else {
                  var count = 0;
                  for (var i = 0;
                      i < previous.timerSets[index].timers.length;
                      i++) {
                    if (previous.timerSets[index].timers[i] !=
                        current.timerSets[index].timers[i]) {
                      count++;
                      if (count >= 2) {
                        return true;
                      }
                    }
                  }
                  return false;
                }
              } on RangeError {
                return false;
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var i = 0; i < state.timerSets[index].timers.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      child: TimerView(
                        key: UniqueKey(),
                        timer: state.timerSets[index].timers[i],
                        setIndex: index,
                        index: i,
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FlatButton.icon(
              onPressed: () {
                context.bloc<TimerCreatingBloc>().add(TimerAdded(index));
              },
              icon: Icon(Icons.add),
              label: Text('Add'),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget repeatCount(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(width: 8),
        Icon(Icons.repeat),
        SizedBox(width: 8),
        Container(
          width: 24,
          height: 24,
          child: IconButton(
            onPressed: () {
              context
                  .bloc<TimerCreatingBloc>()
                  .add(TimerSetRepeatCountDecreased(index));
            },
            icon: Icon(Icons.remove_circle),
            iconSize: 16,
            padding: const EdgeInsets.all(0),
          ),
        ),
        BlocBuilder<TimerCreatingBloc, TimerModel>(
          buildWhen: (previous, current) {
            try {
              if (previous.timerSets[index].repeatCount !=
                  current.timerSets[index].repeatCount) {
                return true;
              } else {
                return false;
              }
            } on RangeError {
              return false;
            }
          },
          builder: (context, state) {
            return Text(
              '${state.timerSets[index].repeatCount}x',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
            );
          },
        ),
        Container(
          width: 24,
          height: 24,
          child: IconButton(
            onPressed: () {
              context
                  .bloc<TimerCreatingBloc>()
                  .add(TimerSetRepeatCountIncreased(index));
            },
            icon: Icon(Icons.add_circle),
            iconSize: 16,
            padding: const EdgeInsets.all(0),
          ),
        ),
      ],
    );
  }

  Widget options(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case TimerSetOptions.copy:
            context.bloc<TimerCreatingBloc>().add(TimerSetCopied(index));
            break;
          case TimerSetOptions.delete:
            context.bloc<TimerCreatingBloc>().add(TimerSetDeleted(index));
            break;
          case TimerSetOptions.moveUp:
            context.bloc<TimerCreatingBloc>().add(TimerSetMovedUp(index));
            break;
          case TimerSetOptions.moveDown:
            context.bloc<TimerCreatingBloc>().add(TimerSetMovedDown(index));
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          for (final option in TimerSetOptions.all)
            PopupMenuItem(
              value: option,
              child: Text(option),
            ),
        ];
      },
    );
  }
}
