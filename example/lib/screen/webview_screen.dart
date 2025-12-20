import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key, required this.uri, required this.observer});

  final Uri uri;
  final InAppWebviewObserver observer;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? webViewController;

  final key = UniqueKey();

  @override
  void initState() {
    widget.observer.set(loading: true);
    super.initState();
  }

  @override
  void dispose() {
    widget.observer.set(loading: false);
    webViewController = null;
    super.dispose();
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
      ],
    );
  }

  Widget _webview(BuildContext context) {
    return InAppWebView(
      key: key,
      initialUrlRequest: URLRequest(url: WebUri.uri(widget.uri)),
      onWebViewCreated: (controller) {
        webViewController = controller;
        widget.observer.onWebViewCreated(uri: widget.uri);
      },
      initialSettings: InAppWebViewSettings(
        isInspectable: true,
        javaScriptEnabled: true,
        supportZoom: false,
      ),
      onContentSizeChanged: (_, curr, prev) {
        widget.observer.onContentSizeChanged(previous: prev, current: curr);
      },
      onTitleChanged: (_, title) {
        widget.observer.onTitleChanged(title: title);
      },
      onLoadStart: (_, url) {
        widget.observer.onLoadStart(uri: url?.uriValue);
      },
      onLoadStop: (controller, url) async {
        widget.observer.onLoadStop(uri: url?.uriValue);
        await controller.injectJavascriptFileFromUrl(
          urlFile: WebUri('https://code.jquery.com/jquery-3.7.1.min.js'),
          scriptHtmlTagAttributes: ScriptHtmlTagAttributes(
            id: 'jquery',
            onLoad: () async {
              controller.evaluateJavascript(
                source: '''
              \$.ajax(
    {
        url: "https://toonclash.com/wp-admin/admin-ajax.php",
        method: "POST",
        data: "action=wp_manga_signin&login=asdasd&pass=adsadasd&rememberme=forever",
        success: function (data, textStatus, jqXHR) {
            console.log(data);
            alert(data);
        },
        error: function (jqXHR, textStatus, errorThrown){
              alert(textStatus);
              console.log(textStatus);
            }
        });''',
              );

              print("jQuery loaded and ready to be used!");
            },
            onError: () {
              print("jQuery not available! Some error occurred.");
            },
          ),
        );
      },
      onProgressChanged: (_, progress) {
        widget.observer.onProgressChanged(progress: progress);
      },
      onReceivedError: (_, request, error) {
        widget.observer.onReceivedError(
          request: request.toMap(),
          error: error.toMap(),
        );
      },
      onReceivedHttpError: (_, request, response) {
        widget.observer.onReceivedHttpError(
          request: request.toMap(),
          response: response.toMap(),
        );
      },
      onLoadResource: (_, resource) {
        widget.observer.onLoadResource(resource: resource.toMap());
      },
      onConsoleMessage: (_, message) {
        widget.observer.onConsoleMessage(message: message.toMap());
      },
      shouldOverrideUrlLoading: (_, action) async {
        final destination = action.request.url;
        widget.observer.shouldOverrideUrlLoading(action: action.toMap());

        if (destination == null) {
          return NavigationActionPolicy.CANCEL;
        }

        final isSame = [
          destination.scheme == widget.uri.scheme,
          destination.host == widget.uri.host,
        ].every((e) => e);

        return action.isCloudFlare(widget.uri)
            ? NavigationActionPolicy.ALLOW
            : isSame
            ? NavigationActionPolicy.ALLOW
            : NavigationActionPolicy.CANCEL;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(child: _webview(context)),
    );
  }
}
