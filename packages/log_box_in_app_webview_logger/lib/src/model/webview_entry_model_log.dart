import 'package:json_annotation/json_annotation.dart';

import '../enum/enum.dart';

part 'webview_entry_model_log.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class WebviewEntryModelLog {
  final WebviewEvent event;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  factory WebviewEntryModelLog.create({
    required WebviewEvent event,
    Map<String, dynamic>? extra,
  }) {
    return WebviewEntryModelLog(event: event, extra: extra);
  }

  WebviewEntryModelLog({required this.event, this.extra})
      : timestamp = DateTime.timestamp();

  Map<String, dynamic> toJson() => _$WebviewEntryModelLogToJson(this);

  factory WebviewEntryModelLog.fromJson(Map<String, dynamic> json) {
    return _$WebviewEntryModelLogFromJson(json);
  }
}