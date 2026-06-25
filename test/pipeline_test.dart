import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Pipeline layout', () {
    test('seeds root with tight terminal constraints', () {
      final root = RenderRoot();
      final child = RenderText(text: 'hi');
      root.child = child;

      final pipeline = Pipeline();
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

      final pipeline = Pipeline();
      pipeline.layout(root, Size(10, 5));

      expect(child.size, Size(10, 5));
    });
  });

  group('Pipeline paint', () {
    test('paints RenderText through RenderRoot into a CellBuffer', () {
      final root = RenderRoot();
      final child = RenderText(text: 'hi');
      root.child = child;

      final pipeline = Pipeline();
      pipeline.layout(root, Size(5, 5));
      final buffer = pipeline.paint(root, Size(5, 5));

      expect(buffer.size, Size(5, 5));
      expect(buffer.get(0, 0).character, 'h');
      expect(buffer.get(1, 0).character, 'i');
    });

    test('fills unpainted cells with the default blank cell', () {
      final root = RenderRoot();
      root.child = RenderText(text: 'x');

      final pipeline = Pipeline();
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

      final pipeline = Pipeline();
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
}
