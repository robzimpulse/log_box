import 'package:log_box_in_app_webview_logger/src/enum/enum.dart';
import 'package:log_box_in_app_webview_logger/src/model/webview_entry_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box_in_app_webview_logger/src/model/webview_entry_model_log.dart';

void main() {
  final entry1 = WebviewEntryModel(
    id: '1',
    timestamp: DateTime.timestamp(),
    uri: Uri.tryParse('https://www.google.com'),
    loading: false,
    scripts: ['script entry 1'],
    events: [WebviewEntryModelLog(event: WebviewEvent.onWebViewCreated)],
    html: null,
    error: null,
  );

  final entry2 = WebviewEntryModel(
    id: '2',
    timestamp: DateTime.timestamp(),
    uri: Uri.tryParse('https://www.facebook.com'),
    loading: false,
    scripts: ['script entry 2'],
    events: [WebviewEntryModelLog(event: WebviewEvent.onLoadStart)],
    html: null,
    error: null,
  );

  group('Merge Network Entry Model', () {
    late WebviewEntryModel data;

    setUp(() => data = entry1.merge(entry2));

    test('data should have entry 1 id', () => expect(data.id, entry1.id));
    test(
      'data should have entry 1 timestamp',
      () => expect(data.timestamp, entry1.timestamp),
    );
    test('data should have entry 2 uri', () => expect(data.uri, entry2.uri));
    test(
      'data should have entry 2 loading',
      () => expect(data.loading, entry2.loading),
    );
    test('data should have entry 1 and entry 2 scripts', () {
      for (var value in [...entry1.scripts, ...entry2.scripts]) {
        expect(data.scripts.contains(value), true);
      }
    });

    // test(
    //   'data should have entry 1 and entry 2 events',
    //   () => expect(data.events, entry2.events),
    // );
    test('data should have entry 2 html', () => expect(data.html, entry2.html));
    test(
      'data should have entry 2 error',
      () => expect(data.error, entry2.error),
    );
  });
}
