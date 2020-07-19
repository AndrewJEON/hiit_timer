import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:meta/meta.dart';

import '../../../bloc/timer_creating/timer_creating_bloc.dart';
import '../../../data/models/model_timer.dart';

class TimerOptions {
  static const copy = 'Copy';
  static const delete = 'Delete';
  static const moveUp = 'Move Up';
  static const moveDown = 'Move Down';
  static const all = [copy, delete, moveUp, moveDown];
}

class TimerView extends StatefulWidget {
  final TimerModel timer;
  final int setIndex;
  final int index;

  const TimerView({
    Key key,
    @required this.timer,
    @required this.setIndex,
    @required this.index,
  }) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.timer.description;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          duration(),
          Flexible(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: description(),
          )),
          options(),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget description() {
    return TextField(
      controller: _controller,
      maxLines: null,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        context.bloc<TimerCreatingBloc>().add(
              TimerDescriptionChanged(
                description: value,
                setIndex: widget.setIndex,
                index: widget.index,
              ),
            );
      },
    );
  }

  Widget duration() {
    return BlocBuilder<TimerCreatingBloc, TimerCreatingState>(
      buildWhen: (previous, current) {
        if (previous.timerSets[widget.setIndex].timers[widget.index].duration !=
            current.timerSets[widget.setIndex].timers[widget.index].duration) {
          return true;
        } else {
          return false;
        }
      },
      builder: (context, state) {
        final duration =
            state.timerSets[widget.setIndex].timers[widget.index].duration;
        return FlatButton(
          onPressed: () async {
            final dateTime = await DatePicker.showTimePicker(
              context,
              currentTime: DateTime(
                0,
                0,
                0,
                duration.inHours,
                duration.inMinutes.remainder(60),
                duration.inSeconds.remainder(60),
              ),
            );
            if (dateTime != null) {
              context.bloc<TimerCreatingBloc>().add(
                    TimerDurationChanged(
                      duration: Duration(
                        hours: dateTime.hour,
                        minutes: dateTime.minute,
                        seconds: dateTime.second,
                      ),
                      setIndex: widget.setIndex,
                      index: widget.index,
                    ),
                  );
            }
          },
          child: Text(
            '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
          ),
        );
      },
    );
  }

  Widget options() {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case TimerOptions.copy:
            break;
          case TimerOptions.delete:
            break;
          case TimerOptions.moveUp:
            break;
          case TimerOptions.moveDown:
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          for (final option in TimerOptions.all)
            PopupMenuItem(
              value: option,
              child: Text(option),
            ),
        ];
      },
    );
  }
}
