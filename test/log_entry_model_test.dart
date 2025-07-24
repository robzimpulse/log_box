import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/model/log_entry_model.dart';

void main() {
  final entry1 = LogEntryModel(
    id: '1',
    message: 'message entry 1',
    name: 'name entry 1',
    error: Exception('exception entry 1'),
    extra: {'extra1': 'extra1'},
  );

  final entry2 = LogEntryModel(
    id: '2',
    message: 'message entry 2',
    name: 'name entry 2',
    error: Exception('exception entry 2'),
    extra: {'extra2': 'extra2'},
  );

  group('Merge Log Entry Model', () {
    late LogEntryModel data;

    setUp(() => data = entry1.merge(entry2));

    test('data should have entry 1 id', () => expect(data.id, entry1.id));
    test('data should have entry 2 name', () => expect(data.name, entry2.name));
    test(
      'data should have entry 2 message',
      () => expect(data.message, entry2.message),
    );
    test(
      'data should have entry 2 error',
      () => expect(data.error, entry2.error),
    );
    test('data should have entry 1 extra and entry 2 extra', () {
      expect(data.extra?['extra1'], entry1.extra?['extra1']);
      expect(data.extra?['extra2'], entry2.extra?['extra2']);
    });
  });
}
