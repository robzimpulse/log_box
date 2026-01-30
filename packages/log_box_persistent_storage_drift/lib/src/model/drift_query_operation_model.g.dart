// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_query_operation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriftQueryOperationModel _$DriftQueryOperationModelFromJson(
  Map<String, dynamic> json,
) => DriftQueryOperationModel(
  timestamp: DateTime.parse(json['timestamp'] as String),
  operation: json['operation'] as String?,
  statements:
      (json['statements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  duration: json['duration'] == null
      ? null
      : Duration(microseconds: (json['duration'] as num).toInt()),
  error: json['error'] as String?,
  stackTrace: json['stack_trace'] as String?,
);

Map<String, dynamic> _$DriftQueryOperationModelToJson(
  DriftQueryOperationModel instance,
) => <String, dynamic>{
  'operation': instance.operation,
  'statements': instance.statements,
  'duration': instance.duration?.inMicroseconds,
  'error': instance.error,
  'stack_trace': instance.stackTrace,
  'timestamp': instance.timestamp.toIso8601String(),
};
