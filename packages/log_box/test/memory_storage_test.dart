import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';

void main() {
  final storage = MemoryStorage(capacity: 5);

  tearDown(() {
    storage.clear();
  });

  test('Adding with unique id until over capacity', () async {
    for (final index in List.generate(100, (e) => e)) {
      storage.add(log: LogEntryModel(id: '$index', message: '$index'));
    }

    expect(storage.data.length, 5);
  });

  test('Adding with key that already exist', () async {
    for (final index in List.generate(5, (e) => e)) {
      storage.add(log: LogEntryModel(id: '$index', message: '$index'));
    }

    storage.add(log: LogEntryModel(id: '4', message: 'custom'));

    expect(storage.data.length, 5);
    expect(
      storage.data.where((e) => e.id == '4').first,
      isA<LogEntryModel>().having((e) => e.message, 'Name', 'custom'),
    );
  });
}
