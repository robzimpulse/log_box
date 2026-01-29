import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_persistent_storage_drift/src/model/drift_query_operation_model.dart';

part 'drift_query_entry_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DriftQueryEntryModel extends EntryModel {
  final List<DriftQueryOperationModel>? operations;
  final bool? loading;

  List<String> get operation {
    return [...?operations?.map((e) => e.operation).nonNulls];
  }

  List<Duration> get duration {
    return [...?operations?.map((e) => e.duration).nonNulls];
  }

  DriftQueryEntryModel({
    super.id,
    super.timestamp,
    this.operations,
    this.loading,
  });

  @override
  bool contains(String keyword) {
    return [
      ...?operations?.map((e) => e.contains(keyword)).nonNulls,
    ].contains(true);
  }

  @override
  String display() => 'Database Query';

  @override
  DriftQueryEntryModel merge(other) {
    if (other is! DriftQueryEntryModel) return this;
    return copyWith(operations: other.operations, loading: other.loading);
  }

  DriftQueryEntryModel copyWith({
    List<DriftQueryOperationModel>? operations,
    bool? loading,
  }) {
    return DriftQueryEntryModel(
      id: id,
      timestamp: timestamp,
      operations: [...?operations, ...?this.operations],
      loading: loading ?? this.loading,
    );
  }

  @override
  int tabLength(BuildContext context) => 2;

  @override
  Map<Tab, Widget> tabs(BuildContext context, {String? searchTerm}) {
    return Map.fromEntries([
      _overview(context, searchTerm: searchTerm),
      _events(context, searchTerm: searchTerm),
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
                value: operation.join(' > '),
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Duration',
                value: '${duration.fold(Duration.zero, (a, b) => a + b)}',
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

  MapEntry<Tab, Widget> _events(BuildContext context, {String? searchTerm}) {
    final items = operations?.reversed;
    return MapEntry(
      const Tab(
        text: 'Detail',
        icon: Icon(Icons.list, color: Colors.white),
      ),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverList.builder(
            itemBuilder: (context, index) {
              final item = items?.elementAtOrNull(index);
              return item?.display(context, searchTerm: searchTerm);
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  @override
  Widget title(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.storage, size: 16),
            const SizedBox(width: 8),
            if (loading == true) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                'Database Queries',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                operation.join('>'),
                maxLines: 1,
                style: Theme.of(context).textTheme.labelLarge,
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
