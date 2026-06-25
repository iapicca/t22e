/// The public API for `t22e`, a pure-Dart Terminal User Interface (TUI) framework.
///
/// Consumers of the package should import this file. Direct imports of files
/// under `src/` are unsupported and may break in future releases.
// ignore_for_file: invalid_export_of_internal_element
library;

export 'src/engine/cell.dart' show Cell;
export 'src/engine/cell_buffer.dart' show CellBuffer;
export 'src/engine/cell_buffer_builder.dart' show CellBufferBuilder;
export 'src/engine/cell_buffer_builder_extensions.dart'
    show CellBufferBuilderBatch;
export 'src/engine/cell_buffer_builder_provider.dart'
    show cellBufferBuilderProvider;
export 'src/engine/ansi_writer.dart' show AnsiWriter;
export 'src/engine/ansi_writer_provider.dart' show ansiWriterProvider;
export 'src/engine/cell_buffer_extensions.dart' show CellBufferExtensions;
export 'src/engine/cell_style.dart' show CellStyle;
export 'src/engine/diff_engine.dart'
    show DiffEngine, DiffOp, DiffOpMove, DiffOpStyle, DiffOpWrite;
export 'src/engine/diff_engine_provider.dart' show diffEngineProvider;
export 'src/engine/color.dart' show AnsiColor, Color, IndexedColor;
export 'src/engine/color_extensions.dart'
    show AnsiToColor, ColorAnsi, ColorIndex, IndexedToColor;
export 'src/engine/pipeline.dart' show Pipeline;
export 'src/engine/pipeline_provider.dart' show pipelineProvider;
export 'src/engine/stdout_interface.dart' show StdoutWriter;
export 'src/engine/stdout_interface_provider.dart' show stdoutInterfaceProvider;
export 'src/engine/render_object.dart'
    show BoxParentData, ParentData, RenderObject, SingleChildRenderObject;
export 'src/engine/render_object_extensions.dart' show RenderObjectTraversal;
export 'src/engine/render_root.dart' show RenderRoot;
export 'src/engine/render_root_extensions.dart' show RenderRootBinding;
export 'src/engine/render_root_provider.dart' show renderRootProvider;
export 'src/engine/render_text.dart' show RenderText;
export 'src/engine/render_text_extensions.dart' show RenderTextLayout;
export 'src/engine/render_text_provider.dart' show renderTextProvider;
export 'src/models/constraints.dart' show Constraints;
export 'src/models/offset.dart' show Offset;
export 'src/models/rect.dart' show Rect;
export 'src/models/size.dart' show Size;

export 'src/notifier/notifier.dart'
    show
        ChangeNotifier,
        CheckDisposed,
        CheckInitialized,
        Disposable,
        Disposed,
        InitMixin,
        ValueNotifier,
        VoidCallback;

export 'src/io/stdin_stream_provider.dart' show stdinStreamProvider;
export 'src/async_value/stdin_value_notifier_provider.dart'
    show stdinValueNotifierProvider;
