enum SuggestionFilterOption {
  all('all', '全部'),
  my('my', '我的'),
  pending('pending', '待处理'),
  working('working', '进行中'),
  completed('completed', '已完成'),
  noPlan('no_plan', '无计划'),
  infeasible('infeasible', '不可实现');

  final String value;
  final String description;

  const SuggestionFilterOption(this.value, this.description);
}
