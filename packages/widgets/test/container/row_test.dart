import 'package:test/test.dart';
import 'package:core/core.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('Row', () {
    test('lay out two text children', () {
      final row = Row(children: [
        Text('A'),
        Text('B'),
      ]);
      final size = row.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.width, 2);
      expect(size.height, 1);
    });

    test('gap adds spacing between children', () {
      final row = Row(children: [
        Text('A'),
        Text('B'),
      ], gap: 2);
      final size = row.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.width, 4);
    });

    test('paint positions children correctly', () {
      final surface = Surface(10, 3);
      final row = Row(children: [
        Text('A'),
        Text('B'),
      ]);
      row.layout(Constraints(maxWidth: 10, maxHeight: 3));
      row.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][0].char, 'A');
      expect(surface.grid[0][1].char, 'B');
    });

    test('mainAxisAlignment center', () {
      final row = Row(
        children: [Text('A'), Text('B')],
        mainAxisAlignment: MainAxisAlignment.center,
      );
      final surface = Surface(10, 3);
      row.layout(Constraints(maxWidth: 10, maxHeight: 3));
      row.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][4].char, 'A');
      expect(surface.grid[0][5].char, 'B');
    });

    test('mainAxisAlignment end', () {
      final row = Row(
        children: [Text('A')],
        mainAxisAlignment: MainAxisAlignment.end,
      );
      final surface = Surface(10, 3);
      row.layout(Constraints(maxWidth: 10, maxHeight: 3));
      row.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][9].char, 'A');
    });

    test('empty children returns zero size', () {
      final row = Row(children: []);
      final size = row.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.width, 0);
    });
  });
}
