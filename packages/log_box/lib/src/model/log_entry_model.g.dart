// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntryModel _$LogEntryModelFromJson(Map<String, dynamic> json) =>
    LogEntryModel(
      id: json['id'] as String?,
      timestamp:
          json['timestamp'] == null
              ? null
              : DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String,
      extra: json['extra'] as Map<String, dynamic>?,
      name: json['name'] as String?,
      error: json['error'] as String?,
      stackTrace: json['stack_trace'] as String?,
    );

Map<String, dynamic> _$LogEntryModelToJson(LogEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'message': instance.message,
      'name': instance.name,
      'error': instance.error,
      'stack_trace': instance.stackTrace,
      'extra': instance.extra,
    };
