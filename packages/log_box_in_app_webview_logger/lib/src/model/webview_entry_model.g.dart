// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebviewEntryModelLog _$WebviewEntryModelLogFromJson(
  Map<String, dynamic> json,
) => WebviewEntryModelLog(
  event: $enumDecode(_$WebviewEventEnumMap, json['event']),
  extra: json['extra'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$WebviewEntryModelLogToJson(
  WebviewEntryModelLog instance,
) => <String, dynamic>{
  'event': _$WebviewEventEnumMap[instance.event]!,
  'extra': instance.extra,
};

const _$WebviewEventEnumMap = {
  WebviewEvent.onWebViewCreated: 'onWebViewCreated',
  WebviewEvent.onContentSizeChanged: 'onContentSizeChanged',
  WebviewEvent.onLoadStart: 'onLoadStart',
  WebviewEvent.onLoadStop: 'onLoadStop',
  WebviewEvent.onProgressChanged: 'onProgressChanged',
  WebviewEvent.onReceivedError: 'onReceivedError',
  WebviewEvent.onConsoleMessage: 'onConsoleMessage',
  WebviewEvent.onRunJavascript: 'onRunJavascript',
  WebviewEvent.shouldOverrideUrlLoading: 'shouldOverrideUrlLoading',
  WebviewEvent.onTitleChanged: 'onTitleChanged',
  WebviewEvent.onLoadResource: 'onLoadResource',
  WebviewEvent.shouldInterceptAjaxRequest: 'shouldInterceptAjaxRequest',
  WebviewEvent.onAjaxProgress: 'onAjaxProgress',
  WebviewEvent.onReceivedHttpError: 'onReceivedHttpError',
  WebviewEvent.onAjaxReadyStateChange: 'onAjaxReadyStateChange',
};

WebviewEntryModel _$WebviewEntryModelFromJson(
  Map<String, dynamic> json,
) => WebviewEntryModel(
  id: json['id'] as String?,
  timestamp:
      json['timestamp'] == null
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
