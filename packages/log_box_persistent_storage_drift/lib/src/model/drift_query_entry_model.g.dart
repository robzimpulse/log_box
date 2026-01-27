// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_query_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriftQueryEntryModel _$DriftQueryEntryModelFromJson(
  Map<String, dynamic> json,
) => DriftQueryEntryModel(
  id: json['id'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  operation: json['operation'] as String?,
  statement: json['statement'] as String?,
  duration: json['duration'] == null
      ? null
      : Duration(microseconds: (json['duration'] as num).toInt()),
  arguments: json['arguments'] as Map<String, dynamic>?,
  error: json['error'] as String?,
  stackTrace: json['stack_trace'] as String?,
);

Map<String, dynamic> _$DriftQueryEntryModelToJson(
  DriftQueryEntryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'operation': instance.operation,
  'statement': instance.statement,
  'duration': instance.duration?.inMicroseconds,
  'arguments': instance.arguments,
  'error': instance.error,
  'stack_trace': instance.stackTrace,
};
