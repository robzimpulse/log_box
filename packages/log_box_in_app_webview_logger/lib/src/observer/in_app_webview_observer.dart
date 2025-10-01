import 'dart:ui';

import 'package:log_box/log_box.dart';
import 'package:uuid/uuid.dart';

import '../enum/enum.dart';
import '../model/webview_entry_model.dart';

class InAppWebviewObserver {
  final Storage _storage;

  final String _id;

  InAppWebviewObserver({required Storage storage})
    : _storage = storage,
      _id = const Uuid().v4();

  void set({Uri? uri, String? html, Object? error, bool? loading}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        uri: uri,
        html: html,
        error: error,
        loading: loading,
      ),
    );
  }

  void onTitleChanged({String? title, Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onTitleChanged,
            extra: {'title': title, ...?extra},
          ),
        ],
      ),
    );
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
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onContentSizeChanged,
            extra: {
              'previous': previous.toString(),
              'current': current.toString(),
              ...?extra,
            },
          ),
        ],
      ),
    );
  }

  void onLoadStart({Uri? uri, Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onLoadStart,
            extra: {'uri': uri.toString(), ...?extra},
          ),
        ],
      ),
    );
  }

  void onLoadStop({Uri? uri, Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onLoadStop,
            extra: {'uri': uri.toString(), ...?extra},
          ),
        ],
      ),
    );
  }

  void onProgressChanged({int? progress, Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onProgressChanged,
            extra: {'progress': progress, ...?extra},
          ),
        ],
      ),
    );
  }

  void onReceivedError({
    Map<String, dynamic>? request,
    Map<String, dynamic>? error,
    Map<String, dynamic>? extra,
  }) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onProgressChanged,
            extra: {'request': request, 'error': error, ...?extra},
          ),
        ],
      ),
    );
  }

  void onConsoleMessage({
    Map<String, dynamic>? message,
    Map<String, dynamic>? extra,
  }) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onConsoleMessage,
            extra: {'message': message, ...?extra},
          ),
        ],
      ),
    );
  }

  void shouldOverrideUrlLoading({
    Map<String, dynamic>? action,
    Map<String, dynamic>? extra,
  }) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.shouldOverrideUrlLoading,
            extra: {'action': action, ...?extra},
          ),
        ],
      ),
    );
  }

  void onRunJavascript({required String script, Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onRunJavascript,
            extra: {'script': script, ...?extra},
          ),
        ],
      ),
    );
  }

  void onLoadResource({
    Map<String, dynamic>? resource,
    Map<String, dynamic>? extra,
  }) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onLoadResource,
            extra: {'resource': resource, ...?extra},
          ),
        ],
      ),
    );
  }

  void onReceivedHttpError({
    Map<String, dynamic>? request,
    Map<String, dynamic>? response,
    Map<String, dynamic>? extra,
  }) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onReceivedHttpError,
            extra: {'request': request, 'response': response, ...?extra},
          ),
        ],
      ),
    );
  }
}
