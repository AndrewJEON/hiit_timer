import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../bloc/timer_creating/timer_creating_bloc.dart';
import '../../../data/models/model_timer.dart';

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
    return Row(
      children: <Widget>[
        Flexible(child: description()),
        duration(),
      ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove_circle),
          iconSize: 16,
          onPressed: () {},
        ),
        Text('00:30'),
        IconButton(
          icon: Icon(Icons.add_circle),
          iconSize: 16,
          onPressed: () {},
        ),
      ],
    );
  }
}
