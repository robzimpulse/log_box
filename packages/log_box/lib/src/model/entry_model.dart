import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
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

  /// Total tabs count that will be rendered
  int tabLength(BuildContext context);

  /// Renders the tab and its content on detail screen
  Map<Tab, Widget> tabs(BuildContext context, {String? searchTerm});

  /// Renders the action menu on detail screen
  List<Widget> menus(BuildContext context, LogBox box) => [];

  /// Logic for filtering in dashboard screen
  bool contains(String keyword);

  /// Logic for merging data with same types
  EntryModel merge(dynamic other);

  /// String that will be displayed on dashboard selector
  String display();

  /// Convert to map
  Map<String, dynamic> toJson();
}
