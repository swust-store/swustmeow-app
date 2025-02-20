import 'package:json_annotation/json_annotation.dart';

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
  @JsonKey(name: 'is_completed')
  bool isCompleted;
  @JsonKey(name: 'is_working')
  bool isWorking;
  @JsonKey(name: 'has_voted')
  bool hasVoted;

  FeatureSuggestion({
    required this.id,
    required this.content,
    required this.creatorId,
    required this.votesCount,
    required this.createdAt,
    this.isCompleted = false,
    this.isWorking = false,
    this.hasVoted = false,
  });

  factory FeatureSuggestion.fromJson(Map<String, dynamic> json) =>
      _$FeatureSuggestionFromJson(json);
}
