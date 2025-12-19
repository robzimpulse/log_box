import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/src/model/network_entry_model.dart';

class DioLoggerStorageDecoder implements StorageDecoder {
  @override
  StorageCodec get codec => {
    (NetworkEntryModel).toString(): NetworkEntryModel.fromJson
  };
}