import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Grapheme', () {
    test('const construction accepts a single ASCII cluster', () {
      const g = Grapheme('x');
      expect(g.string, 'x');
      expect(g, 'x');
    });

    test('Grapheme.space is the single-cell space', () {
      expect(Grapheme.space.string, ' ');
      expect(Grapheme.space.width, 1);
    });

    test('validated accepts a combining-mark cluster', () {
      final g = Grapheme.validated('e\u{0301}');
      expect(g.string, 'e\u{0301}');
      expect(g.width, 1);
    });

    test('validated rejects an empty string', () {
      expect(() => Grapheme.validated(''), throwsArgumentError);
    });

    test('validated rejects a multi-cluster string', () {
      expect(() => Grapheme.validated('xy'), throwsArgumentError);
      expect(() => Grapheme.validated('a\nb'), throwsArgumentError);
    });

    test('width is 1 for ASCII and Latin', () {
      expect(const Grapheme('A').width, 1);
      expect(const Grapheme('z').width, 1);
      expect(const Grapheme('é').width, 1);
    });

    test('width is 2 for CJK ideographs', () {
      expect(const Grapheme('漢').width, 2);
      expect(const Grapheme('字').width, 2);
    });

    test('width is 2 for hangul syllables', () {
      expect(const Grapheme('가').width, 2);
    });

    test('width is 2 for fullwidth forms', () {
      expect(const Grapheme('Ａ').width, 2);
      expect(const Grapheme('！').width, 2);
    });

    test('width is 2 for common emoji', () {
      expect(const Grapheme('😀').width, 2);
      expect(const Grapheme('🚀').width, 2);
    });

    test('width is 0 for lone combining marks', () {
      expect(const Grapheme('\u{0301}').width, 0);
      expect(const Grapheme('\u{0308}').width, 0);
    });

    test('width is 0 for variation selectors and ZWJ', () {
      expect(const Grapheme('\u{FE0F}').width, 0);
      expect(const Grapheme('\u{200D}').width, 0);
    });

    test('equality and hashCode follow string content', () {
      const a = Grapheme('A');
      const b = Grapheme('A');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(const Grapheme('A'), isNot(const Grapheme('B')));
    });

    test('toString returns the backing string', () {
      expect(const Grapheme('A').toString(), 'A');
    });
  });
}