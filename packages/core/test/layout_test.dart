import 'package:test/test.dart';
import 'package:core/core.dart';

void main() {
  group('Constraints', () {
    test('loose constraints have wide range', () {
      const c = Constraints();
      expect(c.isTight, isFalse);
      expect(c.isUnbounded, isTrue);
    });

    test('tight constraints have min == max', () {
      const c = Constraints.tight(10, 20);
      expect(c.isTight, isTrue);
      expect(c.minWidth, 10);
      expect(c.maxWidth, 10);
      expect(c.minHeight, 20);
      expect(c.maxHeight, 20);
    });

    test('constrain clamps to bounds', () {
      const c = Constraints(minWidth: 5, maxWidth: 15, minHeight: 3, maxHeight: 10);
      expect(c.constrain(const Size(0, 0)), const Size(5, 3));
      expect(c.constrain(const Size(20, 20)), const Size(15, 10));
      expect(c.constrain(const Size(10, 5)), const Size(10, 5));
    });

    test('equality', () {
      const a = Constraints(minWidth: 5, maxWidth: 15);
      const b = Constraints(minWidth: 5, maxWidth: 15);
      const c = Constraints(minWidth: 5, maxWidth: 20);
      expect(a == b, isTrue);
      expect(a == c, isFalse);
    });
  });

  group('Size', () {
    test('equality', () {
      expect(const Size(10, 20) == const Size(10, 20), isTrue);
      expect(const Size(10, 20) == const Size(10, 21), isFalse);
    });
  });

  group('LayoutItem', () {
    test('isFlexible when no fixedSize', () {
      const item = LayoutItem(flex: 2);
      expect(item.isFlexible, isTrue);
    });

    test('not flexible when fixedSize set', () {
      const item = LayoutItem(fixedSize: 10);
      expect(item.isFlexible, isFalse);
    });
  });

  group('splitHorizontal', () {
    test('all fixed items', () {
      final items = [
        const LayoutItem(fixedSize: 5),
        const LayoutItem(fixedSize: 10),
      ];
      final result = splitHorizontal(20, items, 1);
      expect(result, [5, 10]);
    });

    test('all flexible items split evenly', () {
      final items = [
        const LayoutItem(),
        const LayoutItem(),
      ];
      final result = splitHorizontal(20, items, 0);
      expect(result[0] + result[1], 20);
      expect((result[0] - result[1]).abs() <= 1, isTrue);
    });

    test('flexible items with different flex factors', () {
      final items = [
        const LayoutItem(flex: 1),
        const LayoutItem(flex: 2),
      ];
      final result = splitHorizontal(30, items, 0);
      expect(result, [10, 20]);
    });

    test('gaps are subtracted from total', () {
      final items = [
        const LayoutItem(fixedSize: 5),
        const LayoutItem(),
        const LayoutItem(fixedSize: 5),
      ];
      final result = splitHorizontal(20, items, 2);
      expect(result[0], 5);
      expect(result[1], 6);
      expect(result[2], 5);
    });

    test('single item fills total', () {
      final result = splitHorizontal(100, [const LayoutItem()], 0);
      expect(result, [100]);
    });

    test('zero remaining space gives flexible items minimum 1', () {
      final items = [
        const LayoutItem(fixedSize: 10),
        const LayoutItem(),
      ];
      final result = splitHorizontal(12, items, 1);
      expect(result[0], 10);
      expect(result[1], 1);
    });

    test('empty items list returns empty', () {
      expect(splitHorizontal(10, [], 0), []);
    });

    test('remainder distribution handles rounding', () {
      final items = [
        const LayoutItem(flex: 1),
        const LayoutItem(flex: 1),
        const LayoutItem(flex: 1),
      ];
      final result = splitHorizontal(10, items, 0);
      expect(result, [4, 3, 3]);
    });
  });

  group('splitVertical', () {
    test('same algorithm as horizontal', () {
      final items = [
        const LayoutItem(fixedSize: 5),
        const LayoutItem(),
      ];
      final result = splitVertical(20, items, 1);
      expect(result[0], 5);
      expect(result[1] > 0, isTrue);
    });
  });
}
