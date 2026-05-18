import 'raw_mode_backend.dart';
import 'ffi_raw_backend.dart';
import 'io_raw_backend.dart';

/// Orchestrates multiple [RawModeBackend]s with fallback.
class TerminalRunner {
  final List<RawModeBackend> _backends;
  RawModeBackend? _activeBackend;
  bool _isRawMode = false;

  /// Tries backends in order; defaults to Ffi + Io backends.
  TerminalRunner({List<RawModeBackend>? backends})
    : _backends = backends ?? [FfiRawModeBackend(), const IoRawModeBackend()];

  /// Whether raw mode is currently active.
  bool get isRawMode => _isRawMode;

  /// Enables raw mode via the first successful backend.
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

  /// Disables raw mode, restoring terminal settings.
  void exitRawMode() {
    if (!_isRawMode) return;
    try {
      _activeBackend?.disable();
    } catch (_) {}
    _activeBackend = null;
    _isRawMode = false;
  }

  /// Runs [body] with raw mode enabled, restoring on exit.
  void runWithRawMode<T>(T Function() body) {
    enterRawMode();
    try {
      body();
    } finally {
      exitRawMode();
    }
  }
}
