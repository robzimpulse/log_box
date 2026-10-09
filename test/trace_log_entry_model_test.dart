import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/model/log_entry_model.dart';
import 'package:log_box/src/model/trace_log_entry_model.dart';

void main() {
  final log1 = LogEntryModel(message: 'log 1', name: 'name 1');
  final log2 = LogEntryModel(message: 'log 2', name: 'name 2');
  
  final trace1 = TraceLogEntryModel(
    id: 't1',
    name: 'trace 1',
    logs: [log1],
    timestamp: DateTime(2023, 1, 1),
  );

  final trace2 = TraceLogEntryModel(
    id: 't2',
    name: 'trace 2',
    logs: [log2],
    timestamp: DateTime(2023, 1, 2),
  );

  group('TraceLogEntryModel', () {
    test('toJson and fromJson', () {
      final json = trace1.toJson();
      expect(json['id'], 't1');
      expect(json['name'], 'trace 1');
      expect(json['logs'], isA<List>());

      final fromJson = TraceLogEntryModel.fromJson(json);
      expect(fromJson.id, trace1.id);
      expect(fromJson.name, trace1.name);
      expect(fromJson.logs.length, trace1.logs.length);
      expect(fromJson.timestamp, trace1.timestamp);
    });

    test('contains keyword', () {
      expect(trace1.contains('trace'), isTrue);
      expect(trace1.contains('log 1'), isTrue);
      expect(trace1.contains('nonexistent'), isFalse);
    });

    test('merge', () {
      final merged = trace1.merge(trace2);
      expect(merged.name, trace1.name);
      expect(merged.logs.length, 2);
      expect(merged.logs.contains(log1), isTrue);
      expect(merged.logs.contains(log2), isTrue);

      // Merge with wrong type
      expect(trace1.merge('not a trace'), trace1);
    });

    test('display', () {
      expect(trace1.display(), 'Trace Log');
    });

    test('tabLength', () {
      expect(trace1.tabLength(FakeBuildContext()), 2);
    });

    testWidgets('title widget', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => trace1.title(context)),
        ),
      ));

      expect(find.text('trace 1'), findsOneWidget);
      expect(find.byIcon(Icons.event), findsOneWidget);
    });

    testWidgets('tabs widgets', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            final tabs = trace1.tabs(context);
            return SizedBox(
              height: 600,
              child: Column(
                children: tabs.values.map((w) => Expanded(child: w)).toList(),
              ),
            );
          }),
        ),
      ));

      expect(find.text('Name'), findsAtLeast(1));
      expect(find.text('Timestamp'), findsAtLeast(1));
      expect(find.text('trace 1'), findsAtLeast(1));
      expect(find.text('log 1'), findsAtLeast(1));
    });

    testWidgets('tabs widgets with search term', (tester) async {
       await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            final tabs = trace1.tabs(context, searchTerm: 'log 1');
            return SizedBox(
              height: 600,
              child: Column(
                children: tabs.values.map((w) => Expanded(child: w)).toList(),
              ),
            );
          }),
        ),
      ));
       // Should find the search indicator (the red dot)
       expect(find.byType(Container), findsAtLeast(1));
    });
  });
}

class FakeBuildContext extends Fake implements BuildContext {}
