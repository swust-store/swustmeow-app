// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseEntity<T> _$ResponseEntityFromJson<T>(Map<String, dynamic> json) =>
    ResponseEntity<T>(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data: ResponseEntity._dataFromJson(json['data'] as Object),
    );

Map<String, dynamic> _$ResponseEntityToJson<T>(ResponseEntity<T> instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': ResponseEntity._dataToJson(instance.data),
    };
