import 'package:meta/meta.dart' show internal;

import '../engine/cell_buffer_builder.dart' show CellBufferBuilder;
import '../engine/render_object.dart' show RenderObject;
import '../models/constraints.dart' show Constraints;
import '../models/offset.dart' show Offset;
import 'element.dart' show Element;

/// Element that owns a [RenderObject].
@internal
abstract class RenderObjectElement<R extends RenderObject> extends Element {
  /// Creates an element that will instantiate a render object.
  RenderObjectElement({required super.widget, required super.context});

  /// Creates the render object managed by this element.
  R createRenderObject();

  late final R _renderObject = createRenderObject();

  /// The render object managed by this element.
  R get renderObject => _renderObject;

  @override
  void layout(Constraints constraints) {
    renderObject.layout(constraints);
    size = renderObject.size;
    offset = renderObject.offset;
  }

  @override
  void paint(CellBufferBuilder buffer, Offset offset) {
    renderObject.paint(buffer, offset + this.offset);
  }
}
