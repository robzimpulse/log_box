import 'package:log_box/log_box.dart';
import 'package:log_box_persistent_storage_drift/src/model/drift_query_entry_model.dart';

import '../interceptor/drift_query_interceptor.dart';
import '../util/drift_log_grouper.dart';

extension DriftInterceptorExtension on LogBox {
  DriftQueryInterceptor get queryInterceptor {
    final grouper = DriftLogGrouper(
      onGroup: (e) => storage.add(log: DriftQueryEntryModel(operations: e)),
    );
    return DriftQueryInterceptor(onEvent: grouper.add);
  }
}
