import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:log_box/log_box.dart';

part 'drift_query_operation_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DriftQueryOperationModel {
  final String? operation;
  final String? statement;
  final Duration? duration;
  final String? error;
  final String? stackTrace;
  final DateTime timestamp;

  factory DriftQueryOperationModel.create({
    String? operation,
    String? statement,
    Duration? duration,
    String? error,
    String? stackTrace,
  }) {
    return DriftQueryOperationModel(
      timestamp: DateTime.timestamp(),
      operation: operation,
      statement: statement,
      duration: duration,
      error: error,
      stackTrace: stackTrace,
    );
  }

  DriftQueryOperationModel copyWith({
    String? operation,
    String? statement,
    Duration? duration,
    String? error,
    String? stackTrace,
  }) {
    return DriftQueryOperationModel(
      timestamp: timestamp,
      operation: operation ?? this.operation,
      statement: statement ?? this.statement,
      duration: duration ?? this.duration,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  const DriftQueryOperationModel({
    required this.timestamp,
    this.operation,
    this.statement,
    this.duration,
    this.error,
    this.stackTrace,
  });

  bool contains(String keyword) {
    return [
      operation?.toLowerCase().contains(keyword.toLowerCase()) == true,
      statement?.toLowerCase().contains(keyword.toLowerCase()) == true,
      error?.toLowerCase().contains(keyword.toLowerCase()) == true,
      stackTrace?.toLowerCase().contains(keyword.toLowerCase()) == true,
    ].contains(true);
  }

  Map<String, dynamic> toJson() => _$DriftQueryOperationModelToJson(this);

  factory DriftQueryOperationModel.fromJson(Map<String, dynamic> json) {
    return _$DriftQueryOperationModelFromJson(json);
  }

  Widget display(BuildContext context, {String? searchTerm}) {
    final theme = Theme.of(context);

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
                  operation ?? 'Unknown Operation',
                  maxLines: 1,
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (searchTerm != null && contains(searchTerm))
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
      subtitle: Row(
        children: [
          Text(
            timestamp.toIso8601String(),
            textAlign: TextAlign.start,
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
          Spacer(),
          Text(
            duration.toString(),
            textAlign: TextAlign.end,
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HumanReadableWidget(
            name: 'Statement',
            value: statement,
            searchTerm: searchTerm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HumanReadableWidget(
            name: 'Error',
            value: error,
            searchTerm: searchTerm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HumanReadableWidget(
            name: 'Stack Trace',
            value: stackTrace,
            searchTerm: searchTerm,
          ),
        ),
      ],
    );
  }
}
