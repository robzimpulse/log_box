import 'package:flutter/foundation.dart';
import 'package:log_box_persistent_storage_drift/src/model/drift_query_entry_model.dart';

import '../model/drift_query_operation_model.dart';

class DriftLogBuilder {
  final ValueSetter<DriftQueryEntryModel>? _onEntry;

  DriftLogBuilder({ValueSetter<DriftQueryEntryModel>? onEntry})
    : _onEntry = onEntry;

  void add(List<DriftQueryOperationModel> group) {
    // TODO: convert List<DriftQueryOperationModel> to DriftQueryEntryModel
    _onEntry?.call(DriftQueryEntryModel(operations: group));
  }
}
