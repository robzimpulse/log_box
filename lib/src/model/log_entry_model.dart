import 'package:flutter/material.dart';

import '../widget/human_readable_widget.dart';
import '../common/extension.dart';
import 'entry_model.dart';

class LogEntryModel extends EntryModel {
  final String message;
  final String? name;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extra;

  LogEntryModel({
    super.id,
    super.timestamp,
    required this.message,
    this.extra,
    this.name,
    this.error,
    this.stackTrace,
  });

  @override
  bool contains(String keyword) {
    return [
      message.toLowerCase().contains(keyword.toLowerCase()),
      name?.toLowerCase().contains(keyword.toLowerCase()),
    ].nonNulls.contains(true);
  }

  @override
  LogEntryModel merge(dynamic other) {
    if (other is! LogEntryModel) return this;

    return LogEntryModel(
      id: id,
      timestamp: timestamp,
      name: other.name ?? name,
      message: other.message,
      extra: other.extra ?? extra,
      error: other.error ?? error,
      stackTrace: other.stackTrace ?? stackTrace,
    );
  }

  @override
  Map<Tab, Widget> tabs(BuildContext context) {
    return Map.fromEntries([
      _overview(context),
      _details(context),
      _errors(context),
    ]);
  }

  @override
  Widget title(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.bug_report, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name ?? 'Logging',
                maxLines: 1,
                style: Theme.of(context).textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                message,
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

  MapEntry<Tab, Widget> _overview(BuildContext context) {
    return MapEntry(
      const Tab(text: 'Overview', icon: Icon(Icons.info, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(name: 'Name', value: name),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(name: 'Message', value: message),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Timestamp',
                value: timestamp.toIso8601String(),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  MapEntry<Tab, Widget> _details(BuildContext context) {
    return MapEntry(
      const Tab(text: 'Detail', icon: Icon(Icons.list, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(name: 'Extra', value: extra?.json),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  MapEntry<Tab, Widget> _errors(BuildContext context) {
    return MapEntry(
      const Tab(text: 'Error', icon: Icon(Icons.warning, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Error',
                value: error.toString(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Stack Trace',
                value: stackTrace.toString(),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  @override
  String display() => 'Log';
}
