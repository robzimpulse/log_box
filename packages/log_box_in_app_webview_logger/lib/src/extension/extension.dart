import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/src/observer/in_app_webview_observer.dart';
import 'package:log_box_in_app_webview_logger/src/screen/in_app_webview_screen.dart';

typedef SnapshotCallback = void Function(String? url, String? html);

extension InAppWebviewLoggerExtension on LogBox {
  InAppWebviewObserver get inAppWebviewObserver {
    return InAppWebviewObserver(storage: storage);
  }

  Future<void> webview({
    required BuildContext context,
    required Uri uri,
    String? html,
    ThemeData? theme,
    SnapshotCallback? onTapSnapshot,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: routes.putIfAbsent(
          'webview_route',
          () => const RouteSettings(name: 'logbox/webview'),
        ),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: InAppWebviewScreen(
              uri: uri,
              html: html,
              onTapSnapshot: onTapSnapshot,
              observer: inAppWebviewObserver,
            ),
          );
        },
      ),
    );
  }
}

extension CloudFlareNavigationAction on NavigationAction {
  bool isCloudFlare(Uri original) {
    final destination = request.url;
    final header = request.headers;
    final securityOriginHost = targetFrame?.securityOrigin?.host;
    final targetUrl = targetFrame?.request?.url;
    const cloudFlare = 'challenges.cloudflare.com';
    const cloudFlareTokenKey = '__cf_chl_tk';

    if (destination == null) return false;

    return [
      // check if host contains cloud flare challenges
      destination.host == cloudFlare,

      // check if header contains cloud flare challenges
      ...?header?.values.map((e) => e.contains(cloudFlare)),

      // check if security origin host contains cloud flare challenges
      if (securityOriginHost != null) securityOriginHost.contains(cloudFlare),

      // check if target url contains cloudflare challenges token
      if (targetUrl != null)
        targetUrl.queryParameters.keys.contains(cloudFlareTokenKey),
    ].any((e) => e);
  }
}
