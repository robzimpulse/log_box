import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';

import 'http_error_model.dart';
import 'http_request_model.dart';
import 'http_response_model.dart';

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
  bool contains(String keyword) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  String display() {
    // TODO: implement display
    throw UnimplementedError();
  }

  @override
  EntryModel merge(other) {
    // TODO: implement merge
    throw UnimplementedError();
  }

  @override
  Map<Tab, Widget> tabs(BuildContext context) {
    // TODO: implement tabs
    throw UnimplementedError();
  }

  @override
  Widget title(BuildContext context) {
    // TODO: implement title
    throw UnimplementedError();
  }
}






