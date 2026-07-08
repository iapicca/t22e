import 'package:meta/meta.dart' show internal;

import '../engine/render_object.dart' show RenderObject, SingleChildRenderObject;
import 'element.dart' show Element;
import 'render_object_element.dart' show RenderObjectElement;
import 'widget.dart' show Widget;

/// Element with exactly one child.
@internal
abstract class SingleChildRenderObjectElement
    extends RenderObjectElement<SingleChildRenderObject> {
  /// Creates an element for a single-child widget.
  SingleChildRenderObjectElement({required super.widget, required super.context});

  /// The child widget to compile.
  Widget? get childWidget;

  Element? _child;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    final childWidget = this.childWidget;
    if (childWidget != null) {
      _child = childWidget.compile(context);
      _child!.mount(this);
      children.add(_child!);
      renderObject.child = _renderObjectDescendant(_child!);
    }
  }

  /// Nearest [RenderObject] among [element]'s descendants, skipping proxies.
  static RenderObject _renderObjectDescendant(Element element) {
    if (element is RenderObjectElement) return element.renderObject;
    for (final child in element.children) {
      return _renderObjectDescendant(child);
    }
    throw StateError(
      'SingleChildRenderObjectElement child produced no render object',
    );
  }
}
