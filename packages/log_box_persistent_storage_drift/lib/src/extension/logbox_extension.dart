import 'package:log_box/log_box.dart';

import '../interceptor/drift_query_interceptor.dart';
import '../util/drift_log_grouper.dart';

extension DriftInterceptorExtension on LogBox {
  DriftQueryInterceptor get queryInterceptor {
    final grouper = DriftLogGrouper(onGroup: (e) => storage.add(log: e));
    return DriftQueryInterceptor(onEvent: grouper.add);
  }
}
