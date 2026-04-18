import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/src/extension/extension.dart';
import 'package:log_box_dio_logger/src/model/http_request_model.dart';
import 'package:log_box_dio_logger/src/model/http_response_model.dart';
import 'package:log_box_dio_logger/src/model/network_entry_model.dart';
import 'package:log_box_dio_logger/src/interceptor/log_box_network_interceptor.dart';

void main() {
  group('LogBoxDioLoggerExtension', () {
    test('interceptor should return LogBoxNetworkInterceptor', () {
      final logBox = LogBox();
      expect(logBox.interceptor, isA<LogBoxNetworkInterceptor>());
    });
  });

  group('DurationNetworkExtension', () {
    test('duration should return difference between response and request time', () {
      final now = DateTime.now();
      final requestTime = now;
      final responseTime = now.add(const Duration(seconds: 1));
      
      final entry = NetworkEntryModel(
        request: HttpRequestModel(
          size: 0,
          time: requestTime,
          cookies: {},
          queryParameters: {},
        ),
        response: HttpResponseModel(
          size: 0,
          time: responseTime,
          status: 200,
        ),
      );

      expect(entry.duration, const Duration(seconds: 1));
    });

    test('duration should return zero if request is null', () {
      final entry = NetworkEntryModel(
        request: null,
        response: HttpResponseModel(
          size: 0,
          time: DateTime.now(),
          status: 200,
        ),
      );
      expect(entry.duration, Duration.zero);
    });

    test('duration should return zero if response is null', () {
      final entry = NetworkEntryModel(
        request: HttpRequestModel(
          size: 0,
          time: DateTime.now(),
          cookies: {},
          queryParameters: {},
        ),
        response: null,
      );
      expect(entry.duration, Duration.zero);
    });
  });

  group('CurlCommandExtension', () {
    test('curl should generate correct command for simple GET', () {
      final entry = NetworkEntryModel(
        method: 'GET',
        uri: Uri.parse('https://example.com/api'),
      );
      expect(entry.curl, "curl -X GET 'https://example.com/api'");
    });

    test('curl should include headers', () {
      final entry = NetworkEntryModel(
        method: 'POST',
        uri: Uri.parse('https://example.com/api'),
        request: HttpRequestModel(
          size: 0,
          time: DateTime.now(),
          headers: {'Content-Type': 'application/json', 'Empty': ''},
          cookies: {},
          queryParameters: {},
        ),
      );
      // Note: Empty header value should be excluded based on the logic: if (header.value.toString().isNotEmpty)
      expect(entry.curl, "curl -X POST -H 'Content-Type: application/json' 'https://example.com/api'");
    });

    test('curl should include body', () {
      final entry = NetworkEntryModel(
        method: 'POST',
        uri: Uri.parse('https://example.com/api'),
        request: HttpRequestModel(
          size: 0,
          time: DateTime.now(),
          body: '{"key":"value"}',
          cookies: {},
          queryParameters: {},
        ),
      );
      expect(entry.curl, "curl -X POST --data '{\"key\":\"value\"}' 'https://example.com/api'");
    });

    test('curl should handle multiline body', () {
      final entry = NetworkEntryModel(
        method: 'POST',
        uri: Uri.parse('https://example.com/api'),
        request: HttpRequestModel(
          size: 0,
          time: DateTime.now(),
          body: 'line1\nline2',
          cookies: {},
          queryParameters: {},
        ),
      );
      expect(entry.curl, "curl -X POST --data 'line1\\nline2' 'https://example.com/api'");
    });

    test('curl should include --compressed if gzip encoding is present', () {
      final entry = NetworkEntryModel(
        method: 'GET',
        uri: Uri.parse('https://example.com/api'),
        request: HttpRequestModel(
          size: 0,
          time: DateTime.now(),
          headers: {'accept-encoding': 'gzip'},
          cookies: {},
          queryParameters: {},
        ),
      );
      expect(entry.curl, "curl -X GET -H 'accept-encoding: gzip' --compressed 'https://example.com/api'");
    });

    test('curl should NOT include --compressed if accept-encoding is NOT gzip', () {
      final entry = NetworkEntryModel(
        method: 'GET',
        uri: Uri.parse('https://example.com/api'),
        request: HttpRequestModel(
          size: 0,
          time: DateTime.now(),
          headers: {'accept-encoding': 'br'},
          cookies: {},
          queryParameters: {},
        ),
      );
      expect(entry.curl, isNot(contains('--compressed')));
    });

    test('curl should handle null body and "null" string body', () {
       final entryNull = NetworkEntryModel(
        method: 'GET',
        uri: Uri.parse('https://example.com'),
        request: HttpRequestModel(size: 0, time: DateTime.now(), body: null, cookies: {}, queryParameters: {}),
      );
      expect(entryNull.curl, isNot(contains('--data')));

      final entryNullString = NetworkEntryModel(
        method: 'GET',
        uri: Uri.parse('https://example.com'),
        request: HttpRequestModel(size: 0, time: DateTime.now(), body: 'null', cookies: {}, queryParameters: {}),
      );
      expect(entryNullString.curl, isNot(contains('--data')));
    });
  });
}
