extension DoubleExtension on double {
  String toFormattedString() {
    return toStringAsFixed(truncateToDouble() == this ? 0 : 2);
  }
}