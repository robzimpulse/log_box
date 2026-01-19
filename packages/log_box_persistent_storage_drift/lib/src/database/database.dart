import 'package:drift/drift.dart';

import '../dao/data_dao.dart';
import '../table/data_tables.dart';
import 'executor/base.dart';

part 'database.g.dart';

@DriftDatabase(tables: [DataTables], daos: [DataDao])
class AppDatabase extends _$AppDatabase {

  AppDatabase({required Executor executor}) : super(executor.executor);

  @override
  int get schemaVersion => 1;
}
