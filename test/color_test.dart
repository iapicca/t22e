import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('AnsiColor', () {
    test('holds a valid code', () {
      const color = AnsiColor(code: 7);
      expect(color.code, 7);
    });

    test('rejects codes below 0', () {
      expect(() => AnsiColor(code: -1), throwsA(isA<AssertionError>()));
    });

    test('rejects codes above 15', () {
      expect(() => AnsiColor(code: 16), throwsA(isA<AssertionError>()));
    });

    test('converts to RGB', () {
      expect(AnsiColor(code: 0).toColor(), const Color.black());
      expect(AnsiColor(code: 7).toColor(), const Color.white());
      expect(AnsiColor(code: 8).toColor(), const Color.brightBlack());
    });
  });

  group('IndexedColor', () {
    test('holds a valid index', () {
      const color = IndexedColor(index: 42);
      expect(color.index, 42);
    });

    test('rejects indices below 0', () {
      expect(() => IndexedColor(index: -1), throwsA(isA<AssertionError>()));
    });

    test('rejects indices above 255', () {
      expect(() => IndexedColor(index: 256), throwsA(isA<AssertionError>()));
    });

    test('converts to RGB', () {
      expect(IndexedColor(index: 0).toColor(), const Color.black());
    });
  });

  group('Color', () {
    test('holds RGB components', () {
      const color = Color(red: 10, green: 20, blue: 30);
      expect(color.red, 10);
      expect(color.green, 20);
      expect(color.blue, 30);
    });

    test('clamps components above the max to 255', () {
      expect(const Color(red: 300).red, 255);
      expect(const Color(green: 256).green, 255);
      expect(const Color(blue: 9999).blue, 255);
    });

    test('ANSI named colors are correct', () {
      expect(const Color.black(), const Color(red: 0, green: 0, blue: 0));
      expect(const Color.red(), const Color(red: 153, green: 0, blue: 0));
      expect(
        const Color.brightWhite(),
        const Color(red: 255, green: 255, blue: 255),
      );
    });

    test('round-trips through indexed palette', () {
      const original = Color(red: 255, green: 0, blue: 0);
      final recovered = IndexedColor(index: original.index).toColor();
      expect(recovered, original);
    });

    test('converts to nearest ANSI color', () {
      expect(const Color.black().ansi.code, 0);
      expect(const Color.brightWhite().ansi.code, 15);
    });
  });

  group('AnsiColorSgr', () {
    test('emits dark foreground SGR (codes 0–7)', () {
      expect(AnsiColor(code: 0).toSgr(), '\x1B[30m');
      expect(AnsiColor(code: 7).toSgr(), '\x1B[37m');
    });

    test('emits bright foreground SGR (codes 8–15)', () {
      expect(AnsiColor(code: 8).toSgr(), '\x1B[90m');
      expect(AnsiColor(code: 15).toSgr(), '\x1B[97m');
    });

    test('emits background SGR when background is true', () {
      expect(AnsiColor(code: 1).toSgr(background: true), '\x1B[41m');
      expect(AnsiColor(code: 9).toSgr(background: true), '\x1B[101m');
    });
  });

  group('IndexedColorSgr', () {
    test('emits 256-color foreground SGR', () {
      expect(IndexedColor(index: 42).toSgr(), '\x1B[38;5;42m');
    });

    test('emits 256-color background SGR', () {
      expect(IndexedColor(index: 200).toSgr(background: true), '\x1B[48;5;200m');
    });
  });

  group('ColorSgr', () {
    test('emits 24-bit true-color foreground SGR', () {
      expect(
        const Color(red: 255, green: 0, blue: 0).toSgr(),
        '\x1B[38;2;255;0;0m',
      );
    });

    test('emits 24-bit true-color background SGR', () {
      expect(
        const Color(red: 1, green: 2, blue: 3).toSgr(background: true),
        '\x1B[48;2;1;2;3m',
      );
    });

    test('clamped components round-trip through the SGR sequence', () {
      expect(
        const Color(red: 9999).toSgr(),
        '\x1B[38;2;255;0;0m',
      );
    });
  });
}
