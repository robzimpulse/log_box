import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';

class InAppWebviewScreen extends StatefulWidget {
  const InAppWebviewScreen({
    super.key,
    required this.uri,
    required this.observer,
    this.html,
    this.scripts = const [],
    this.headers,
    this.onTapSnapshot,
  });

  final String? html;
  final Uri uri;
  final List<String> scripts;
  final Map<String, String>? headers;
  final SnapshotCallback? onTapSnapshot;
  final InAppWebviewObserver observer;

  @override
  State<InAppWebviewScreen> createState() => _InAppWebviewScreenState();
}

class _InAppWebviewScreenState extends State<InAppWebviewScreen> {
  InAppWebViewController? webViewController;

  final List<String> messages = [];
  final key = UniqueKey();

  void _log(String message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  Widget _drawer(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: Text('No messages'));
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: messages.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(messages[index]),
        );
      },
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: const Text('Web Preview'),
      elevation: 3,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            final controller = TextEditingController();

            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Run JavaScript'),
                  content: TextField(controller: controller),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );

            final script = controller.text;

            controller.dispose();

            if (script.isEmpty) return;

            webViewController?.evaluateJavascript(source: script);
          },
          icon: const Icon(Icons.javascript),
        ),
        IconButton(
          onPressed: () {
            webViewController?.loadUrl(
              urlRequest: URLRequest(url: WebUri.uri(widget.uri)),
            );
          },
          icon: const Icon(Icons.refresh),
        ),
        if (widget.onTapSnapshot != null)
          IconButton(
            onPressed: () async {
              widget.onTapSnapshot?.call(
                (await webViewController?.getUrl()).toString(),
                await webViewController?.getHtml(),
              );
            },
            icon: const Icon(Icons.camera_alt),
          ),
        Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.code),
            );
          },
        ),
      ],
    );
  }

  Widget _webview(BuildContext context) {
    final html = widget.html;
    InAppWebViewInitialData? initialData;
    if (html != null && html.isNotEmpty) {
      initialData = InAppWebViewInitialData(
        baseUrl: WebUri.uri(widget.uri),
        data: html,
      );
    }

    return InAppWebView(
      key: key,
      initialUrlRequest: URLRequest(
        url: WebUri.uri(widget.uri),
        headers: widget.headers,
      ),
      initialData: initialData,
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      initialSettings: InAppWebViewSettings(
        isInspectable: true,
        javaScriptEnabled: true,
        supportZoom: false,
      ),
      onTitleChanged: (_, name) {
        _log('On Title Change: $name');
        widget.observer.onTitleChanged(title: name);
      },
      onContentSizeChanged: (_, curr, prev) {
        _log('onContentSizeChanged: $curr - $prev');
        widget.observer.onContentSizeChanged(previous: prev, current: curr);
      },
      onLoadStart: (_, url) {
        _log('onLoadStart: $url');
        widget.observer.onLoadStart(uri: url?.uriValue);
      },
      onLoadStop: (_, url) {
        _log('onLoadStop: $url');
        widget.observer.onLoadStop(uri: url?.uriValue);
      },
      onProgressChanged: (controller, progress) {
        _log('onProgress: $progress');
        widget.observer.onProgressChanged(progress: progress);
      },
      onReceivedError: (_, request, error) {
        _log('onReceivedError: ${request.url} - ${error.description}');
        widget.observer.onReceivedError(
          request: request.toMap(),
          error: error.toMap(),
        );
      },
      onConsoleMessage: (controller, message) {
        _log('onConsoleMessage: ${message.message}');
        widget.observer.onConsoleMessage(
          message: message.message,
          extra: message.toMap(),
        );
      },
      shouldOverrideUrlLoading: (_, action) async {
        final destination = action.request.url;
        _log('shouldOverrideUrlLoading: $destination');
        widget.observer.shouldOverrideUrlLoading(
          action: action.toMap(),
          extra: {'is_cloudflare': action.isCloudFlare(widget.uri)},
        );

        if (destination == null) {
          return NavigationActionPolicy.CANCEL;
        }

        final isSame = [
          destination.scheme == widget.uri.scheme,
          destination.host == widget.uri.host,
        ].every((e) => e);

        if (action.isCloudFlare(widget.uri)) {
          return NavigationActionPolicy.ALLOW;
        }

        return isSame
            ? NavigationActionPolicy.ALLOW
            : NavigationActionPolicy.CANCEL;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: _drawer(context),
      ),
      appBar: _appBar(context),
      body: SafeArea(child: _webview(context)),
    );
  }
}
