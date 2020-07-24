import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../data/repositories/repository_timer.dart';

class TimerNameDialog extends StatefulWidget {
  final String currentName;

  TimerNameDialog(this.currentName);

  static Future<String> show(
    BuildContext context, {
    String currentName,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return TimerNameDialog(currentName);
      },
    );
  }

  @override
  _TimerNameDialogState createState() => _TimerNameDialogState();
}

class _TimerNameDialogState extends State<TimerNameDialog> {
  final _controller = TextEditingController();

  bool _isValid = false;
  bool _isDuplicate = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.currentName == null ? 'Timer Name' : 'Rename'),
      content: SingleChildScrollView(
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: null,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            setState(() {
              _isValid = value.isNotEmpty;
            });
          },
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            errorText: _isDuplicate ? 'Duplicate name exists' : null,
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context, null),
        ),
        FlatButton(
          child: Text(widget.currentName == null ? 'Save' : 'Rename'),
          onPressed: _isValid
              ? () async {
                  final repo = sl<TimerRepository>();
                  if (!await repo.isDuplicate(_controller.text)) {
                    Navigator.pop(context, _controller.text);
                  } else {
                    setState(() {
                      _isDuplicate = true;
                    });
                  }
                }
              : null,
        ),
      ],
    );
  }
}
