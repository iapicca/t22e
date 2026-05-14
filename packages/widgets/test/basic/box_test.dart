import 'package:test/test.dart';
import 'package:core/core.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('Box', () {
    test('layout adds border to child size', () {
      final box = Box(
        child: Text('Hi'),
        padding: Insets.all(0),
      );
      final size = box.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.width, greaterThanOrEqualTo(4));
      expect(size.height, greaterThanOrEqualTo(2));
    });

    test('layout adds border and padding', () {
      final box = Box(
        child: Text('Hi'),
        padding: Insets.all(2),
      );
      final size = box.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.width, greaterThanOrEqualTo(8));
    });

    test('paint draws border corners', () {
      final surface = Surface(20, 10);
      final box = Box(
        child: Text('Hi'),
        padding: Insets.all(1),
      );
      box.layout(Constraints(maxWidth: 20, maxHeight: 10));
      box.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][0].char, '┌');
      expect(surface.grid[0][5].char, '┐');
      expect(surface.grid[4][0].char, '└');
      expect(surface.grid[4][5].char, '┘');
    });

    test('paint draws title in top border', () {
      final surface = Surface(20, 10);
      final box = Box(
        child: Text('Hello Wide World'),
        title: 'Title',
        padding: Insets.all(1),
      );
      box.layout(Constraints(maxWidth: 30, maxHeight: 10));
      box.paint(PaintingContext(surface: surface));
      expect(surface.toPlainLines()[0], contains('Title'));
    });

    test('double border style uses double chars', () {
      final surface = Surface(20, 10);
      final box = Box(
        child: Text('Hi'),
        borderStyle: BorderStyle.double,
        padding: Insets.all(1),
      );
      box.layout(Constraints(maxWidth: 20, maxHeight: 10));
      box.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][0].char, '╔');
      expect(surface.grid[0][5].char, '╗');
    });

    test('rounded border style uses rounded chars', () {
      final surface = Surface(20, 10);
      final box = Box(
        child: Text('Hi'),
        borderStyle: BorderStyle.rounded,
        padding: Insets.all(1),
      );
      box.layout(Constraints(maxWidth: 20, maxHeight: 10));
      box.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][0].char, '╭');
      expect(surface.grid[0][5].char, '╮');
    });

    test('thick border style uses thick chars', () {
      final surface = Surface(20, 10);
      final box = Box(
        child: Text('Hi'),
        borderStyle: BorderStyle.thick,
        padding: Insets.all(1),
      );
      box.layout(Constraints(maxWidth: 20, maxHeight: 10));
      box.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][0].char, '┏');
      expect(surface.grid[0][5].char, '┓');
    });

    test('child content area is inset by border + padding', () {
      final surface = Surface(20, 10);
      final box = Box(
        child: Text('Hi'),
        padding: Insets.all(1),
      );
      box.layout(Constraints(maxWidth: 20, maxHeight: 10));
      box.paint(PaintingContext(surface: surface));
      expect(surface.grid[2][2].char, 'H');
      expect(surface.grid[2][3].char, 'i');
    });

    test('layout without child returns minimum size', () {
      final box = Box();
      final size = box.layout(Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.width, 2);
      expect(size.height, 2);
    });
  });
}
