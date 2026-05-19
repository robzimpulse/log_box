import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/src/interceptor/log_box_network_interceptor.dart';
import 'package:log_box_dio_logger/src/model/network_entry_model.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockResponseInterceptorHandler extends Mock implements ResponseInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

class RequestOptionsFake extends Fake implements RequestOptions {}
class ResponseFake extends Fake implements Response {}
class DioExceptionFake extends Fake implements DioException {}

void main() {
  late LogBoxNetworkInterceptor interceptor;
  late MockStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(NetworkEntryModel());
    registerFallbackValue(RequestOptionsFake());
    registerFallbackValue(ResponseFake());
    registerFallbackValue(DioExceptionFake());
  });

  setUp(() {
    mockStorage = MockStorage();
    interceptor = LogBoxNetworkInterceptor(storage: mockStorage);
    when(() => mockStorage.add(log: any(named: 'log'))).thenAnswer((_) async {});
  });

  group('onRequest', () {
    test('captures simple GET request (data is null)', () {
      final options = RequestOptions(path: 'https://example.com');
      final handler = MockRequestInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onRequest(options, handler);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.request?.size, 0);
      expect(captured.request?.body, isNull);
    });

    test('captures POST request with Map data (not FormData)', () {
      final data = {'key': 'value'};
      final options = RequestOptions(
        path: 'https://example.com',
        method: 'POST',
        data: data,
      );
      final handler = MockRequestInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onRequest(options, handler);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.request?.size, utf8.encode(data.toString()).length);
      expect(captured.request?.body, jsonEncode(data));
    });

    test('captures FormData with fields and files', () {
      final formData = FormData.fromMap({
        'field1': 'value1',
        'file1': MultipartFile.fromBytes([1, 2, 3], filename: 'test.txt'),
      });
      final options = RequestOptions(
        path: 'https://example.com',
        method: 'POST',
        data: formData,
      );
      final handler = MockRequestInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onRequest(options, handler);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.request?.formDataFields?.length, 1);
      expect(captured.request?.formDataFiles?.length, 1);
      expect(captured.request?.body, jsonEncode({'field1': 'value1'}));
    });

    test('captures FormData with only files (hits _rawJson branch)', () {
      final formData = FormData.fromMap({
        'file1': MultipartFile.fromBytes([1, 2, 3], filename: 'test.txt'),
      });
      final options = RequestOptions(
        path: 'https://example.com',
        method: 'POST',
        data: formData,
      );
      final handler = MockRequestInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onRequest(options, handler);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.request?.formDataFields, isNull);
      expect(captured.request?.body, contains('FormData'));
    });
  });

  group('onResponse', () {
    test('captures ResponseBody stream and handles completion', () async {
      final bytes = utf8.encode('hello');
      final stream = Stream.value(Uint8List.fromList(bytes));
      final responseBody = ResponseBody(stream, 200);
      final response = Response(
        requestOptions: RequestOptions(path: 'https://example.com'),
        data: responseBody,
        statusCode: 200,
        headers: Headers(),
      );
      final handler = MockResponseInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onResponse(response, handler);

      final capturedResponse = verify(() => handler.next(captureAny())).captured.first as Response;
      final newResponseBody = capturedResponse.data as ResponseBody;
      
      // Consume the stream to trigger whenComplete in the interceptor
      await newResponseBody.stream.toList();

      // Wait for the async storage.add inside whenComplete
      await untilCalled(() => mockStorage.add(log: any(named: 'log')));

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.response?.body, jsonEncode(bytes));
      expect(captured.response?.size, bytes.length);
    });

    test('captures non-ResponseBody with data', () {
      final data = {'a': 1};
      final response = Response(
        requestOptions: RequestOptions(path: 'https://example.com'),
        data: data,
        statusCode: 200,
        headers: Headers(),
      );
      final handler = MockResponseInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onResponse(response, handler);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.response?.body, jsonEncode(data));
      expect(captured.response?.size, utf8.encode(data.toString()).length);
    });

    test('captures non-ResponseBody with null data', () {
      final response = Response(
        requestOptions: RequestOptions(path: 'https://example.com'),
        data: null,
        statusCode: 200,
        headers: Headers(),
      );
      final handler = MockResponseInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onResponse(response, handler);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.response?.body, isNull);
      expect(captured.response?.size, 0);
    });
  });

  group('onError', () {
    test('captures DioException with response', () {
      final options = RequestOptions(path: 'https://example.com');
      final error = DioException(
        requestOptions: options,
        error: 'err',
        response: Response(requestOptions: options, data: 'error body', statusCode: 500, headers: Headers()),
      );
      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onError(error, handler);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.response?.body, 'error body');
    });

    test('captures DioException without response', () {
      final options = RequestOptions(path: 'https://example.com');
      final error = DioException(
        requestOptions: options,
        error: 'err',
      );
      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(any())).thenReturn(null);

      interceptor.onError(error, handler);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.first as NetworkEntryModel;
      expect(captured.response?.status, isNull);
      expect(captured.response?.body, isNull);
    });
  });

  group('_rawJson helper', () {
    test('Map<String, dynamic>', () {
      final data = <String, dynamic>{'a': 1};
      final response = Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: 200, headers: Headers());
      interceptor.onResponse(response, MockResponseInterceptorHandler());
      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.last as NetworkEntryModel;
      expect(captured.response?.body, jsonEncode(data));
    });

    test('empty Map<String, dynamic>', () {
      final data = <String, dynamic>{};
      final response = Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: 200, headers: Headers());
      interceptor.onResponse(response, MockResponseInterceptorHandler());
      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.last as NetworkEntryModel;
      expect(captured.response?.body, isNull);
    });

    test('List<dynamic>', () {
      final data = [1, 2];
      final response = Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: 200, headers: Headers());
      interceptor.onResponse(response, MockResponseInterceptorHandler());
      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.last as NetworkEntryModel;
      expect(captured.response?.body, jsonEncode(data));
    });

    test('empty List<dynamic>', () {
      final data = <dynamic>[];
      final response = Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: 200, headers: Headers());
      interceptor.onResponse(response, MockResponseInterceptorHandler());
      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.last as NetworkEntryModel;
      expect(captured.response?.body, isNull);
    });

    test('non-empty String', () {
      final data = 'hello';
      final response = Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: 200, headers: Headers());
      interceptor.onResponse(response, MockResponseInterceptorHandler());
      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.last as NetworkEntryModel;
      expect(captured.response?.body, 'hello');
    });

    test('empty String', () {
      final data = '';
      final response = Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: 200, headers: Headers());
      interceptor.onResponse(response, MockResponseInterceptorHandler());
      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.last as NetworkEntryModel;
      expect(captured.response?.body, isNull);
    });

    test('other type (int)', () {
      final data = 123;
      final response = Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: 200, headers: Headers());
      interceptor.onResponse(response, MockResponseInterceptorHandler());
      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.last as NetworkEntryModel;
      expect(captured.response?.body, '123');
    });
    
    test('Map<dynamic, dynamic> falls to toString()', () {
      final data = {1: 2};
      final response = Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: 200, headers: Headers());
      interceptor.onResponse(response, MockResponseInterceptorHandler());
      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured.last as NetworkEntryModel;
      expect(captured.response?.body, '{1: 2}');
    });
  });
}
