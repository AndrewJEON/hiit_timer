import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'bloc/timer/timer_bloc.dart';
import 'core/utils.dart';
import 'presentation/widgets/bottom_sheet/bottom_sheet_presets.dart';
import 'presentation/widgets/bottom_sheet/bottom_sheet_repeat_count.dart';

class RepeatCountOptions {
  static const x2 = '2x';
  static const x3 = '3x';
  static const x4 = '4x';
  static const x5 = '5x';
  static const infinite = 'Infinite';
  static const custom = 'Custom';
  static const all = [x2, x3, x4, x5, infinite, custom];
}

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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  repeatCount(),
                  resetButton(),
                ],
              ),
            ),
            Expanded(child: remainingTime()),
          ],
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
          BlocListener<TimerBloc, TimerState>(
            listener: (context, state) {
              if (state is TimerInitial) {
                _controller.reverse();
              } else if (state is TimerReady) {
                _controller.reverse();
              } else if (state is TimerRunning) {
                _controller.forward();
              } else if (state is TimerPause) {
                _controller.reverse();
              } else if (state is TimerFinish) {
                _controller.reverse();
              } else if (state is TimerFailure) {
                _controller.reverse();
              }
            },
            child: FloatingActionButton(
              heroTag: 'play_pause',
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _controller,
              ),
              onPressed: () {
                final currentState = context.bloc<TimerBloc>().state;
                if (currentState is TimerRunning) {
                  context.bloc<TimerBloc>().add(TimerPaused());
                } else if (currentState is TimerReady) {
                  context.bloc<TimerBloc>().add(TimerStarted());
                } else if (currentState is TimerPause) {
                  context.bloc<TimerBloc>().add(TimerResumed());
                } else if (currentState is TimerFinish) {
                  context.bloc<TimerBloc>().add(TimerStarted());
                }
              },
            ),
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
                final timer = await PresetsBottomSheet.show(context);
                if (timer != null) {
                  context.bloc<TimerBloc>().add(TimerSelected(timer));
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget repeatCount() {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        if (state is TimerReady) {
          return FlatButton.icon(
            onPressed: () async {
              final repeatCount = await RepeatCountBottomSheet.show(
                context,
                currentRepeatCount:
                    state.repeatCount == -1 ? 1 : state.repeatCount,
              );
              if (repeatCount != null) {
                context
                    .bloc<TimerBloc>()
                    .add(TimerRepeatCountChanged(repeatCount));
              }
            },
            icon: Icon(Icons.repeat),
            label: BlocBuilder<TimerBloc, TimerState>(
              builder: (context, state) {
                if (state.repeatCount == -1) {
                  return Icon(Ionicons.ios_infinite);
                } else {
                  return Text(
                    '${state.repeatCount}x',
                    style: Theme.of(context).textTheme.bodyText1,
                  );
                }
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        } else {
          return FlatButton.icon(
            onPressed: null,
            icon: Icon(Icons.repeat),
            label: BlocBuilder<TimerBloc, TimerState>(
              builder: (context, state) {
                if (state.repeatCount == -1) {
                  return Icon(Ionicons.ios_infinite);
                } else {
                  return Text(
                    '${state.repeatCount}x',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.grey),
                  );
                }
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }
      },
    );
  }

  Widget resetButton() {
    return FlatButton.icon(
      onPressed: () {
        context.bloc<TimerBloc>().add(TimerReset());
      },
      icon: Icon(Icons.refresh),
      label: Text('Reset'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget remainingTime() {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        if (state is TimerInitial) {
          return Center(child: CircularProgressIndicator());
        } else if (state is TimerReady) {
          return Center(
            child: Text(formatDuration(state.remainingTime)),
          );
        } else if (state is TimerRunning) {
          return Center(
            child: Text(formatDuration(state.remainingTime)),
          );
        } else if (state is TimerPause) {
          return Center(
            child: Text(formatDuration(state.remainingTime)),
          );
        } else if (state is TimerFinish) {
          return Center(
            child: Text('Done!'),
          );
        } else if (state is TimerFailure) {
          return Center(
            child: Text(state.message),
          );
        }
        return Container();
      },
    );
  }
}
