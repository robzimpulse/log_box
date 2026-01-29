import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:log_box/log_box.dart';

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

  Widget display(BuildContext context, {String? searchTerm}) {
    final theme = Theme.of(context);
    final json = extra?.json;

    if (json == null) {
      return ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
          event.name,
          maxLines: 1,
          style: theme.textTheme.labelLarge,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          timestamp.toIso8601String(),
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
      );
    }

    return ExpansionTile(
      visualDensity: VisualDensity.compact,
      title: Row(
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  event.name,
                  maxLines: 1,
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (searchTerm != null && json.contains(searchTerm))
                Positioned(
                  width: 6,
                  height: 6,
                  right: 0,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
            ],
          ),
          Spacer(),
        ],
      ),
      subtitle: Text(
        timestamp.toIso8601String(),
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
      showTrailingIcon: json.isNotEmpty,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HumanReadableWidget(
            name: 'Extra',
            value: json,
            searchTerm: searchTerm,
          ),
        ),
      ],
    );
  }
}
