import 'package:meta/meta.dart' show internal;

import '../models/constraints.dart' show Constraints;
import '../models/offset.dart' show Offset;
import '../models/size.dart' show Size;
import 'ansi_writer.dart' show AnsiWriter;
import 'cell.dart' show Cell;
import 'cell_buffer.dart' show CellBuffer;
import 'cell_buffer_builder.dart' show CellBufferBuilder;
import 'diff_engine.dart' show DiffEngine;
import 'render_object.dart' show RenderObject;
import 'stdout_interface.dart' show StdoutInterface;

/// Orchestrates the rendering pipeline passes and flushes output to stdout.
@internal
class Pipeline {
  /// Creates a pipeline with the given engine dependencies.
  Pipeline({
    required this._ansiWriter,
    required this._diffEngine,
    required this._stdoutInterface,
  });

  final AnsiWriter _ansiWriter;
  final DiffEngine _diffEngine;
  final StdoutInterface _stdoutInterface;
  CellBuffer? _current;

  /// Runs the layout pass for [root] using tight [terminalSize] constraints.
  Size layout(RenderObject root, Size terminalSize) =>
      root.layout(Constraints.tight(terminalSize));

  /// Paints [root] into a [CellBuffer] of [terminalSize]; run [layout] first.
  CellBuffer paint(RenderObject root, Size terminalSize) {
    final builder = CellBufferBuilder(terminalSize);
    root.paint(builder, const Offset(0, 0));
    return builder.build();
  }

  /// Renders one frame: layout, paint, diff, ANSI emit, flush, buffer copy.
  void render(RenderObject root, Size size) {
    layout(root, size);
    final target = paint(root, size);
    final current = _bufferForSize(size);
    final ops = _diffEngine.diff(target, current, size);
    final ansi = _ansiWriter.write(ops, size);
    _stdoutInterface.write(ansi);
    _current = _diffEngine.copyTarget(target);
  }

  /// Returns the current buffer, or a blank one sized for [size].
  CellBuffer _bufferForSize(Size size) {
    final buffer = _current;
    if (buffer != null && buffer.size == size) return buffer;
    return CellBuffer(
      width: size.width,
      cells: List.filled(size.area, Cell.blank),
    );
  }
}
