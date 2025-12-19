import 'package:log_box/log_box.dart';

import '../model/trace_log_entry_model.dart';

class StorageDecoder {
  StorageCodec get codec => {
    (LogEntryModel).toString(): LogEntryModel.fromJson,
    (TraceLogEntryModel).toString(): TraceLogEntryModel.fromJson,
  };
}
