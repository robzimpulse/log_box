// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkEntryModel _$NetworkEntryModelFromJson(Map<String, dynamic> json) =>
    NetworkEntryModel(
      id: json['id'] as String?,
      timestamp:
          json['timestamp'] == null
              ? null
              : DateTime.parse(json['timestamp'] as String),
      client: json['client'] as String?,
      loading: json['loading'] as bool? ?? true,
      method: json['method'] as String?,
      uri: json['uri'] == null ? null : Uri.parse(json['uri'] as String),
      request:
          json['request'] == null
              ? null
              : HttpRequestModel.fromJson(
                json['request'] as Map<String, dynamic>,
              ),
      response:
          json['response'] == null
              ? null
              : HttpResponseModel.fromJson(
                json['response'] as Map<String, dynamic>,
              ),
      error:
          json['error'] == null
              ? null
              : HttpErrorModel.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NetworkEntryModelToJson(NetworkEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'client': instance.client,
      'loading': instance.loading,
      'method': instance.method,
      'uri': instance.uri?.toString(),
      'request': instance.request?.toJson(),
      'response': instance.response?.toJson(),
      'error': instance.error?.toJson(),
    };
