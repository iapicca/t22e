import 'package:meta/meta.dart' show internal;

/// Parser state while scanning a terminal escape sequence.
@internal
enum AnsiParserState {
  /// Reading plain characters and control bytes.
  ground,

  /// Saw ESC, waiting for the next byte.
  escape,

  /// Inside a CSI sequence (`ESC [`).
  csi,
}