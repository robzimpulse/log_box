// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_log_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraceLogEntryModel _$TraceLogEntryModelFromJson(Map<String, dynamic> json) =>
    TraceLogEntryModel(
      id: json['id'] as String?,
      timestamp:
          json['timestamp'] == null
              ? null
              : DateTime.parse(json['timestamp'] as String),
      name: json['name'] as String,
      logs:
          (json['logs'] as List<dynamic>?)
              ?.map((e) => LogEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TraceLogEntryModelToJson(TraceLogEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'name': instance.name,
      'logs': instance.logs.map((e) => e.toJson()).toList(),
    };
