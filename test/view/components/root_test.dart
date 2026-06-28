import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('Root widget', () {
    test('stores terminal size and child', () {
      const child = Text('hi');
      const root = Root(terminalSize: Size(80, 24), child: child);

      expect(root.terminalSize, const Size(80, 24));
      expect(root.child, same(child));
    });

    test('compiles to a SingleChildRenderObjectElement owning a RenderRoot', () {
      const root = Root(terminalSize: Size(80, 24), child: Text('hi'));
      final element = root.compile(const Context());

      expect(element, isA<SingleChildRenderObjectElement>());
      expect(element.renderObject, isA<RenderRoot>());
      expect(element.widget, same(root));
    });

    test('compiles the child recursively on mount', () {
      const child = Text('hi');
      const root = Root(terminalSize: Size(80, 24), child: child);
      final element = root.compile(const Context());

      expect(element.children, isEmpty);
      element.mount(null);
      expect(element.children, hasLength(1));
      expect(element.children.first.widget, same(child));
      expect(element.children.first.parent, same(element));
    });

    test('layout sets the root size to the terminal size', () {
      const root = Root(terminalSize: Size(80, 24), child: Text('hi'));
      final element = root.compile(const Context())..mount(null);

      element.layout(Constraints.tight(const Size(80, 24)));

      expect(element.size, const Size(80, 24));
      expect(element.renderObject.size, const Size(80, 24));
    });

    test('child render object is positioned at (0, 0) and fills the terminal', () {
      const root = Root(terminalSize: Size(30, 10), child: Text('hi'));
      final element = root.compile(const Context())..mount(null);

      element.layout(Constraints.tight(const Size(30, 10)));

      final childRender = element.renderObject.child;
      expect(childRender, isNotNull);
      expect(childRender!.size, const Size(30, 10));
      expect(childRender.offset, const Offset(0, 0));
    });

    test('child render object receives constraints equal to the terminal size', () {
      const root = Root(terminalSize: Size(12, 3), child: Text('hi'));
      final element = root.compile(const Context())..mount(null);

      element.layout(Constraints.tight(const Size(12, 3)));

      final renderRoot = element.renderObject;
      final childRender = renderRoot.child;
      expect(childRender, isNotNull);
      expect(childRender!.size, const Size(12, 3));
      expect(childRender.offset, const Offset(0, 0));
    });

    test('layout reflects a different terminal size', () {
      const root = Root(terminalSize: Size(40, 12), child: Text('hi'));
      final element = root.compile(const Context())..mount(null);

      element.layout(Constraints.tight(const Size(40, 12)));

      expect(element.size, const Size(40, 12));
      expect(element.renderObject.child!.size, const Size(40, 12));
    });
  });
}
