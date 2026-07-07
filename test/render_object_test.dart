import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('RenderObject tree', () {
    test('RenderText is a leaf with no children', () {
      final text = RenderText(text: 'hello');
      var visited = false;
      text.visitChildren((_) => visited = true);
      expect(visited, isFalse);
    });

    test('SingleChildRenderObject manages parent and parentData', () {
      final root = RenderRoot();
      final child = RenderText(text: 'child');

      root.child = child;

      expect(child.parent, same(root));
      expect(child.parentData, isA<BoxParentData>());
      expect(child.offset, Offset(0, 0));
    });

    test('detaching a child clears parent and parentData', () {
      final root = RenderRoot();
      final child = RenderText(text: 'child');
      root.child = child;

      root.child = null;

      expect(child.parent, isNull);
      expect(child.parentData, isNull);
    });

    test('render tree can be traversed manually', () {
      final root = RenderRoot();
      final child = RenderText(text: 'hello');
      root.child = child;

      final nodes = <RenderObject>[root];
      root.visitChildren(nodes.add);

      expect(nodes, [root, child]);
    });
  });

  group('RenderText layout', () {
    test('sizes to longest line and line count', () {
      final text = RenderText(text: 'ab\n1234\nc');
      text.layout(Constraints.loose(Size(100, 100)));
      expect(text.size, Size(4, 3));
    });

    test('empty text reports Size(0, 1)', () {
      final text = RenderText(text: '');
      text.layout(Constraints.loose(Size(100, 100)));
      expect(text.size, Size(0, 1));
    });

    test('clamps to constraints', () {
      final text = RenderText(text: 'abcdefghijklmnopqrstuvwxyz');
      text.layout(Constraints.loose(Size(10, 10)));
      expect(text.size, Size(10, 1));
    });

    test('sizes CJK lines by sum of grapheme widths', () {
      final text = RenderText(text: '漢A');
      text.layout(Constraints.loose(Size(100, 100)));
      expect(text.size, Size(3, 1));
    });

    test('sizes an emoji line to width 2', () {
      final text = RenderText(text: '😀');
      text.layout(Constraints.loose(Size(100, 100)));
      expect(text.size, Size(2, 1));
    });

    test('counts combining marks as part of the base grapheme', () {
      final text = RenderText(text: 'e\u{0301}');
      text.layout(Constraints.loose(Size(100, 100)));
      expect(text.size, Size(1, 1));
    });
  });

  group('RenderRoot layout', () {
    test('sizes child to terminal bounds and assigns offset (0, 0)', () {
      final root = RenderRoot();
      final child = RenderText(text: 'hi');
      root.child = child;

      root.layout(Constraints.tight(Size(80, 24)));

      expect(root.size, Size(80, 24));
      expect(child.size, Size(80, 24));
      expect(child.offset, Offset(0, 0));
    });
  });

  group('Paint pass', () {
    test('RenderText paints characters at the correct offset', () {
      final text = RenderText(text: 'AB');
      text.layout(Constraints.loose(Size(10, 10)));

      final builder = CellBufferBuilder(Size(10, 10));
      text.paint(builder, Offset(1, 2));
      final buffer = builder.build();

      expect(buffer.get(1, 2).character, 'A');
      expect(buffer.get(2, 2).character, 'B');
    });

    test('RenderText clips characters outside computed size', () {
      final text = RenderText(text: 'ABCD');
      text.layout(Constraints.tight(Size(2, 1)));

      final builder = CellBufferBuilder(Size(2, 1));
      text.paint(builder, Offset(0, 0));
      final buffer = builder.build();

      expect(buffer.get(0, 0).character, 'A');
      expect(buffer.get(1, 0).character, 'B');
    });

    test('RenderRoot paints child at child offset', () {
      final root = RenderRoot();
      final child = RenderText(text: 'X');
      root.child = child;
      root.layout(Constraints.tight(Size(5, 5)));

      final builder = CellBufferBuilder(Size(5, 5));
      root.paint(builder, Offset(0, 0));
      final buffer = builder.build();

      expect(buffer.get(0, 0).character, 'X');
    });

    test('RenderText paints a wide glyph plus continuation marker', () {
      final text = RenderText(text: '漢A');
      text.layout(Constraints.loose(Size(10, 10)));

      final builder = CellBufferBuilder(Size(10, 10));
      text.paint(builder, Offset(0, 0));
      final buffer = builder.build();

      expect(buffer.get(0, 0).character, '漢');
      expect(buffer.get(0, 0).character.width, 2);
      expect(buffer.get(1, 0).character, ' ');
      expect(
        buffer.get(1, 0).styles,
        contains(CellStyle.continuation),
      );
      expect(buffer.get(2, 0).character, 'A');
    });

    test('RenderText clips a wide glyph that does not fit', () {
      final text = RenderText(text: '漢A');
      text.layout(Constraints.tight(Size(2, 1)));

      final builder = CellBufferBuilder(Size(2, 1));
      text.paint(builder, Offset(0, 0));
      final buffer = builder.build();

      expect(buffer.get(0, 0).character, '漢');
      expect(buffer.get(1, 0).character, ' ');
      expect(buffer.get(1, 0).styles, contains(CellStyle.continuation));
    });
  });
}
