import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_navigation_logger/src/enum/enum.dart';
import 'package:log_box_navigation_logger/src/model/navigation_entry_model.dart';
import 'package:mocktail/mocktail.dart';

class MockBuildContext extends Mock implements BuildContext {}

class LogEntryModel extends EntryModel {
  final String message;
  LogEntryModel({required this.message});
  @override
  Map<String, dynamic> toJson() => {};
  @override
  String display() => '';
  @override
  Widget title(BuildContext context) => Container();
  @override
  bool contains(String keyword) => false;
  @override
  EntryModel merge(dynamic other) => this;
  @override
  int tabLength(BuildContext context) => 0;
  @override
  Map<Tab, Widget> tabs(BuildContext context, {String? searchTerm}) => {};
}

void main() {
  final timestamp = DateTime(2023, 1, 1);
  final model = NavigationEntryModel(
    id: '1',
    timestamp: timestamp,
    action: NavigationAction.push,
    route: '/home',
    argument: '{"id": 1}',
    previousRoute: '/login',
    previousArgument: 'null',
  );

  group('NavigationEntryModel', () {
    test('toJson and fromJson', () {
      final json = model.toJson();
      expect(json['action'], 'push');
      expect(json['route'], '/home');
      
      final fromJson = NavigationEntryModel.fromJson(json);
      expect(fromJson.id, model.id);
      expect(fromJson.action, model.action);
    });

    test('tabLength returns 2', () {
      expect(model.tabLength(MockBuildContext()), 2);
    });

    testWidgets('tabs returns Overview and Detail', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          final tabs = model.tabs(context);
          expect(tabs.length, 2);
          expect(tabs.keys.first.text, 'Overview');
          expect(tabs.keys.last.text, 'Detail');
          return Container();
        }),
      ));
    });

    testWidgets('title returns rich text for each action', (tester) async {
      for (final action in NavigationAction.values) {
        final m = NavigationEntryModel(action: action, route: 'test');
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: Builder(builder: (context) => m.title(context))),
        ));
        expect(find.textContaining(action.name.toUpperCase()), findsOneWidget);
      }
    });

    test('contains search logic', () {
      expect(model.contains('home'), isTrue);
      expect(model.contains('login'), isTrue);
      expect(model.contains('id'), isTrue);
      expect(model.contains('missing'), isFalse);
      
      final mNull = NavigationEntryModel(action: NavigationAction.push);
      expect(mNull.contains('any'), isFalse);
    });

    test('display returns Navigation', () {
      expect(model.display(), 'Navigation');
    });

    test('merge updates fields', () {
      final other = NavigationEntryModel(
        action: NavigationAction.pop,
        route: '/new',
        previousRoute: '/old',
      );
      final merged = model.merge(other);
      expect(merged.route, '/new');
      expect(merged.previousRoute, '/old');
    });

    test('merge returns self if other is not NavigationEntryModel', () {
      final entry = LogEntryModel(message: 'test');
      expect(model.merge(entry), model);
    });

    test('copyWith creates new instance with updated fields', () {
      final copy = model.copyWith(route: '/copy');
      expect(copy.route, '/copy');
      expect(copy.id, model.id);
    });
  });
}
