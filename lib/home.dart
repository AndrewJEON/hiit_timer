import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/timer/timer_bloc.dart';
import 'bloc/timer_creating/timer_creating_bloc.dart';
import 'core/service_locator.dart';
import 'data/models/model_timer.dart';
import 'data/repositories/repository_timer.dart';
import 'presentation/pages/page_timer_creating.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TimerBloc, TimerState>(
        builder: (context, state) {
          if (state is TimerInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TimerIdle) {
            return Center(
              child: Text(state.timer.name),
            );
          } else if (state is TimerFailure) {
            if (state == TimerFailure.noSavedTimer()) {
              return Center(
                child: Text(state.message),
              );
            }
          }
          return Container();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'fast_rewind',
            mini: true,
            child: Icon(Icons.fast_rewind, size: 20),
            onPressed: () {},
          ),
          FloatingActionButton(
            heroTag: 'play_pause',
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _controller,
            ),
            onPressed: () {
              if (_controller.isCompleted) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            },
          ),
          FloatingActionButton(
            heroTag: 'fast_forward',
            mini: true,
            child: Icon(Icons.fast_forward, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () async {
                final timer = await selectTimer();
                if (timer != null) {
                  context.bloc<TimerBloc>().add(TimerSelected(timer));
                }
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
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
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<TimerModel> selectTimer() async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<List<TimerModel>>(
          future: sl<TimerRepository>().load(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Oops! Something went wrong'));
            }
            final sortedTimers =
                snapshot.data.sort((a, b) => a.name.compareTo(b.name));
            return snapshot.data.isEmpty
                ? Center(child: Text('No Saved Timer'))
                : ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: Icon(Icons.timer),
                        title: Text(snapshot.data[i].name),
                        onTap: () {
                          Navigator.pop(context, snapshot.data[i]);
                        },
                      );
                    },
                  );
          },
        );
      },
    );
  }
}
