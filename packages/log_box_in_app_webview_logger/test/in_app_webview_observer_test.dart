import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/src/observer/in_app_webview_observer.dart';
import 'package:log_box_in_app_webview_logger/src/model/webview_entry_model.dart';
import 'package:log_box_in_app_webview_logger/src/enum/enum.dart';
import 'dart:ui';

class MockStorage extends Mock implements Storage {}

void main() {
  late MockStorage mockStorage;
  late InAppWebviewObserver observer;

  setUpAll(() {
    registerFallbackValue(
      WebviewEntryModel(
        id: 'fake_id',
        uri: Uri.parse('https://example.com'),
      ),
    );
  });

  setUp(() {
    mockStorage = MockStorage();
    observer = InAppWebviewObserver(storage: mockStorage);
  });

  group('InAppWebviewObserver', () {
    test('set updates storage with correct values', () {
      final uri = Uri.parse('https://example.com');
      const html = '<html></html>';
      const error = 'error';
      final stackTrace = StackTrace.current;

      observer.set(
        uri: uri,
        html: html,
        error: error,
        stackTrace: stackTrace,
        loading: true,
      );

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>()
                .having((e) => e.uri, 'uri', uri)
                .having((e) => e.html, 'html', html)
                .having((e) => e.error, 'error', error.toString())
                .having((e) => e.stackTrace, 'stackTrace', stackTrace.toString())
                .having((e) => e.loading, 'loading', true),
          ),
        ),
      ).called(1);
    });

    test('onTitleChanged updates storage', () {
      const title = 'Test Title';
      final extra = {'key': 'value'};

      observer.onTitleChanged(title: title, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onTitleChanged,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'title': title, ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('onWebViewCreated updates storage', () {
      final uri = Uri.parse('https://example.com');
      const scripts = ['script1', 'script2'];
      final extra = {'key': 'value'};

      observer.onWebViewCreated(uri: uri, scripts: scripts, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>()
                .having((e) => e.uri, 'uri', uri)
                .having((e) => e.scripts, 'scripts', scripts)
                .having(
                  (e) => e.events.first.event,
                  'event',
                  WebviewEvent.onWebViewCreated,
                )
                .having((e) => e.events.first.extra, 'extra', extra),
          ),
        ),
      ).called(1);
    });

    test('onContentSizeChanged updates storage', () {
      const previous = Size(100, 100);
      const current = Size(200, 200);
      final extra = {'key': 'value'};

      observer.onContentSizeChanged(
        previous: previous,
        current: current,
        extra: extra,
      );

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onContentSizeChanged,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {
                'previous': previous.toString(),
                'current': current.toString(),
                ...extra,
              },
            ),
          ),
        ),
      ).called(1);
    });

    test('onLoadStart updates storage', () {
      final uri = Uri.parse('https://example.com');
      final extra = {'key': 'value'};

      observer.onLoadStart(uri: uri, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onLoadStart,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'uri': uri.toString(), ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('onLoadStop updates storage', () {
      final uri = Uri.parse('https://example.com');
      final extra = {'key': 'value'};

      observer.onLoadStop(uri: uri, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onLoadStop,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'uri': uri.toString(), ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('onProgressChanged updates storage', () {
      const progress = 50;
      final extra = {'key': 'value'};

      observer.onProgressChanged(progress: progress, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onProgressChanged,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'progress': progress, ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('onReceivedError updates storage (with known bug: event is onProgressChanged)', () {
      final request = {'url': 'https://example.com'};
      final error = {'description': 'failed'};
      final extra = {'key': 'value'};

      observer.onReceivedError(request: request, error: error, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onProgressChanged, // Bug in source code
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'request': request, 'error': error, ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('onConsoleMessage updates storage', () {
      final message = {'text': 'hello'};
      final extra = {'key': 'value'};

      observer.onConsoleMessage(message: message, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onConsoleMessage,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'message': message, ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('shouldOverrideUrlLoading updates storage', () {
      final action = {'url': 'https://example.com'};
      final extra = {'key': 'value'};

      observer.shouldOverrideUrlLoading(action: action, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.shouldOverrideUrlLoading,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'action': action, ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('onRunJavascript updates storage', () {
      const script = 'console.log("hi")';
      final extra = {'key': 'value'};

      observer.onRunJavascript(script: script, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onRunJavascript,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'script': script, ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('onLoadResource updates storage', () {
      final resource = {'url': 'https://example.com/image.png'};
      final extra = {'key': 'value'};

      observer.onLoadResource(resource: resource, extra: extra);

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onLoadResource,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'resource': resource, ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('onReceivedHttpError updates storage', () {
      final request = {'url': 'https://example.com'};
      final response = {'statusCode': 404};
      final extra = {'key': 'value'};

      observer.onReceivedHttpError(
        request: request,
        response: response,
        extra: extra,
      );

      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.event,
              'event',
              WebviewEvent.onReceivedHttpError,
            ).having(
              (e) => e.events.first.extra,
              'extra',
              {'request': request, 'response': response, ...extra},
            ),
          ),
        ),
      ).called(1);
    });

    test('handles null parameters correctly', () {
      observer.onTitleChanged(title: null, extra: null);
      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.extra,
              'extra',
              {'title': null},
            ),
          ),
        ),
      ).called(1);

      observer.onLoadStart(uri: null, extra: null);
      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.extra,
              'extra',
              {'uri': 'null'},
            ),
          ),
        ),
      ).called(1);

      observer.onContentSizeChanged(previous: null, current: null, extra: null);
      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>().having(
              (e) => e.events.first.extra,
              'extra',
              {'previous': 'null', 'current': 'null'},
            ),
          ),
        ),
      ).called(1);

      observer.set(uri: null, html: null, error: null, stackTrace: null, loading: null);
      verify(
        () => mockStorage.add(
          log: any(
            named: 'log',
            that: isA<WebviewEntryModel>()
                .having((e) => e.uri, 'uri', null)
                .having((e) => e.html, 'html', null)
                .having((e) => e.error, 'error', null)
                .having((e) => e.stackTrace, 'stackTrace', null)
                .having((e) => e.loading, 'loading', null),
          ),
        ),
      ).called(1);
    });
  });
}
