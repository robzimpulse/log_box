import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';

class MockEntryModel extends EntryModel {
  MockEntryModel({super.id, super.timestamp});

  @override
  bool contains(String keyword) => false;

  @override
  String display() => 'Mock';

  @override
  EntryModel merge(other) => this;

  @override
  int tabLength(BuildContext context) => 0;

  @override
  Map<Tab, Widget> tabs(BuildContext context, {String? searchTerm}) => {};

  @override
  Widget title(BuildContext context) => const Text('Mock');

  @override
  Map<String, dynamic> toJson() => {};
}

void main() {
  group('EntryModel', () {
    test('default constructor sets id and timestamp', () {
      final entry = MockEntryModel();
      expect(entry.id, isNotEmpty);
      expect(entry.timestamp, isNotNull);
    });

    test('constructor accepts id and timestamp', () {
      final ts = DateTime(2022);
      final entry = MockEntryModel(id: 'custom', timestamp: ts);
      expect(entry.id, 'custom');
      expect(entry.timestamp, ts);
    });

    testWidgets('subtitle renders timestamp', (tester) async {
      final ts = DateTime(2023, 1, 1, 12, 0);
      final entry = MockEntryModel(timestamp: ts);
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => entry.subtitle(context)),
        ),
      ));

      expect(find.text(ts.toIso8601String()), findsOneWidget);
    });

    test('menus returns empty list by default', () {
      final entry = MockEntryModel();
      expect(entry.menus(FakeBuildContext(), LogBox()), isEmpty);
    });
  });
}

class FakeBuildContext extends Fake implements BuildContext {}
