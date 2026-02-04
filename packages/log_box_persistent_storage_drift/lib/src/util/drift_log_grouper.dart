import 'package:flutter/foundation.dart';

import '../enum/database_operation.dart';
import '../model/drift_query_operation_model.dart';

class DriftLogGrouper {
  final ValueSetter<List<DriftQueryOperationModel>>? _onGroup;
  final _stack = <DriftQueryOperationModel>[];
  int _depth = 0;

  DriftLogGrouper({ValueSetter<List<DriftQueryOperationModel>>? onGroup})
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

    if (_depth <= 0) {
      _onGroup?.call([..._stack]);
      _stack.clear();
    }
  }
}
