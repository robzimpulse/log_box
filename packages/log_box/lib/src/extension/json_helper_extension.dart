import 'dart:convert';

extension JsonHelperExtension on String {
  bool get isJson {
    try {
      json.decode(this);
      return true;
    } catch (_) {
      return false;
    }
  }

  String get prettify {
    try {
      var decoded = json.decode(this);
      var encoder = const JsonEncoder.withIndent('  ');
      var prettyJson = encoder.convert(decoded);
      return prettyJson;
    } catch (e) {
      return 'N/A-Cannot Parse';
    }
  }
}