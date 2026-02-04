import 'package:log_box/log_box.dart';

import '../interceptor/drift_query_interceptor.dart';
import '../util/drift_log_builder.dart';
import '../util/drift_log_grouper.dart';

extension DriftInterceptorExtension on LogBox {
  DriftQueryInterceptor get queryInterceptor {
    final builder = DriftLogBuilder(onEntry: (e) => storage.add(log: e));
    final grouper = DriftLogGrouper(onGroup: builder.add);
    return DriftQueryInterceptor(onEvent: grouper.add);
  }
}
