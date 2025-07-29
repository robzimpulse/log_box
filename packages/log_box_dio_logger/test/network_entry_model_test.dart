import 'package:flutter_test/flutter_test.dart';
import 'package:log_box_dio_logger/src/model/http_error_model.dart';
import 'package:log_box_dio_logger/src/model/http_request_model.dart';
import 'package:log_box_dio_logger/src/model/http_response_model.dart';
import 'package:log_box_dio_logger/src/model/network_entry_model.dart';

void main() {
  final entry1 = NetworkEntryModel(
    id: '1',
    timestamp: DateTime.timestamp(),
    client: 'entry 1',
    loading: false,
    method: 'entry 1',
    uri: Uri.tryParse('https://entry1.com'),
    request: null,
    response: null,
    error: null,
  );

  final entry2 = NetworkEntryModel(
    id: '2',
    timestamp: DateTime.timestamp(),
    client: 'entry 2',
    loading: true,
    method: 'entry 2',
    uri: Uri.tryParse('https://entry2.com'),
    request: HttpRequestModel.create(),
    response: HttpResponseModel.create(),
    error: HttpErrorModel(),
  );

  group('Merge Network Entry Model', () {
    late NetworkEntryModel data;

    setUp(() => data = entry1.merge(entry2));

    test('data should have entry 1 id', () => expect(data.id, entry1.id));
    test(
      'data should have entry 1 timestamp',
      () => expect(data.timestamp, entry1.timestamp),
    );
    test(
      'data should have entry 1 client',
      () => expect(data.client, entry1.client),
    );
    test(
      'data should have entry 2 loading',
      () => expect(data.loading, entry2.loading),
    );
    test(
      'data should have entry 1 method',
      () => expect(data.method, entry1.method),
    );
    test('data should have entry 1 uri', () => expect(data.uri, entry1.uri));

    test(
      'data should have entry 2 response',
      () => expect(data.response, entry2.response),
    );
    test(
      'data should have entry 2 request',
      () => expect(data.request, entry2.request),
    );
    test(
      'data should have entry 2 error',
      () => expect(data.error, entry2.error),
    );
  });
}
