import 'dart:io';

import 'raw_io.dart' as io;
import 'raw_ffi.dart' as ffi;

class TerminalRunner {
  bool _isRawMode = false;
  ffi.RawModeState? _ffiState;

  bool get isRawMode => _isRawMode;

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

  void runWithRawMode<T>(T Function() body) {
    enterRawMode();
    try {
      body();
    } finally {
      exitRawMode();
    }
  }
}
