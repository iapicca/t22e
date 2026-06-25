import 'dart:async';

import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('StdinReader', () {
    test('forwards byte chunks to listeners', () async {
      final controller = StreamController<List<int>>(sync: true);
      final reader = StdinReader(source: controller.stream);
      addTearDown(reader.dispose);

      final events = <List<int>>[];
      reader.bytes.listen(events.add);

      controller.add([65, 66]);
      controller.add([67]);
      await Future.microtask(() {});

      expect(events, [
        [65, 66],
        [67],
      ]);
    });

    test('supports multiple listeners', () async {
      final controller = StreamController<List<int>>(sync: true);
      final reader = StdinReader(source: controller.stream);
      addTearDown(reader.dispose);

      final first = <List<int>>[];
      final second = <List<int>>[];
      reader.bytes.listen(first.add);
      reader.bytes.listen(second.add);

      controller.add([1, 2, 3]);
      await Future.microtask(() {});

      expect(first, [
        [1, 2, 3],
      ]);
      expect(second, [
        [1, 2, 3],
      ]);
    });

    test('forwards errors and completion', () async {
      final controller = StreamController<List<int>>(sync: true);
      final reader = StdinReader(source: controller.stream);
      addTearDown(reader.dispose);

      final errors = <Object?>[];
      var done = false;
      reader.bytes.listen(null, onError: errors.add, onDone: () => done = true);

      controller.addError('boom');
      await controller.close();
      await Future.microtask(() {});

      expect(errors, ['boom']);
      expect(done, isTrue);
    });

    test('dispose cancels subscription and closes stream', () async {
      final controller = StreamController<List<int>>(sync: true);
      final reader = StdinReader(source: controller.stream);

      var done = false;
      reader.bytes.listen(null, onDone: () => done = true);

      reader.dispose();
      await Future.microtask(() {});

      expect(done, isTrue);
      expect(controller.hasListener, isFalse);
    });
  });
}
