import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('charWidth', () {
    test('returns 1 for ASCII letters and digits', () {
      expect(charWidth('A'), 1);
      expect(charWidth('z'), 1);
      expect(charWidth('0'), 1);
      expect(charWidth(' '), 1);
    });

    test('returns 1 for Latin-1 accented letters', () {
      expect(charWidth('é'), 1);
      expect(charWidth('ñ'), 1);
    });

    test('returns 2 for CJK unified ideographs', () {
      expect(charWidth('漢'), 2);
      expect(charWidth('字'), 2);
      expect(charWidth('中'), 2);
    });

    test('returns 2 for hiragana and katakana', () {
      expect(charWidth('あ'), 2);
      expect(charWidth('カ'), 2);
    });

    test('returns 2 for hangul syllables', () {
      expect(charWidth('가'), 2);
      expect(charWidth('한'), 2);
    });

    test('returns 2 for fullwidth ASCII and forms', () {
      expect(charWidth('Ａ'), 2);
      expect(charWidth('！'), 2);
    });

    test('returns 2 for CJK symbols and punctuation', () {
      expect(charWidth('、'), 2);
      expect(charWidth('。'), 2);
    });

    test('returns 2 for common emoji', () {
      expect(charWidth('😀'), 2);
      expect(charWidth('🚀'), 2);
      expect(charWidth('⭐'), 2);
    });

    test('returns 0 for combining diacritical marks', () {
      expect(charWidth('\u{0301}'), 0);
      expect(charWidth('\u{0308}'), 0);
      expect(charWidth('\u{0327}'), 0);
    });

    test('returns 0 for variation selectors and ZWJ', () {
      expect(charWidth('\u{FE0F}'), 0);
      expect(charWidth('\u{FE0E}'), 0);
      expect(charWidth('\u{200D}'), 0);
    });

    test('returns 0 for an empty grapheme', () {
      expect(charWidth(''), 0);
    });

    test('uses the leading codepoint width for clusters', () {
      // 'e' + combining acute is one grapheme; the base 'e' is narrow.
      expect(charWidth('e\u{0301}'), 1);
      // '漢' + variation selector stays wide.
      expect(charWidth('漢\u{FE0E}'), 2);
    });
  });
}