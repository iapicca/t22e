import 'package:test/test.dart';
import 'package:core/core.dart';

void main() {
  group('Surface', () {
    test('constructs grid of correct dimensions', () {
      final s = Surface(10, 5);
      expect(s.width, 10);
      expect(s.height, 5);
      expect(s.grid.length, 5);
      expect(s.grid[0].length, 10);
      for (final row in s.grid) {
        for (final cell in row) {
          expect(cell.char, ' ');
        }
      }
    });

    test('putChar places character at position', () {
      final s = Surface(5, 3);
      s.putChar(2, 1, 'X', TextStyle.empty);
      expect(s.grid[1][2].char, 'X');
    });

    test('putChar clips out of bounds', () {
      final s = Surface(5, 3);
      s.putChar(10, 10, 'X', TextStyle.empty);
      expect(s.grid[2][4].char, ' ');
    });

    test('putChar with wide character marks continuation', () {
      final s = Surface(5, 3);
      s.putChar(2, 1, '文', TextStyle.empty);
      expect(s.grid[1][2].char, '文');
      expect(s.grid[1][3].wideContinuation, isTrue);
    });

    test('putChar with wide character at last column does not overflow', () {
      final s = Surface(5, 3);
      s.putChar(4, 1, '文', TextStyle.empty);
      expect(s.grid[1][4].char, '文');
    });

    test('putText places grapheme clusters', () {
      final s = Surface(10, 3);
      s.putText(1, 1, 'Hello', TextStyle.empty);
      expect(s.grid[1][1].char, 'H');
      expect(s.grid[1][2].char, 'e');
      expect(s.grid[1][3].char, 'l');
      expect(s.grid[1][4].char, 'l');
      expect(s.grid[1][5].char, 'o');
    });

    test('putText handles CJK wide characters', () {
      final s = Surface(10, 3);
      s.putText(1, 1, '文A', TextStyle.empty);
      expect(s.grid[1][1].char, '文');
      expect(s.grid[1][2].wideContinuation, isTrue);
      expect(s.grid[1][3].char, 'A');
    });

    test('putText clips at right edge', () {
      final s = Surface(5, 3);
      s.putText(3, 1, 'ABCDE', TextStyle.empty);
      expect(s.grid[1][3].char, 'A');
      expect(s.grid[1][4].char, 'B');
    });

    test('putText with x at or beyond width does nothing', () {
      final s = Surface(5, 3);
      s.putText(5, 1, 'Hi', TextStyle.empty);
      expect(s.grid[1][4].char, ' ');
    });

    test('fillRect fills region', () {
      final s = Surface(5, 5);
      s.fillRect(1, 1, 3, 3, '#', TextStyle.empty);
      for (var row = 1; row < 4; row++) {
        for (var col = 1; col < 4; col++) {
          expect(s.grid[row][col].char, '#');
        }
      }
      expect(s.grid[0][0].char, ' ');
      expect(s.grid[4][4].char, ' ');
    });

    test('fillRect clips to surface bounds', () {
      final s = Surface(5, 5);
      s.fillRect(3, 3, 10, 10, '#', TextStyle.empty);
      for (var row = 3; row < 5; row++) {
        for (var col = 3; col < 5; col++) {
          expect(s.grid[row][col].char, '#');
        }
      }
    });

    test('clearRect resets cells to default', () {
      final s = Surface(5, 5);
      s.fillRect(0, 0, 5, 5, 'X', TextStyle.empty);
      s.clearRect(1, 1, 3, 3);
      for (var row = 1; row < 4; row++) {
        for (var col = 1; col < 4; col++) {
          expect(s.grid[row][col].char, ' ');
        }
      }
      expect(s.grid[0][0].char, 'X');
    });

    test('drawBorder draws box around region', () {
      final s = Surface(10, 8);
      s.drawBorder(Rect(1, 1, 8, 6));
      expect(s.grid[1][1].char, '┌');
      expect(s.grid[1][8].char, '┐');
      expect(s.grid[6][1].char, '└');
      expect(s.grid[6][8].char, '┘');
      expect(s.grid[1][3].char, '─');
      expect(s.grid[3][1].char, '│');
    });

    test('drawBorder with title', () {
      final s = Surface(20, 5);
      s.drawBorder(Rect(0, 0, 20, 5), title: 'Hello');
      final titleRow = s.toPlainLines()[0];
      expect(titleRow, contains('Hello'));
    });

    test('drawBorder is no-op for too-small rect', () {
      final s = Surface(5, 5);
      s.drawBorder(Rect(0, 0, 1, 1));
      expect(s.grid[0][0].char, ' ');
    });

    test('toPlainLines returns correct strings', () {
      final s = Surface(4, 3);
      s.putChar(0, 0, 'A', TextStyle.empty);
      s.putChar(1, 0, 'B', TextStyle.empty);
      final lines = s.toPlainLines();
      expect(lines[0], 'AB  ');
      expect(lines[1], '    ');
      expect(lines[2], '    ');
    });

    test('toAnsiLines contains style sequences', () {
      final s = Surface(5, 3);
      s.putChar(0, 0, 'A', TextStyle(bold: true));
      final lines = s.toAnsiLines();
      expect(lines[0], contains('\x1b[1m'));
      expect(lines[0], contains('A'));
    });

    test('resize preserves overlapping region', () {
      final s = Surface(10, 10);
      s.putChar(5, 5, 'X', TextStyle.empty);
      final resized = s.resize(20, 20);
      expect(resized.grid[5][5].char, 'X');
      expect(resized.width, 20);
      expect(resized.height, 20);
    });

    test('resize smaller clips content', () {
      final s = Surface(10, 10);
      s.putChar(8, 8, 'X', TextStyle.empty);
      final resized = s.resize(5, 5);
      expect(resized.grid.length, 5);
      expect(resized.grid[0].length, 5);
    });

    test('putChar applies style', () {
      final s = Surface(5, 3);
      const style = TextStyle(bold: true, italic: true);
      s.putChar(2, 1, 'X', style);
      expect(s.grid[1][2].style.bold, isTrue);
      expect(s.grid[1][2].style.italic, isTrue);
    });

    test('putText applies style to all chars', () {
      final s = Surface(10, 3);
      const style = TextStyle(foreground: Color(red: 0, green: 153, blue: 0));
      s.putText(1, 1, 'Hi', style);
      expect(s.grid[1][1].style.foreground, const Color(red: 0, green: 153, blue: 0));
      expect(s.grid[1][2].style.foreground, const Color(red: 0, green: 153, blue: 0));
    });

    test('fillRect with wide chars marks continuation', () {
      final s = Surface(10, 3);
      s.fillRect(1, 1, 6, 1, '文', TextStyle.empty);
      expect(s.grid[1][1].char, '文');
      expect(s.grid[1][2].wideContinuation, isTrue);
      expect(s.grid[1][3].char, '文');
      expect(s.grid[1][4].wideContinuation, isTrue);
    });
  });
}
