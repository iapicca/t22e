import 'package:test/test.dart';
import 'package:core/core.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('Column', () {
    test('lay out two text children vertically', () {
      final col = Column(children: [
        Text('A'),
        Text('B'),
      ]);
      final size = col.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.width, 1);
      expect(size.height, 2);
    });

    test('gap adds spacing', () {
      final col = Column(children: [
        Text('A'),
        Text('B'),
      ], gap: 2);
      final size = col.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.height, 4);
    });

    test('paint positions children at correct rows', () {
      final surface = Surface(10, 10);
      final col = Column(children: [
        Text('A'),
        Text('B'),
      ]);
      col.layout(Constraints(maxWidth: 10, maxHeight: 10));
      col.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][0].char, 'A');
      expect(surface.grid[1][0].char, 'B');
    });

    test('mainAxisAlignment center', () {
      final col = Column(
        children: [Text('A')],
        mainAxisAlignment: MainAxisAlignment.center,
      );
      final surface = Surface(10, 10);
      col.layout(Constraints(maxWidth: 10, maxHeight: 10));
      col.paint(PaintingContext(surface: surface));
      expect(surface.grid[4][0].char, 'A');
    });

    test('crossAxisAlignment center', () {
      final col = Column(
        children: [Text('AB')],
        crossAxisAlignment: CrossAxisAlignment.center,
      );
      final surface = Surface(10, 10);
      col.layout(Constraints(maxWidth: 10, maxHeight: 10));
      col.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][4].char, 'A');
      expect(surface.grid[0][5].char, 'B');
    });

    test('empty children returns zero size', () {
      final col = Column(children: []);
      final size = col.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.height, 0);
    });
  });
}
