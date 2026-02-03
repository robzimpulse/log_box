import '../enum/database_operation.dart';
import '../model/drift_query_entry_model.dart';

extension TreeVisualizerExtension on List<DriftQueryEntryModel> {
  String get visualize {
    final buffer = StringBuffer();

    if (isEmpty) {
      return '(No logs captured)';
    }

    buffer.writeln(
      '┌─ Drift Query Log Tree ─────────────────────────────────────────',
    );
    for (final (index, child) in indexed) {
      child.debug(buffer, '', index == length - 1);
    }
    buffer.write(
      '└────────────────────────────────────────────────────────────────',
    );

    return buffer.toString();
  }
}

extension LeafVisualizerExtension on DriftQueryEntryModel {
  void debug(StringBuffer buffer, String prefix, bool isLast) {
    // 1. Setup
    final connector = isLast ? '└── ' : '├── ';

    // 2. Icon
    final icon = switch (operation) {
      DatabaseOperation.beginTransaction => '📂',
      DatabaseOperation.commitTransaction => '✅',
      DatabaseOperation.rollbackTransaction => '❌',
      DatabaseOperation.runBatched => '📦',
      DatabaseOperation.runCustom => '⚙️',
      DatabaseOperation.runDelete => '🗑',
      DatabaseOperation.runInsert => '📥',
      DatabaseOperation.runSelect => '🔍',
      DatabaseOperation.runUpdate => '📝',
      DatabaseOperation.unknown => '🔹',
    };
    String statusInfo = "";

    // Calculate Status (Committed vs Active)
    if (isComplete == true) {
      if (completionType == DatabaseOperation.commitTransaction) {
        statusInfo = " [Committed]";
      } else if (completionType == DatabaseOperation.rollbackTransaction) {
        statusInfo = " [Rolled Back]";
      }
    } else if (operation == DatabaseOperation.beginTransaction) {
      // Only show "Active" for unclosed transactions
      statusInfo = " [ACTIVE/OPEN]";
    }

    // 3. Format Timings

    // final t = data.timestamp;
    final timeStr = [
      timestamp.hour.toString().padLeft(2, '0'),
      timestamp.minute.toString().padLeft(2, '0'),
      timestamp.second.toString().padLeft(2, '0'),
      timestamp.millisecond.toString().padLeft(3, '0'),
    ].join(':');

    // Only show duration if it exists (e.g. " (15ms)")
    final duration = this.duration;
    final durationStr = duration != null
        ? " (${duration.inMilliseconds}ms)"
        : "";

    // 4. Write The Main Row
    buffer.writeln(
      '$prefix$connector$icon ${operation.rawValue} ($timeStr)$durationStr$statusInfo',
    );

    // 5. Write Details (Errors & SQL Statements)
    // We add extra indentation to align these under the text, not the tree lines
    final detailPrefix = "$prefix${isLast ? '    ' : '│   '}   ";

    // Write Error if present
    if (error != null) {
      buffer.writeln('$detailPrefix⚠️  ERROR: $error');
      if (stackTrace != null) {
        // Optional: Print first line of stack trace to keep it clean
        final stackLine = stackTrace.toString().split('\n').first;
        buffer.writeln('$detailPrefix   Stack: $stackLine');
      }
    }

    // Write SQL Statements
    if (statements.isNotEmpty) {
      for (var stmt in statements) {
        // clean up newlines for compact logging
        final cleanStmt = stmt.replaceAll('\n', ' ').trim();
        buffer.writeln('$detailPrefix$cleanStmt');
      }
    }

    // 6. Recursion for Children
    final childPrefix = prefix + (isLast ? '    ' : '│   ');
    for (final (index, child) in children.indexed) {
      child.debug(buffer, childPrefix, index == children.length - 1);
    }
  }
}
