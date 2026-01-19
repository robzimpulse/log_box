import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:log_box/log_box.dart';

import '../database/database.dart';
import '../table/data_tables.dart';

part 'data_dao.g.dart';

@DriftAccessor(tables: [DataTables])
class DataDao extends DatabaseAccessor<AppDatabase> with _$DataDaoMixin {
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

    if (refId != null) {
      final subquery = Subquery(
        selectOnly(dataTables)
          ..addColumns([dataTables.id, dataTables.createdAt])
          ..where(dataTables.uid.equals(refId))
          ..limit(1),
        's',
      );

      selector.where((t) {
        // 2. Cursor Logic
        if (fetchBefore) {
          // "Previous": We want rows NEWER than cursor
          // Logic: (date > cursorDate) OR (date == cursorDate AND id > cursorId)
          return t.createdAt.isBiggerThan(subquery.ref(dataTables.createdAt)) |
              (t.createdAt.equalsExp(subquery.ref(dataTables.createdAt)) &
                  t.id.isBiggerThan(subquery.ref(dataTables.id)));
        } else {
          // "Next": We want rows OLDER than cursor
          // Logic: (date < cursorDate) OR (date == cursorDate AND id < cursorId)
          return t.createdAt.isSmallerThan(subquery.ref(dataTables.createdAt)) |
              (t.createdAt.equalsExp(subquery.ref(dataTables.createdAt)) &
                  t.id.isSmallerThan(subquery.ref(dataTables.id)));
        }
      });
    } else {
      selector.where((t) => const Constant(true));
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

  Stream<List<String>> get types {
    final selector = selectOnly(dataTables, distinct: true)
      ..addColumns([dataTables.type]);

    return selector.watch().map(
      (e) => e.map((e) => e.read(dataTables.type)).nonNulls.toList(),
    );
  }
}
