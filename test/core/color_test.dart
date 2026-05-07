import 'package:test/test.dart';
import 'package:t22e/src/core/color.dart';

void main() {
  group('Color', () {
    group('constructors', () {
      test('noColor', () {
        const c = Color.noColor();
        expect(c.kind, ColorKind.noColor);
        expect(c.value, 0);
      });

      test('ansi', () {
        const c = Color.ansi(1);
        expect(c.kind, ColorKind.ansi);
        expect(c.value, 1);
      });

      test('indexed', () {
        const c = Color.indexed(42);
        expect(c.kind, ColorKind.indexed);
        expect(c.value, 42);
      });

      test('rgb', () {
        const c = Color.rgb(255, 128, 64);
        expect(c.kind, ColorKind.rgb);
        expect(c.red, 255);
        expect(c.green, 128);
        expect(c.blue, 64);
      });

      test('ansi rejects out of range', () {
        expect(() => Color.ansi(16), throwsA(isA<AssertionError>()));
      });

      test('indexed rejects out of range', () {
        expect(() => Color.indexed(256), throwsA(isA<AssertionError>()));
      });

      test('rgb rejects out of range', () {
        expect(() => Color.rgb(256, 0, 0), throwsA(isA<AssertionError>()));
      });
    });

    group('profile', () {
      test('noColor profile', () {
        expect(const Color.noColor().profile, ColorProfile.noColor);
      });

      test('ansi profile', () {
        expect(const Color.ansi(0).profile, ColorProfile.ansi16);
      });

      test('indexed profile', () {
        expect(const Color.indexed(0).profile, ColorProfile.indexed256);
      });

      test('rgb profile', () {
        expect(const Color.rgb(0, 0, 0).profile, ColorProfile.trueColor);
      });
    });

    group('conversion - never upgrades', () {
      test('rgb stays rgb when target is rgb', () {
        const c = Color.rgb(100, 150, 200);
        final converted = c.convert(ColorKind.rgb);
        expect(converted.kind, ColorKind.rgb);
      });

      test('ansi stays ansi when target is indexed', () {
        const c = Color.ansi(1);
        final converted = c.convert(ColorKind.indexed);
        expect(converted.kind, ColorKind.ansi);
      });

      test('indexed stays indexed when target is rgb', () {
        const c = Color.indexed(42);
        final converted = c.convert(ColorKind.rgb);
        expect(converted.kind, ColorKind.indexed);
      });

      test('noColor stays noColor for any target', () {
        const c = Color.noColor();
        expect(c.convert(ColorKind.rgb).kind, ColorKind.noColor);
        expect(c.convert(ColorKind.ansi).kind, ColorKind.noColor);
      });
    });

    group('conversion - downgrade chain', () {
      test('rgb -> indexed', () {
        const c = Color.rgb(255, 0, 0);
        final converted = c.convert(ColorKind.indexed);
        expect(converted.kind, ColorKind.indexed);
      });

      test('rgb -> ansi', () {
        const c = Color.rgb(0, 255, 0);
        final converted = c.convert(ColorKind.ansi);
        expect(converted.kind, ColorKind.ansi);
      });

      test('rgb -> noColor', () {
        const c = Color.rgb(100, 100, 100);
        final converted = c.convert(ColorKind.noColor);
        expect(converted.kind, ColorKind.noColor);
      });

      test('indexed -> ansi', () {
        const c = Color.indexed(16);
        final converted = c.convert(ColorKind.ansi);
        expect(converted.kind, ColorKind.ansi);
      });

      test('indexed -> noColor', () {
        const c = Color.indexed(16);
        final converted = c.convert(ColorKind.noColor);
        expect(converted.kind, ColorKind.noColor);
      });

      test('ansi -> noColor', () {
        const c = Color.ansi(1);
        final converted = c.convert(ColorKind.noColor);
        expect(converted.kind, ColorKind.noColor);
      });
    });

    group('sgrSequence', () {
      test('noColor foreground', () {
        expect(const Color.noColor().sgrSequence(), '\x1b[39m');
      });

      test('noColor background', () {
        expect(const Color.noColor().sgrSequence(background: true), '\x1b[49m');
      });

      test('ansi foreground 0-7', () {
        expect(const Color.ansi(1).sgrSequence(), '\x1b[31m');
        expect(const Color.ansi(7).sgrSequence(), '\x1b[37m');
      });

      test('ansi foreground 8-15 (bright)', () {
        expect(const Color.ansi(9).sgrSequence(), '\x1b[91m');
        expect(const Color.ansi(15).sgrSequence(), '\x1b[97m');
      });

      test('ansi background 0-7', () {
        expect(const Color.ansi(1).sgrSequence(background: true), '\x1b[41m');
      });

      test('ansi background 8-15 (bright)', () {
        expect(const Color.ansi(9).sgrSequence(background: true), '\x1b[101m');
      });

      test('indexed foreground', () {
        expect(const Color.indexed(42).sgrSequence(), '\x1b[38;5;42m');
      });

      test('indexed background', () {
        expect(const Color.indexed(42).sgrSequence(background: true), '\x1b[48;5;42m');
      });

      test('rgb foreground', () {
        expect(const Color.rgb(255, 128, 64).sgrSequence(), '\x1b[38;2;255;128;64m');
      });

      test('rgb background', () {
        expect(const Color.rgb(255, 128, 64).sgrSequence(background: true), '\x1b[48;2;255;128;64m');
      });
    });

    group('equality', () {
      test('same kind and value are equal', () {
        expect(const Color.ansi(1) == const Color.ansi(1), isTrue);
        expect(const Color.rgb(10, 20, 30) == const Color.rgb(10, 20, 30), isTrue);
      });

      test('different values are not equal', () {
        expect(const Color.ansi(1) == const Color.ansi(2), isFalse);
      });
    });
  });
}
