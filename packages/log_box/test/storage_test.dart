import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/model/entry_model.dart';
import 'package:log_box/src/storage/base/persistent_data_storage.dart';
import 'package:log_box/src/storage/base/live_data_storage.dart';
import 'package:log_box/src/storage/storage.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class MockPersistentStorage extends Mock implements PersistentDataStorage {}
abstract class FakeLiveDataStorage extends LiveDataStorage with ChangeNotifier {}
class MockLiveDataStorage extends Mock implements FakeLiveDataStorage {}

class FakeEntryModel extends Fake implements EntryModel {
  @override
  final String id;
  FakeEntryModel(this.id);
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEntryModel('fallback'));
  });

  group('Storage', () {
    late MockLiveDataStorage liveStorage;
    late MockPersistentStorage persistentStorage;
    late StreamController<EntryModel> onDeleteController;

    setUp(() {
      liveStorage = MockLiveDataStorage();
      persistentStorage = MockPersistentStorage();
      onDeleteController = StreamController<EntryModel>.broadcast();
      
      when(() => liveStorage.onDeleteEntry).thenAnswer((_) => onDeleteController.stream);
      when(() => liveStorage.dispose()).thenReturn(null);
      
      when(() => persistentStorage.add(log: any(named: 'log'))).thenAnswer((_) async {});
      when(() => persistentStorage.dispose()).thenAnswer((_) async {});
      when(() => persistentStorage.clear()).thenAnswer((_) async {});
    });

    tearDown(() {
      onDeleteController.close();
    });

    test('onDeleteEntry listener adds to persistent storage', () async {
      final storage = Storage(
        liveDataStorage: liveStorage,
        persistentDataStorage: persistentStorage,
      );
      final log = FakeEntryModel('1');
      onDeleteController.add(log);
      
      await Future.delayed(Duration(milliseconds: 10));
      
      verify(() => persistentStorage.add(log: log)).called(1);
      await storage.dispose();
    });

    test('onDeleteEntry listener handles null persistent storage', () async {
      final storage = Storage(liveDataStorage: liveStorage);
      final log = FakeEntryModel('1');
      onDeleteController.add(log);
      
      await Future.delayed(Duration(milliseconds: 10));
      
      // Should not throw
      await storage.dispose();
    });

    test('add entry when persistent storage is null', () async {
      final storageNoP = Storage(liveDataStorage: liveStorage);
      final log = FakeEntryModel('1');
      
      when(() => liveStorage.add(log: any(named: 'log'))).thenReturn(null);

      storageNoP.add(log: log);
      
      verify(() => liveStorage.add(log: log)).called(1);
    });

    test('add entry when not in persistent storage', () async {
      final storage = Storage(
        liveDataStorage: liveStorage,
        persistentDataStorage: persistentStorage,
      );
      final log = FakeEntryModel('1');
      when(() => persistentStorage.get('1')).thenAnswer((_) async => null);
      when(() => liveStorage.add(log: any(named: 'log'))).thenReturn(null);

      storage.add(log: log);
      
      await Future.delayed(Duration(milliseconds: 10));
      
      verify(() => liveStorage.add(log: log)).called(1);
      verifyNever(() => persistentStorage.add(log: any(named: 'log')));
    });

    test('add entry when already in persistent storage', () async {
      final storage = Storage(
        liveDataStorage: liveStorage,
        persistentDataStorage: persistentStorage,
      );
      final log = FakeEntryModel('1');
      when(() => persistentStorage.get('1')).thenAnswer((_) async => log);

      storage.add(log: log);
      
      await Future.delayed(Duration(milliseconds: 10));
      
      verify(() => persistentStorage.add(log: log)).called(1);
      verifyNever(() => liveStorage.add(log: any(named: 'log')));
    });

    test('clear clears both storages', () {
      final storage = Storage(
        liveDataStorage: liveStorage,
        persistentDataStorage: persistentStorage,
      );
      when(() => liveStorage.clear()).thenReturn(null);

      storage.clear();
      
      verify(() => persistentStorage.clear()).called(1);
      verify(() => liveStorage.clear()).called(1);
    });

    test('clear handles null persistent storage', () {
      final storage = Storage(liveDataStorage: liveStorage);
      when(() => liveStorage.clear()).thenReturn(null);

      storage.clear();
      
      verify(() => liveStorage.clear()).called(1);
    });

    test('dispose cancels subscription and disposes storages', () async {
      final storage = Storage(
        liveDataStorage: liveStorage,
        persistentDataStorage: persistentStorage,
      );

      await storage.dispose();
      
      verify(() => liveStorage.dispose()).called(1);
      verify(() => persistentStorage.dispose()).called(1);
    });

    test('dispose handles null persistent storage', () async {
      final storage = Storage(liveDataStorage: liveStorage);

      await storage.dispose();
      
      verify(() => liveStorage.dispose()).called(1);
    });

    test('stream merges live and persistent', () async {
      final realLiveStorage = _SimpleLiveStorage();
      final storage = Storage(
        liveDataStorage: realLiveStorage,
        persistentDataStorage: persistentStorage,
      );
      
      final log1 = FakeEntryModel('1');
      final log2 = FakeEntryModel('1');
      
      realLiveStorage.data.add(log1);
      when(() => persistentStorage.getStream('1')).thenAnswer((_) => Stream.value(log2));

      final stream = storage.stream('1');
      final results = await stream.take(2).toList();
      
      expect(results, containsAll([log1, log2]));
    });

    test('stream handles null persistent storage', () async {
      final realLiveStorage = _SimpleLiveStorage();
      final storage = Storage(liveDataStorage: realLiveStorage);
      final log1 = FakeEntryModel('1');
      
      realLiveStorage.data.add(log1);

      final stream = storage.stream('1');
      final first = await stream.first;
      
      expect(first, log1);
    });

    test('getters return correct storages', () {
      final storage = Storage(
        liveDataStorage: liveStorage,
        persistentDataStorage: persistentStorage,
      );
      expect(storage.liveStorage, liveStorage);
      expect(storage.persistentStorage, persistentStorage);
    });
  });
}

class _SimpleLiveStorage extends LiveDataStorage with ChangeNotifier {
  @override
  final List<EntryModel> data = [];
  @override
  final Map<String, Type> types = {};
  @override
  void add({required EntryModel log}) => data.add(log);
  @override
  void clear() => data.clear();
  @override
  Stream<EntryModel> get onDeleteEntry => Stream.empty();
}
