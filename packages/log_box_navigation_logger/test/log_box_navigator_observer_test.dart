import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box_navigation_logger/src/enum/enum.dart';
import 'package:log_box_navigation_logger/src/model/navigation_entry_model.dart';
import 'package:log_box_navigation_logger/src/observer/log_box_navigator_observer.dart';
import 'package:mocktail/mocktail.dart';

class MockRoute extends Mock implements Route {}
class MockRouteSettings extends Mock implements RouteSettings {}

void main() {
  late List<NavigationEntryModel> events;
  late LogBoxNavigatorObserver observer;

  setUp(() {
    events = [];
    observer = LogBoxNavigatorObserver(
      onEvent: (event) => events.add(event),
    );
    
    registerFallbackValue(NavigationAction.push);
  });

  group('LogBoxNavigatorObserver', () {
    test('didPush triggers onEvent', () {
      final route = MockRoute();
      final prevRoute = MockRoute();
      final settings = const RouteSettings(name: 'new', arguments: 'arg');
      final prevSettings = const RouteSettings(name: 'old', arguments: 'old_arg');
      
      when(() => route.settings).thenReturn(settings);
      when(() => prevRoute.settings).thenReturn(prevSettings);

      observer.didPush(route, prevRoute);

      expect(events.length, 1);
      expect(events.first.action, NavigationAction.push);
      expect(events.first.route, 'new');
      expect(events.first.argument, '"arg"');
      expect(events.first.previousRoute, 'old');
      expect(events.first.previousArgument, '"old_arg"');
    });

    test('didPop triggers onEvent', () {
      final route = MockRoute();
      final prevRoute = MockRoute();
      
      when(() => route.settings).thenReturn(const RouteSettings(name: 'pop_route'));
      when(() => prevRoute.settings).thenReturn(const RouteSettings(name: 'prev_route'));

      observer.didPop(route, prevRoute);

      expect(events.length, 1);
      expect(events.first.action, NavigationAction.pop);
      expect(events.first.route, 'pop_route');
      expect(events.first.previousRoute, 'prev_route');
    });

    test('didRemove triggers onEvent', () {
      final route = MockRoute();
      final prevRoute = MockRoute();
      
      when(() => route.settings).thenReturn(const RouteSettings(name: 'removed'));
      when(() => prevRoute.settings).thenReturn(const RouteSettings(name: 'prev'));

      observer.didRemove(route, prevRoute);

      expect(events.length, 1);
      expect(events.first.action, NavigationAction.remove);
      expect(events.first.route, 'removed');
      expect(events.first.previousRoute, 'prev');
    });

    test('didReplace triggers onEvent', () {
      final newRoute = MockRoute();
      final oldRoute = MockRoute();
      
      when(() => newRoute.settings).thenReturn(const RouteSettings(name: 'new_replace'));
      when(() => oldRoute.settings).thenReturn(const RouteSettings(name: 'old_replace'));

      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);

      expect(events.length, 1);
      expect(events.first.action, NavigationAction.replace);
      expect(events.first.route, 'new_replace');
      expect(events.first.previousRoute, 'old_replace');
    });
    
    test('didReplace with null routes', () {
      observer.didReplace(newRoute: null, oldRoute: null);
      
      expect(events.length, 1);
      expect(events.first.action, NavigationAction.replace);
      expect(events.first.route, isNull);
      expect(events.first.previousRoute, isNull);
    });
  });
}
