
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart' as lb;
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';
import 'package:log_box_in_app_webview_logger/src/screen/in_app_webview_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLogBox extends Mock implements lb.LogBox {}
class MockStorage extends Mock implements lb.Storage {}
class MockBuildContext extends Mock implements BuildContext {}
class MockNavigationAction extends Mock implements NavigationAction {}
class MockURLRequest extends Mock implements URLRequest {}
class MockInAppWebViewHitTestResult extends Mock implements InAppWebViewHitTestResult {}
class MockServerTrustChallenge extends Mock implements ServerTrustChallenge {}
class MockFrameInfo extends Mock implements FrameInfo {}
class MockSecurityOrigin extends Mock implements SecurityOrigin {}

class FakeInAppWebViewPlatform extends InAppWebViewPlatform {
  FakeInAppWebViewPlatform() : super();

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return MockInAppWebViewWidget();
  }
}

class MockInAppWebViewWidget extends Mock 
    with MockPlatformInterfaceMixin 
    implements PlatformInAppWebViewWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  setUpAll(() {
    final fakePlatform = FakeInAppWebViewPlatform();
    InAppWebViewPlatform.instance = fakePlatform;
    
    registerFallbackValue(PlatformInAppWebViewWidgetCreationParams(
      initialUrlRequest: URLRequest(url: WebUri('https://example.com')),
    ));
  });

  group('InAppWebviewLoggerExtension', () {
    late lb.LogBox logBox;
    late lb.Storage storage;

    setUp(() {
      logBox = MockLogBox();
      storage = MockStorage();
      when(() => logBox.storage).thenReturn(storage);
    });

    test('inAppWebviewObserver returns an InAppWebviewObserver', () {
      final observer = logBox.inAppWebviewObserver;
      expect(observer, isA<InAppWebviewObserver>());
    });

    testWidgets('webview pushes InAppWebviewScreen', (tester) async {
      final uri = Uri.parse('https://example.com');
      final routes = <String, RouteSettings>{};
      when(() => logBox.routes).thenReturn(routes);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => logBox.webview(context: context, uri: uri),
                child: const Text('Open WebView'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open WebView'));
      await tester.pumpAndSettle();

      expect(find.byType(InAppWebviewScreen), findsOneWidget);
      expect(routes.containsKey('webview_route'), isTrue);
      expect(routes['webview_route']?.name, 'logbox/webview');
    });

    testWidgets('webview uses provided theme', (tester) async {
      final uri = Uri.parse('https://example.com');
      final routes = <String, RouteSettings>{};
      when(() => logBox.routes).thenReturn(routes);
      final customTheme = ThemeData(primaryColor: Colors.red);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => logBox.webview(
                  context: context,
                  uri: uri,
                  theme: customTheme,
                ),
                child: const Text('Open WebView'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open WebView'));
      await tester.pumpAndSettle();

      final themeWidget = tester.widget<Theme>(find.byType(Theme).last);
      expect(themeWidget.data.primaryColor, customTheme.primaryColor);
    });
  });

  group('CloudFlareNavigationAction', () {
    late MockNavigationAction action;
    late MockURLRequest request;
    final cloudFlare = 'challenges.cloudflare.com';
    final cloudFlareTokenKey = '__cf_chl_tk';

    setUp(() {
      action = MockNavigationAction();
      request = MockURLRequest();
      when(() => action.request).thenReturn(request);
      when(() => action.targetFrame).thenReturn(null);
    });

    test('isCloudFlare returns false when url is null', () {
      when(() => request.url).thenReturn(null);
      expect(action.isCloudFlare(Uri.parse('https://original.com')), isFalse);
    });

    test('isCloudFlare returns true when host is cloudflare', () {
      when(() => request.url).thenReturn(WebUri('https://$cloudFlare'));
      expect(action.isCloudFlare(Uri.parse('https://original.com')), isTrue);
    });

    test('isCloudFlare returns true when headers contain cloudflare', () {
      when(() => request.url).thenReturn(WebUri('https://some-other-host.com'));
      when(() => request.headers).thenReturn({'X-Challenge': 'challenges.cloudflare.com'});
      expect(action.isCloudFlare(Uri.parse('https://original.com')), isTrue);
    });

    test('isCloudFlare returns true when security origin host contains cloudflare', () {
      final targetFrame = MockFrameInfo();
      final securityOrigin = MockSecurityOrigin();
      when(() => request.url).thenReturn(WebUri('https://some-other-host.com'));
      when(() => request.headers).thenReturn(null);
      when(() => action.targetFrame).thenReturn(targetFrame);
      when(() => targetFrame.securityOrigin).thenReturn(securityOrigin);
      when(() => securityOrigin.host).thenReturn(cloudFlare);
      when(() => targetFrame.request).thenReturn(null);

      expect(action.isCloudFlare(Uri.parse('https://original.com')), isTrue);
    });

    test('isCloudFlare returns true when target url contains cloudflare token', () {
      final targetFrame = MockFrameInfo();
      final targetRequest = MockURLRequest();
      when(() => request.url).thenReturn(WebUri('https://some-other-host.com'));
      when(() => request.headers).thenReturn(null);
      when(() => action.targetFrame).thenReturn(targetFrame);
      when(() => targetFrame.securityOrigin).thenReturn(null);
      when(() => targetFrame.request).thenReturn(targetRequest);
      when(() => targetRequest.url).thenReturn(WebUri('https://target.com?$cloudFlareTokenKey=123'));

      expect(action.isCloudFlare(Uri.parse('https://original.com')), isTrue);
    });

    test('isCloudFlare returns false when nothing matches', () {
      when(() => request.url).thenReturn(WebUri('https://clean.com'));
      when(() => request.headers).thenReturn({'Clean': 'Header'});
      expect(action.isCloudFlare(Uri.parse('https://original.com')), isFalse);
    });
  });
}
