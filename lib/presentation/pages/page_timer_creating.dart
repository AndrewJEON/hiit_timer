import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/timer_creating/timer_creating_bloc.dart';
import '../../data/models/model_timer.dart';
import '../widgets/dialogs/dialog_timer_name.dart';
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
            onPressed: () async {
              final name = await TimerNameDialog.show(context);
              if (name != null) {
                context.bloc<TimerCreatingBloc>().add(TimerSaved(name));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: BlocBuilder<TimerCreatingBloc, TimerModel>(
                buildWhen: (previous, current) {
                  if (previous.timerSets.length != current.timerSets.length) {
                    return true;
                  } else {
                    var count = 0;
                    for (var i = 0; i < previous.timerSets.length; i++) {
                      if (previous.timerSets[i] != current.timerSets[i]) {
                        count++;
                        if (count >= 2) {
                          return true;
                        }
                      }
                    }
                    return false;
                  }
                },
                builder: (context, state) {
                  return ListView(
                    children: <Widget>[
                      for (var i = 0; i < state.timerSets.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: TimerSetView(
                            key: UniqueKey(),
                            timerSet: state.timerSets[i],
                            index: i,
                          ),
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
