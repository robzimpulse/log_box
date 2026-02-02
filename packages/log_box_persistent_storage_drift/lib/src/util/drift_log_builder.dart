import 'dart:async';

import '../enum/database_operation.dart';

class LogNode {
  final DatabaseOperation operation;
  final DateTime timestamp;
  final List<LogNode> children; // The nested structure

  // Optional: details specific to the operation (e.g., the SQL query string)
  final String? statement;

  // specific for transactions to know if they finished successfully
  bool? isCompleted;
  DatabaseOperation? completionType; // Did it Commit or Rollback?

  LogNode({
    required this.operation,
    required this.timestamp,
    this.statement,
    this.children = const [],
    this.isCompleted,
    this.completionType,
  });
}

// A simple helper class to represent your input data
class RawLogEntry {
  final DatabaseOperation operation;
  final DateTime timestamp;
  RawLogEntry(this.operation, this.timestamp);
}

class LogTreeBuilder {
  // 1. Internal State
  final List<LogNode> _roots = [];
  final List<LogNode> _stack = [];

  // 2. The Transformer
  // Input: Stream<RawLogEntry> -> Output: Stream<List<LogNode>>
  StreamTransformer<RawLogEntry, List<LogNode>> get transformer {
    return StreamTransformer<RawLogEntry, List<LogNode>>.fromHandlers(
      handleData: (entry, sink) {
        // Emit a copy or the reference of the roots to trigger UI updates
        sink.add(add(entry));
      },
    );
  }

  List<LogNode> add(RawLogEntry entry) {
    _processEntry(entry);
    return List.unmodifiable(_roots);
  }

  // 3. The Logic (Same stack logic, adapted for single entry)
  void _processEntry(RawLogEntry entry) {
    final op = entry.operation;

    // --- CASE A: Start Transaction ---
    if (op == DatabaseOperation.beginTransaction) {
      final newNode = LogNode(
        operation: op,
        timestamp: entry.timestamp,
        isCompleted: false,
      );
      _addToActiveContext(newNode);
      _stack.add(newNode);
    }
    // --- CASE B: End Transaction (Commit/Rollback) ---
    else if (op == DatabaseOperation.commitTransaction ||
        op == DatabaseOperation.rollbackTransaction) {
      if (_stack.isNotEmpty) {
        // 1. Standard Case: Closing an explicit transaction
        final closingNode = _stack.last;
        closingNode.isCompleted = true;
        closingNode.completionType = op;
        _stack.removeLast();
      } else {
        // 2. Implicit Case: Auto-commit following a single operation
        // Check if the last root item was an atomic operation (Delete, Insert, etc.)
        if (_roots.isNotEmpty && _isAtomic(_roots.last.operation)) {
          // Retroactively mark the previous operation as committed
          _roots.last.isCompleted = true;
          _roots.last.completionType = op;
          // We DO NOT add this commit node to the list. We swallowed it.
        } else {
          // 3. Truly Orphaned Case
          _addToActiveContext(
            LogNode(
              operation: op,
              timestamp: entry.timestamp,
              statement: "Orphaned",
            ),
          );
        }
      }
    }
    // --- CASE C: Atomic Operations ---
    else {
      final newNode = LogNode(operation: op, timestamp: entry.timestamp);
      _addToActiveContext(newNode);
    }
  }

  // Helper to identify operations that might have auto-commits
  bool _isAtomic(DatabaseOperation op) {
    return op == DatabaseOperation.runInsert ||
        op == DatabaseOperation.runUpdate ||
        op == DatabaseOperation.runDelete ||
        op == DatabaseOperation.runBatched ||
        op == DatabaseOperation.runCustom;
  }

  // Helper to add node to either the stack top or the root
  void _addToActiveContext(LogNode node) {
    if (_stack.isNotEmpty) {
      _stack.last.children.add(node);
    } else {
      _roots.add(node);
    }
  }
}
