import 'package:meta/meta.dart' show internal;

import '../models/constraints.dart' show Constraints;
import '../models/offset.dart' show Offset;
import '../models/size.dart' show Size;
import 'cell_buffer_builder.dart' show CellBufferBuilder;
import 'render_object.dart' show RenderObject, SingleChildRenderObject;

/// Single-child render object that sizes its child to fill the terminal.
@internal
class RenderRoot extends RenderObject with SingleChildRenderObject {
  @override
  void performLayout(Constraints constraints) {
    size = Size(constraints.maxWidth, constraints.maxHeight);
    final child = this.child;
    if (child != null) {
      child.layout(constraints);
      child.offset = const Offset(0, 0);
    }
  }

  @override
  void paint(CellBufferBuilder buffer, Offset offset) {
    final child = this.child;
    if (child != null) child.paint(buffer, offset + child.offset);
  }
}
