import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/timer_creating/timer_creating_bloc.dart';
import '../../../core/service_locator.dart';
import '../../../data/models/model_timer.dart';
import '../../../data/repositories/repository_timer.dart';
import '../../pages/page_timer_creating.dart';

class PresetsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TimerModel>>(
      future: sl<TimerRepository>().load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Oops! Something went wrong'));
        }
        final sortedTimers = snapshot.data
          ..sort((a, b) => a.name.compareTo(b.name));
        if (sortedTimers.isEmpty) {
          return Center(child: Text('No Saved Timer'));
        } else {
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
                  FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
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
                    },
                    icon: Icon(Icons.add),
                    label: Text('New Timer'),
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedTimers.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: Icon(Icons.timer),
                      title: Text(snapshot.data[i].name),
                      onTap: () {
                        Navigator.pop(context, snapshot.data[i]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
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
