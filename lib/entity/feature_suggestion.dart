import 'package:json_annotation/json_annotation.dart';

import 'feature_suggestion_status.dart';

part 'feature_suggestion.g.dart';

@JsonSerializable()
class FeatureSuggestion {
  final int id;
  final String content;
  @JsonKey(name: 'creator_id')
  final String creatorId;
  @JsonKey(name: 'votes_count')
  int votesCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson)
  SuggestionStatus status;
  @JsonKey(name: 'has_voted')
  bool hasVoted;

  FeatureSuggestion({
    required this.id,
    required this.content,
    required this.creatorId,
    required this.votesCount,
    required this.createdAt,
    this.status = SuggestionStatus.pending,
    this.hasVoted = false,
  });

  factory FeatureSuggestion.fromJson(Map<String, dynamic> json) =>
      _$FeatureSuggestionFromJson(json);

  bool get isCompleted => status == SuggestionStatus.completed;

  bool get isWorking => status == SuggestionStatus.working;

  static SuggestionStatus _statusFromJson(dynamic value) {
    final intValue = (value as num).toInt();
    return SuggestionStatus.fromValue(intValue);
  }

  static int _statusToJson(SuggestionStatus status) {
    return status.value;
  }
}
