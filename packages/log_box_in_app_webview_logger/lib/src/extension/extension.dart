import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/src/observer/in_app_webview_observer.dart';
import 'package:log_box_in_app_webview_logger/src/screen/in_app_webview_screen.dart';

extension InAppWebviewLoggerExtension on LogBox {
  InAppWebviewObserver get inAppWebviewObserver {
    return InAppWebviewObserver(storage: storage);
  }

  Future<void> webview({
    required BuildContext context,
    required Uri uri,
    String? html,
    ThemeData? theme,
    void Function(String? url, String? html)? onTapSnapshot,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: routes.putIfAbsent(
          'webview_route',
          () => const RouteSettings(name: 'Log Box Webview'),
        ),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: InAppWebviewScreen(
              uri: uri,
              html: html,
              onTapSnapshot: onTapSnapshot,
            ),
          );
        },
      ),
    );
  }
}
