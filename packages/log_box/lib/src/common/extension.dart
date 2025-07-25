import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

extension MapJsonExtension on Map<String, dynamic> {
  String? get json {
    try {
      return jsonEncode(this);
    } catch (e) {
      return null;
    }
  }
}

extension CopyableTextExtension on String {
  void copyToClipboard({
    required BuildContext context,
    String message = 'Copied to clipboard',
  }) async {
    await Clipboard.setData(ClipboardData(text: this));
    if (!context.mounted) return;
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
