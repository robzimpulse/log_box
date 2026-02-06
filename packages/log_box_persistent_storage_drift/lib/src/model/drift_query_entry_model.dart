import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:log_box/log_box.dart';

import 'drift_log_node.dart';
import 'drift_query_operation_model.dart';
import '../extension/drift_query_operation_model_extension.dart';

part 'drift_query_entry_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DriftQueryEntryModel extends EntryModel {
  final List<DriftQueryOperationModel> operations;

  Duration get duration {
    return operations.fold(
      Duration.zero,
      (a, b) => a + (b.duration ?? Duration.zero),
    );
  }

  List<LogNode> get tree => operations.tree;

  DriftQueryEntryModel({super.id, super.timestamp, required this.operations});

  @override
  bool contains(String keyword) {
    return operations.any((e) => e.contains(keyword));
  }

  @override
  String display() => 'Database Query';

  @override
  DriftQueryEntryModel merge(other) {
    if (other is! DriftQueryEntryModel) return this;
    return DriftQueryEntryModel(
      operations: [...operations, ...other.operations],
    );
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
                name: 'Operation',
                value: operations.map((e) => e.operation.rawValue).join(' | '),
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Duration',
                value: '$duration',
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
    final children = tree.expand(
      (e) => e.widgets(context, searchTerm: searchTerm),
    );

    return MapEntry(
      const Tab(
        text: 'Detail',
        icon: Icon(Icons.list, color: Colors.white),
      ),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverList.separated(
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) => children.elementAtOrNull(index),
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
                operations.map((e) => e.operation.rawValue).join(' | '),
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
