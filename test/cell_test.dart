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
        character: Grapheme('A'),
        foreground: const Color.red(),
        styles: {CellStyle.bold},
      );
      expect(updated.character, 'A');
      expect(updated.foreground, const Color.red());
      expect(updated.styles, {CellStyle.bold});
    });

    test('equals another cell with same values', () {
      const a = Cell(character: Grapheme('X'), foreground: Color.blue());
      const b = Cell(character: Grapheme('X'), foreground: Color.blue());
      expect(a, b);
    });

    test('wide grapheme reports width 2', () {
      const cell = Cell(character: Grapheme('漢'));
      expect(cell.character.width, 2);
    });

    test('validated rejects multi-cluster strings', () {
      expect(() => Grapheme.validated('xy'), throwsArgumentError);
    });

    test('validated accepts combining-mark cluster', () {
      expect(Grapheme.validated('e\u{0301}').string, 'e\u{0301}');
    });
  });
}
