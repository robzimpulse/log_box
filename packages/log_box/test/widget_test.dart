import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box/src/widget/human_readable_widget.dart';
import 'package:log_box/src/widget/searchable_text_widget.dart';
import 'package:flutter/services.dart';

void main() {
  group('HighlightedTextWidget', () {
    testWidgets('renders simple text without search term', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HighlightedTextWidget(text: 'Hello World'),
        ),
      ));
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(SelectableText), findsNothing);
    });

    testWidgets('renders highlighted text with search term', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HighlightedTextWidget(text: 'Hello World', searchTerm: 'Hello'),
        ),
      ));
      expect(find.byType(SelectableText), findsOneWidget);
      // SelectableText with rich text is harder to find by text if it's split
      // but we can check if it exists.
    });

    testWidgets('handles empty search term', (tester) async {
       await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HighlightedTextWidget(text: 'Hello World', searchTerm: ''),
        ),
      ));
      expect(find.byType(SelectableText), findsOneWidget);
    });
  });

  group('HumanReadableWidget', () {
    testWidgets('renders name and value', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HumanReadableWidget(name: 'Key', value: 'Value'),
        ),
      ));
      expect(find.text('Key'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
    });

    testWidgets('renders image if provided', (tester) async {
      final image = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82
      ]);
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: HumanReadableWidget(name: 'Image', image: image),
          ),
        ));
      });
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders nothing if value and image are null', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HumanReadableWidget(name: 'Empty'),
        ),
      ));
      expect(find.byType(Padding), findsNothing);
    });

    testWidgets('copy button works', (tester) async {
       String? clipboardData;
       TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (methodCall) async {
            if (methodCall.method == 'Clipboard.setData') {
              clipboardData = methodCall.arguments['text'];
              return null;
            }
            return null;
          });

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HumanReadableWidget(name: 'CopyMe', value: 'secret'),
        ),
      ));

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();
      expect(clipboardData, 'secret');
      expect(find.byType(SnackBar), findsOneWidget);
    });
    
    testWidgets('renders prettified json', (tester) async {
      const json = '{"a":1}';
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HumanReadableWidget(name: 'JSON', value: json),
        ),
      ));
      // Prettified version contains spaces and newlines
      expect(find.textContaining('"a": 1'), findsOneWidget);
    });
  });
}
