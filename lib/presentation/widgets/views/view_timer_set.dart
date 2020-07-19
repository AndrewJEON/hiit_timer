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
              repeatCount(),
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

  Widget repeatCount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove_circle),
          iconSize: 16,
          onPressed: () {},
        ),
        Text('${timerSet.repeatCount}'),
        IconButton(
          icon: Icon(Icons.remove_circle),
          iconSize: 16,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget options(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case TimerSetOptions.copy:
            break;
          case TimerSetOptions.delete:
            context.bloc<TimerCreatingBloc>().add(TimerSetDeleted(index));
            break;
          case TimerSetOptions.moveUp:
            break;
          case TimerSetOptions.moveDown:
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
