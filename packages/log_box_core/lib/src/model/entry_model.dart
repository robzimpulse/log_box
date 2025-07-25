import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class EntryModel {
  final String id;
  final DateTime timestamp;

  EntryModel({String? id, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.timestamp(),
      id = id ?? const Uuid().v4();

  /// Renders the title widget on dashboard screen.
  Widget title(BuildContext context);

  /// Renders the subtitle widget on dashboard screen.
  /// Default will be render timestamp
  Widget subtitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      timestamp.toIso8601String(),
      style: textTheme.labelSmall?.copyWith(color: Colors.grey),
    );
  }

  /// Renders the tab and its content on detail screen
  Map<Tab, Widget> tabs(BuildContext context);

  /// Logic for filtering in dashboard screen
  bool contains(String keyword);

  /// Logic for merging data with same types
  EntryModel merge(dynamic other);

  /// String that will be displayed on dashboard selector
  String display();
}
