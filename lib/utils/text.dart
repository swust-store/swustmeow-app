String overflowed(String string, int maxLen) {
  double realMaxLen = maxLen.toDouble();
  for (final char in string.split('')) {
    realMaxLen += (char.codeUnitAt(0) & ~0x7F) == 0 ? 0.5 : 0;
  }
  int floor = realMaxLen.floor();
  return string.length <= floor
      ? string
      : "${string.substring(0, floor - 1)}...";
}

String fill(String origin, int length, String toFill) => origin.length >= length
    ? origin
    : toFill * (length - origin.length) + origin;
