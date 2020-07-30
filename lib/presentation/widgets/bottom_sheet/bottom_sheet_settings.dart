import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/prefs_keys.dart';
import '../../../core/service_locator.dart';
import '../dialogs/dialog_duration.dart';

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

  bool _warning3Remaining;
  int _forwardDuration;
  int _rewindDuration;

  @override
  void initState() {
    super.initState();
    _warning3Remaining = prefs.getBool(PrefsKeys.warning3Remaining) ?? true;
    _forwardDuration = prefs.getInt(PrefsKeys.forwardDuration) ?? 5;
    _rewindDuration = prefs.getInt(PrefsKeys.rewindDuration) ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        SwitchListTile(
          onChanged: (value) {
            setState(() {
              _warning3Remaining = value;
            });
            prefs.setBool(PrefsKeys.warning3Remaining, value);
          },
          value: _warning3Remaining,
          title: Text('Warning With 3 Seconds Remaining'),
        ),
        ListTile(
          title: Text('Forward Duration'),
          subtitle: Text('$_forwardDuration sec'),
          onTap: () async {
            final duration =
                await DurationDialog.show(context, duration: _forwardDuration);
            if (duration != null) {
              setState(() {
                _forwardDuration = duration;
              });
              prefs.setInt(PrefsKeys.forwardDuration, duration);
            }
          },
        ),
        ListTile(
          title: Text('Rewind Duration'),
          subtitle: Text('$_rewindDuration sec'),
          onTap: () async {
            final duration =
                await DurationDialog.show(context, duration: _rewindDuration);
            if (duration != null) {
              setState(() {
                _rewindDuration = duration;
              });
              prefs.setInt(PrefsKeys.rewindDuration, duration);
            }
          },
        ),
      ],
    );
  }
}
