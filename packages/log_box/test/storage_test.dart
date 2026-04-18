import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/model/entry_model.dart';
import 'package:log_box/src/storage/base/persistent_data_storage.dart';
import 'package:log_box/src/storage/memory_storage.dart';
import 'package:log_box/src/storage/storage.dart';
import 'package:log_box/src/model/log_entry_model.dart';
import 'dart:async';

class MockPersistentStorage extends PersistentDataStorage {
  final Map<String, EntryModel> _data = {};
  bool cleared = false;
  bool disposed = false;

  @override
  Future<void> add({required EntryModel log}) async {
    _data[log.id] = log;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    _data.clear();
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }

  @override
  Future<EntryModel?> get(String id) async {
    return _data[id];
  }

  @override
  Stream<EntryModel?> getStream(String id) {
    return Stream.value(_data[id]);
  }
  
  @override
  Future<List<EntryModel>> fetch({required Cursor cursor, int limit = 20}) async {
    return _data.values.toList();
  }

  @override
  Stream<List<EntryModel>> fetchStream({required Cursor cursor, int limit = 20}) {
    return Stream.value(_data.values.toList());
  }

  @override
  Stream<Map<String, Type>> get types => Stream.value({});
}

void main() {
  group('Storage', () {
    late MemoryStorage liveStorage;
    late MockPersistentStorage persistentStorage;
    late Storage storage;

    setUp(() {
      liveStorage = MemoryStorage(capacity: 5);
      persistentStorage = MockPersistentStorage();
      storage = Storage(
        liveDataStorage: liveStorage,
        persistentDataStorage: persistentStorage,
      );
    });

    test('add entry when not in persistent storage', () async {
      final log = LogEntryModel(id: '1', message: 'msg');
      storage.add(log: log);
      
      // Since persistence.get is called, we might need to wait or use a more synchronous mock if possible
      // But Storage.add is async internally (void async).
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(liveStorage.data.length, 1);
    });

    test('add entry when already in persistent storage', () async {
      final log = LogEntryModel(id: '1', message: 'msg');
      await persistentStorage.add(log: log);
      
      storage.add(log: log);
      await Future.delayed(Duration(milliseconds: 100));
      
      // Should add to persistent instead of live if it exists? 
      // Actually the logic is:
      // if (existing == null) { _liveDataStorage.add(log: log); return; }
      // await persistence.add(log: log);
      // So if it exists, it goes to persistence.
      
      expect(liveStorage.data.length, 0);
      expect(persistentStorage._data.containsKey('1'), isTrue);
    });

    test('clear clears both storages', () {
      storage.clear();
      expect(persistentStorage.cleared, isTrue);
      // MemoryStorage clear is tested elsewhere
    });

    test('dispose cancels subscription and disposes storages', () async {
      await storage.dispose();
      expect(persistentStorage.disposed, isTrue);
    });

    test('stream merges live and persistent', () async {
      final log = LogEntryModel(id: '1', message: 'msg');
      liveStorage.add(log: log);
      
      final stream = storage.stream('1');
      final first = await stream.first;
      expect(first.id, '1');
    });
    
    test('Storage without persistence', () {
      final storageNoP = Storage(liveDataStorage: MemoryStorage());
      final log = LogEntryModel(id: '1', message: 'msg');
      storageNoP.add(log: log);
      expect(storageNoP.liveStorage.data.length, 1);
    });
  });
}
