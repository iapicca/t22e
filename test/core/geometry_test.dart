import 'package:test/test.dart';
import 'package:t22e/src/core/geometry.dart';

void main() {
  group('Point', () {
    test('constructs and accesses fields', () {
      final p = Point(3, 5);
      expect(p.x, 3);
      expect(p.y, 5);
    });

    test('addition', () {
      expect(Point(1, 2) + Point(3, 4), Point(4, 6));
    });

    test('subtraction', () {
      expect(Point(5, 7) - Point(2, 3), Point(3, 4));
    });

    test('equality and hashCode', () {
      expect(Point(1, 2) == Point(1, 2), isTrue);
      expect(Point(1, 2).hashCode, Point(1, 2).hashCode);
      expect(Point(1, 2) == Point(3, 4), isFalse);
    });

    test('withX and withY', () {
      expect(Point(1, 2).withX(5), Point(5, 2));
      expect(Point(1, 2).withY(5), Point(1, 5));
    });
  });

  group('Rect', () {
    test('constructs and provides edges', () {
      final r = Rect(2, 3, 10, 20);
      expect(r.left, 2);
      expect(r.top, 3);
      expect(r.right, 12);
      expect(r.bottom, 23);
    });

    test('contains point', () {
      final r = Rect(0, 0, 10, 10);
      expect(r.contains(Point(0, 0)), isTrue);
      expect(r.contains(Point(9, 9)), isTrue);
      expect(r.contains(Point(10, 10)), isFalse);
      expect(r.contains(Point(-1, 5)), isFalse);
    });

    test('intersect overlapping rects', () {
      final a = Rect(0, 0, 10, 10);
      final b = Rect(5, 5, 10, 10);
      final i = a.intersect(b);
      expect(i, Rect(5, 5, 5, 5));
    });

    test('intersect non-overlapping rects returns empty', () {
      final a = Rect(0, 0, 5, 5);
      final b = Rect(10, 10, 5, 5);
      final i = a.intersect(b);
      expect(i.isEmpty, isTrue);
    });

    test('union', () {
      final a = Rect(0, 0, 5, 5);
      final b = Rect(3, 3, 5, 5);
      final u = a.union(b);
      expect(u, Rect(0, 0, 8, 8));
    });

    test('inset shrinks', () {
      final r = Rect(0, 0, 10, 10);
      final i = r.inset(const Insets.all(2));
      expect(i, Rect(2, 2, 6, 6));
    });

    test('inset with large values clamps to zero', () {
      final r = Rect(0, 0, 5, 5);
      final i = r.inset(const Insets.all(10));
      expect(i.isEmpty, isTrue);
    });

    test('inflate grows', () {
      final r = Rect(2, 2, 6, 6);
      final i = r.inflate(2, 2);
      expect(i, Rect(0, 0, 10, 10));
    });

    test('isEmpty', () {
      expect(Rect(0, 0, 0, 10).isEmpty, isTrue);
      expect(Rect(0, 0, 10, 0).isEmpty, isTrue);
      expect(Rect(0, 0, 10, 10).isEmpty, isFalse);
    });

    test('equality and hashCode', () {
      expect(Rect(1, 2, 3, 4) == Rect(1, 2, 3, 4), isTrue);
      expect(Rect(1, 2, 3, 4) == Rect(1, 2, 5, 6), isFalse);
    });
  });

  group('Insets', () {
    test('all constructor', () {
      const i = Insets.all(3);
      expect(i.left, 3);
      expect(i.top, 3);
      expect(i.right, 3);
      expect(i.bottom, 3);
    });

    test('symmetric constructor', () {
      const i = Insets.symmetric(horizontal: 5, vertical: 10);
      expect(i.left, 5);
      expect(i.right, 5);
      expect(i.top, 10);
      expect(i.bottom, 10);
    });

    test('only constructor', () {
      const i = Insets.only(left: 1, top: 2, right: 3, bottom: 4);
      expect(i.left, 1);
      expect(i.top, 2);
      expect(i.right, 3);
      expect(i.bottom, 4);
    });

    test('horizontal and vertical totals', () {
      const i = Insets.all(3);
      expect(i.horizontal, 6);
      expect(i.vertical, 6);
    });

    test('add combines insets', () {
      const a = Insets.all(2);
      const b = Insets.all(3);
      final s = a.add(b);
      expect(s, const Insets.all(5));
    });

    test('equality and hashCode', () {
      expect(const Insets.all(2) == const Insets.all(2), isTrue);
      expect(const Insets.all(2) == const Insets.all(3), isFalse);
    });
  });
}
