enum SuggestionStatus {
  pending(0, '待处理'),
  working(1, '正在实现'),
  completed(2, '已完成'),
  noPlan(3, '无计划实现'),
  infeasible(4, '不可实现');

  final int value;
  final String displayName;

  const SuggestionStatus(this.value, this.displayName);

  static SuggestionStatus fromValue(int value) {
    return SuggestionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SuggestionStatus.pending,
    );
  }
}
