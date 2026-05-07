import 'package:test/test.dart';
import 'package:t22e/src/widgets/basic/text.dart';
import 'package:t22e/src/widgets/widget.dart';
import 'package:t22e/src/widgets/enums.dart';
import 'package:t22e/src/core/surface.dart';
import 'package:t22e/src/core/style.dart';
import 'package:t22e/src/core/layout.dart';

void main() {
  group('Text', () {
    test('layout measures text width', () {
      final text = Text('Hello');
      final size = text.layout(constraints(80, 24));
      expect(size.width, 5);
      expect(size.height, 1);
    });

    test('layout for empty text returns width 0', () {
      final text = Text('');
      final size = text.layout(constraints(80, 24));
      expect(size.width, 0);
      expect(size.height, 1);
    });

    test('paint writes text to surface', () {
      final surface = Surface(10, 3);
      final text = Text('Hi');
      text.layout(constraints(10, 3));
      text.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][0].char, 'H');
      expect(surface.grid[0][1].char, 'i');
    });

    test('paint with center alignment', () {
      final surface = Surface(10, 3);
      final text = Text('Hi', align: TextAlign.center);
      text.layout(constraints(10, 3));
      text.paint(PaintingContext(surface: surface));
      // "Hi" is width 2, centered in 10 → offset 4
      expect(surface.grid[0][4].char, 'H');
      expect(surface.grid[0][5].char, 'i');
    });

    test('paint with right alignment', () {
      final surface = Surface(10, 3);
      final text = Text('Hi', align: TextAlign.right);
      text.layout(constraints(10, 3));
      text.paint(PaintingContext(surface: surface));
      // "Hi" is width 2, right-aligned in 10 → offset 8
      expect(surface.grid[0][8].char, 'H');
      expect(surface.grid[0][9].char, 'i');
    });

    test('paint applies style', () {
      final surface = Surface(10, 3);
      const style = TextStyle(bold: true);
      final text = Text('Hi', style: style);
      text.layout(constraints(10, 3));
      text.paint(PaintingContext(surface: surface));
      expect(surface.grid[0][0].style.bold, isTrue);
    });

    test('wordWrap wraps text at maxWidth', () {
      final text = Text('Hello World', wordWrap: true);
      final size = text.layout(Constraints(maxWidth: 6, maxHeight: 24));
      expect(size.height, greaterThan(1));
    });

    test('layout respects constraints', () {
      final text = Text('Hello');
      final size = text.layout(Constraints(maxWidth: 3, maxHeight: 1));
      expect(size.width, lessThanOrEqualTo(3));
    });

    test('inherited style merges with text style', () {
      final surface = Surface(10, 3);
      const inherited = TextStyle(italic: true);
      const own = TextStyle(bold: true);
      final text = Text('Hi', style: own);
      text.layout(constraints(10, 3));
      text.paint(PaintingContext(
        surface: surface,
        inheritedStyle: inherited,
      ));
      expect(surface.grid[0][0].style.bold, isTrue);
      expect(surface.grid[0][0].style.italic, isTrue);
    });
  });
}

Constraints constraints(int w, int h) => Constraints(maxWidth: w, maxHeight: h);
