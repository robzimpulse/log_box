import '../enum/database_operation.dart';

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
}
