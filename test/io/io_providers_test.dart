import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

Future<void> _pump() => Future.microtask(() {});

void main() {
  group('IO providers', () {
    test('stdinReaderProvider exposes a StdinReader', () async {
      final controller = StreamController<List<int>>.broadcast();
      final reader = StdinReader(source: controller.stream);
      final container = ProviderContainer(
        overrides: [stdinReaderProvider.overrideWithValue(reader)],
      );
      addTearDown(container.dispose);

      final value = container.read(stdinReaderProvider);

      expect(value, same(reader));

      controller.add([1, 2]);
      await _pump();
      expect(value.bytes.isBroadcast, isTrue);
    });

    test('ansiParserProvider exposes an AnsiParser', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final parser = container.read(ansiParserProvider);

      expect(parser, isA<AnsiParser>());
    });

    test('stdinStreamProvider exposes a broadcast stream', () async {
      final controller = StreamController<List<int>>.broadcast();
      final reader = StdinReader(source: controller.stream);
      final container = ProviderContainer(
        overrides: [stdinReaderProvider.overrideWithValue(reader)],
      );
      addTearDown(container.dispose);

      final stream = container.read(stdinStreamProvider);
      final events = <List<int>>[];
      stream.listen(events.add);

      expect(stream.isBroadcast, isTrue);

      controller.add([1, 2, 3]);
      await _pump();

      expect(events, [
        [1, 2, 3],
      ]);
    });
  });
}
