import 'dart:io';

import 'raw_io.dart' as io;
import 'raw_ffi.dart' as ffi;

/// Manages entering/exiting raw mode with FFI (preferred) or IO fallback
class TerminalRunner {
  /// Whether raw mode is currently active
  bool _isRawMode = false;
  /// Saved FFI termios state for restoring later
  ffi.RawModeState? _ffiState;

  /// True if the terminal is currently in raw mode
  bool get isRawMode => _isRawMode;

  /// Enters raw mode: tries FFI first, falls back to dart:io
  void enterRawMode() {
    if (_isRawMode) return;
    if (!Platform.isWindows) {
      final state = ffi.enableRawModeFfi();
      if (state != null) {
        _ffiState = state;
        _isRawMode = true;
        return;
      }
    }
    try {
      io.enableRawModeIo();
      _isRawMode = true;
    } catch (_) {}
  }

  /// Exits raw mode, restoring the saved terminal state
  void exitRawMode() {
    if (!_isRawMode) return;
    if (_ffiState != null) {
      try {
        ffi.disableRawModeFfi(_ffiState!);
      } catch (_) {}
      _ffiState = null;
    }
    try {
      io.disableRawModeIo();
    } catch (_) {}
    _isRawMode = false;
  }

  /// Runs body in raw mode, restoring terminal state when done
  void runWithRawMode<T>(T Function() body) {
    enterRawMode();
    try {
      body();
    } finally {
      exitRawMode();
    }
  }
}
