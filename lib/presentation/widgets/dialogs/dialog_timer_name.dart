import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/service_locator.dart';

class TimerNameDialog extends StatefulWidget {
  static Future<String> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return TimerNameDialog();
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Timer Name'),
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
          child: Text('Save'),
          onPressed: _isValid
              ? () async {
                  if (!await isDuplicate(_controller.text)) {
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

  Future<bool> isDuplicate(String name) async {
    final timerDir = sl<Directory>();
    final files = timerDir.list().where((entity) => entity is File).cast<File>();
    await for (final file in files) {
      if (p.basenameWithoutExtension(file.path) == name) {
        return true;
      }
    }
    return false;
  }
}
