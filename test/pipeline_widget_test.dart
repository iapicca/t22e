import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

import 'fake_iosink.dart';

void main() {
  group('Pipeline widget build pass', () {
    Pipeline pipeline(FakeIOSink sink) => Pipeline(
          ansiWriter: const AnsiWriter(),
          diffEngine: const DiffEngine(),
          stdoutInterface: StdoutWriter(sink: sink),
        );

    test('renders a Text app child full-screen end-to-end', () {
      final sink = FakeIOSink();
      pipeline(sink).renderWidget(const Text('hi'), const Size(5, 5));

      expect(sink.output, 'hi');
      expect(sink.flushes, const ['hi']);
    });

    test('builds the root with the current terminal size each frame', () {
      final sink = FakeIOSink();
      final p = pipeline(sink);

      p.renderWidget(const Text('hi'), const Size(5, 5));
      sink.clear();
      p.renderWidget(const Text('hi'), const Size(5, 5));

      expect(sink.output, isEmpty);
    });

    test('emits a minimal diff when the app child changes between frames', () {
      final sink = FakeIOSink();
      final p = pipeline(sink);

      p.renderWidget(const Text('hi'), const Size(5, 5));
      sink.clear();
      p.renderWidget(const Text('ho'), const Size(5, 5));

      expect(sink.output, '\x1B[1;2Ho');
    });
  });
}
