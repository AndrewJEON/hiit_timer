import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete'),
      content: SingleChildScrollView(
        child: Text('Are you sure you want to delete this timer?'),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
          textColor: Colors.black,
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Delete'),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
        ),
      ],
    );
  }

  static Future<bool> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog();
      },
    );
  }
}
