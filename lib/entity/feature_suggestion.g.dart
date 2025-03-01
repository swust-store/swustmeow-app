// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureSuggestion _$FeatureSuggestionFromJson(Map<String, dynamic> json) =>
    FeatureSuggestion(
      id: (json['id'] as num).toInt(),
      content: json['content'] as String,
      creatorId: json['creator_id'] as String,
      votesCount: (json['votes_count'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] == null
          ? SuggestionStatus.pending
          : FeatureSuggestion._statusFromJson(json['status']),
      hasVoted: json['has_voted'] as bool? ?? false,
    );

Map<String, dynamic> _$FeatureSuggestionToJson(FeatureSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'creator_id': instance.creatorId,
      'votes_count': instance.votesCount,
      'created_at': instance.createdAt.toIso8601String(),
      'status': FeatureSuggestion._statusToJson(instance.status),
      'has_voted': instance.hasVoted,
    };
