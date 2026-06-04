import 'package:test/test.dart';
import 'package:widgets/widgets.dart';

void main() {
  group('WidgetRenderer', () {
    test('renders Text widget to surface', () {
      final root = Text('Hello');
      final surface = WidgetRenderer.render(root, 10, 5);
      expect(surface.width, 10);
      expect(surface.height, 5);
      expect(surface.grid[0][0].char, 'H');
      expect(surface.grid[0][4].char, 'o');
    });

    test('renders with correct dimensions', () {
      final root = Text('Hi');
      final surface = WidgetRenderer.render(root, 80, 24);
      expect(surface.width, 80);
      expect(surface.height, 24);
    });

    test('surface contains styled text output', () {
      final root = Text('Test');
      final surface = WidgetRenderer.render(root, 20, 5);
      final plainLines = surface.toPlainLines();
      expect(plainLines[0], contains('Test'));
    });
  });
}
