import 'package:log_box/log_box.dart';
import 'package:log_box_persistent_storage_drift/log_box_persistent_storage_drift.dart';

extension DriftInterceptorExtension on LogBox {

  DriftQueryInterceptor get queryInterceptor {
    return DriftQueryInterceptor(storage: storage);
  }

}