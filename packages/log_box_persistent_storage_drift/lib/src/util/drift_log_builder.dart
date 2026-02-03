import 'dart:async';

import '../enum/database_operation.dart';
import '../model/drift_query_entry_model.dart';
import '../model/drift_query_operation_model.dart';

class DriftLogBuilder {
  // 1. Internal State
  final List<DriftQueryEntryModel> _roots = [];
  final List<DriftQueryEntryModel> _stack = [];

  List<DriftQueryEntryModel> add(DriftQueryOperationModel entry) {
    _processEntry(entry);
    return List.unmodifiable(_roots);
  }

  // 3. The Logic (Same stack logic, adapted for single entry)
  void _processEntry(DriftQueryOperationModel entry) {
    switch (entry.operation) {
      // --- CASE A: Start Transaction ---
      case DatabaseOperation.beginTransaction:
        final newNode = DriftQueryEntryModel.fromRawModel(entry);
        _addToActiveContext(newNode.copyWith(isComplete: false));
        _stack.add(newNode.copyWith(isComplete: false));
        break;

      // --- CASE B: End Transaction (Commit/Rollback) ---
      case DatabaseOperation.commitTransaction:
      case DatabaseOperation.rollbackTransaction:
        if (_stack.isNotEmpty) {
          // 1. Standard Case: Closing an explicit transaction
          // 1. Explicit Transaction
          final oldNode = _stack.last;

          // Create the new completed node
          final completedNode = oldNode.copyWith(isComplete: true);

          // REPLACE the old node in the Tree Structure with the new one
          _replaceNodeInTree(oldNode, completedNode);

          // Remove from stack (context closed)
          _stack.removeLast();
        } else {
          // 2. Implicit Case: Auto-commit following a single operation
          // Check if the last root item was an atomic operation (Delete, Insert, etc.)
          if (_roots.isNotEmpty && _isAtomic(_roots.last.operation)) {
            final oldNode = _roots.last;

            // Create the new completed node
            final completedNode = oldNode.copyWith(isComplete: true);

            // Replace in roots
            _roots.removeLast();
            _roots.add(completedNode);
          } else {
            // 3. Truly Orphaned Case
            _addToActiveContext(
              DriftQueryEntryModel.fromRawModel(
                entry,
              ).copyWith(isComplete: true),
            );
          }
        }
        break;

      // --- CASE C: Atomic Operations ---
      case DatabaseOperation.runBatched:
      case DatabaseOperation.runCustom:
      case DatabaseOperation.runDelete:
      case DatabaseOperation.runInsert:
      case DatabaseOperation.runSelect:
      case DatabaseOperation.runUpdate:
      case DatabaseOperation.unknown:
        _addToActiveContext(
          DriftQueryEntryModel.fromRawModel(entry).copyWith(isComplete: true),
        );
        break;
    }
  }

  // Helper to identify operations that might have auto-commits
  bool _isAtomic(DatabaseOperation op) {
    return [
      DatabaseOperation.runInsert,
      DatabaseOperation.runUpdate,
      DatabaseOperation.runDelete,
      DatabaseOperation.runBatched,
      DatabaseOperation.runCustom,
    ].contains(op);
  }

  // Helper to add node to either the stack top or the root
  void _addToActiveContext(DriftQueryEntryModel node) {
    _stack.isNotEmpty ? _stack.last.children.add(node) : _roots.add(node);
  }

  /// Helper to swap an old node with a new node in the hierarchy
  void _replaceNodeInTree(
    DriftQueryEntryModel oldNode,
    DriftQueryEntryModel newNode,
  ) {
    // If the stack has more than 1 item, the oldNode is a child of the 2nd to last item
    if (_stack.length > 1) {
      final parent = _stack[_stack.length - 2];
      final index = parent.children.indexOf(oldNode);
      if (index != -1) {
        parent.children[index] = newNode;
      }
    }
    // If the stack has 1 item, the oldNode is a root
    else if (_stack.length == 1) {
      final index = _roots.indexOf(oldNode);
      if (index != -1) {
        _roots[index] = newNode;
      }
    }
  }
}
