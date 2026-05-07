import 'package:test/test.dart';
import '../../lib/src/core/cell.dart';
import '../../lib/src/core/style.dart';
import '../../lib/src/core/surface.dart';
import '../../lib/src/renderer/cell_renderer.dart';
import '../../lib/src/renderer/frame.dart';

void main() {
  group('CellRenderer', () {
    late CellRenderer renderer;

    setUp(() {
      renderer = const CellRenderer();
    });

    test('empty output when frames are identical', () {
      final surface = Surface(3, 1);
      surface.putText(0, 0, 'abc', TextStyle.empty);
      final prev = Frame.fromSurface(surface, includeCells: true);
      final curr = Frame.fromSurface(surface, includeCells: true);
      expect(renderer.render(prev, curr), isEmpty);
    });

    test('emits cursor move and char on single cell change', () {
      final prevSurface = Surface(3, 1);
      prevSurface.putText(0, 0, 'abc', TextStyle.empty);
      final currSurface = Surface(3, 1);
      currSurface.putText(0, 0, 'axc', TextStyle.empty);
      final prev = Frame.fromSurface(prevSurface, includeCells: true);
      final curr = Frame.fromSurface(currSurface, includeCells: true);
      final output = renderer.render(prev, curr);
      expect(output, contains('\x1b[1;2H'));
      expect(output, contains('x'));
    });

    test('emits SGR when style changes', () {
      final prevSurface = Surface(3, 1);
      prevSurface.putText(0, 0, 'abc', TextStyle.empty);
      final currSurface = Surface(3, 1);
      currSurface.putText(0, 0, 'abc', const TextStyle(bold: true));
      final prev = Frame.fromSurface(prevSurface, includeCells: true);
      final curr = Frame.fromSurface(currSurface, includeCells: true);
      final output = renderer.render(prev, curr);
      expect(output, contains('\x1b[1m'));
    });

    test('handles wide characters correctly', () {
      final prevSurface = Surface(4, 1);
      prevSurface.putText(0, 0, 'ab', TextStyle.empty);
      final currSurface = Surface(4, 1);
      currSurface.putText(0, 0, '\u{4E2D}c', TextStyle.empty);
      final prev = Frame.fromSurface(prevSurface, includeCells: true);
      final curr = Frame.fromSurface(currSurface, includeCells: true);
      final output = renderer.render(prev, curr);
      expect(output, contains('\x1b[1;1H'));
      expect(output, contains('\u{4E2D}'));
    });

    test('emits all cells when no previous frame', () {
      final currSurface = Surface(3, 2);
      currSurface.putText(0, 0, 'ab', TextStyle.empty);
      currSurface.putText(0, 1, 'cd', TextStyle.empty);
      final empty = Frame([], [], cells: []);
      final curr = Frame.fromSurface(currSurface, includeCells: true);
      final output = renderer.render(empty, curr);
      expect(output, contains('\x1b[1;1H'));
      expect(output, contains('\x1b[2;1H'));
    });

    test('handles resize gracefully', () {
      final smallSurface = Surface(2, 1);
      smallSurface.putText(0, 0, 'ab', TextStyle.empty);
      final largeSurface = Surface(4, 2);
      largeSurface.putText(0, 0, 'abcd', TextStyle.empty);
      largeSurface.putText(0, 1, 'efgh', TextStyle.empty);
      final prev = Frame.fromSurface(smallSurface, includeCells: true);
      final curr = Frame.fromSurface(largeSurface, includeCells: true);
      final output = renderer.render(prev, curr);
      expect(output, isNotEmpty);
    });
  });
}
