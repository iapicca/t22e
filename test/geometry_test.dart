import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Offset', () {
    test('adds offsets', () {
      expect(Offset(1, 2) + Offset(3, 4), Offset(4, 6));
    });

    test('equals offset with same values', () {
      expect(Offset(1, 2), Offset(1, 2));
    });
  });

  group('Size', () {
    test('calculates area', () {
      expect(Size(3, 4).area, 12);
    });

    test('is empty when a dimension is zero', () {
      expect(Size(0, 5).isEmpty, isTrue);
      expect(Size(5, 0).isEmpty, isTrue);
      expect(Size(1, 1).isEmpty, isFalse);
    });

    test('constrains to a maximum size', () {
      expect(Size(10, 20).constrain(Size(5, 15)), Size(5, 15));
      expect(Size(2, 3).constrain(Size(5, 5)), Size(2, 3));
    });

    test('equals size with same values', () {
      expect(Size(2, 3), Size(2, 3));
    });
  });

  group('Rect', () {
    test('calculates width and height', () {
      final rect = Rect(1, 2, 5, 7);
      expect(rect.width, 4);
      expect(rect.height, 5);
    });

    test('detects empty rectangles', () {
      expect(Rect(0, 0, 0, 5).isEmpty, isTrue);
      expect(Rect(0, 0, 5, 0).isEmpty, isTrue);
      expect(Rect(0, 0, 5, 5).isEmpty, isFalse);
    });

    test('contains offsets with half-open semantics', () {
      final rect = Rect(0, 0, 2, 2);
      expect(rect.contains(Offset(0, 0)), isTrue);
      expect(rect.contains(Offset(1, 1)), isTrue);
      expect(rect.contains(Offset(2, 1)), isFalse);
      expect(rect.contains(Offset(1, 2)), isFalse);
    });

    test('intersects rectangles', () {
      final a = Rect(0, 0, 4, 4);
      final b = Rect(2, 2, 6, 6);
      expect(a.intersect(b), Rect(2, 2, 4, 4));
    });

    test('intersection is empty when rectangles do not overlap', () {
      final a = Rect(0, 0, 2, 2);
      final b = Rect(2, 2, 4, 4);
      final intersection = a.intersect(b);
      expect(intersection.isEmpty, isTrue);
    });
  });
}
