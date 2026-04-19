import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box_in_app_webview_logger/src/observer/in_app_webview_observer.dart';
import 'package:log_box_in_app_webview_logger/src/screen/in_app_webview_screen.dart';
import 'package:log_box_in_app_webview_logger/src/extension/extension.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInAppWebviewObserver extends Mock implements InAppWebviewObserver {}

class MockInAppWebViewController extends Mock
    implements InAppWebViewController {}

class MockNavigationAction extends Mock implements NavigationAction {}

class MockURLRequest extends Mock implements URLRequest {}

class MockWebResourceRequest extends Mock implements WebResourceRequest {}

class MockWebResourceError extends Mock implements WebResourceError {}

class MockWebResourceResponse extends Mock implements WebResourceResponse {}

class MockLoadedResource extends Mock implements LoadedResource {}

class MockConsoleMessage extends Mock implements ConsoleMessage {}

class MockInAppWebViewHitTestResult extends Mock
    implements InAppWebViewHitTestResult {}

class MockInAppWebViewWidget extends StatelessWidget
    with MockPlatformInterfaceMixin
    implements PlatformInAppWebViewWidget {
  @override
  final PlatformInAppWebViewWidgetCreationParams params;
  MockInAppWebViewWidget(this.params, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink(key: params.key);
  }

  @override
  void dispose() {}

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    return controller as T;
  }
}

class FakeInAppWebViewPlatform extends InAppWebViewPlatform {
  FakeInAppWebViewPlatform() : super();

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return MockInAppWebViewWidget(params);
  }
}

