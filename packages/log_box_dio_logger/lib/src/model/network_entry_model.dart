import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';

import 'http_error_model.dart';
import 'http_request_model.dart';
import 'http_response_model.dart';
import '../extension/extension.dart';

class NetworkEntryModel extends EntryModel {
  final String? client;
  final bool? loading;
  final String? method;
  final Uri? uri;
  final HttpRequestModel? request;
  final HttpResponseModel? response;
  final HttpErrorModel? error;

  NetworkEntryModel({
    super.id,
    super.timestamp,
    this.client,
    this.loading = true,
    this.method,
    this.uri,
    this.request,
    this.response,
    this.error,
  });

  NetworkEntryModel copyWith({
    bool? loading,
    HttpRequestModel? request,
    HttpResponseModel? response,
    HttpErrorModel? error,
  }) {
    return NetworkEntryModel(
      id: id,
      timestamp: timestamp,
      client: client,
      loading: loading ?? this.loading,
      method: method,
      uri: uri,
      request: request ?? this.request,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }

  @override
  String toString() => 'NetworkEntryModel($uri)';

  @override
  bool contains(String keyword) {
    return [
      uri?.path.toLowerCase().contains(keyword.toLowerCase()) ?? false,
      uri?.host.toLowerCase().contains(keyword.toLowerCase()) ?? false,
      response?.status.toString().contains(keyword.toLowerCase()) ?? false,
      method?.toLowerCase().contains(keyword.toLowerCase()) ?? false,
    ].contains(true);
  }

  @override
  String display() => 'Network';

  @override
  NetworkEntryModel merge(other) {
    if (other is! NetworkEntryModel) return this;
    return NetworkEntryModel(
      id: id,
      timestamp: timestamp,
      client: client,
      method: method,
      uri: uri,
      loading: other.loading ?? loading,
      request: other.request ?? request,
      response: other.response ?? response,
      error: other.error ?? error,
    );
  }

  @override
  int tabLength(BuildContext context) => 4;

  @override
  Map<Tab, Widget> tabs(BuildContext context, {String? searchTerm}) {
    return Map.fromEntries([
      _overview(context, searchTerm: searchTerm),
      _request(context, searchTerm: searchTerm),
      _response(context, searchTerm: searchTerm),
      _errors(context, searchTerm: searchTerm),
    ]);
  }

  @override
  Widget title(BuildContext context) {
    final theme = Theme.of(context);

    Color? color() {
      final status = response?.status;
      if (status == null) return null;
      if (status >= 200 && status < 300) {
        return Colors.green;
      } else if (status >= 300 && status < 400) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }

    Widget status0(BuildContext context) {
      if (loading == true) {
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(),
        );
      }

      final status = response?.status;
      if (status != null) {
        return Text(
          '$status',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(color: color()),
        );
      }

      return Text(
        'ERROR',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(color: Colors.red),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.public, size: 16, color: color()),
            const SizedBox(width: 8),
            status0(context),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${method ?? 'Undefined'} ${uri?.path}',
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
                '${uri?.host}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ],
    );
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
                name: 'Method',
                value: method,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Url',
                value: uri.toString(),
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

  MapEntry<Tab, Widget> _request(BuildContext context, {String? searchTerm}) {
    return MapEntry(
      const Tab(text: 'Detail', icon: Icon(Icons.list, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Timestamp',
                value: request?.time.toIso8601String(),
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Headers',
                value: request?.headers?.json,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Query',
                value: request?.queryParameters.json,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Size (bytes)',
                value: request?.size.toString(),
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Body',
                value: request?.body,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  MapEntry<Tab, Widget> _response(BuildContext context, {String? searchTerm}) {
    return MapEntry(
      const Tab(text: 'Response', icon: Icon(Icons.list, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Timestamp',
                value: response?.time.toIso8601String(),
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Size (bytes)',
                value: response?.size.toString(),
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Headers',
                value: response?.headers?.json,
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Body',
                value: response?.body,
                image: response?.image,
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
      const Tab(text: 'Error', icon: Icon(Icons.warning, color: Colors.white)),
      CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Error',
                value: error?.error.toString(),
                searchTerm: searchTerm,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: HumanReadableWidget(
                name: 'Stack Trace',
                value: error?.stackTrace.toString(),
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
  List<Widget> menus(BuildContext context, LogBox box) {
    return [
      IconButton(
        onPressed: () => curl.copyToClipboard(context: context),
        icon: Icon(Icons.copy),
      ),
    ];
  }
}
