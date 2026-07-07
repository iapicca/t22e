/// Public API for `t22e`, a pure-Dart Terminal User Interface (TUI) framework.
///
/// Import this file; direct `src/` imports are unsupported and may break.
// ignore_for_file: invalid_export_of_internal_element
library;

export 'src/engine/cell.dart' show Cell;
export 'src/engine/cell_buffer.dart' show CellBuffer;
export 'src/engine/char_width.dart' show charWidth;
export 'src/engine/char_width_symbols.dart' show CharWidthSymbols;
export 'src/engine/grapheme.dart' show Grapheme;
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
export 'src/models/size_provider.dart' show terminalSizeProvider;

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

export 'src/io/input_stream_provider.dart' show inputStreamProvider;
export 'src/io/ansi_parser.dart'
    show AnsiParser, InputEvent, CharEvent, KeyEvent, UnknownEvent, Key;
export 'src/io/ansi_parser_provider.dart' show ansiParserProvider;
export 'src/io/input_value_notifier_provider.dart'
    show inputValueProvider;
export 'src/view/context.dart' show Context;
export 'src/view/context_provider.dart' show contextProvider;
export 'src/view/element.dart' show Element;
export 'src/view/widget_ref.dart' show WidgetRef;
export 'src/view/render_object_element.dart' show RenderObjectElement;
export 'src/view/single_child_render_object_element.dart'
    show SingleChildRenderObjectElement;
export 'src/view/widget.dart' show Widget;
export 'src/view/components/text.dart' show Text;
export 'src/view/components/root.dart' show Root;
export 'src/view/components/consumer.dart'
    show Consumer, ConsumerBuilder, ConsumerElement;
export 'src/view/pipeline_widget_binding.dart' show PipelineWidgetBinding;
