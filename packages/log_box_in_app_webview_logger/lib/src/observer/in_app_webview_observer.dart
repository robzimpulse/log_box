import 'dart:ui';

import 'package:log_box/log_box.dart';
import 'package:uuid/uuid.dart';

import '../enum/enum.dart';
import '../model/webview_entry_model.dart';
import '../model/webview_entry_model_log.dart';

/// Observer for InAppWebView events that logs them to [Storage].
class InAppWebviewObserver {
  final Storage _storage;
  final String _id;

  InAppWebviewObserver({required Storage storage})
    : _storage = storage,
      _id = const Uuid().v4();

  /// Updates the top-level state of the webview entry.
  void set({
    Uri? uri,
    String? html,
    Object? error,
    StackTrace? stackTrace,
    bool? loading,
  }) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        uri: uri,
        html: html,
        error: error?.toString(),
        stackTrace: stackTrace?.toString(),
        loading: loading,
      ),
    );
  }

  /// Helper method to add a [WebviewEvent] to the storage.
  void _addEvent(WebviewEvent event, Map<String, dynamic> extra) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [WebviewEntryModelLog(event: event, extra: extra)],
      ),
    );
  }

  void onTitleChanged({String? title, Map<String, dynamic>? extra}) {
    _addEvent(WebviewEvent.onTitleChanged, {'title': title, ...?extra});
  }

  void onWebViewCreated({
    required Uri uri,
    List<String> scripts = const [],
    Map<String, dynamic>? extra,
  }) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        scripts: scripts,
        uri: uri,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onWebViewCreated,
            extra: extra,
          ),
        ],
      ),
    );
  }

  void onContentSizeChanged({
    Size? previous,
    Size? current,
    Map<String, dynamic>? extra,
  }) {
    _addEvent(WebviewEvent.onContentSizeChanged, {
      'previous': previous.toString(),
      'current': current.toString(),
      ...?extra,
    });
  }

  void onLoadStart({Uri? uri, Map<String, dynamic>? extra}) {
    _addEvent(WebviewEvent.onLoadStart, {'uri': uri.toString(), ...?extra});
  }

  void onLoadStop({Uri? uri, Map<String, dynamic>? extra}) {
    _addEvent(WebviewEvent.onLoadStop, {'uri': uri.toString(), ...?extra});
  }

  void onProgressChanged({int? progress, Map<String, dynamic>? extra}) {
    _addEvent(WebviewEvent.onProgressChanged, {
      'progress': progress,
      ...?extra,
    });
  }

  void onReceivedError({
    Map<String, dynamic>? request,
    Map<String, dynamic>? error,
    Map<String, dynamic>? extra,
  }) {
    _addEvent(WebviewEvent.onReceivedError, {
      'request': request,
      'error': error,
      ...?extra,
    });
  }

  void onConsoleMessage({
    Map<String, dynamic>? message,
    Map<String, dynamic>? extra,
  }) {
    _addEvent(WebviewEvent.onConsoleMessage, {'message': message, ...?extra});
  }

  void shouldOverrideUrlLoading({
    Map<String, dynamic>? action,
    Map<String, dynamic>? extra,
  }) {
    _addEvent(WebviewEvent.shouldOverrideUrlLoading, {
      'action': action,
      ...?extra,
    });
  }

  void onRunJavascript({required String script, Map<String, dynamic>? extra}) {
    _addEvent(WebviewEvent.onRunJavascript, {'script': script, ...?extra});
  }

  void onLoadResource({
    Map<String, dynamic>? resource,
    Map<String, dynamic>? extra,
  }) {
    _addEvent(WebviewEvent.onLoadResource, {'resource': resource, ...?extra});
  }

  void onReceivedHttpError({
    Map<String, dynamic>? request,
    Map<String, dynamic>? response,
    Map<String, dynamic>? extra,
  }) {
    _addEvent(WebviewEvent.onReceivedHttpError, {
      'request': request,
      'response': response,
      ...?extra,
    });
  }
}
