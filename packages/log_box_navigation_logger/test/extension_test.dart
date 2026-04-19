import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_navigation_logger/src/extension/extension.dart';
import 'package:log_box_navigation_logger/src/model/navigation_entry_model.dart';
import 'package:log_box_navigation_logger/src/enum/enum.dart';
import 'package:log_box_navigation_logger/src/observer/log_box_navigator_observer.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  group('RouteSettingArgumentExtension', () {
    test('argumentString returns null when arguments is null', () {
      const settings = RouteSettings(name: 'test');
      expect(settings.argumentString, isNull);
    });

    test('argumentString returns json string when arguments is not null', () {
      final settings = RouteSettings(name: 'test', arguments: {'id': 123});
      expect(settings.argumentString, jsonEncode({'id': 123}));
    });
  });

  group('LogBoxNavigatorObserverExtension', () {
    late LogBox logBox;
    late MockStorage mockStorage;

    setUp(() {
      mockStorage = MockStorage();
      logBox = LogBox(storage: mockStorage);
      
      registerFallbackValue(NavigationEntryModel(action: NavigationAction.push));
    });

    test('observer returns LogBoxNavigatorObserver', () {
      final observer = logBox.observer;
      expect(observer, isInstanceOf<LogBoxNavigatorObserver>());
    });

    test('observer onEvent skips when route is in known routes', () {
      logBox.routes['test'] = const RouteSettings(name: 'test');
      final observer = logBox.observer as LogBoxNavigatorObserver;
      
      final event = NavigationEntryModel(
        action: NavigationAction.push,
        route: 'test',
      );

      observer.onEvent(event);

      verifyNever(() => mockStorage.add(log: any(named: 'log')));
    });

    test('observer onEvent skips when previousRoute is in known routes', () {
      logBox.routes['prev'] = const RouteSettings(name: 'prev');
      final observer = logBox.observer as LogBoxNavigatorObserver;
      
      final event = NavigationEntryModel(
        action: NavigationAction.push,
        route: 'new',
        previousRoute: 'prev',
      );

      observer.onEvent(event);

      verifyNever(() => mockStorage.add(log: any(named: 'log')));
    });

    test('observer onEvent adds to storage when not skipped', () {
      final observer = logBox.observer as LogBoxNavigatorObserver;
      
      final event = NavigationEntryModel(
        action: NavigationAction.push,
        route: 'new_route',
      );

      when(() => mockStorage.add(log: any(named: 'log'))).thenReturn(null);

      observer.onEvent(event);

      verify(() => mockStorage.add(log: any(named: 'log'))).called(1);
    });

    test('observer onEvent uses and updates _prevRouteName', () {
      final observer = logBox.observer as LogBoxNavigatorObserver;
      
      // First event to set _prevRouteName
      final event1 = NavigationEntryModel(
        action: NavigationAction.push,
        route: 'route1',
      );
      when(() => mockStorage.add(log: any(named: 'log'))).thenReturn(null);
      observer.onEvent(event1);

      // Second event to check if it uses _prevRouteName when previousRoute is null
      final event2 = NavigationEntryModel(
        action: NavigationAction.push,
        route: 'route2',
        previousRoute: null,
      );
      
      observer.onEvent(event2);

      final captured = verify(() => mockStorage.add(log: captureAny(named: 'log'))).captured;
      final capturedLog = captured.last as NavigationEntryModel;
      expect(capturedLog.previousRoute, 'route1');
    });
  });
}
