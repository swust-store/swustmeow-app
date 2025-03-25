class ChaoXingHomework {
  final String title;
  final List<String> labels;
  final String status;

  const ChaoXingHomework({
    required this.title,
    required this.labels,
    required this.status,
  });

  @override
  String toString() {
    return 'ChaoXingHomework(title: $title, labels: $labels, status: $status)';
  }
}
