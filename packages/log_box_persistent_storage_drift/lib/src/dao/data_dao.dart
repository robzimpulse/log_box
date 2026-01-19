import 'package:drift/drift.dart';

import '../database/database.dart';
import '../table/data_tables.dart';

part 'data_dao.g.dart';

@DriftAccessor(tables: [DataTables])
class DataDao extends DatabaseAccessor<AppDatabase> with _$DataDaoMixin {
  DataDao(super.db);

}