import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';

void main() {
  late MemoryStorage storage;

  setUp(() {
    storage = MemoryStorage(capacity: 5);
  });

  test('Adding with unique id until over capacity', () async {
    final deletedLogs = [];
    storage.onDeleteEntry.listen(deletedLogs.add);

    for (final index in List.generate(6, (e) => e)) {
      storage.add(
        log: LogEntryModel(id: '$index', message: '$index'),
      );
    }

    expect(storage.data.length, 5);
    // Wait for microtask (notifyListeners)
    await Future.delayed(Duration.zero);
    expect(deletedLogs.length, 1);
    expect(deletedLogs.first.id, '0');
  });

  test('Adding with key that already exist', () async {
    for (final index in List.generate(5, (e) => e)) {
      storage.add(
        log: LogEntryModel(id: '$index', message: '$index'),
      );
    }

    storage.add(
      log: LogEntryModel(id: '4', message: 'custom'),
    );

    expect(storage.data.length, 5);
    expect(
      storage.data.where((e) => e.id == '4').first,
      isA<LogEntryModel>().having((e) => e.message, 'message', 'custom'),
    );
  });

  test('clear', () async {
    final deletedLogs = [];
    storage.onDeleteEntry.listen(deletedLogs.add);

    storage.add(
      log: LogEntryModel(id: '1', message: '1'),
    );
    storage.clear();

    expect(storage.data.length, 0);
    await Future.delayed(Duration.zero);
    expect(deletedLogs.length, 1);
  });

  test('types', () {
    storage.add(
      log: LogEntryModel(id: '1', message: '1', name: 'N'),
    );
    expect(storage.types.values, contains(LogEntryModel));
    expect(storage.types.keys, contains('Log'));
  });

  test('dispose', () {
    storage.dispose();
    // Subsequent adds might fail or stream might be closed
    expect(
      () => storage.add(log: LogEntryModel(message: 'm')),
      throwsAssertionError,
    );
  });
}
