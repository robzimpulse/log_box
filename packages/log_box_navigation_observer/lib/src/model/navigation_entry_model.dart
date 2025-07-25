import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';

import '../enum/enum.dart';

class NavigationEntryModel extends EntryModel {
  final NavigationAction action;
  final String? route;
  final String? previousRoute;

  NavigationEntryModel({
    super.id,
    super.timestamp,
    required this.action,
    this.route,
    this.previousRoute,
  });

  @override
  Map<Tab, Widget> tabs(BuildContext context) {
    return {};
  }

  @override
  Widget title(BuildContext context) {
    final theme = Theme.of(context);

    final icon = switch (action) {
      NavigationAction.push => Icons.arrow_forward,
      NavigationAction.pop => Icons.arrow_back,
      NavigationAction.remove => Icons.remove,
      NavigationAction.replace => Icons.change_circle,
    };

    final color = switch (action) {
      NavigationAction.push => Colors.green,
      NavigationAction.pop => Colors.red,
      NavigationAction.remove => Colors.grey,
      NavigationAction.replace => Colors.blue,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              action.name.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
        Text('Route: $route', style: theme.textTheme.labelMedium),
        Text('Previous: $previousRoute', style: theme.textTheme.labelMedium),
      ],
    );
  }

  @override
  bool contains(String keyword) {
    return [
      route?.toLowerCase().contains(keyword.toLowerCase()),
      previousRoute?.toLowerCase().contains(keyword.toLowerCase()),
    ].nonNulls.contains(true);
  }

  @override
  String display() => 'Navigation';

  @override
  EntryModel merge(other) {
    if (other is! NavigationEntryModel) return this;
    return copyWith(
      previousRoute: other.previousRoute ?? previousRoute,
      route: other.route ?? route,
    );
  }

  NavigationEntryModel copyWith({String? route, String? previousRoute}) {
    return NavigationEntryModel(
      id: id,
      timestamp: timestamp,
      action: action,
      route: route ?? this.route,
      previousRoute: previousRoute ?? this.previousRoute,
    );
  }
}
