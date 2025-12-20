import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:log_box/log_box.dart';
import 'package:rxdart/rxdart.dart';

import '../model/form_data_field_model.dart';
import '../model/form_data_file_model.dart';
import '../model/http_error_model.dart';
import '../model/http_request_model.dart';
import '../model/http_response_model.dart';
import '../model/network_entry_model.dart';

class LogBoxNetworkInterceptor extends Interceptor {
  final Storage _storage;

  LogBoxNetworkInterceptor({required Storage storage}) : _storage = storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final dynamic data = options.data;
    final fields = <FormDataFieldModel>[];
    final fieldsJson = <String, String>{};
    final files = <FormDataFileModel>[];

    if (data is FormData) {
      if (data.fields.isNotEmpty) {
        for (var entry in data.fields) {
          fields.add(FormDataFieldModel(name: entry.key, value: entry.value));
          fieldsJson[entry.key] = entry.value;
        }
      }

      if (data.files.isNotEmpty) {
        for (final entry in data.files) {
          files.add(
            FormDataFileModel(
              fileName: entry.value.filename,
              contentType: entry.value.contentType.toString(),
              length: entry.value.length,
            ),
          );
        }
      }
    }

    _storage.add(
      log: NetworkEntryModel(
        id: options.hashCode.toString(),
        client: 'Dio',
        method: options.method,
        uri: options.uri,
        request: HttpRequestModel.create(
          queryParameters: options.queryParameters,
          headers: options.headers,
          contentType: options.contentType.toString(),
          size: data == null ? 0 : utf8.encode(data.toString()).length,
          body:
              fieldsJson.isNotEmpty
                  ? jsonEncode(fieldsJson)
                  : data is FormData
                  ? _rawJson(data)
                  : null,
          formDataFiles: files.isEmpty ? null : files,
          formDataFields: fields.isEmpty ? null : fields,
        ),
      ),
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    if (data is ResponseBody) {
      final replay = ReplaySubject<Uint8List>();

      replay.addStream(data.stream).whenComplete(() {
        final interceptedData = replay.values.expand((e) => e);

        _storage.add(
          log: NetworkEntryModel(
            id: response.requestOptions.hashCode.toString(),
            loading: false,
            response: HttpResponseModel.create(
              status: response.statusCode,
              headers: response.headers.map,
              body: _rawJson([...interceptedData]),
              size: interceptedData.length,
            ),
          ),
        );

        return replay.close();
      });

      super.onResponse(
        Response(
          data: ResponseBody(
            replay.stream,
            data.statusCode,
            isRedirect: data.isRedirect,
            redirects: data.redirects,
            headers: data.headers,
            onClose: () => replay.close(),
          ),
          requestOptions: response.requestOptions,
          statusCode: response.statusCode,
          isRedirect: response.isRedirect,
          redirects: response.redirects,
          headers: response.headers,
        ),
        handler,
      );
    } else {
      _storage.add(
        log: NetworkEntryModel(
          id: response.requestOptions.hashCode.toString(),
          loading: false,
          response: HttpResponseModel.create(
            status: response.statusCode,
            headers: response.headers.map,
            body: _rawJson(data),
            size: data == null ? 0 : utf8.encode(data.toString()).length,
          ),
        ),
      );

      super.onResponse(response, handler);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final dynamic data = response?.data;

    _storage.add(
      log: NetworkEntryModel(
        id: err.requestOptions.hashCode.toString(),
        loading: false,
        error: HttpErrorModel(
          error: err.toString(),
          stackTrace: err.stackTrace.toString(),
        ),
        response: HttpResponseModel.create(
          status: response?.statusCode,
          headers: err.response?.headers.map,
          size: data == null ? 0 : utf8.encode(data.toString()).length,
          body: _rawJson(data),
        ),
      ),
    );

    super.onError(err, handler);
  }

  String? _rawJson(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      return (data.isNotEmpty) ? json.encode(data) : null;
    } else if (data is List<dynamic>) {
      return (data.isNotEmpty) ? json.encode(data) : null;
    }
    if (data is String) {
      return data.isNotEmpty ? data : null;
    } else {
      return data.toString();
    }
  }
}
