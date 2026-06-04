import 'package:test/test.dart';
import 'package:core/core.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('Spacer', () {
    test('layout takes max constraints', () {
      const spacer = Spacer();
      final constraints = Constraints(maxWidth: 80, maxHeight: 24);
      final size = spacer.layout(constraints);
      expect(size.width, 80);
      expect(size.height, 24);
    });

    test('paint does not modify surface', () {
      final surface = Surface(10, 5);
      const spacer = Spacer();
      spacer.layout(const Constraints(maxWidth: 10, maxHeight: 5));
      spacer.paint(PaintingContext(surface: surface));
      for (final row in surface.grid) {
        for (final cell in row) {
          expect(cell.char, ' ');
        }
      }
    });

    test('can be composed with other widgets', () {
      const spacer = Spacer(flex: 2);
      expect(spacer.flex, 2);
    });
  });
}
