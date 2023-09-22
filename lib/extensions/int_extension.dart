extension IntExtension on int {
  String minutesToTimeString() {
    const minInDay = 60 * 24;
    const minInHour = 60;

    int days = (this / minInDay).floor();
    final minLeftForHours = (this - (days * minInDay));
    int hours = (minLeftForHours / minInHour).floor();
    int minutes = (minLeftForHours - (hours * minInHour)).round();

    String time_str = "";

    if (days > 0) time_str += "${days}d ";
    if (hours > 0) time_str += "${hours}h ";
    if (minutes > 0) time_str += "${minutes}min ";

    return time_str.trim();
  }
}
