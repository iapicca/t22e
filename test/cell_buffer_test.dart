import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('CellBuffer', () {
    test('exposes width, area, and derived size', () {
      final buffer = CellBuffer(width: 4, cells: List.filled(12, Cell.blank));
      expect(buffer.width, 4);
      expect(buffer.size.area, 12);
      expect(buffer.size, Size(4, 3));
    });

    test('coordinate helpers are inverse', () {
      final buffer = CellBuffer(width: 4, cells: List.filled(12, Cell.blank));
      expect(buffer.indexAt(2, 1), 6);
      expect(buffer.offsetAt(6), Offset(2, 1));
    });

    test('set returns a new buffer and leaves the original unchanged', () {
      final original = CellBuffer(width: 2, cells: List.filled(4, Cell.blank));
      final updated = original.set(1, 0, Cell(character: 'X'));
      expect(original.get(1, 0).character, ' ');
      expect(updated.get(1, 0).character, 'X');
    });

    test('throws on out-of-bounds access', () {
      final buffer = CellBuffer(width: 2, cells: List.filled(4, Cell.blank));
      expect(() => buffer.get(2, 0), throwsA(isA<RangeError>()));
      expect(() => buffer.getAt(4), throwsA(isA<RangeError>()));
    });
  });
}
