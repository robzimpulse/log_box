import 'dart:async';

import 'package:flutter/foundation.dart';

extension ChangeNotifierSelector on ChangeNotifier {
  /// Converts a specific property of the ChangeNotifier into a Stream
  Stream<T> stream<T>(T Function() selector) {
    late StreamController<T> controller;

    void listener() {
      if (!controller.isClosed) {
        // Extract the specific data using the selector
        controller.add(selector());
      }
    }

    controller = StreamController<T>(
      onListen: () {
        try {
          // Emit the CURRENT value immediately upon listening
          controller.add(selector());
          addListener(listener);
        } catch (e) {
          controller.close();
        }
      },
      onCancel: () {
        try {
          removeListener(listener);
        } catch (e) {
          // Ignore
        }
      },
    );

    return controller.stream;
  }
}
