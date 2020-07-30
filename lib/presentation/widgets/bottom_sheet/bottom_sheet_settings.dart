import 'package:flutter/material.dart';
import 'package:interval_timer/core/prefs_keys.dart';
import 'package:interval_timer/core/service_locator.dart';
import 'package:interval_timer/presentation/widgets/dialogs/dialog_duration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBottomSheet extends StatefulWidget {
  static Future<int> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SettingsBottomSheet();
      },
    );
  }

  @override
  _SettingsBottomSheetState createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  final prefs = sl<SharedPreferences>();

  int forwardDuration;
  int rewindDuration;

  @override
  void initState() {
    super.initState();
    forwardDuration = prefs.getInt(PrefsKeys.forwardDuration) ?? 5;
    rewindDuration = prefs.getInt(PrefsKeys.rewindDuration) ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          title: Text('Forward Duration'),
          subtitle: Text('$forwardDuration sec'),
          onTap: () async {
            final duration =
                await DurationDialog.show(context, duration: forwardDuration);
            if (duration != null) {
              setState(() {
                forwardDuration = duration;
              });
              prefs.setInt(PrefsKeys.forwardDuration, duration);
            }
          },
        ),
        ListTile(
          title: Text('Rewind Duration'),
          subtitle: Text('$rewindDuration sec'),
          onTap: () async {
            final duration =
                await DurationDialog.show(context, duration: rewindDuration);
            if (duration != null) {
              setState(() {
                rewindDuration = duration;
              });
              prefs.setInt(PrefsKeys.rewindDuration, duration);
            }
          },
        ),
      ],
    );
  }
}
