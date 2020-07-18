import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/timer_creating/timer_creating_bloc.dart';
import '../widgets/views/view_timer_set.dart';

class TimerCreatingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creating'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: BlocBuilder<TimerCreatingBloc, TimerCreatingState>(
                builder: (context, state) {
                  return ListView(
                    children: <Widget>[
                      for (var i = 0; i < state.timerSets.length; i++)
                        TimerSetView(
                          key: ValueKey(i),
                          timerSet: state.timerSets[i],
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FlatButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add New Set'),
                onPressed: () {
                  context.bloc<TimerCreatingBloc>().add(TimerSetAdded());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
