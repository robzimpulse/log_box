import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:log_box/log_box.dart';

part 'drift_query_entry_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DriftQueryEntryModel extends EntryModel {
  final String? operation;
  final String? statement;
  final Duration? duration;
  final Map<String, dynamic>? arguments;
  final String? error;
  final String? stackTrace;

  DriftQueryEntryModel({
    super.id,
    super.timestamp,
    this.operation,
    this.statement,
    this.duration,
    this.arguments,
    this.error,
    this.stackTrace,
  });

  @override
  bool contains(String keyword) {
    return [
      statement?.toLowerCase().contains(keyword.toLowerCase()) ?? false,
      operation?.toLowerCase().contains(keyword.toLowerCase()) ?? false,
    ].contains(true);
  }

  @override
  String display() => 'Database Query';

  @override
  DriftQueryEntryModel merge(other) {
    if (other is! DriftQueryEntryModel) return this;
    return copyWith(
      operation: other.operation,
      statement: other.statement,
      duration: other.duration,
      arguments: other.arguments,
      error: other.error,
      stackTrace: other.stackTrace,
    );
  }

  DriftQueryEntryModel copyWith({
    String? operation,
    String? statement,
    Duration? duration,
    Map<String, dynamic>? arguments,
    String? error,
    String? stackTrace,
  }) {
    return DriftQueryEntryModel(
      id: id,
      timestamp: timestamp,
      operation: operation ?? this.operation,
      statement: statement ?? this.statement,
      duration: duration ?? this.duration,
      arguments: {...?arguments, ...?this.arguments},
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  int tabLength(BuildContext context) => 3;

  @override
  Map<Tab, Widget> tabs(BuildContext context, {String? searchTerm}) {
    return Map.fromEntries([
      _overview(context, searchTerm: searchTerm),
      _details(context, searchTerm: searchTerm),
      _errors(context, searchTerm: searchTerm),
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
                name: 'Operation',
                value: operation,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Duration',
                value: duration.toString(),
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
                name: 'Statement',
                value: statement,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Extra',
                value: arguments?.json,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  MapEntry<Tab, Widget> _errors(BuildContext context, {String? searchTerm}) {
    return MapEntry(
      const Tab(
        text: 'Error',
        icon: Icon(Icons.warning, color: Colors.white),
      ),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Error',
                value: error,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Stack Trace',
                value: stackTrace,
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
    final statement = this.statement;
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.storage, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                operation ?? 'Unknown Operation',
                maxLines: 1,
                style: Theme.of(context).textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (statement != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  statement,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$DriftQueryEntryModelToJson(this);

  factory DriftQueryEntryModel.fromJson(Map<String, dynamic> json) {
    return _$DriftQueryEntryModelFromJson(json);
  }
}
