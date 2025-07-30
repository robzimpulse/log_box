import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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