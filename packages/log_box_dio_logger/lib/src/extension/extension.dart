import 'package:dio/dio.dart';
import 'package:log_box/log_box.dart';

import '../interceptor/log_box_network_interceptor.dart';

extension LogBoxDioLogger on LogBox {

  Interceptor get interceptor => LogBoxNetworkInterceptor(storage: storage);

}