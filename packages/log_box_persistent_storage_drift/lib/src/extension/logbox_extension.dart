import 'package:log_box/log_box.dart';
import 'package:log_box_persistent_storage_drift/log_box_persistent_storage_drift.dart';

import '../util/drift_log_builder.dart';

extension DriftInterceptorExtension on LogBox {

  DriftQueryInterceptor get queryInterceptor {
    final builder = DriftLogBuilder();
    return DriftQueryInterceptor(onEvent: (e) {
      // TODO: add this to storage
      print(builder.add(e));
    });
  }

}