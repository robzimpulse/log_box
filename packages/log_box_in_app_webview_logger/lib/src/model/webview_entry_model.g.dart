// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebviewEntryModel _$WebviewEntryModelFromJson(
  Map<String, dynamic> json,
) => WebviewEntryModel(
  id: json['id'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  uri: json['uri'] == null ? null : Uri.parse(json['uri'] as String),
  loading: json['loading'] as bool?,
  scripts:
      (json['scripts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => WebviewEntryModelLog.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  html: json['html'] as String?,
  error: json['error'],
);

Map<String, dynamic> _$WebviewEntryModelToJson(WebviewEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'uri': instance.uri?.toString(),
      'scripts': instance.scripts,
      'events': instance.events.map((e) => e.toJson()).toList(),
      'html': instance.html,
      'error': instance.error,
      'loading': instance.loading,
    };
