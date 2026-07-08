import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

import 'fake_iosink.dart';

void main() {
  group('Pipeline layout', () {
    test('seeds root with tight terminal constraints', () {
      final root = RenderRoot();
      final child = RenderText(text: 'hi');
      root.child = child;

      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter());
      final size = pipeline.layout(root, Size(80, 24));

      expect(size, Size(80, 24));
      expect(root.size, Size(80, 24));
      expect(child.size, Size(80, 24));
      expect(child.offset, Offset(0, 0));
    });

    test('sizes child to small terminal bounds', () {
      final root = RenderRoot();
      final child = RenderText(text: 'abcdefghijklmnopqrstuvwxyz');
      root.child = child;

      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter());
      pipeline.layout(root, Size(10, 5));

      expect(child.size, Size(10, 5));
    });
  });

  group('Pipeline paint', () {
    test('paints RenderText through RenderRoot into a CellBuffer', () {
      final root = RenderRoot();
      final child = RenderText(text: 'hi');
      root.child = child;

      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter());
      pipeline.layout(root, Size(5, 5));
      final buffer = pipeline.paint(root, Size(5, 5));

      expect(buffer.size, Size(5, 5));
      expect(buffer.get(0, 0).character, 'h');
      expect(buffer.get(1, 0).character, 'i');
    });

    test('fills unpainted cells with the default blank cell', () {
      final root = RenderRoot();
      root.child = RenderText(text: 'x');

      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter());
      pipeline.layout(root, Size(3, 3));
      final buffer = pipeline.paint(root, Size(3, 3));

      expect(buffer.get(0, 0).character, 'x');
      expect(buffer.get(1, 0).character, ' ');
      expect(buffer.get(0, 1).character, ' ');
    });

    test('paints styled RenderText cells', () {
      final root = RenderRoot();
      root.child = RenderText(
        text: 'A',
        foreground: const Color.red(),
        styles: const {CellStyle.bold},
      );

      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter());
      pipeline.layout(root, Size(2, 2));
      final buffer = pipeline.paint(root, Size(2, 2));

      final cell = buffer.get(0, 0);
      expect(cell.character, 'A');
      expect(cell.foreground, const Color.red());
      expect(cell.styles, contains(CellStyle.bold));
    });
  });

  group('Pipeline provider', () {
    test('provides a default pipeline instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final pipeline = container.read(pipelineProvider);

      expect(pipeline, isA<Pipeline>());
    });
  });

  group('Pipeline render', () {
    test('flushes ANSI output for a full frame', () {
      final sink = FakeIOSink();
      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter(sink: sink));
      final root = RenderRoot();
      root.child = RenderText(text: 'hi');

      pipeline.render(root, Size(5, 5));

      expect(sink.output, 'hi');
      expect(sink.flushes, const ['hi']);
    });

    test('emits an empty diff on an identical second frame', () {
      final sink = FakeIOSink();
      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter(sink: sink));
      final root = RenderRoot();
      root.child = RenderText(text: 'hi');

      pipeline.render(root, Size(5, 5));
      sink.clear();
      pipeline.render(root, Size(5, 5));

      expect(sink.output, isEmpty);
    });

    test('emits a minimal diff when content changes', () {
      final sink = FakeIOSink();
      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter(sink: sink));
      final root = RenderRoot();
      final text = RenderText(text: 'hi');
      root.child = text;

      pipeline.render(root, Size(5, 5));
      sink.clear();

      text.text = 'ho';
      pipeline.render(root, Size(5, 5));

      expect(sink.output, '\x1B[1;2Ho');
    });

    test('flushes a wide CJK glyph as a single write', () {
      final sink = FakeIOSink();
      final pipeline = Pipeline(ansiWriter: const AnsiWriter(), diffEngine: const DiffEngine(), stdoutInterface: StdoutWriter(sink: sink));
      final root = RenderRoot();
      root.child = RenderText(text: '漢');

      pipeline.render(root, const Size(5, 5));

      expect(sink.output, '漢');
      expect(sink.flushes, const ['漢']);
    });
  });
}
