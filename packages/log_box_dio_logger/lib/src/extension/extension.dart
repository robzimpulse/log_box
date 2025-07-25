import 'package:dio/dio.dart';
import 'package:log_box/log_box.dart';
import 'package:universal_io/io.dart';

import '../interceptor/log_box_network_interceptor.dart';
import '../model/network_entry_model.dart';

extension LogBoxDioLoggerExtension on LogBox {
  Interceptor get interceptor => LogBoxNetworkInterceptor(storage: storage);
}

extension DurationNetworkExtension on NetworkEntryModel {
  Duration get duration {
    final request = this.request;
    final response = this.response;
    if (request != null && response != null) {
      return response.time.difference(request.time);
    }
    return Duration.zero;
  }
}

extension CurlCommandExtension on NetworkEntryModel {
  String get curl {
    final String? body = request?.body?.toString();
    final encodingKey = HttpHeaders.acceptEncodingHeader.toLowerCase();
    final compressed = request?.headers?.entries.where(
      (entry) => [
        entry.key.toLowerCase() == encodingKey,
        entry.value == 'gzip',
      ].every((e) => e),
    );

    return [
      'curl',
      '-X $method',
      for (final header in {...?request?.headers?.entries})
        if (header.value.toString().isNotEmpty)
          '-H \'${header.key}: ${header.value.toString()}\'',
      if (body != null && body.isNotEmpty && body != 'null')
        '--data \'${body.replaceAll('\n', r'\n')}\'',
      if (compressed?.isNotEmpty == true) '--compressed',
      '\'${uri.toString()}\'',
    ].join(' ');
  }
}
