extension DoubleExtension on double {
  String toFormattedString({int precision = 2}) {
    return toStringAsFixed(truncateToDouble() == this ? 0 : precision);
  }
}