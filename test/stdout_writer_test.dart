import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

import 'fake_iosink.dart';

void main() {
  group('StdoutWriter', () {
    test('writes and flushes an ANSI string', () {
      final sink = FakeIOSink();
      final writer = StdoutWriter(sink: sink);

      writer.write('hello');

      expect(sink.output, 'hello');
      expect(sink.flushes, const ['hello']);
    });

    test('provider exposes a default stdout writer instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final writer = container.read(stdoutInterfaceProvider);

      expect(writer, isA<StdoutWriter>());
    });
  });
}
