import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

Future<void> _pump() => Future.microtask(() {});

void main() {
  group('inputEventStreamProvider', () {
    test('parses stdin bytes into input events', () async {
      final controller = StreamController<List<int>>(sync: true);
      final container = ProviderContainer(
        overrides: [
          stdinStreamProvider.overrideWithValue(controller.stream),
        ],
      );
      addTearDown(container.dispose);

      final events = <InputEvent>[];
      container.read(inputEventStreamProvider).listen(events.add);

      controller.add([0x1B, 0x5B, 0x41]); // up arrow
      await _pump();

      expect(events, [const InputEvent.key(key: Key.up)]);
    });

    test('closes the event stream when stdin closes', () async {
      final controller = StreamController<List<int>>(sync: true);
      final container = ProviderContainer(
        overrides: [stdinStreamProvider.overrideWithValue(controller.stream)],
      );
      addTearDown(container.dispose);

      var done = false;
      container.read(inputEventStreamProvider).listen(
        null,
        onDone: () => done = true,
      );

      await controller.close();
      await _pump();

      expect(done, isTrue);
    });
  });
}
