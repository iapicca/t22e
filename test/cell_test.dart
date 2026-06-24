import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Cell', () {
    test('blank cell has default values', () {
      const cell = Cell.blank;
      expect(cell.character, ' ');
      expect(cell.foreground, isNull);
      expect(cell.background, isNull);
      expect(cell.styles, isEmpty);
    });

    test('copyWith overrides fields', () {
      const cell = Cell.blank;
      final updated = cell.copyWith(
        character: 'A',
        foreground: const Color.red(),
        styles: {CellStyle.bold},
      );
      expect(updated.character, 'A');
      expect(updated.foreground, const Color.red());
      expect(updated.styles, {CellStyle.bold});
    });

    test('equals another cell with same values', () {
      const a = Cell(character: 'X', foreground: Color.blue());
      const b = Cell(character: 'X', foreground: Color.blue());
      expect(a, b);
    });
  });
}
