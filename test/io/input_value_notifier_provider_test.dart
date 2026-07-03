import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('inputValueProvider', () {
    test('starts with an empty list', () {
      final controller = StreamController<List<int>>(sync: true);
      final container = ProviderContainer(
        overrides: [inputStreamProvider.overrideWithValue(controller)],
      );
      addTearDown(container.dispose);
      addTearDown(() => controller.close());

      final notifier = container.read(inputValueProvider);
      expect(notifier.value, isEmpty);
    });

    test('updates value on stream events', () {
      final controller = StreamController<List<int>>(sync: true);
      final container = ProviderContainer(
        overrides: [inputStreamProvider.overrideWithValue(controller)],
      );
      addTearDown(container.dispose);
      addTearDown(() => controller.close());

      final notifier = container.read(inputValueProvider);
      final events = <List<int>>[];
      notifier.addListener(() => events.add(notifier.value));

      controller.add([65, 66]);
      expect(notifier.value, [65, 66]);
      expect(events, [
        [65, 66],
      ]);

      controller.add([67]);
      expect(notifier.value, [67]);
      expect(events, [
        [65, 66],
        [67],
      ]);
    });

    test('disposing container cancels subscription and disposes notifier', () {
      final controller = StreamController<List<int>>(sync: true);
      final container = ProviderContainer(
        overrides: [inputStreamProvider.overrideWithValue(controller)],
      );
      addTearDown(() => controller.close());

      final notifier = container.read(inputValueProvider);
      expect(notifier.isDisposed, isFalse);

      container.dispose();

      expect(notifier.isDisposed, isTrue);
      expect(controller.hasListener, isFalse);
    });

    test('same value does not notify listeners twice', () {
      final controller = StreamController<List<int>>(sync: true);
      final container = ProviderContainer(
        overrides: [inputStreamProvider.overrideWithValue(controller)],
      );
      addTearDown(container.dispose);
      addTearDown(() => controller.close());

      final notifier = container.read(inputValueProvider);
      var count = 0;
      notifier.addListener(() => count++);

      final value = [1];
      controller.add(value);
      controller.add(value);
      expect(count, 1);
    });
  });
}
