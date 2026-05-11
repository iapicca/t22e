import 'package:test/test.dart';
import 'package:unicode/unicode.dart';

void main() {
  group('charWidthFromTable', () {
    test('Latin letter A is width 1', () {
      expect(charWidthFromTable(0x41), equals(1));
    });

    test('CJK ideograph is width 2', () {
      expect(charWidthFromTable(0x4E00), equals(2));
    });

    test('combining grave accent is width 0', () {
      expect(charWidthFromTable(0x0300), equals(0));
    });

    test('zero width space is width 0', () {
      expect(charWidthFromTable(0x200B), equals(0));
    });

    test('fullwidth exclamation is width 2', () {
      expect(charWidthFromTable(0xFF01), equals(2));
    });

    test('Hangul Jamo is width 2', () {
      expect(charWidthFromTable(0x1100), equals(2));
    });

    test('Hiragana is width 2', () {
      expect(charWidthFromTable(0x3041), equals(2));
    });

    test('Emoji is width 2', () {
      expect(charWidthFromTable(0x1F300), equals(2));
    });
  });

  group('isEmojiFromTable', () {
    test('grinning face is emoji', () {
      expect(isEmojiFromTable(0x1F600), isTrue);
    });

    test('Latin A is not emoji', () {
      expect(isEmojiFromTable(0x41), isFalse);
    });
  });

  group('isPrintableFromTable', () {
    test('Latin A is printable', () {
      expect(isPrintableFromTable(0x41), isTrue);
    });

    test('null byte is not printable', () {
      expect(isPrintableFromTable(0x00), isFalse);
    });
  });

  group('boundary conditions', () {
    test('codepoint 0 returns 0', () {
      expect(charWidthFromTable(0), equals(0));
    });

    test('codepoint beyond max returns 0', () {
      expect(charWidthFromTable(0x110000), equals(0));
    });

    test('negative codepoint returns 0', () {
      expect(charWidthFromTable(-1), equals(0));
    });
  });
}
