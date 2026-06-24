/// The public API for `t22e`, a pure-Dart Terminal User Interface (TUI) framework.
///
/// Consumers of the package should import this file. Direct imports of files
/// under `src/` are unsupported and may break in future releases.
library;

export 'src/engine/cell.dart' show Cell;
export 'src/engine/cell_buffer.dart' show CellBuffer;
export 'src/engine/cell_buffer_extensions.dart' show CellBufferExtensions;
export 'src/engine/cell_style.dart' show CellStyle;
export 'src/engine/color.dart' show AnsiColor, Color, IndexedColor;
export 'src/engine/color_extensions.dart'
    show AnsiToColor, ColorAnsi, ColorIndex, IndexedToColor;
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
