import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:log_box/log_box.dart';

import '../database/database.dart';
import '../table/data_tables.dart';

part 'data_dao.g.dart';

@DriftAccessor(
  tables: [DataTables],
  queries: {
    'latestDistinctRowByType': '''
    SELECT * FROM (
      SELECT *, ROW_NUMBER() OVER (PARTITION BY type ORDER BY created_at DESC) as rn
      FROM data_tables
    ) WHERE rn = 1
    ''',
  },
)
class DataDao extends DatabaseAccessor<LogBoxPersistentDatabase> with _$DataDaoMixin {
  DataDao(super.db);

  Future<void> add({required EntryModel log}) {
    return transaction(() async {
      final companion = DataTablesCompanion.insert(
        uid: Value(log.id),
        type: Value(log.runtimeType.toString()),
        json: Value(jsonEncode(log.toJson())),
      );

      await into(dataTables).insert(companion);
    });
  }

  Future<void> clear() => transaction(() => delete(dataTables).go());

  Future<List<DataDrift>> fetch({
    String? refId,
    String? keyword,
    Set<String>? types,
    bool fetchBefore = false,
    int limit = 20,
  }) async {
    final selector = select(dataTables)
      ..orderBy([
        (t) {
          // 3. Sorting Direction
          if (fetchBefore) {
            // "Previous": Sort ASC to get the closest neighbors "above" the cursor
            return OrderingTerm.asc(t.createdAt);
          } else {
            // "Next" (and First Page): Standard DESC sort (Newest First)
            return OrderingTerm.desc(t.createdAt);
          }
        },
        (t) {
          // Tie-breaker ID sorting
          if (fetchBefore) {
            return OrderingTerm.asc(t.id);
          } else {
            return OrderingTerm.desc(t.id);
          }
        },
      ])
      ..limit(limit);

    if (types != null && types.isNotEmpty) {
      selector.where((t) => t.type.isIn(types));
    }
    
    if (keyword != null && keyword.isNotEmpty) {
      selector.where((t) => t.json.like('%$keyword%'));
    }

    if (refId != null && refId.isNotEmpty) {
      final cursorSelector = selectOnly(dataTables)
        ..addColumns([dataTables.id, dataTables.createdAt])
        ..where(dataTables.uid.equals(refId))
        ..limit(1);

      final cursor = await cursorSelector.getSingleOrNull();
      final cursorId = cursor?.read(dataTables.id);
      final cursorCreatedAt = cursor?.read(dataTables.createdAt);

      if (cursorId == null || cursorCreatedAt == null) {
        return [];
      }

      selector.where((t) {
        if (fetchBefore) {
          // "Previous" logic
          return t.createdAt.isBiggerThanValue(cursorCreatedAt) |
              (t.createdAt.equals(cursorCreatedAt) &
                  t.id.isBiggerThanValue(cursorId));
        } else {
          // "Next" logic
          return t.createdAt.isSmallerThanValue(cursorCreatedAt) |
              (t.createdAt.equals(cursorCreatedAt) &
                  t.id.isSmallerThanValue(cursorId));
        }
      });
    }

    return selector.get().then((e) {
      // 4. Post-Processing
      // If we fetched "Before", the DB gave us [Oldest -> Newest].
      // We must reverse it to maintain the UI order [Newest -> Oldest].
      return fetchBefore ? [...e.reversed] : e;
    });
  }

  Stream<DataDrift> single(String uid) {
    final selector = select(dataTables)
      ..where((t) => t.uid.equals(uid))
      ..limit(1);

    return selector.watchSingle();
  }

  Stream<List<DataDrift>> get latestDistinctByType {
    return latestDistinctRowByType().watch().map((e) => [...e.map(_transform)]);
  }

  DataDrift _transform(LatestDistinctRowByTypeResult result) {
    return DataDrift(
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
      id: result.id,
      uid: result.uid,
      type: result.type,
      json: result.json,
    );
  }
}
