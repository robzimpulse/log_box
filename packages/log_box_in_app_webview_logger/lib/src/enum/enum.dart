import 'package:json_annotation/json_annotation.dart';

enum WebviewEvent {
  @JsonValue('onWebViewCreated')
  onWebViewCreated,
  @JsonValue('onContentSizeChanged')
  onContentSizeChanged,
  @JsonValue('onLoadStart')
  onLoadStart,
  @JsonValue('onLoadStop')
  onLoadStop,
  @JsonValue('onProgressChanged')
  onProgressChanged,
  @JsonValue('onReceivedError')
  onReceivedError,
  @JsonValue('onConsoleMessage')
  onConsoleMessage,
  @JsonValue('onRunJavascript')
  onRunJavascript,
  @JsonValue('shouldOverrideUrlLoading')
  shouldOverrideUrlLoading,
  @JsonValue('onTitleChanged')
  onTitleChanged,
  @JsonValue('onLoadResource')
  onLoadResource,
  @JsonValue('shouldInterceptAjaxRequest')
  shouldInterceptAjaxRequest,
  @JsonValue('onAjaxProgress')
  onAjaxProgress,
  @JsonValue('onReceivedHttpError')
  onReceivedHttpError,
  @JsonValue('onAjaxReadyStateChange')
  onAjaxReadyStateChange,
}