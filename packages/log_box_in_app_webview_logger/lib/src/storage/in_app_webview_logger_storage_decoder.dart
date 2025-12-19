import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/src/model/webview_entry_model.dart';

class InAppWebviewLoggerStorageDecoder implements StorageDecoder {
  @override
  StorageCodec get codec => {
    (WebviewEntryModel).toString(): WebviewEntryModel.fromJson,
  };
}
