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
  operations: (json['operations'] as List<dynamic>)
      .map((e) => DriftQueryOperationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DriftQueryEntryModelToJson(
  DriftQueryEntryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'operations': instance.operations.map((e) => e.toJson()).toList(),
};
