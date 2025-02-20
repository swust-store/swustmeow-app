enum SuggestionSortOption {
  timeDesc('time_desc', '按时间倒序'),
  timeAsc('time_asc', '按时间正序'),
  votesDesc('votes_desc', '按投票数倒序'),
  votesAsc('votes_asc', '按投票数正序');

  final String value;
  final String description;

  const SuggestionSortOption(this.value, this.description);
}
