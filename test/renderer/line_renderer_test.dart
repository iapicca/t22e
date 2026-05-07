import 'package:test/test.dart';
import 'package:t22e/src/renderer/line_renderer.dart';
import 'package:t22e/src/renderer/frame.dart';

void main() {
  group('LineRenderer', () {
    const renderer = LineRenderer();

    test('empty diff produces empty output', () {
      final diff = DiffResult([]);
      final frame = Frame([''], ['']);
      expect(renderer.render(diff, frame), '');
    });

    test('single changed row produces cursor move and content', () {
      final diff = DiffResult([0]);
      final frame = Frame(['Hi'], ['Hi']);
      final output = renderer.render(diff, frame);
      expect(output, '\x1b[1;0HHi');
    });

    test('multiple changed rows', () {
      final diff = DiffResult([0, 2]);
      final frame = Frame(['A', 'B', 'C'], ['A', 'B', 'C']);
      final output = renderer.render(diff, frame);
      expect(output, '\x1b[1;0HA\x1b[3;0HC');
    });

    test('row beyond current height is skipped', () {
      final diff = DiffResult([5]);
      final frame = Frame(['A'], ['A']);
      expect(renderer.render(diff, frame), '');
    });

    test('full frame outputs every row', () {
      final frame = Frame(['A', 'B'], ['A', 'B']);
      final diff = DiffResult([0, 1]);
      final output = renderer.render(diff, frame);
      expect(output, '\x1b[1;0HA\x1b[2;0HB');
    });
  });
}
