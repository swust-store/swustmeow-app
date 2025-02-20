enum SuggestionFilterOption {
  all('all', '无筛选'),
  my('my', '我的'),
  incomplete('pending', '未完成'),
  working('working', '进行中'),
  completed('completed', '已完成');

  final String value;
  final String description;

  const SuggestionFilterOption(this.value, this.description);
}
