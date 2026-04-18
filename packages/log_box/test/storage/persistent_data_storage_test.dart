import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/model/entry_model.dart';
import 'package:log_box/src/storage/base/persistent_data_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_paging/super_paging.dart';

class MockEntryModel extends Mock implements EntryModel {}

class TestPersistentDataStorage extends PersistentDataStorage {
  final Future<List<EntryModel>> Function({required Cursor cursor, required int limit})? onFetch;
  final Stream<List<EntryModel>> Function({required Cursor cursor, required int limit})? onFetchStream;

  TestPersistentDataStorage({this.onFetch, this.onFetchStream});

  @override
  Future<void> add({required EntryModel log}) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<EntryModel?> get(String id) async => null;

  @override
  Stream<EntryModel?> getStream(String id) => Stream.empty();

  @override
  Stream<Map<String, Type>> get types => Stream.empty();

  @override
  Future<List<EntryModel>> fetch({required Cursor cursor, int limit = 20}) async {
    if (onFetch != null) {
      return onFetch!(cursor: cursor, limit: limit);
    }
    return [];
  }

  @override
  Stream<List<EntryModel>> fetchStream({required Cursor cursor, int limit = 20}) {
    if (onFetchStream != null) {
      return onFetchStream!(cursor: cursor, limit: limit);
    }
    return Stream.empty();
  }
}

void main() {
  group('Cursor', () {
    test('copyWith should work correctly', () {
      const cursor = Cursor(id: '1', keyword: 'test', types: ['a'], direction: PageDirection.after);
      
      final copy = cursor.copyWith(
        id: '2',
        keyword: 'new',
        types: ['b'],
        direction: PageDirection.before,
      );

      expect(copy.id, '2');
      expect(copy.keyword, 'new');
      expect(copy.types, ['b']);
      expect(copy.direction, PageDirection.before);

      final copyEmpty = cursor.copyWith();
      expect(copyEmpty.id, '1');
      expect(copyEmpty.keyword, 'test');
      expect(copyEmpty.types, ['a']);
      expect(copyEmpty.direction, PageDirection.after);
    });
  });

  group('PersistentDataStorage.load', () {
    late MockEntryModel entry1;
    late MockEntryModel entry2;

    setUp(() {
      entry1 = MockEntryModel();
      entry2 = MockEntryModel();
      when(() => entry1.id).thenReturn('id1');
      when(() => entry2.id).thenReturn('id2');
    });

    test('load should handle initial load with null key', () async {
      final storage = TestPersistentDataStorage(
        onFetch: ({required cursor, required limit}) async {
          expect(cursor.id, isNull);
          return [entry1];
        },
      );

      final params = LoadParams<Cursor>(key: null, loadSize: 20, loadType: LoadType.refresh);
      final result = await storage.load(params) as LoadResultPage<Cursor, EntryModel>;

      expect(result.items, [entry1]);
      expect(result.nextKey?.id, 'id1');
      expect(result.prevKey?.id, 'id1');
    });

    test('load should handle fetch with data and next/prev keys', () async {
      final storage = TestPersistentDataStorage(
        onFetch: ({required cursor, required limit}) async {
          return [entry1, entry2];
        },
      );

      final params = LoadParams<Cursor>(key: const Cursor(id: 'start'), loadSize: 20, loadType: LoadType.refresh);
      final result = await storage.load(params) as LoadResultPage<Cursor, EntryModel>;

      expect(result.items, [entry1, entry2]);
      expect(result.nextKey?.id, 'id2');
      expect(result.nextKey?.direction, PageDirection.after);
      expect(result.prevKey?.id, 'id1');
      expect(result.prevKey?.direction, PageDirection.before);
    });

    test('load should trigger fetchStream when result is empty and direction is before', () async {
      final controller = StreamController<List<EntryModel>>();
      final storage = TestPersistentDataStorage(
        onFetch: ({required cursor, required limit}) async {
          return [];
        },
        onFetchStream: ({required cursor, required limit}) {
          return controller.stream;
        },
      );

      final params = LoadParams<Cursor>(
        key: const Cursor(id: 'some', direction: PageDirection.before),
        loadSize: 20,
        loadType: LoadType.refresh,
      );

      final futureResult = storage.load(params);
      
      controller.add([]); // Should be skipped by firstWhere
      controller.add([entry1]);
      
      final result = await futureResult as LoadResultPage<Cursor, EntryModel>;

      expect(result.items, [entry1]);
      expect(result.nextKey?.id, 'id1');
      expect(result.prevKey?.id, 'id1');
      
      await controller.close();
    });

    test('load should return error when fetch fails', () async {
      final exception = Exception('fetch failed');
      final storage = TestPersistentDataStorage(
        onFetch: ({required cursor, required limit}) async {
          throw exception;
        },
      );

      final params = LoadParams<Cursor>(key: null, loadSize: 20, loadType: LoadType.refresh);
      final result = await storage.load(params) as LoadResultError<Cursor, EntryModel>;

      expect(result.error, exception);
    });
    
    test('load should handle empty result when direction is after', () async {
      final storage = TestPersistentDataStorage(
        onFetch: ({required cursor, required limit}) async {
          return [];
        },
      );

      final params = LoadParams<Cursor>(key: const Cursor(direction: PageDirection.after), loadSize: 20, loadType: LoadType.refresh);
      final result = await storage.load(params) as LoadResultPage<Cursor, EntryModel>;

      expect(result.items, isEmpty);
      expect(result.nextKey, isNull);
      expect(result.prevKey, isNull);
    });
  });
}
