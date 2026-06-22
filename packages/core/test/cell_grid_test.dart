import 'package:test/test.dart';
import 'package:core/core.dart';

void main() {
  group('CellGrid', () {
    test('empty grid has zero dimensions', () {
      const grid = CellGrid.empty();
      expect(grid.isEmpty, isTrue);
      expect(grid.height, 0);
      expect(grid.width, 0);
      expect(grid.row(0), isEmpty);
    });

    test('generate creates grid of correct dimensions', () {
      final grid = CellGrid.generate(const Size(5, 3));
      expect(grid.isEmpty, isFalse);
      expect(grid.height, 3);
      expect(grid.width, 5);
      for (final row in grid) {
        expect(row.length, 5);
        for (final cell in row) {
          expect(cell.char, ' ');
        }
      }
    });

    test('row access returns correct row', () {
      final grid = CellGrid.generate(const Size(3, 2));
      grid[0][1] = const Cell(char: 'X');
      expect(grid.row(0)[1].char, 'X');
      expect(grid[1][0].char, ' ');
    });

    test('row access on empty grid returns empty list', () {
      const grid = CellGrid.empty();
      expect(grid.row(0), isEmpty);
    });

    test('getCell returns cell at valid position', () {
      final grid = CellGrid.generate(const Size(3, 2));
      grid[1][2] = const Cell(char: 'Z');
      expect(grid.getCell(1, 2)!.char, 'Z');
    });

    test('getCell returns null for out of bounds', () {
      final grid = CellGrid.generate(const Size(3, 2));
      expect(grid.getCell(-1, 0), isNull);
      expect(grid.getCell(0, -1), isNull);
      expect(grid.getCell(2, 3), isNull);
      expect(grid.getCell(3, 0), isNull);
    });

    test('implements List interface', () {
      final grid = CellGrid.generate(const Size(2, 2));
      grid[0][0] = const Cell(char: 'A');
      expect(grid[0][0].char, 'A');
      expect(grid.length, 2);
      expect(grid.first[0].char, 'A');
    });
  });
}
