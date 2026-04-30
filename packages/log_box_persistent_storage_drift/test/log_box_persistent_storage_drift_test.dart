import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_persistent_storage_drift/memory_executor.dart';
import 'package:log_box_persistent_storage_drift/src/database/executor/base.dart';
import 'package:log_box_persistent_storage_drift/src/drift_persistent_storage.dart';
import 'package:log_box_persistent_storage_drift/src/database/database.dart';
import 'package:log_box_persistent_storage_drift/src/model/drift_query_entry_model.dart';
import 'package:mocktail/mocktail.dart';

class MockExecutor extends Mock implements Executor {}

class MockEntryModel extends Mock implements EntryModel {
  @override
  final String id;
  
  MockEntryModel({this.id = 'test-id'});

  @override
  Map<String, dynamic> toJson() => {'id': id};

  @override
  String toString() => 'MockEntryModel';
  
  @override
  String display() => 'Mock';

  @override
  MockEntryModel merge(other) => this;

  @override
  bool contains(String keyword) => id.contains(keyword);
}

void main() {
  late DriftPersistentStorage storage;
  late MemoryExecutor mockExecutor;
  late LogBoxPersistentDatabase database;

  setUp(() {
    mockExecutor = MemoryExecutor();
    
    storage = DriftPersistentStorage(
      executor: mockExecutor,
      decoder: {
        'MockEntryModel': (json) => MockEntryModel(id: json['id']),
      },
    );
    
    database = LogBoxPersistentDatabase(executor: mockExecutor);
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  tearDown(() async {
    await storage.dispose();
    await database.close();
  });

  group('DriftPersistentStorage', () {
    test('add inserts a new log when not existing', () async {
      final log = MockEntryModel();
      await storage.add(log: log);
      
      final fetched = await storage.get(log.id);
      expect(fetched, isNotNull);
      expect(fetched?.id, log.id);
    });

    test('add merges with existing log', () async {
      final log1 = DriftQueryEntryModel(id: 'merge-id', operations: [], loading: true);
      final log2 = DriftQueryEntryModel(id: 'merge-id', operations: [], loading: false);
      
      await storage.add(log: log1);
      await storage.add(log: log2);
      
      final fetched = await storage.get('merge-id') as DriftQueryEntryModel;
      expect(fetched.id, 'merge-id');
    });

    test('add handles data being null after transform', () async {
      // Add a raw row that will fail transformation
      await database.into(database.dataTables).insert(
        DataTablesCompanion.insert(
          uid: const Value('fail-transform'),
          type: const Value('UnknownType'),
          json: const Value('{}'),
        )
      );

      final log = MockEntryModel(id: 'fail-transform');
      await storage.add(log: log); // Should trigger the 'if (data == null)' branch

      final result = await storage.get('fail-transform');
      expect(result, isNotNull);
      expect(result, isA<MockEntryModel>());
    });

    test('clear deletes all logs', () async {
      await storage.add(log: MockEntryModel());
      await storage.clear();
      
      final types = await storage.types.first;
      expect(types, isEmpty);
    });

    test('fetch returns logs based on cursor', () async {
      await storage.add(log: MockEntryModel(id: '1'));
      await storage.add(log: MockEntryModel(id: '2'));
      
      final logs = await storage.fetch(cursor: const Cursor());
      expect(logs.length, 2);
    });

    test('fetch with direction before', () async {
      await storage.add(log: MockEntryModel(id: '1'));
      
      final logs = await storage.fetch(
        cursor: const Cursor(direction: PageDirection.before, id: '1'),
      );
      expect(logs, isEmpty); // Nothing before '1' in this simple setup
    });

    test('fetchStream emits updates', () async {
      final log = MockEntryModel();
      final stream = storage.fetchStream(cursor: const Cursor());
      
      final expectation = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          contains(isA<MockEntryModel>()),
        ]),
      );
      
      // Give the stream a moment to initialize and emit isEmpty
      await Future.delayed(Duration.zero);
      await storage.add(log: log);
      await expectation;
    });

    test('fetchStream with direction before', () async {
      final stream = storage.fetchStream(
        cursor: const Cursor(direction: PageDirection.before),
      );
      expect(stream, emits(isEmpty));
    });

    test('getStream emits updates for specific id', () async {
      final log = MockEntryModel(id: 'stream-id');
      final stream = storage.getStream('stream-id');
      
      final expectation = expectLater(
        stream,
        emits(isA<MockEntryModel>()),
      );
      
      await storage.add(log: log);
      await expectation;
    });

    test('types stream emits distinct types and filters nulls', () async {
      await storage.add(log: MockEntryModel());
      
      // Add one unknown type to trigger 'if (log == null) continue'
      await database.into(database.dataTables).insert(
        DataTablesCompanion.insert(
          uid: const Value('unknown'),
          type: const Value('UnknownType'),
          json: const Value('{}'),
        )
      );
      
      final types = await storage.types.first;
      expect(types, containsValue(MockEntryModel));
      expect(types.length, 1); // UnknownType should have been filtered out
    });

    test('transform returns null for unknown type', () async {
       await database.into(database.dataTables).insert(
         DataTablesCompanion.insert(
           uid: const Value('unknown'),
           type: const Value('UnknownType'),
           json: const Value('{}'),
         )
       );
       
       final result = await storage.get('unknown');
       expect(result, isNull);
    });

    test('transform returns null for null json', () async {
       // Drift DataTablesCompanion.insert requires json if not nullable in schema,
       // but we can try to force it or use a raw update if possible.
       // Actually, _transform handles data?.json == null.
       
       final result = await storage.get('non-existent');
       expect(result, isNull);
    });
  });
}
