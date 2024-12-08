import 'package:miaomiaoswust/core/values.dart';
import 'package:miaomiaoswust/utils/time.dart';

class Festival {
  const Festival({required this.dateString, required this.greetings});

  final String dateString;
  final List<String> greetings;

  DateTime get parsedDateStart => dateStringToDate(dateString.split('-').first);

  DateTime get parsedDateEnd => dateStringToDate(dateString.split('-').last);

  bool isInHoliday([DateTime? date]) {
    date = date ?? Values.now;
    final before = DateTime(date.year - 1, date.month, date.day);
    final after = DateTime(date.year + 1, date.month, date.day);
    if (parsedDateStart.monthDayEquals(parsedDateEnd)) {
      return date.monthDayEquals(parsedDateStart);
    } else {
      return isMDInRange(before, parsedDateStart, parsedDateEnd) ||
          isMDInRange(date, parsedDateStart, parsedDateEnd) ||
          isMDInRange(after, parsedDateStart, parsedDateEnd);
    }
  }
}
