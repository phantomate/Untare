extension DoubleExtension on double {
  String toFormattedString() {
    return this.toStringAsFixed(this.truncateToDouble() == this ? 0 : 2);
  }
}