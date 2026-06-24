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

    test('rejects out-of-bound components', () {
      expect(() => Color(red: -1), throwsA(isA<AssertionError>()));
      expect(() => Color(green: 256), throwsA(isA<AssertionError>()));
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
}
