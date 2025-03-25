enum SuggestionStatus {
  pending(0, '待处理'),
  working(1, '正在处理'),
  completed(2, '已完成'),
  noPlan(3, '无计划处理'),
  infeasible(4, '驳回');

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
