import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/model/log_entry_model.dart';
import 'package:log_box/src/storage/memory_storage.dart';

void main() {
  final storage = MemoryStorage(capacity: 5);

  tearDown(() {
    storage.clear();
  });

  test('Adding with unique id until over capacity', () async {
    for (final index in List.generate(100, (e) => e)) {
      storage.add(
        log: LogEntryModel(id: '$index', message: '$index'),
      );
    }

    expect((await storage.data).length, 5);
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

    expect((await storage.data).length, 5);
    expect(
      (await storage.data)['4'],
      isA<LogEntryModel>().having((e) => e.message, 'Name', 'custom'),
    );
  });
}
