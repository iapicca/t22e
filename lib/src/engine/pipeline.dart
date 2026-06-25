import 'package:meta/meta.dart' show internal;

import '../models/constraints.dart' show Constraints;
import '../models/offset.dart' show Offset;
import '../models/size.dart' show Size;
import 'cell_buffer.dart' show CellBuffer;
import 'cell_buffer_builder.dart' show CellBufferBuilder;
import 'render_object.dart' show RenderObject;

/// Orchestrates the rendering pipeline passes.
@internal
class Pipeline {
  /// Runs the layout pass for [root] using tight [terminalSize] constraints.
  Size layout(RenderObject root, Size terminalSize) =>
      root.layout(Constraints.tight(terminalSize));

  /// Runs the paint pass for [root] into a [CellBuffer] of [terminalSize].
  ///
  /// Callers should run [layout] first so that sizes and offsets are resolved.
  CellBuffer paint(RenderObject root, Size terminalSize) {
    final builder = CellBufferBuilder(terminalSize);
    root.paint(builder, const Offset(0, 0));
    return builder.build();
  }
}
