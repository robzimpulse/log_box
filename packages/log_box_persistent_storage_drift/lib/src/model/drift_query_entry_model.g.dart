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
  operation: $enumDecode(_$DatabaseOperationEnumMap, json['operation']),
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => DriftQueryEntryModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  statements:
      (json['statements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isComplete: json['is_complete'] as bool?,
  completionType: $enumDecodeNullable(
    _$DatabaseOperationEnumMap,
    json['completion_type'],
  ),
  duration: json['duration'] == null
      ? null
      : Duration(microseconds: (json['duration'] as num).toInt()),
  error: json['error'] as String?,
  stackTrace: json['stack_trace'] as String?,
);

Map<String, dynamic> _$DriftQueryEntryModelToJson(
  DriftQueryEntryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'operation': _$DatabaseOperationEnumMap[instance.operation]!,
  'children': instance.children.map((e) => e.toJson()).toList(),
  'statements': instance.statements,
  'is_complete': instance.isComplete,
  'completion_type': _$DatabaseOperationEnumMap[instance.completionType],
  'duration': instance.duration?.inMicroseconds,
  'error': instance.error,
  'stack_trace': instance.stackTrace,
};

const _$DatabaseOperationEnumMap = {
  DatabaseOperation.beginTransaction: 'beginTransaction',
  DatabaseOperation.commitTransaction: 'commitTransaction',
  DatabaseOperation.rollbackTransaction: 'rollbackTransaction',
  DatabaseOperation.runBatched: 'runBatched',
  DatabaseOperation.runCustom: 'runCustom',
  DatabaseOperation.runDelete: 'runDelete',
  DatabaseOperation.runInsert: 'runInsert',
  DatabaseOperation.runSelect: 'runSelect',
  DatabaseOperation.runUpdate: 'runUpdate',
  DatabaseOperation.unknown: 'unknown',
};
