import 'package:test/test.dart';
import 'package:t22e/src/core/cell.dart';
import 'package:t22e/src/core/style.dart';

void main() {
  group('Cell', () {
    test('default cell has space char and empty style', () {
      const cell = Cell();
      expect(cell.char, ' ');
      expect(cell.style, TextStyle.empty);
      expect(cell.wideContinuation, isFalse);
    });

    test('custom cell construction', () {
      const style = TextStyle(bold: true);
      const cell = Cell(char: 'A', style: style, wideContinuation: true);
      expect(cell.char, 'A');
      expect(cell.style, style);
      expect(cell.wideContinuation, isTrue);
    });

    test('copyWith preserves unchanged fields', () {
      const cell = Cell(char: 'X', style: TextStyle.empty, wideContinuation: false);
      final copy = cell.copyWith(char: 'Y');
      expect(copy.char, 'Y');
      expect(copy.style, cell.style);
      expect(copy.wideContinuation, cell.wideContinuation);
    });

    test('mergeStyle creates merged style', () {
      const cell = Cell(char: 'A');
      const override = TextStyle(bold: true);
      final merged = cell.mergeStyle(override);
      expect(merged.style.bold, isTrue);
      expect(merged.char, 'A');
    });

    test('equality', () {
      const style = TextStyle(bold: true);
      const a = Cell(char: 'A', style: style);
      const b = Cell(char: 'A', style: style);
      const c = Cell(char: 'B', style: style);
      expect(a == b, isTrue);
      expect(a == c, isFalse);
    });

    test('hashCode consistent with equality', () {
      const a = Cell(char: 'A');
      const b = Cell(char: 'A');
      expect(a.hashCode, b.hashCode);
    });
  });
}
