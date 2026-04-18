import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/extension/json_helper_extension.dart';
import 'package:log_box/src/extension/map_json_extension.dart';
import 'package:log_box/src/extension/copyable_text_extension.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapJsonExtension', () {
    test('json getter returns encoded string', () {
      final map = {'key': 'value'};
      expect(map.json, '{"key":"value"}');
    });

    test('json getter returns null on error', () {
      final map = {'key': double.nan}; // NaN cannot be encoded to JSON
      expect(map.json, isNull);
    });
  });

  group('JsonHelperExtension', () {
    test('isJson returns true for valid json', () {
      expect('{"a":1}'.isJson, isTrue);
      expect('[1,2,3]'.isJson, isTrue);
    });

    test('isJson returns false for invalid json', () {
      expect('not json'.isJson, isFalse);
    });

    test('prettify returns formatted json', () {
      const json = '{"a":1}';
      expect(json.prettify, '{\n  "a": 1\n}');
    });

    test('prettify returns N/A on error', () {
      expect('not json'.prettify, 'N/A-Cannot Parse');
    });
  });

  group('CopyableTextExtension', () {
    String? clipboardData;

    setUp(() {
      // Mock the Clipboard channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            methodCall,
          ) async {
            if (methodCall.method == 'Clipboard.setData') {
              clipboardData = methodCall.arguments['text'];
              return null;
            } else if (methodCall.method == 'Clipboard.getData') {
              return <String, dynamic>{'text': clipboardData};
            }
            return null;
          });
    });

    tearDown(() {
      // Clean up the mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
      clipboardData = null;
    });

    testWidgets('copyToClipboard copies text', (tester) async {
      const text = 'hello world';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => text.copyToClipboard(context: context),
                  child: const Text('Copy'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Copy'));
      await tester.pump(); // Start snackbar animation

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      expect(data?.text, text);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
