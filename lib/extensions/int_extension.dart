extension IntExtension on int {
  String minutesToTimeString() {
    const minInDay = 60 * 24;
    const minInHour = 60;

    int days = (this / minInDay).floor();
    final minLeftForHours = (this - (days * minInDay));
    int hours = (minLeftForHours / minInHour).floor();
    int minutes = (minLeftForHours - (hours * minInHour)).round();

    String timeStr = "";

    if (days > 0) timeStr += "${days}d ";
    if (hours > 0) timeStr += "${hours}h ";
    if (minutes > 0) timeStr += "${minutes}min ";

    return timeStr.trim();
  }
}
