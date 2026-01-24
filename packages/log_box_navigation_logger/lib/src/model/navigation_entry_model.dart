import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enum/enum.dart';

part 'navigation_entry_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class NavigationEntryModel extends EntryModel {
  final NavigationAction action;
  final String? route;
  final String? argument;
  final String? previousRoute;
  final String? previousArgument;

  NavigationEntryModel({
    super.id,
    super.timestamp,
    required this.action,
    this.route,
    this.previousRoute,
    this.argument,
    this.previousArgument,
  });

  @override
  Map<String, dynamic> toJson() => _$NavigationEntryModelToJson(this);

  factory NavigationEntryModel.fromJson(Map<String, dynamic> json) {
    return _$NavigationEntryModelFromJson(json);
  }

  @override
  int tabLength(BuildContext context) => 2;

  @override
  Map<Tab, Widget> tabs(BuildContext context, {String? searchTerm}) {
    return Map.fromEntries([
      _overview(context, searchTerm: searchTerm),
      _details(context, searchTerm: searchTerm),
    ]);
  }

  MapEntry<Tab, Widget> _overview(BuildContext context, {String? searchTerm}) {
    return MapEntry(
      const Tab(
        text: 'Overview',
        icon: Icon(Icons.info, color: Colors.white),
      ),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Action',
                value: action.name,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Timestamp',
                value: timestamp.toIso8601String(),
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  MapEntry<Tab, Widget> _details(BuildContext context, {String? searchTerm}) {
    return MapEntry(
      const Tab(
        text: 'Detail',
        icon: Icon(Icons.list, color: Colors.white),
      ),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'From Route Name',
                value: previousRoute,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'From Route Arguments',
                value: previousArgument,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'To Route Name',
                value: route,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'To Route Arguments',
                value: argument,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
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
      argument?.toLowerCase().contains(keyword.toLowerCase()),
      previousRoute?.toLowerCase().contains(keyword.toLowerCase()),
      previousArgument?.toLowerCase().contains(keyword.toLowerCase()),
    ].nonNulls.contains(true);
  }

  @override
  String display() => 'Navigation';

  @override
  NavigationEntryModel merge(other) {
    if (other is! NavigationEntryModel) return this;
    return copyWith(
      previousRoute: other.previousRoute ?? previousRoute,
      previousArgument: other.previousArgument ?? previousArgument,
      route: other.route ?? route,
      argument: other.argument ?? argument,
    );
  }

  NavigationEntryModel copyWith({
    String? route,
    String? argument,
    String? previousRoute,
    String? previousArgument,
  }) {
    return NavigationEntryModel(
      id: id,
      timestamp: timestamp,
      action: action,
      route: route ?? this.route,
      argument: argument ?? this.argument,
      previousArgument: previousArgument ?? this.previousArgument,
      previousRoute: previousRoute ?? this.previousRoute,
    );
  }
}
