import 'package:test/test.dart';
import 'package:t22e/src/widgets/basic/link.dart' show Hyperlink;
import 'package:t22e/src/core/surface.dart';
import 'package:t22e/src/core/style.dart';
import 'package:t22e/src/core/layout.dart';
import 'package:t22e/src/widgets/widget.dart';

void main() {
  group('Hyperlink', () {
    test('layout returns correct size', () {
      final link = Hyperlink('https://example.com', 'Click');
      final size = link.layout(const Constraints(maxWidth: 80, maxHeight: 24));
      expect(size.width, equals(5));
      expect(size.height, equals(1));
    });

    test('paint sets hyperlink on cells', () {
      final link = Hyperlink('https://example.com', 'Hi');
      link.layout(Constraints.tight(80, 24));
      final surface = Surface(80, 24);
      final ctx = PaintingContext(surface: surface);
      link.paint(ctx);
      expect(surface.grid[0][0].hyperlink, equals('https://example.com'));
      expect(surface.grid[0][1].hyperlink, equals('https://example.com'));
    });

    test('paint uses link style by default', () {
      final link = Hyperlink('https://example.com', 'Hi');
      link.layout(Constraints.tight(80, 24));
      final surface = Surface(80, 24);
      final ctx = PaintingContext(surface: surface);
      link.paint(ctx);
      final linkStyle = TextStyle.link();
      expect(surface.grid[0][0].style.underline, equals(linkStyle.underline));
    });

    test('paint uses custom style when provided', () {
      final style = const TextStyle(bold: true);
      final link = Hyperlink('https://example.com', 'Hi', style: style);
      link.layout(Constraints.tight(80, 24));
      final surface = Surface(80, 24);
      final ctx = PaintingContext(surface: surface);
      link.paint(ctx);
      expect(surface.grid[0][0].style.bold, equals(true));
    });

    test('empty text paints nothing', () {
      final link = Hyperlink('https://example.com', '');
      link.layout(Constraints.tight(80, 24));
      final surface = Surface(80, 24);
      final ctx = PaintingContext(surface: surface);
      link.paint(ctx);
      expect(surface.grid[0][0].char, equals(' '));
    });
  });
}
