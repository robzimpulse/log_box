import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enum/enum.dart';

part 'navigation_entry_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
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
  Map<String, dynamic> toJson() => _$NavigationEntryModelToJson(this);

  factory NavigationEntryModel.fromJson(Map<String, dynamic> json) {
    return _$NavigationEntryModelFromJson(json);
  }

  @override
  int tabLength(BuildContext context) => 0;

  @override
  Map<Tab, Widget> tabs(BuildContext context, {String? searchTerm}) {
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

    final preposition = switch (action) {
      NavigationAction.push => 'To',
      NavigationAction.pop => 'From',
      NavigationAction.remove => 'Route',
      NavigationAction.replace => 'With',
    };

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(child: Icon(icon, size: 16, color: color)),
          WidgetSpan(child: SizedBox(width: 8)),
          TextSpan(
            text: action.name.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
          TextSpan(text: ' $preposition '),
          TextSpan(text: route),
        ],
      ),
      style: theme.textTheme.labelLarge,
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
  NavigationEntryModel merge(other) {
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
