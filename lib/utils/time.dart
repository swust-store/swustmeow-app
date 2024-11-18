bool isHourMinuteInRange(String time, String left, String right, String splitPattern) {
  split(String string) => string.split(splitPattern).map(int.parse).toList();
  final format = DateTime(0);
  final timeSplit = split(time);
  final leftSplit = split(left);
  final rightSplit = split(right);

  final givenTime = DateTime(format.year, format.month, format.day, timeSplit[0], timeSplit[1]);
  final startTime = DateTime(format.year, format.month, format.day, leftSplit[0], leftSplit[1]);
  final endTime = DateTime(format.year, format.month, format.day, rightSplit[0], rightSplit[1]);

  return givenTime.isAfter(startTime) && givenTime.isBefore(endTime);
}

int getWeekNumber() {
  final year = DateTime.now().year;
  var sep = DateTime(year, 9);
  while (true) {
    if (sep.weekday != 1) {
      sep = sep.add(const Duration(days: 1));
    } else {
      break;
    }
  }
  final diff = DateTime.now().difference(sep);
  return ((diff.inDays + 1) / 7).ceil();
}