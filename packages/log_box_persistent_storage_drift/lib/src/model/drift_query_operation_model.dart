import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:log_box/log_box.dart';

import '../enum/database_operation.dart';

part 'drift_query_operation_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DriftQueryOperationModel {
  final DatabaseOperation operation;
  final List<String> statements;
  final Duration? duration;
  final String? error;
  final String? stackTrace;
  final DateTime timestamp;

  factory DriftQueryOperationModel.create({
    required DatabaseOperation operation,
    List<String> statements = const [],
    Duration? duration,
    String? error,
    String? stackTrace,
  }) {
    return DriftQueryOperationModel(
      timestamp: DateTime.timestamp(),
      operation: operation,
      statements: statements,
      duration: duration,
      error: error,
      stackTrace: stackTrace,
    );
  }

  DriftQueryOperationModel copyWith({
    DatabaseOperation? operation,
    List<String>? statements,
    Duration? duration,
    String? error,
    String? stackTrace,
  }) {
    return DriftQueryOperationModel(
      timestamp: timestamp,
      operation: operation ?? this.operation,
      statements: [...?statements, ...this.statements],
      duration: duration ?? this.duration,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  const DriftQueryOperationModel({
    required this.timestamp,
    required this.operation,
    this.statements = const [],
    this.duration,
    this.error,
    this.stackTrace,
  });

  bool contains(String keyword) {
    return [
      operation.rawValue.toLowerCase().contains(keyword.toLowerCase()),
      for (final statement in statements)
        statement.toLowerCase().contains(keyword.toLowerCase()),
      error?.toLowerCase().contains(keyword.toLowerCase()) == true,
      stackTrace?.toLowerCase().contains(keyword.toLowerCase()) == true,
    ].contains(true);
  }

  Map<String, dynamic> toJson() => _$DriftQueryOperationModelToJson(this);

  factory DriftQueryOperationModel.fromJson(Map<String, dynamic> json) {
    return _$DriftQueryOperationModelFromJson(json);
  }

  Widget widget(BuildContext context, {String? searchTerm}) {
    return ExpansionTile(
      title: Text(operation.rawValue),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HumanReadableWidget(
            name: 'Timestamp',
            value: timestamp.toIso8601String(),
            searchTerm: searchTerm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HumanReadableWidget(
            name: 'Duration',
            value: duration.toString(),
            searchTerm: searchTerm,
          ),
        ),
        for (final (index, statement) in statements.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HumanReadableWidget(
              name: 'Statement #${index + 1}',
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
            name: 'Stacktrace',
            value: stackTrace,
            searchTerm: searchTerm,
          ),
        ),
      ],
    );
  }
}
