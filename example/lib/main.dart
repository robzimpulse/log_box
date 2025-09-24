import 'package:dio/dio.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';

void main() {
  final box = LogBox(capacity: 100);
  final dio = Dio()..interceptors.add(box.interceptor);
  runApp(App(box: box, dio: dio));
}

class App extends StatelessWidget {
  const App({super.key, required this.box, required this.dio});

  final LogBox box;
  final Dio dio;

  ThemeData _themeLight() {
    return FlexThemeData.light(
      scheme: FlexScheme.outerSpace,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedHasBorder: false,
        appBarBackgroundSchemeColor: SchemeColor.primary,
        outlinedButtonRadius: 8,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: _themeLight(),
      routerConfig: GoRouter(
        observers: [box.observer],
        initialLocation: '/',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) {
              return Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: shell.currentIndex,
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: true,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Account',
                    ),
                  ],
                  onTap: (index) {
                    shell.goBranch(
                      index,
                      initialLocation: index == shell.currentIndex,
                    );
                  },
                ),
                body: shell,
                floatingActionButton: FloatingActionButton(
                  onPressed: () => box.dashboard(context: context),
                  child: const Icon(Icons.bug_report),
                ),
              );
            },
            branches: [
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Home')),
                        body: Center(
                          child: TextButton(
                            onPressed: () => context.push('/screen_1'),
                            child: Text('Push to Screen 1'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Search')),
                        body: Center(
                          child: TextButton(
                            onPressed: () => context.push('/screen_1'),
                            child: Text('Push to Screen 1'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(
                    path: '/account',
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Account')),
                        body: Center(
                          child: TextButton(
                            onPressed: () => context.push('/screen_1'),
                            child: Text('Push to Screen 1'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/screen_1',
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: Text('Screen 1')),
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => context.push('/screen_2'),
                        child: Text('Push Screen 2'),
                      ),
                      TextButton(
                        onPressed: () => context.push('/features'),
                        child: Text('Push Screen Feature'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/screen_2',
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: Text('Screen 2')),
                body: Center(
                  child: TextButton(
                    onPressed: () => context.pushReplacement('/screen_1'),
                    child: Text('Push Screen 1'),
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/features',
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: Text('Screen 2')),
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => box.log('testing message'),
                        child: Text('Send Log'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final response = await dio.get(
                            options: Options(responseType: ResponseType.bytes),
                            'https://toonclash.com/wp-content/uploads/2020/03/cropped-22.jpg',
                          );
                          if (!context.mounted) return;
                          final snackbar = SnackBar(
                            content: Text(response.toString()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                        },
                        child: Text('Send Get Request'),
                      ),
                      TextButton(
                        onPressed: () => context.push('/webview'),
                        child: Text('Open Webview'),
                      ),
                      TextButton(
                        onPressed: () {
                          box.webview(
                            context: context,
                            uri: Uri.parse('https://www.scrapingcourse.com/cloudflare-challenge'),
                            onTapSnapshot: (url, html, cookies) {
                              final snackbar = SnackBar(
                                content: Text(url.toString()),
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(snackbar);
                            },
                          );
                        },
                        child: Text('Open Cloudflare Webview'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/webview',
            builder: (context, state) {
              return WebviewScreen(
                uri: Uri.parse('https://www.google.com'),
                observer: box.inAppWebviewObserver,
              );
            },
          ),
        ],
      ),
    );
  }
}

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
      onLoadStart: (_, url) {
        widget.observer.onLoadStart(uri: url?.uriValue);
      },
      onLoadStop: (_, url) {
        widget.observer.onLoadStop(uri: url?.uriValue);
      },
      onProgressChanged: (_, progress) {
        widget.observer.onProgressChanged(progress: progress);
      },
      onReceivedError: (_, request, error) {
        widget.observer.onReceivedError(
          extra: {'error': error.toMap(), 'request': request.toMap()},
        );
      },
      onConsoleMessage: (_, message) async {
        widget.observer.onConsoleMessage(extra: {'message': message.toMap()});
      },
      shouldOverrideUrlLoading: (_, action) async {
        final destination = action.request.url;
        widget.observer.shouldOverrideUrlLoading(
          extra: {'action': action.toMap()},
        );

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
