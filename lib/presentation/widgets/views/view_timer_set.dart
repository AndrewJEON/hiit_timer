import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../bloc/timer_creating/timer_creating_bloc.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              repeatCount(context),
              options(context),
            ],
          ),
          Divider(),
          for (var i = 0; i < timerSet.timers.length; i++)
            TimerView(
              key: UniqueKey(),
              timer: timerSet.timers[i],
              setIndex: index,
              index: i,
            ),
          SizedBox(
            width: double.infinity,
            child: FlatButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text('Add'),
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
        BlocBuilder<TimerCreatingBloc, TimerCreatingState>(
          buildWhen: (previous, current) {
            if (previous.timerSets[index].repeatCount !=
                current.timerSets[index].repeatCount) {
              return true;
            } else {
              return false;
            }
          },
          builder: (context, state) {
            return Text('${state.timerSets[index].repeatCount}x');
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
