import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/model/log_entry_model.dart';
import 'package:log_box/src/storage/storage.dart';

void main() {
  final storage = Storage(capacity: 5);

  tearDown(() {
    storage.clear();
  });

  test('Adding with unique id until over capacity', () {
    for (final index in List.generate(100, (e) => e)) {
      storage.add(log: LogEntryModel(id: '$index', message: '$index'));
    }

    expect(storage.data.length, 5);
  });

  test('Adding with key that already exist', () {
    for (final index in List.generate(5, (e) => e)) {
      storage.add(log: LogEntryModel(id: '$index', message: '$index'));
    }

    storage.add(log: LogEntryModel(id: '4', message: 'custom'));

    expect(storage.data.length, 5);
    expect(
      storage.data['4'],
      isA<LogEntryModel>().having((e) => e.message, 'Name', 'custom'),
    );
  });
}
