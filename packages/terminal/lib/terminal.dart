// Low-level terminal I/O: raw mode via FFI (macOS/Linux) or dart:io fallback.
export 'src/raw_io.dart' show enableRawModeIo, disableRawModeIo;
export 'src/raw_ffi.dart'
    show enableRawModeFfi, disableRawModeFfi, RawModeState;
export 'src/runner.dart' show TerminalRunner;
