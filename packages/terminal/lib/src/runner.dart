import 'raw_mode_backend.dart';

import 'package:notifier/notifier.dart' show Disposable;

/// Orchestrates multiple [RawModeBackend]s with fallback.
class TerminalRunner with Disposable {
  final List<RawModeBackend> backends;
  RawModeBackend? _activeBackend;
  bool _isRawMode = false;

  /// Tries backends in order.
  TerminalRunner({required this.backends});

  /// Whether raw mode is currently active.
  bool get isRawMode => _isRawMode;

  /// Enables raw mode via the first successful backend.
  void enterRawMode() {
    check();
    if (_isRawMode) return;
    for (final backend in backends) {
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

  @override
  void dispose({String? message}) {
    super.dispose(message: message);
    exitRawMode();
  }
}
