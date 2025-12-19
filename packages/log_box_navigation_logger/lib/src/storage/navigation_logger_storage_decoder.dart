import 'package:log_box/log_box.dart';
import 'package:log_box_navigation_logger/src/model/navigation_entry_model.dart';

class NavigationLoggerStorageDecoder implements StorageDecoder {
  @override
  StorageCodec get codec => {
    (NavigationEntryModel).toString(): NavigationEntryModel.fromJson,
  };
}
