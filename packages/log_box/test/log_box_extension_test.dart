import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box/src/extension/log_box_extension.dart';

void main() {
  group('LogBoxExtension', () {
    late LogBox logBox;

    setUp(() {
      logBox = LogBox(storage: Storage(liveDataStorage: MemoryStorage()));
    });

    test('log adds LogEntryModel to storage', () {
      logBox.log('test message', name: 'test name', extra: {'key': 'value'});
      
      final logs = logBox.storage.liveStorage.data;
      expect(logs.length, 1);
      expect(logs.first, isA<LogEntryModel>());
      final log = logs.first as LogEntryModel;
      expect(log.message, 'test message');
      expect(log.name, 'test name');
      expect(log.extra, {'key': 'value'});
    });

    test('tracer adds TraceLogEntryModel and wraps process', () async {
      final result = await logBox.tracer<String>('test tracer', (trace) async {
        trace(LogEntryModel(message: 'Inside trace'));
        return 'done';
      });

      expect(result, 'done');
      
      final logs = logBox.storage.liveStorage.data;
      // 1. Start
      // 2. Inside trace (merged because of same ID)
      // 3. Finish (merged)
      // Since MemoryStorage merges by ID, we should have 1 entry with multiple logs if merged correctly,
      // OR multiple entries if not.
      // TraceLogEntryModel.merge: return TraceLogEntryModel(name: name, logs: [...other.logs, ...logs]);
      
      expect(logs.length, 1);
      expect(logs.first, isA<TraceLogEntryModel>());
      final trace = logs.first as TraceLogEntryModel;
      expect(trace.name, 'test tracer');
      
      // logs: [Finish, Inside trace, Start] due to reverse order in merge? 
      // Let's check merge logic in TraceLogEntryModel: logs: [...other.logs, ...logs]
      // Initial: [Start]
      // After trace('Inside'): [...[Inside], ...[Start]] = [Inside, Start]
      // After 'Finish': [...[Finish], ...[Inside, Start]] = [Finish, Inside, Start]
      expect(trace.logs.length, 3);
      expect(trace.logs[2].message, 'Start');
      expect(trace.logs[1].message, 'Inside trace');
      expect(trace.logs[0].message, 'Finish');
    });

    test('log handles null error and stackTrace', () {
      logBox.log('test', error: null, stackTrace: null);
      final log = logBox.storage.liveStorage.data.first as LogEntryModel;
      expect(log.error, isNull);
      expect(log.stackTrace, isNull);
    });

    test('log handles non-null error and stackTrace', () {
      final error = Exception('err');
      final st = StackTrace.current;
      logBox.log('test', error: error, stackTrace: st);
      final log = logBox.storage.liveStorage.data.first as LogEntryModel;
      expect(log.error, 'Exception: err');
      expect(log.stackTrace, st.toString());
    });
    test('log handles null name and extra', () {
      logBox.log('test');
      final log = logBox.storage.liveStorage.data.first as LogEntryModel;
      expect(log.name, isNull);
      expect(log.extra, {});
    });

    test('log handles custom id', () {
      logBox.log('test', id: 'custom-id');
      final log = logBox.storage.liveStorage.data.first as LogEntryModel;
      expect(log.id, 'custom-id');
    });

    test('tracer handles synchronous process', () async {
      final result = await logBox.tracer<int>('sync tracer', (trace) {
        trace(LogEntryModel(message: 'Sync log'));
        return 42;
      });

      expect(result, 42);
      final trace = logBox.storage.liveStorage.data.first as TraceLogEntryModel;
      expect(trace.logs.length, 3);
    });
  });
}
