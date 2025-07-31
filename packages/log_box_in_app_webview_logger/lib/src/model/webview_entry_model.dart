import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';

import '../enum/enum.dart';

class WebviewEntryModelLog {
  final WebviewEvent event;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  WebviewEntryModelLog({required this.event, this.extra})
    : timestamp = DateTime.timestamp();
}

class WebviewEntryModel extends EntryModel {
  final Uri? uri;
  final List<String> scripts;
  final List<WebviewEntryModelLog> events;
  final String? html;
  final Object? error;
  final bool? loading;

  WebviewEntryModel({
    super.id,
    super.timestamp,
    this.uri,
    this.loading,
    this.scripts = const [],
    this.events = const [],
    this.html,
    this.error,
  });

  @override
  bool contains(String keyword) {
    return [
      uri?.path.toLowerCase().contains(keyword.toLowerCase()) ?? false,
      uri?.host.toLowerCase().contains(keyword.toLowerCase()) ?? false,
    ].contains(true);
  }

  @override
  String display() => 'Webview';

  @override
  WebviewEntryModel merge(other) {
    if (other is! WebviewEntryModel) return this;

    return WebviewEntryModel(
      id: id,
      timestamp: timestamp,
      loading: other.loading ?? loading,
      uri: other.uri ?? uri,
      scripts: [...other.scripts, ...scripts],
      events: [...other.events, ...events],
      html: other.html ?? html,
      error: other.error ?? error,
    );
  }

  @override
  Map<Tab, Widget> tabs(BuildContext context) {
    return Map.fromEntries([
      _overview(context),
      _html(context),
      _events(context),
      _error(context),
    ]);
  }

  @override
  Widget title(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.web, size: 16),
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
                uri?.path ?? '/',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${uri?.host} (${events.length})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
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
              child: HumanReadableWidget(name: 'url', value: uri.toString()),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'scripts',
                value: jsonEncode(scripts),
              ),
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

  MapEntry<Tab, Widget> _events(BuildContext context) {
    final theme = Theme.of(context);

    final slivers = [];
    for (final event in events.reversed) {
      final json = event.extra?.json;
      if (json == null) {
        slivers.add(
          SliverToBoxAdapter(
            child: ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(
                event.event.name,
                maxLines: 1,
                style: theme.textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                event.timestamp.toIso8601String(),
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
            ),
          ),
        );
      } else {
        slivers.add(
          SliverToBoxAdapter(
            child: ExpansionTile(
              visualDensity: VisualDensity.compact,
              title: Text(
                event.event.name,
                maxLines: 1,
                style: theme.textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                event.timestamp.toIso8601String(),
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
              showTrailingIcon: event.extra?.json != null,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HumanReadableWidget(name: 'Extra', value: json),
                ),
              ],
            ),
          ),
        );
      }
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

  MapEntry<Tab, Widget> _html(BuildContext context) {
    return MapEntry(
      const Tab(text: 'Html', icon: Icon(Icons.html, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(name: 'Html', value: html),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  MapEntry<Tab, Widget> _error(BuildContext context) {
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
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  @override
  List<Widget> menus(BuildContext context, LogBox box) {
    final uri = this.uri;
    return [
      if (uri != null)
        IconButton(
          onPressed: () => box.webview(context: context, uri: uri),
          icon: Icon(Icons.public),
        ),
    ];
  }
}
