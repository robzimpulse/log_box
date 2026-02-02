import '../enum/database_operation.dart';
import '../util/drift_log_builder.dart';

extension TreeVisualizerExtension on List<LogNode> {
  void debug() {
    if (isEmpty) {
      print('(No logs captured)');
      return;
    }

    print('┌─ Database Operation Log Tree ──────────────────────────────────');
    for (final (index, node) in indexed) {
      node.debug('', index == length - 1);
    }
    print('└──────────────────────────────────────────────────────────────');
  }
}

extension LeafVisualizerExtension on LogNode {
  void debug(String prefix, bool isLast) {
    final connector = isLast ? '└── ' : '├── ';

    String icon;
    // We calculate status for ALL node types now
    String statusInfo = "";

    // 1. Determine Status String
    if (isCompleted == true) {
      // It finished with a Commit or Rollback
      statusInfo = completionType == DatabaseOperation.commitTransaction
          ? " [Committed]"
          : " [Rolled Back]";
    } else if (operation == DatabaseOperation.beginTransaction) {
      // Only "Begin" should show "Active" if not completed.
      // Atomic ops (Delete/Insert) are instantaneous, so we don't say "Active".
      statusInfo = " [ACTIVE/OPEN]";
    }

    // 2. Determine Icon
    switch (operation) {
      case DatabaseOperation.beginTransaction:
        icon = "📂";
        break;
      case DatabaseOperation.commitTransaction:
        icon = "✅";
        break;
      case DatabaseOperation.rollbackTransaction:
        icon = "❌";
        break;
      case DatabaseOperation.runInsert:
        icon = "📥";
        break;
      case DatabaseOperation.runUpdate:
        icon = "📝";
        break;
      case DatabaseOperation.runDelete:
        icon = "🗑️ ";
        break;
      case DatabaseOperation.runSelect:
        icon = "🔍";
        break;
      default:
        icon = "🔹";
        break;
    }

    final t = timestamp;
    final timeStr = "${t.hour}:${t.minute}:${t.second}.${t.millisecond}";

    // 3. Print
    print('$prefix$connector$icon ${operation.rawValue} ($timeStr)$statusInfo');

    final childPrefix = prefix + (isLast ? '    ' : '│   ');

    // 6. Recurse
    for (final (index, child) in children.indexed) {
      child.debug(childPrefix, index == children.length - 1);
    }
  }
}
