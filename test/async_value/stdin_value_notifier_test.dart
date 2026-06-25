import 'dart:async';

import 'package:t22e/t22e.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

/// Pumps the microtask queue so async stream events are delivered.
Future<void> _pump() => Future.microtask(() {});

void main() {
  group('stdinValueNotifierProvider', () {
    test('starts with an empty list', () {
      final controller = StreamController<List<int>>();
      final container = ProviderContainer(
        overrides: [stdinStreamProvider.overrideWithValue(controller.stream)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(stdinValueNotifierProvider);
      expect(notifier.value, isEmpty);
    });

    test('updates value on stream events', () async {
      final controller = StreamController<List<int>>();
      final container = ProviderContainer(
        overrides: [stdinStreamProvider.overrideWithValue(controller.stream)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(stdinValueNotifierProvider);
      final events = <List<int>>[];
      notifier.addListener(() => events.add(notifier.value));

      controller.add([65, 66]);
      await _pump();
      expect(notifier.value, [65, 66]);
      expect(events, [
        [65, 66],
      ]);

      controller.add([67]);
      await _pump();
      expect(notifier.value, [67]);
      expect(events, [
        [65, 66],
        [67],
      ]);
    });

    test('disposing container cancels subscription and disposes notifier', () {
      final controller = StreamController<List<int>>();
      final container = ProviderContainer(
        overrides: [stdinStreamProvider.overrideWithValue(controller.stream)],
      );

      final notifier = container.read(stdinValueNotifierProvider);
      expect(notifier.isDisposed, isFalse);

      container.dispose();

      expect(notifier.isDisposed, isTrue);
      expect(controller.hasListener, isFalse);
    });

    test('same value does not notify listeners twice', () async {
      final controller = StreamController<List<int>>();
      final container = ProviderContainer(
        overrides: [stdinStreamProvider.overrideWithValue(controller.stream)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(stdinValueNotifierProvider);
      var count = 0;
      notifier.addListener(() => count++);

      final value = [1];
      controller.add(value);
      await _pump();
      controller.add(value);
      await _pump();
      expect(count, 1);
    });
  });
}
