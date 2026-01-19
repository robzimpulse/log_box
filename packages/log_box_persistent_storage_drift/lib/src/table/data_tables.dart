import 'package:drift/drift.dart';

import '../mixin/auto_id_mixin.dart';
import '../mixin/auto_timestamp_mixin.dart';

@DataClassName('DataDrift')
class DataTables extends Table with AutoTimestampTable, AutoIntegerIdTable {

  TextColumn get uid => text().named('uid').nullable()();

  TextColumn get type => text().named('type').nullable()();

  TextColumn get json => text().named('json').nullable()();

}