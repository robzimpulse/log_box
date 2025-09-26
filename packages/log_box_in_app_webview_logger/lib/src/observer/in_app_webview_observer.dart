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

  void onTitleChanged({String? title}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onTitleChanged,
            extra: {'title': title},
          ),
        ],
      ),
    );
  }

  void onWebViewCreated({required Uri uri, List<String> scripts = const []}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        scripts: scripts,
        uri: uri,
        events: [WebviewEntryModelLog(event: WebviewEvent.onWebViewCreated)],
      ),
    );
  }

  void onAjaxRequest({Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(event: WebviewEvent.onAjaxRequest, extra: extra),
        ],
      ),
    );
  }

  void onContentSizeChanged({Size? previous, Size? current}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onContentSizeChanged,
            extra: {
              'previous': previous.toString(),
              'current': current.toString(),
            },
          ),
        ],
      ),
    );
  }

  void onLoadStart({Uri? uri}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onLoadStart,
            extra: {'uri': uri.toString()},
          ),
        ],
      ),
    );
  }

  void onLoadStop({Uri? uri}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onLoadStop,
            extra: {'uri': uri.toString()},
          ),
        ],
      ),
    );
  }

  void onProgressChanged({int? progress}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onProgressChanged,
            extra: {'progress': progress},
          ),
        ],
      ),
    );
  }

  void onReceivedError({Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onProgressChanged,
            extra: extra,
          ),
        ],
      ),
    );
  }

  void onConsoleMessage({Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onConsoleMessage,
            extra: extra,
          ),
        ],
      ),
    );
  }

  void shouldOverrideUrlLoading({Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.shouldOverrideUrlLoading,
            extra: extra,
          ),
        ],
      ),
    );
  }

  void onRunJavascript({required String script}) {
    _storage.add(
      log: WebviewEntryModel(
        id: _id,
        events: [
          WebviewEntryModelLog(
            event: WebviewEvent.onRunJavascript,
            extra: {'script': script},
          ),
        ],
      ),
    );
  }
}
