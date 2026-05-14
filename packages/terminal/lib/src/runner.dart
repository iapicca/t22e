import 'raw_mode_backend.dart';
import 'ffi_raw_backend.dart';
import 'io_raw_backend.dart';

class TerminalRunner {
  final List<RawModeBackend> _backends;
  RawModeBackend? _activeBackend;
  bool _isRawMode = false;

  TerminalRunner({List<RawModeBackend>? backends})
    : _backends = backends ?? [FfiRawModeBackend(), const IoRawModeBackend()];

  bool get isRawMode => _isRawMode;

  void enterRawMode() {
    if (_isRawMode) return;
    for (final backend in _backends) {
      try {
        backend.enable();
        _activeBackend = backend;
        _isRawMode = true;
        return;
      } catch (_) {}
    }
  }

  void exitRawMode() {
    if (!_isRawMode) return;
    try {
      _activeBackend?.disable();
    } catch (_) {}
    _activeBackend = null;
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
