import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/model/log_entry_model.dart';

void main() {
  final entry1 = LogEntryModel(
    id: '1',
    message: 'message entry 1',
    name: 'name entry 1',
    error: Exception('exception entry 1').toString(),
    extra: {'extra1': 'value1'},
    timestamp: DateTime(2023, 1, 1),
  );

  final entry2 = LogEntryModel(
    id: '2',
    message: 'message entry 2',
    name: 'name entry 2',
    error: Exception('exception entry 2').toString(),
    extra: {'extra2': 'value2'},
    timestamp: DateTime(2023, 1, 2),
  );

  group('LogEntryModel', () {
    test('toJson and fromJson', () {
      final json = entry1.toJson();
      expect(json['id'], '1');
      expect(json['message'], 'message entry 1');
      expect(json['name'], 'name entry 1');

      final fromJson = LogEntryModel.fromJson(json);
      expect(fromJson.id, entry1.id);
      expect(fromJson.message, entry1.message);
      expect(fromJson.name, entry1.name);
      expect(fromJson.timestamp, entry1.timestamp);
    });

    test('contains keyword', () {
      expect(entry1.contains('message'), isTrue);
      expect(entry1.contains('name'), isTrue);
      expect(entry1.contains('extra1'), isTrue);
      expect(entry1.contains('value1'), isTrue);
      expect(entry1.contains('nonexistent'), isFalse);
    });

    test('merge', () {
      final merged = entry1.merge(entry2);
      expect(merged.id, entry1.id);
      expect(merged.name, entry2.name);
      expect(merged.message, entry2.message);
      expect(merged.error, entry2.error);
      expect(merged.extra?.containsKey('extra1'), isTrue);
      expect(merged.extra?.containsKey('extra2'), isTrue);

      // Merge with wrong type
      expect(entry1.merge('not a log entry'), entry1);
    });

    test('tabLength', () {
      // Mocking context is hard, but tabLength doesn't use it
      expect(entry1.tabLength(FakeBuildContext()), 3);
    });

    testWidgets('title widget', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => entry1.title(context)),
        ),
      ));

      expect(find.text('name entry 1'), findsOneWidget);
      expect(find.text('message entry 1'), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
    });

    testWidgets('tabs widgets', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            final tabs = entry1.tabs(context);
            return Column(
              children: tabs.values.map((w) => Expanded(child: w)).toList(),
            );
          }),
        ),
      ));

      expect(find.text('Name'), findsAtLeast(1));
      expect(find.text('name entry 1'), findsAtLeast(1));
      expect(find.text('Message'), findsAtLeast(1));
      expect(find.text('message entry 1'), findsAtLeast(1));
      expect(find.text('Extra'), findsAtLeast(1));
      expect(find.text('Error'), findsAtLeast(1));
    });

    test('display and toString', () {
      expect(entry1.display(), 'Log');
      expect(entry1.toString(), 'LogEntryModel(name entry 1,message entry 1)');
    });

    testWidgets('subtitle widget', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => entry1.subtitle(context)),
        ),
      ));
      expect(find.text(entry1.timestamp.toIso8601String()), findsOneWidget);
    });
  });
}

class FakeBuildContext extends Fake implements BuildContext {}
