import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'drift_query_operation_model.dart';

class LogNode {
  final DriftQueryOperationModel log;
  final List<LogNode> children;

  LogNode({required this.log}) : children = [];

  List<Widget> widgets(BuildContext context, {String? searchTerm}) {
    return [
      log.widget(context, searchTerm: searchTerm),
      for (final child in children)
        ...child
            .widgets(context, searchTerm: searchTerm)
            .map((e) => Padding(padding: EdgeInsets.only(left: 8), child: e)),
    ];
  }
}
