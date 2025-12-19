import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:log_box/log_box.dart';

part 'trace_log_entry_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class TraceLogEntryModel extends EntryModel {
  final String name;
  final List<LogEntryModel> logs;

  TraceLogEntryModel({
    super.id,
    super.timestamp,
    required this.name,
    this.logs = const [],
  });

  @override
  bool contains(String keyword) {
    return [
      name.contains(keyword),
      logs.any((element) => element.contains(keyword)),
    ].contains(true);
  }

  @override
  Map<String, dynamic> toJson() => _$TraceLogEntryModelToJson(this);

  factory TraceLogEntryModel.fromJson(Map<String, dynamic> json) {
    return _$TraceLogEntryModelFromJson(json);
  }

  @override
  String display() => 'Trace Log';

  @override
  TraceLogEntryModel merge(other) {
    if (other is! TraceLogEntryModel) return this;

    return TraceLogEntryModel(name: name, logs: [...other.logs, ...logs]);
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
      const Tab(text: 'Overview', icon: Icon(Icons.info, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Name',
                value: name,
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
    final slivers = [];
    for (final event in logs.reversed) {
      slivers.add(
        SliverToBoxAdapter(
          child: ExpansionTile(
            visualDensity: VisualDensity.compact,
            title: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: event.title(context),
                      ),
                      if (searchTerm != null && event.contains(searchTerm))
                        Positioned(
                          width: 6,
                          height: 6,
                          right: 0,
                          top: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: event.subtitle(context),
            showTrailingIcon: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HumanReadableWidget(
                  name: 'Message',
                  value: event.message,
                  searchTerm: searchTerm,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HumanReadableWidget(
                  name: 'Extra',
                  value: event.extra?.json,
                  searchTerm: searchTerm,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HumanReadableWidget(
                  name: 'Error',
                  value: event.error?.toString(),
                  searchTerm: searchTerm,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HumanReadableWidget(
                  name: 'Stack Trace',
                  value: event.stackTrace?.toString(),
                  searchTerm: searchTerm,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MapEntry(
      const Tab(text: 'Events', icon: Icon(Icons.event, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          ...slivers,
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
            const Icon(Icons.event, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
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
}
