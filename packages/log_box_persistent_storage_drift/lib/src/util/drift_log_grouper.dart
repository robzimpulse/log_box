import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../enum/database_operation.dart';
import '../model/drift_query_entry_model.dart';
import '../model/drift_query_operation_model.dart';

class DriftLogGrouper {
  final ValueSetter<DriftQueryEntryModel>? _onGroup;
  final _stack = <DriftQueryOperationModel>[];
  int _depth = 0;
  String _id = const Uuid().v4();

  DriftLogGrouper({ValueSetter<DriftQueryEntryModel>? onGroup})
    : _onGroup = onGroup;

  void add(DriftQueryOperationModel entry) {
    if (entry.operation == DatabaseOperation.beginTransaction) {
      _depth += 1;
    } else if (entry.operation == DatabaseOperation.commitTransaction) {
      _depth -= 1;
    } else if (entry.operation == DatabaseOperation.rollbackTransaction) {
      // TODO: handle case rollback
    }

    _stack.add(entry);

    _onGroup?.call(
      DriftQueryEntryModel(
        id: _id,
        operations: [..._stack],
        loading: _depth > 0,
      ),
    );

    if (_depth <= 0) {
      _id = const Uuid().v4();
      _stack.clear();
    }
  }
}
