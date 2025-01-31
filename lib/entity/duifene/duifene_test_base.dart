abstract class DuiFenETestBase {
  const DuiFenETestBase(
      {required this.name,
      this.beginTime,
      required this.endTime,
      required this.finished});

  final String name;
  final DateTime? beginTime;
  final DateTime endTime;
  final bool finished;
}
