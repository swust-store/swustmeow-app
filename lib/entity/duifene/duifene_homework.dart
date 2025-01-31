import 'package:miaomiaoswust/entity/duifene/duifene_test_base.dart';

class DuiFenEHomework extends DuiFenETestBase {
  const DuiFenEHomework(
      {required super.name,
      required super.endTime,
      required super.finished,
      required this.overdue});

  final bool overdue;
}
