import 'package:swustmeow/entity/duifene/duifene_test_base.dart';

class DuiFenEHomework extends DuiFenETestBase {
  const DuiFenEHomework({
    required super.course,
    required super.name,
    required super.endTime,
    required super.finished,
    required this.overdue,
  });

  final bool overdue;
}
