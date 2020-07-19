import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/timer_creating/timer_creating_bloc.dart';
import 'core/service_locator.dart';
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
      body: Center(
        child: FutureBuilder<TimerCreatingState>(
          future: sl<TimerRepository>().load(),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              return Text(snapshot.data.toString());
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
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
              onPressed: () {},
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
}