void main() {
  late MockInAppWebviewObserver mockObserver;
  late MockInAppWebViewController mockController;

  setUpAll(() {
    final fakePlatform = FakeInAppWebViewPlatform();
    InAppWebViewPlatform.instance = fakePlatform;

    registerFallbackValue(
      PlatformInAppWebViewWidgetCreationParams(
        initialUrlRequest: URLRequest(url: WebUri('https://example.com')),
      ),
    );
    registerFallbackValue(WebUri('https://example.com'));
    registerFallbackValue(URLRequest(url: WebUri('https://example.com')));
  });

  setUp(() {
    mockObserver = MockInAppWebviewObserver();
    mockController = MockInAppWebViewController();

    when(
      () => mockController.evaluateJavascript(source: any(named: 'source')),
    ).thenAnswer((_) async => 'result');
    when(
      () => mockController.loadUrl(urlRequest: any(named: 'urlRequest')),
    ).thenAnswer((_) async {});
    when(
      () => mockController.getUrl(),
    ).thenAnswer((_) async => WebUri('https://example.com'));
    when(
      () => mockController.getHtml(),
    ).thenAnswer((_) async => '<html lang=""></html>');
    when(() => mockController.dispose()).thenAnswer((_) async {});
    when(
      () => mockController.addJavaScriptHandler(
        handlerName: any(named: 'handlerName'),
        callback: any(named: 'callback'),
      ),
    ).thenReturn(null);
  });

  Widget createWidget({
    Uri? uri,
    List<String> scripts = const [],
    String? html,
    SnapshotCallback? onTapSnapshot,
    Map<String, JavaScriptHandlerCallback>? javascriptHandlers,
    Map<String, String>? headers,
    UnmodifiableListView<UserScript>? initialUserScripts,
  }) {
    return MaterialApp(
      home: InAppWebviewScreen(
        uri: uri ?? Uri.parse('https://example.com'),
        observer: mockObserver,
        scripts: scripts,
        html: html,
        onTapSnapshot: onTapSnapshot,
        javascriptHandlers: javascriptHandlers,
        headers: headers,
        initialUserScripts: initialUserScripts,
      ),
    );
  }

  PlatformInAppWebViewWidgetCreationParams getParams(WidgetTester tester) {
    final webView = tester.widget<InAppWebView>(find.byType(InAppWebView));
    return (webView.platform as MockInAppWebViewWidget).params;
  }

  testWidgets('renders WebView and AppBar', (tester) async {
    await tester.pumpWidget(createWidget());
    expect(find.byType(InAppWebviewScreen), findsOneWidget);
    expect(find.text('Web Preview'), findsOneWidget);
  });

  testWidgets('AppBar back button pops context', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => createWidget()),
              ),
              child: const Text('Go'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(find.byType(InAppWebviewScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(InAppWebviewScreen), findsNothing);
  });

  testWidgets('AppBar Refresh button calls loadUrl', (tester) async {
    await tester.pumpWidget(createWidget());

    final params = getParams(tester);
    params.onWebViewCreated?.call(mockController);

    await tester.tap(find.byIcon(Icons.refresh));
    verify(
      () => mockController.loadUrl(urlRequest: any(named: 'urlRequest')),
    ).called(1);
  });

  testWidgets('AppBar Snapshot button calls onTapSnapshot', (tester) async {
    String? snapshotUrl;
    String? snapshotHtml;
    await tester.pumpWidget(
      createWidget(
        onTapSnapshot: (url, html) {
          snapshotUrl = url;
          snapshotHtml = html;
        },
      ),
    );

    final params = getParams(tester);
    params.onWebViewCreated?.call(mockController);

    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pump();

    expect(snapshotUrl, 'https://example.com');
    expect(snapshotHtml, '<html lang=""></html>');
  });

  testWidgets('AppBar JS button opens dialog and runs JS', (tester) async {
    await tester.pumpWidget(createWidget());

    final params = getParams(tester);
    params.onWebViewCreated?.call(mockController);

    await tester.tap(find.byIcon(Icons.javascript));
    await tester.pumpAndSettle();

    expect(find.text('Run JavaScript'), findsOneWidget);

    final textField = find.byType(TextField);
    await tester.tap(textField);
    await tester.pump();

    final EditableText editableText = tester.widget(
      find.descendant(of: textField, matching: find.byType(EditableText)),
    );
    editableText.onSubmitted?.call('console.log("hi")');
    await tester.pumpAndSettle();

    verify(
      () => mockController.evaluateJavascript(source: 'console.log("hi")'),
    ).called(1);
    verify(
      () => mockObserver.onRunJavascript(
        script: 'console.log("hi")',
        extra: {'result': 'result'},
      ),
    ).called(1);

    // Test empty JS does nothing
    await tester.tap(find.byIcon(Icons.javascript), warnIfMissed: false);
    await tester.pumpAndSettle();
    final textFieldEmpty = find.byType(TextField);
    final editableTextEmptyFinder = find.descendant(
      of: textFieldEmpty,
      matching: find.byType(EditableText),
    );
    if (editableTextEmptyFinder.evaluate().isNotEmpty) {
      final EditableText editableTextEmpty = tester.widget(
        editableTextEmptyFinder,
      );
      editableTextEmpty.onSubmitted?.call('');
      await tester.pumpAndSettle();
    }
    verifyNever(() => mockController.evaluateJavascript(source: ''));

    // Test Close button
    await tester.tap(find.byIcon(Icons.javascript), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Run JavaScript'), findsNothing);
  });

  testWidgets('End Drawer displays messages and triggers Divider', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());

    final params = getParams(tester);
    params.onTitleChanged?.call(mockController, 'Title 1');
    params.onTitleChanged?.call(mockController, 'Title 2');

    await tester.tap(find.byIcon(Icons.code));
    await tester.pumpAndSettle();

    expect(find.text('On Title Change: Title 1'), findsOneWidget);
    expect(find.text('On Title Change: Title 2'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('Empty Drawer shows "No messages"', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.byIcon(Icons.code));
    await tester.pumpAndSettle();

    expect(find.text('No messages'), findsOneWidget);
  });

  testWidgets('WebView callbacks trigger observer and logging', (tester) async {
    mockHandler(args) {}
    await tester.pumpWidget(
      createWidget(
        scripts: ['script1', 'script2'],
        javascriptHandlers: {'testHandler': mockHandler},
      ),
    );
    final params = getParams(tester);

    // onWebViewCreated
    params.onWebViewCreated?.call(mockController);
    verify(
      () => mockController.addJavaScriptHandler(
        handlerName: 'testHandler',
        callback: mockHandler,
      ),
    ).called(1);

    // onTitleChanged
    params.onTitleChanged?.call(mockController, 'Title');
    verify(() => mockObserver.onTitleChanged(title: 'Title')).called(1);

    // onContentSizeChanged
    params.onContentSizeChanged?.call(
      mockController,
      const Size(1, 1),
      const Size(0, 0),
    );
    verify(
      () => mockObserver.onContentSizeChanged(
        previous: const Size(0, 0),
        current: const Size(1, 1),
      ),
    ).called(1);

    // onLoadStart
    params.onLoadStart?.call(
      mockController,
      WebUri('https://example.com/start'),
    );
    verify(
      () =>
          mockObserver.onLoadStart(uri: Uri.parse('https://example.com/start')),
    ).called(1);

    // onLoadStop and _runScripts
    params.onLoadStop?.call(mockController, WebUri('https://example.com/stop'));
    verify(
      () => mockObserver.onLoadStop(uri: Uri.parse('https://example.com/stop')),
    ).called(1);

    // First script
    await tester.pump(Duration.zero);
    verify(
      () => mockController.evaluateJavascript(source: 'script1'),
    ).called(1);

    // Second script after delay
    await tester.pump(const Duration(seconds: 1));
    verify(
      () => mockController.evaluateJavascript(source: 'script2'),
    ).called(1);

    // Pump another second to finish the _runScripts loop's last delay if any
    await tester.pump(const Duration(seconds: 1));

    // onProgressChanged
    params.onProgressChanged?.call(mockController, 50);
    verify(() => mockObserver.onProgressChanged(progress: 50)).called(1);

    // onReceivedError
    final mockRequest = MockWebResourceRequest();
    final mockError = MockWebResourceError();
    when(() => mockRequest.url).thenReturn(WebUri('https://err.com'));
    when(() => mockError.description).thenReturn('fail');
    when(() => mockRequest.toMap()).thenReturn({'url': 'https://err.com'});
    when(() => mockError.toMap()).thenReturn({'description': 'fail'});
    params.onReceivedError?.call(mockController, mockRequest, mockError);
    verify(
      () => mockObserver.onReceivedError(
        request: {'url': 'https://err.com'},
        error: {'description': 'fail'},
      ),
    ).called(1);

    // onReceivedHttpError
    final mockHttpResponse = MockWebResourceResponse();
    when(() => mockHttpResponse.reasonPhrase).thenReturn('Not Found');
    when(() => mockHttpResponse.toMap()).thenReturn({'statusCode': 404});
    params.onReceivedHttpError?.call(
      mockController,
      mockRequest,
      mockHttpResponse,
    );
    verify(
      () => mockObserver.onReceivedHttpError(
        request: {'url': 'https://err.com'},
        response: {'statusCode': 404},
      ),
    ).called(1);

    // onLoadResource
    final mockResource = MockLoadedResource();
    when(() => mockResource.url).thenReturn(WebUri('https://res.com'));
    when(() => mockResource.toMap()).thenReturn({'url': 'https://res.com'});
    params.onLoadResource?.call(mockController, mockResource);
    verify(
      () => mockObserver.onLoadResource(resource: {'url': 'https://res.com'}),
    ).called(1);

    // onConsoleMessage
    final mockConsoleMessage = MockConsoleMessage();
    when(() => mockConsoleMessage.message).thenReturn('hello');
    when(() => mockConsoleMessage.toMap()).thenReturn({'message': 'hello'});
    params.onConsoleMessage?.call(mockController, mockConsoleMessage);
    verify(
      () => mockObserver.onConsoleMessage(message: {'message': 'hello'}),
    ).called(1);
  });

  testWidgets('shouldOverrideUrlLoading logic', (tester) async {
    final originalUri = Uri.parse('https://example.com');
    await tester.pumpWidget(createWidget(uri: originalUri));
    final params = getParams(tester);

    // Case 1: Null destination
    final actionNull = NavigationAction(
      request: URLRequest(url: null),
      isForMainFrame: true,
    );
    var result = await params.shouldOverrideUrlLoading?.call(
      mockController,
      actionNull,
    );
    expect(result, NavigationActionPolicy.CANCEL);

    // Case 2: Same origin
    final actionSame = NavigationAction(
      request: URLRequest(url: WebUri('https://example.com/path')),
      isForMainFrame: true,
    );
    result = await params.shouldOverrideUrlLoading?.call(
      mockController,
      actionSame,
    );
    expect(result, NavigationActionPolicy.ALLOW);

    // Case 3: Different origin
    final actionDiff = NavigationAction(
      request: URLRequest(url: WebUri('https://other.com')),
      isForMainFrame: true,
    );
    result = await params.shouldOverrideUrlLoading?.call(
      mockController,
      actionDiff,
    );
    expect(result, NavigationActionPolicy.CANCEL);

    // Case 4: CloudFlare (via host)
    final actionCF = NavigationAction(
      request: URLRequest(url: WebUri('https://challenges.cloudflare.com')),
      isForMainFrame: true,
    );
    result = await params.shouldOverrideUrlLoading?.call(
      mockController,
      actionCF,
    );
    expect(result, NavigationActionPolicy.ALLOW);
  });

  testWidgets('initialData is set when html is provided', (tester) async {
    await tester.pumpWidget(
      createWidget(
        html: '<h1>Hello</h1>',
        headers: {'Authorization': 'Bearer test'},
        initialUserScripts: UnmodifiableListView([
          UserScript(
            source: 'console.log("init")',
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          ),
        ]),
      ),
    );
    final params = getParams(tester);
    expect(params.initialData, isNotNull);
    expect(params.initialData!.data, '<h1>Hello</h1>');
    expect(params.initialUrlRequest?.headers?['Authorization'], 'Bearer test');
    expect(params.initialUserScripts?.length, 1);
  });

  testWidgets('dispose calls controller.dispose', (tester) async {
    await tester.pumpWidget(createWidget());
    final params = getParams(tester);
    params.onWebViewCreated?.call(mockController);

    await tester.pumpWidget(const SizedBox.shrink());
    verify(() => mockController.dispose()).called(1);
  });

  testWidgets('onWebViewCreated with null handlers', (tester) async {
    await tester.pumpWidget(createWidget(javascriptHandlers: null));
    final params = getParams(tester);
    params.onWebViewCreated?.call(mockController);
    verifyNever(
      () => mockController.addJavaScriptHandler(
        handlerName: any(named: 'handlerName'),
        callback: any(named: 'callback'),
      ),
    );
  });
}
