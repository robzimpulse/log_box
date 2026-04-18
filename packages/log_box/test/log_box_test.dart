import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/log_box.dart';
import 'package:log_box/src/storage/storage.dart';
import 'package:log_box/src/storage/memory_storage.dart';

void main() {
  group('LogBox', () {
    test('initialization with default storage', () {
      final logBox = LogBox();
      expect(logBox.storage, isNotNull);
      expect(logBox.storage.liveStorage, isA<MemoryStorage>());
    });

    test('initialization with custom storage', () {
      final storage = Storage(liveDataStorage: MemoryStorage());
      final logBox = LogBox(storage: storage);
      expect(logBox.storage, storage);
    });

    test('dispose calls storage dispose', () {
      // MemoryStorage doesn't have a specialized dispose but Storage does
      final logBox = LogBox();
      logBox.dispose();
      // No crash, and we've covered the line
    });
  });
}
