// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_entry_model_log.dart';

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
