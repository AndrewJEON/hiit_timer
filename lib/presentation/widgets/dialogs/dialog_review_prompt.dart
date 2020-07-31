import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';

class ReviewPromptDialog extends StatelessWidget {
  static Future<void> show(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return ReviewPromptDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enjoying the app?'),
      content: Text(
        'If you enjoy using our app, could you take a moment to rate it? It won\'t take more than a minute.\nThanks for your support!',
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('No Thanks'),
          textColor: Colors.black,
        ),
        FlatButton(
          onPressed: () {
            AppReview.storeListing;
          },
          child: Text('Sure!'),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
        )
      ],
    );
  }
}
