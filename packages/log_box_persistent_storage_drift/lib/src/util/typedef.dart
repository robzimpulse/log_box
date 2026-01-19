import 'package:log_box/log_box.dart';

typedef ObjectDecoder = EntryModel? Function(Map<String, dynamic> json);
typedef MapObjectDecoder = Map<String, ObjectDecoder>;