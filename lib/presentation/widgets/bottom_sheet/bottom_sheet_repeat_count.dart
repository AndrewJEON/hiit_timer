import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class RepeatCountBottomSheet extends StatefulWidget {
  final int currentRepeatCount;

  RepeatCountBottomSheet(this.currentRepeatCount);

  static Future<int> show(
    BuildContext context, {
    int currentRepeatCount,
  }) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return RepeatCountBottomSheet(currentRepeatCount);
      },
    );
  }

  @override
  _RepeatCountBottomSheetState createState() => _RepeatCountBottomSheetState();
}

class _RepeatCountBottomSheetState extends State<RepeatCountBottomSheet> {
  int _repeatCount;

  @override
  void initState() {
    super.initState();
    _repeatCount = widget.currentRepeatCount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Set repeat count',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context, -1);
                  },
                  icon: Icon(Ionicons.ios_infinite),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, _repeatCount);
                  },
                  child: Text('Done'),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  if(_repeatCount > 1) {
                    setState(() {
                      _repeatCount--;
                    });
                  }
                },
                icon: Icon(Icons.remove_circle),
                iconSize: 32,
              ),
              SizedBox(width: 16),
              Text(
                '${_repeatCount}x',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontSize: 32,
                    ),
              ),
              SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  setState(() {
                    _repeatCount++;
                  });
                },
                icon: Icon(Icons.add_circle),
                iconSize: 32,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
