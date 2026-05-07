import 'package:test/test.dart';
import 'package:t22e/src/unicode/grapheme.dart';

void main() {
  group('graphemeClusters', () {
    test('ASCII text each char is one cluster', () {
      final clusters = graphemeClusters('abc');
      expect(clusters.length, equals(3));
      expect(clusters[0].columnWidth, equals(1));
      expect(clusters[1].columnWidth, equals(1));
      expect(clusters[2].columnWidth, equals(1));
    });

    test('flag emoji regional indicators are separate clusters', () {
      final clusters = graphemeClusters('\u{1F1FA}\u{1F1F8}');
      expect(clusters.length, equals(2));
    });

    test('stringWidthGrapheme basic', () {
      expect(stringWidthGrapheme('abc'), equals(3));
    });

    test('stringWidthGrapheme CJK', () {
      expect(stringWidthGrapheme('\u4E00\u4E01'), equals(4));
    });
  });

  group('truncate', () {
    test('no truncation needed', () {
      expect(truncate('hello', 10), equals('hello'));
    });

    test('truncate at width boundary', () {
      expect(truncate('hello world', 5), equals('hello'));
    });

    test('truncate with CJK', () {
      final result = truncate('\u4E00\u4E01\u4E02', 4);
      expect(result, equals('\u4E00\u4E01'));
    });
  });
}
