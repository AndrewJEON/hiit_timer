String formatDuration(Duration duration, {bool showHour = false}) {
  final hour = duration.inHours.toString().padLeft(2, '0');
  final minute = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final second = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (showHour) {
    return '$hour:$minute:$second';
  } else {
    if (hour == '00') {
      return '$minute:$second';
    } else {
      return '$hour:$minute:$second';
    }
  }
}
