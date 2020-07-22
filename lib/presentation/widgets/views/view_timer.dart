import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:meta/meta.dart';

import '../../../bloc/timer_creating/timer_creating_bloc.dart';
import '../../../core/utils.dart';
import '../../../data/models/model_timer.dart';
import '../../../data/models/model_timer_piece.dart';

class TimerOptions {
  static const copy = 'Copy';
  static const delete = 'Delete';
  static const moveUp = 'Move Up';
  static const moveDown = 'Move Down';
  static const all = [copy, delete, moveUp, moveDown];
}

class TimerView extends StatefulWidget {
  final TimerPieceModel timer;
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
    return BlocBuilder<TimerCreatingBloc, TimerModel>(
      buildWhen: (previous, current) {
        try {
          if (previous
                  .timerSets[widget.setIndex].timers[widget.index].duration !=
              current
                  .timerSets[widget.setIndex].timers[widget.index].duration) {
            return true;
          } else {
            return false;
          }
        } on RangeError {
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
          child: Text(formatDuration(duration, showHour: true)),
        );
      },
    );
  }

  Widget options() {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case TimerOptions.copy:
            context.bloc<TimerCreatingBloc>().add(
                  TimerCopied(
                    setIndex: widget.setIndex,
                    index: widget.index,
                  ),
                );
            break;
          case TimerOptions.delete:
            context.bloc<TimerCreatingBloc>().add(
                  TimerDeleted(
                    setIndex: widget.setIndex,
                    index: widget.index,
                  ),
                );
            break;
          case TimerOptions.moveUp:
            context.bloc<TimerCreatingBloc>().add(
                  TimerMovedUp(
                    setIndex: widget.setIndex,
                    index: widget.index,
                  ),
                );
            break;
          case TimerOptions.moveDown:
            context.bloc<TimerCreatingBloc>().add(
                  TimerMovedDown(
                    setIndex: widget.setIndex,
                    index: widget.index,
                  ),
                );
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
