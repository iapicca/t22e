import 'package:test/test.dart';
import 'package:t22e/src/unicode/width.dart';

void main() {
  group('charWidth', () {
    test('Latin A', () => expect(charWidth(0x41), equals(1)));
    test('CJK ideograph', () => expect(charWidth(0x4E00), equals(2)));
    test('combining mark', () => expect(charWidth(0x0300), equals(0)));
    test('zero width space', () => expect(charWidth(0x200B), equals(0)));
    test('emoji', () => expect(charWidth(0x1F600), equals(2)));
  });

  group('isWide', () {
    test('CJK is wide', () => expect(isWide(0x4E00), isTrue));
    test('Latin is not wide', () => expect(isWide(0x41), isFalse));
  });

  group('stringWidth', () {
    test('empty string', () => expect(stringWidth(''), equals(0)));
    test('Latin text', () => expect(stringWidth('hello'), equals(5)));
    test('CJK text', () => expect(stringWidth('\u4E00\u4E01'), equals(4)));
    test('mixed', () => expect(stringWidth('a\u4E00b'), equals(4)));
  });

  group('isAmbiguousWidth', () {
    test('Latin A not ambiguous', () => expect(isAmbiguousWidth(0x41), isFalse));
    test('block element is not ambiguous by default', () {
      expect(isAmbiguousWidth(0x2592), isFalse);
    });
  });
}
