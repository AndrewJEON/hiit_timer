import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DurationDialog extends StatefulWidget {
  final int duration;

  DurationDialog(this.duration);

  static Future<int> show(BuildContext context, {int duration}) async {
    return showDialog(
      context: context,
      builder: (context) {
        return DurationDialog(duration);
      },
    );
  }

  @override
  _DurationDialogState createState() => _DurationDialogState();
}

class _DurationDialogState extends State<DurationDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.duration.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Duration'),
      content: SingleChildScrollView(
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(8),
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text('Cancel'),
        ),
        FlatButton(
          onPressed: () {
            final duration = int.tryParse(_controller.text);
            Navigator.pop(context, duration);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
