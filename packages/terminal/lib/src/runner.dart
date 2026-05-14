import 'dart:io';

import 'raw_io.dart' as io;
import 'raw_ffi.dart' as ffi;

/// Manages raw mode lifecycle with FFI-first, IO-fallback strategy.
class TerminalRunner {
  bool _isRawMode = false;
  ffi.RawModeState? _ffiState;

  /// Whether raw mode is currently active.
  bool get isRawMode => _isRawMode;

  /// Enters raw mode: tries FFI, falls back to dart:io.
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

  /// Exits raw mode, restoring original terminal settings.
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

  /// Runs [body] with raw mode active, restoring on exit.
  void runWithRawMode<T>(T Function() body) {
    enterRawMode();
    try {
      body();
    } finally {
      exitRawMode();
    }
  }
}
