import '../enum/database_operation.dart';
import '../model/drift_log_node.dart';
import '../model/drift_query_operation_model.dart';

extension TreeBuilderExtension on List<DriftQueryOperationModel> {
  List<LogNode> get tree {
    final List<LogNode> rootNodes = [];
    final List<LogNode> stack = [];

    for (final log in this) {
      final newNode = LogNode(log: log);

      if (log.operation == DatabaseOperation.beginTransaction) {
        // If stack is not empty, this is a nested transaction (if supported)
        if (stack.isNotEmpty) {
          stack.last.children.add(newNode);
        } else {
          rootNodes.add(newNode);
        }
        stack.add(newNode);
      } else if (log.operation == DatabaseOperation.commitTransaction ||
          log.operation == DatabaseOperation.rollbackTransaction) {
        if (stack.isNotEmpty) {
          stack.last.children.add(newNode);
          stack.removeLast(); // Close the current transaction scope
        } else {
          // Orphaned commit/rollback: add to root
          rootNodes.add(newNode);
        }
      } else {
        // Regular operation: Add to current transaction or root
        if (stack.isNotEmpty) {
          stack.last.children.add(newNode);
        } else {
          rootNodes.add(newNode);
        }
      }
    }

    return rootNodes;
  }
}
