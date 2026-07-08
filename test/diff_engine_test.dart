import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('DiffEngine', () {
    const engine = DiffEngine();

    CellBuffer blankBuffer(int width, int height) => CellBuffer(
      width: width,
      cells: List.filled(width * height, Cell.blank),
    );

    test('returns no operations for identical buffers', () {
      final buffer = blankBuffer(3, 3);

      final ops = engine.diff(buffer, buffer, Size(3, 3));

      expect(ops, isEmpty);
    });

    test('writes a single changed cell without moving the cursor', () {
      final current = blankBuffer(3, 3);
      final target = current.set(0, 0, const Cell(character: Grapheme('A')));

      final ops = engine.diff(target, current, Size(3, 3));

      expect(ops, const [DiffOpWrite('A')]);
    });

    test('emits a cursor move when the next change is not sequential', () {
      final current = blankBuffer(3, 3);
      final target = current.set(2, 0, const Cell(character: Grapheme('A')));

      final ops = engine.diff(target, current, Size(3, 3));

      expect(ops, const [DiffOpMove(Offset(2, 0)), DiffOpWrite('A')]);
    });

    test('only emits style changes on style transitions', () {
      final current = blankBuffer(2, 1);
      final target = CellBuffer(
        width: 2,
        cells: const [
          Cell(
            character: Grapheme('A'),
            foreground: Color.red(),
            styles: {CellStyle.bold},
          ),
          Cell(
            character: Grapheme('B'),
            foreground: Color.red(),
            styles: {CellStyle.bold},
          ),
        ],
      );

      final ops = engine.diff(target, current, Size(2, 1));

      expect(ops.length, 3);
      expect(
        ops[0],
        const DiffOpStyle(
          Cell(
            character: Grapheme(' '),
            foreground: Color.red(),
            styles: {CellStyle.bold},
          ),
        ),
      );
      expect(ops[1], const DiffOpWrite('A'));
      expect(ops[2], const DiffOpWrite('B'));
    });

    test('resets style when returning to default', () {
      final current = blankBuffer(2, 1);
      final target = CellBuffer(
        width: 2,
        cells: const [
          Cell(character: Grapheme('A'), foreground: Color.red()),
          Cell(character: Grapheme('B')),
        ],
      );

      final ops = engine.diff(target, current, Size(2, 1));

      expect(ops.length, 4);
      expect(
        ops[0],
        const DiffOpStyle(Cell(character: Grapheme(' '), foreground: Color.red())),
      );
      expect(ops[1], const DiffOpWrite('A'));
      expect(ops[2], const DiffOpStyle(Cell.blank));
      expect(ops[3], const DiffOpWrite('B'));
    });

    test('wide glyph produces one write and skips its continuation cell', () {
      final current = blankBuffer(3, 1);
      final primary = const Cell(character: Grapheme('漢'));
      final continuation = Cell(
        character: Grapheme.space,
        styles: const {CellStyle.continuation},
      );
      final target = current
          .set(0, 0, primary)
          .set(1, 0, continuation);

      final ops = engine.diff(target, current, const Size(3, 1));

      expect(ops, const [DiffOpWrite('漢')]);
    });

    test('copyTarget returns an equal buffer with independent storage', () {
      final target = CellBuffer(
        width: 2,
        cells: const [
          Cell(character: Grapheme('A')),
          Cell(character: Grapheme('B')),
        ],
      );

      final copy = engine.copyTarget(target);

      expect(copy, target);
      expect(identical(copy.cells, target.cells), isFalse);
    });

    test('provider exposes a default diff engine instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final engine = container.read(diffEngineProvider);

      expect(engine, isA<DiffEngine>());
    });
  });
}
