import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/extension/change_notifier_selector_stream.dart';

class MockNotifier extends ChangeNotifier {
  int _value = 0;
  int get value => _value;
  set value(int v) {
    _value = v;
    notifyListeners();
  }
}

void main() {
  group('ChangeNotifierSelector', () {
    test('stream emits initial and updated values', () async {
      final notifier = MockNotifier();
      final stream = notifier.stream(() => notifier.value);

      final expectations = [0, 1, 2];
      var index = 0;

      final subscription = stream.listen((value) {
        expect(value, expectations[index++]);
      });

      notifier.value = 1;
      notifier.value = 2;

      // Allow some time for stream events
      await Future.delayed(Duration.zero);
      expect(index, 3);
      
      await subscription.cancel();
    });

    test('stream closes on error in selector', () async {
      final notifier = MockNotifier();
      final stream = notifier.stream(() => throw Exception('error'));

      expect(stream, emitsDone);
    });
  });
}
