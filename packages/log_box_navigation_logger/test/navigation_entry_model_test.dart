import 'package:flutter_test/flutter_test.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';

void main() {
  final entry1 = NavigationEntryModel(
    id: '1',
    timestamp: DateTime.timestamp(),
    action: NavigationAction.pop,
    route: 'entry 1',
    previousRoute: 'entry 1',
  );

  final entry2 = NavigationEntryModel(
    id: '2',
    timestamp: DateTime.timestamp(),
    action: NavigationAction.push,
    route: 'entry 1',
    previousRoute: 'entry 2',
  );

  group('Merge Network Entry Model', () {
    late NavigationEntryModel data;

    setUp(() => data = entry1.merge(entry2));

    test('data should have entry 1 id', () => expect(data.id, entry1.id));
    test(
      'data should have entry 1 timestamp',
      () => expect(data.timestamp, entry1.timestamp),
    );
    test(
      'data should have entry 1 action',
      () => expect(data.action, entry1.action),
    );
    test(
      'data should have entry 2 route',
      () => expect(data.route, entry2.route),
    );
    test(
      'data should have entry 2 previous route',
      () => expect(data.previousRoute, entry2.previousRoute),
    );
  });
}
