import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Text widget', () {
    test('compiles to a RenderObjectElement owning a RenderText', () {
      const widget = Text('hello');
      final element = widget.compile(const Context());

      expect(element, isA<RenderObjectElement<RenderText>>());
      expect(element.widget, same(widget));
      expect((element as RenderObjectElement<RenderText>).renderObject.text,
          'hello');
    });

    test('layout reports text length by one row', () {
      const widget = Text('abcd');
      final element = widget.compile(const Context())..mount(null);

      element.layout(Constraints.loose(const Size(20, 10)));
      expect(element.size, const Size(4, 1));
    });

    test('layout reports Size(0, 1) for empty text', () {
      const widget = Text('');
      final element = widget.compile(const Context())..mount(null);

      element.layout(Constraints.loose(const Size(20, 10)));
      expect(element.size, const Size(0, 1));
    });

    test('layout clamps width to constraints', () {
      const widget = Text('abcdefghijklmnopqrstuvwxyz');
      final element = widget.compile(const Context())..mount(null);

      element.layout(Constraints.loose(const Size(10, 10)));
      expect(element.size, const Size(10, 1));
    });

    test('paint writes characters at the element offset', () {
      const widget = Text('AB');
      final element = widget.compile(const Context())..mount(null);
      element.layout(Constraints.loose(const Size(10, 10)));

      final builder = CellBufferBuilder(const Size(10, 10));
      element.paint(builder, const Offset(1, 2));
      final buffer = builder.build();

      expect(buffer.get(1, 2).character, 'A');
      expect(buffer.get(2, 2).character, 'B');
    });

    test('paint applies style attributes to every cell', () {
      const foreground = Color.red();
      const background = Color.blue();
      const styles = <CellStyle>{CellStyle.bold, CellStyle.italic};
      const widget = Text(
        'X',
        foreground: foreground,
        background: background,
        styles: styles,
      );
      final element = widget.compile(const Context())..mount(null);
      element.layout(Constraints.loose(const Size(10, 10)));

      final builder = CellBufferBuilder(const Size(10, 10));
      element.paint(builder, const Offset(0, 0));
      final buffer = builder.build();

      final cell = buffer.get(0, 0);
      expect(cell.character, 'X');
      expect(cell.foreground, foreground);
      expect(cell.background, background);
      expect(cell.styles, styles);
    });

    test('paint clips characters outside computed size', () {
      const widget = Text('ABCD');
      final element = widget.compile(const Context())..mount(null);
      element.layout(Constraints.tight(const Size(2, 1)));

      final builder = CellBufferBuilder(const Size(2, 1));
      element.paint(builder, const Offset(0, 0));
      final buffer = builder.build();

      expect(buffer.get(0, 0).character, 'A');
      expect(buffer.get(1, 0).character, 'B');
    });
  });
}
