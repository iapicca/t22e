import 'package:meta/meta.dart' show immutable;
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Element', () {
    test('stores widget, context, parent, children, size, and offset', () {
      const widget = _LeafWidget(text: 'a');
      const context = Context();
      final element = widget.compile(context);

      expect(element.widget, same(widget));
      expect(element.context, same(context));
      expect(element.parent, isNull);
      expect(element.children, isEmpty);

      element.layout(Constraints.loose(const Size(10, 10)));
      expect(element.size, const Size(1, 1));
      expect(element.offset, const Offset(0, 0));
    });

    test('mount attaches parent and child elements', () {
      const leaf = _LeafWidget(text: 'child');
      final parentWidget = _ParentWidget(child: leaf);
      final parent = parentWidget.compile(const Context());

      expect(parent.children, isEmpty);
      parent.mount(null);
      expect(parent.children, hasLength(1));
      expect(parent.children.first.widget, same(leaf));
      expect(parent.children.first.parent, same(parent));
    });

    test('RenderObjectElement delegates layout and paint to render object', () {
      const widget = _LeafWidget(text: 'hi');
      final element = widget.compile(const Context());
      element.mount(null);

      element.layout(Constraints.loose(const Size(10, 10)));
      expect(element.size, const Size(2, 1));
      expect(element.renderObject.size, const Size(2, 1));

      final builder = CellBufferBuilder(const Size(10, 10));
      element.paint(builder, const Offset(0, 0));
      final buffer = builder.build();
      expect(buffer.get(0, 0).character, 'h');
      expect(buffer.get(1, 0).character, 'i');
    });
  });
}

@immutable
class _LeafWidget extends Widget {
  const _LeafWidget({required this.text});

  final String text;

  @override
  _LeafElement compile(Context context) =>
      _LeafElement(widget: this, context: context);
}

class _LeafElement extends RenderObjectElement<RenderText> {
  _LeafElement({required _LeafWidget super.widget, required super.context});

  _LeafWidget get _widget => widget as _LeafWidget;

  @override
  RenderText createRenderObject() => RenderText(text: _widget.text);
}

@immutable
class _ParentWidget extends Widget {
  const _ParentWidget({this.child});

  final Widget? child;

  @override
  _ParentElement compile(Context context) =>
      _ParentElement(widget: this, context: context);
}

class _ParentElement extends SingleChildRenderObjectElement {
  _ParentElement({required _ParentWidget super.widget, required super.context});

  _ParentWidget get _widget => widget as _ParentWidget;

  @override
  Widget? get childWidget => _widget.child;

  @override
  RenderRoot createRenderObject() => RenderRoot();
}
