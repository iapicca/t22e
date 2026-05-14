import 'package:test/test.dart';
import 'package:core/core.dart';

void main() {
  group('AnsiColor', () {
    test('valid codes', () {
      expect(() => AnsiColor(0), returnsNormally);
      expect(() => AnsiColor(15), returnsNormally);
    });

    test('rejects out of range', () {
      expect(() => AnsiColor(-1), throwsA(isA<AssertionError>()));
      expect(() => AnsiColor(16), throwsA(isA<AssertionError>()));
    });
  });

  group('IndexedColor', () {
    test('valid indices', () {
      expect(() => IndexedColor(0), returnsNormally);
      expect(() => IndexedColor(255), returnsNormally);
    });

    test('rejects out of range', () {
      expect(() => IndexedColor(-1), throwsA(isA<AssertionError>()));
      expect(() => IndexedColor(256), throwsA(isA<AssertionError>()));
    });
  });

  group('Color', () {
    group('constructors', () {
      test('default to black', () {
        const c = Color();
        expect(c.red, 0);
        expect(c.green, 0);
        expect(c.blue, 0);
      });

      test('direct RGB', () {
        const c = Color(red: 255, green: 128, blue: 64);
        expect(c.red, 255);
        expect(c.green, 128);
        expect(c.blue, 64);
      });

      test('fromAnsi', () {
        final c = Color.fromAnsi(AnsiColor(1));
        expect(c.red, 153);
        expect(c.green, 0);
        expect(c.blue, 0);
      });

      test('fromIndexed', () {
        final c = Color.fromIndexed(IndexedColor(196));
        expect(c.red, 255);
        expect(c.green, 0);
        expect(c.blue, 0);
      });

      test('rgb rejects out of range', () {
        expect(
          () => Color(red: 256, green: 0, blue: 0),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('index getter', () {
      test('black maps to index 16', () {
        expect(const Color().index, 16);
      });

      test('red maps to cube', () {
        final c = Color(red: 255, green: 0, blue: 0);
        expect(c.index, 196);
      });
    });

    group('ansi getter', () {
      test('black converts to ansi 0', () {
        expect(const Color().ansi.code, 0);
      });

      test('red converts to ansi 1', () {
        final c = Color(red: 153, green: 0, blue: 0);
        expect(c.ansi.code, 1);
      });

      test('fromAnsi preserves code', () {
        for (var i = 0; i < 16; i++) {
          final c = Color.fromAnsi(AnsiColor(i));
          expect(c.ansi.code, i);
        }
      });
    });

    group('sgrSequence', () {
      test('noColor foreground', () {
        expect(
          const Color().sgrSequence(profile: ColorProfile.noColor),
          '\x1b[39m',
        );
      });

      test('noColor background', () {
        expect(
          const Color().sgrSequence(
            background: true,
            profile: ColorProfile.noColor,
          ),
          '\x1b[49m',
        );
      });

      test('ansi16 foreground dark', () {
        final c = Color.fromAnsi(AnsiColor(1));
        expect(c.sgrSequence(profile: ColorProfile.ansi16), '\x1b[31m');
      });

      test('ansi16 foreground bright', () {
        final c = Color.fromAnsi(AnsiColor(9));
        expect(c.sgrSequence(profile: ColorProfile.ansi16), '\x1b[91m');
      });

      test('ansi16 background', () {
        final c = Color.fromAnsi(AnsiColor(1));
        expect(
          c.sgrSequence(background: true, profile: ColorProfile.ansi16),
          '\x1b[41m',
        );
      });

      test('ansi16 background bright', () {
        final c = Color.fromAnsi(AnsiColor(9));
        expect(
          c.sgrSequence(background: true, profile: ColorProfile.ansi16),
          '\x1b[101m',
        );
      });

      test('indexed256 foreground', () {
        final c = Color.fromIndexed(IndexedColor(42));
        expect(
          c.sgrSequence(profile: ColorProfile.indexed256),
          '\x1b[38;5;42m',
        );
      });

      test('indexed256 background', () {
        final c = Color.fromIndexed(IndexedColor(42));
        expect(
          c.sgrSequence(background: true, profile: ColorProfile.indexed256),
          '\x1b[48;5;42m',
        );
      });

      test('trueColor foreground', () {
        const c = Color(red: 255, green: 128, blue: 64);
        expect(
          c.sgrSequence(profile: ColorProfile.trueColor),
          '\x1b[38;2;255;128;64m',
        );
      });

      test('trueColor background', () {
        const c = Color(red: 255, green: 128, blue: 64);
        expect(
          c.sgrSequence(background: true, profile: ColorProfile.trueColor),
          '\x1b[48;2;255;128;64m',
        );
      });

      test('defaults to trueColor', () {
        const c = Color(red: 255, green: 128, blue: 64);
        expect(c.sgrSequence(), '\x1b[38;2;255;128;64m');
      });
    });

    group('equality', () {
      test('same fields are equal', () {
        expect(
          const Color(red: 10, green: 20, blue: 30) ==
              const Color(red: 10, green: 20, blue: 30),
          isTrue,
        );
      });

      test('different fields are not equal', () {
        expect(
          const Color(red: 10, green: 20, blue: 30) ==
              const Color(red: 10, green: 20, blue: 99),
          isFalse,
        );
      });
    });
  });
}
