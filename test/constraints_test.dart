import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Constraints', () {
    test('tight factory sets min and max to the same size', () {
      final constraints = Constraints.tight(Size(10, 20));
      expect(constraints.minWidth, 10);
      expect(constraints.maxWidth, 10);
      expect(constraints.minHeight, 20);
      expect(constraints.maxHeight, 20);
      expect(constraints.isTight, isTrue);
    });

    test('loose factory sets minima to zero', () {
      final constraints = Constraints.loose(Size(10, 20));
      expect(constraints.minWidth, 0);
      expect(constraints.maxWidth, 10);
      expect(constraints.minHeight, 0);
      expect(constraints.maxHeight, 20);
      expect(constraints.isTight, isFalse);
    });

    test('constrain clamps to min and max', () {
      final constraints = Constraints(
        minWidth: 5,
        maxWidth: 10,
        minHeight: 8,
        maxHeight: 16,
      );
      expect(constraints.constrain(Size(3, 20)), Size(5, 16));
      expect(constraints.constrain(Size(7, 12)), Size(7, 12));
      expect(constraints.constrain(Size(15, 6)), Size(10, 8));
    });
  });
}
