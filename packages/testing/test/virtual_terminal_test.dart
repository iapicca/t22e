import 'package:test/test.dart';
import 'package:testing/testing.dart';

void main() {
  group('VirtualTerminal', () {
    late VirtualTerminal vt;

    setUp(() {
      vt = VirtualTerminal(width: 10, height: 5);
    });

    test('writes plain text to grid', () {
      vt.write('Hello');
      expect(vt.cellAt(0, 0).char, equals('H'));
      expect(vt.cellAt(0, 4).char, equals('o'));
    });

    test('applies SGR bold', () {
      vt.write('\x1b[1mBold');
      expect(vt.cellAt(0, 0).style.bold, equals(true));
    });

    test('applies SGR foreground color', () {
      vt.write('\x1b[31mRed');
      expect(vt.cellAt(0, 0).style.foreground, isNotNull);
    });

    test('clears screen with ED2', () {
      vt.write('Hello');
      vt.write('\x1b[2J');
      expect(vt.cellAt(0, 0).char, equals(' '));
    });

    test('moves cursor with CUP', () {
      vt.write('\x1b[3;5HX');
      expect(vt.cellAt(2, 4).char, equals('X'));
    });

    test('handles newlines', () {
      vt.write('A\nB\nC');
      expect(vt.cellAt(0, 0).char, equals('A'));
      expect(vt.cellAt(1, 0).char, equals('B'));
      expect(vt.cellAt(2, 0).char, equals('C'));
    });

    test('scrolls at bottom', () {
      for (var i = 0; i < 5; i++) {
        vt.write('X\n');
      }
      vt.write('Y');
      expect(vt.cellAt(4, 0).char, equals('Y'));
    });

    test('resize preserves content', () {
      vt.write('Hello');
      vt.resize(20, 10);
      expect(vt.cellAt(0, 0).char, equals('H'));
      expect(vt.width, equals(20));
      expect(vt.height, equals(10));
    });

    test('plainText returns correct output', () {
      vt.write('Hello');
      vt.write('\x1b[2;1HWorld');
      final text = vt.plainText();
      expect(text.startsWith('Hello'), isTrue);
      expect(text.split('\n')[1], startsWith('World'));
    });

    test('cellAt returns default cell for out of bounds', () {
      expect(vt.cellAt(-1, 0).char, equals(' '));
      expect(vt.cellAt(0, 20).char, equals(' '));
      expect(vt.cellAt(10, 0).char, equals(' '));
    });

    group('alt screen', () {
      test('entering alt screen saves and clears normal buffer', () {
        vt.write('Hello');
        vt.write('\x1b[?1049h');
        // Alt screen should be blank
        expect(vt.cellAt(0, 0).char, equals(' '));
        expect(vt.cellAt(0, 1).char, equals(' '));
      });

      test('exiting alt screen restores normal buffer', () {
        vt.write('Hello');
        vt.write('\x1b[?1049h');
        vt.write('\x1b[?1049l');
        // Normal buffer content restored
        expect(vt.cellAt(0, 0).char, equals('H'));
        expect(vt.cellAt(0, 4).char, equals('o'));
      });

      test('writes to alt screen do not affect normal buffer', () {
        vt.write('Normal');
        vt.write('\x1b[?1049h');
        vt.write('Alt');
        vt.write('\x1b[?1049l');
        expect(vt.cellAt(0, 0).char, equals('N'));
        expect(vt.plainText().startsWith('Normal'), isTrue);
      });

      test('entering alt screen twice is idempotent', () {
        vt.write('Hello');
        vt.write('\x1b[?1049h');
        vt.write('Alt');
        vt.write('\x1b[?1049h'); // second enter is ignored
        vt.write('\x1b[?1049l');
        expect(vt.cellAt(0, 0).char, equals('H'));
      });

      test('restores cursor position on alt screen exit', () {
        vt.write('\x1b[2;3H');
        vt.write('\x1b[?1049h');
        vt.write('\x1b[?1049l');
        // Just verify we can still write at a position
        vt.write('X');
        expect(vt.cellAt(1, 2).char, equals('X'));
      });
    });
  });
}
