import '../terminal/runner.dart' show TerminalRunner;
import 'alt_screen_manager.dart' show AltScreenManager;

/// Ensures terminal state (raw mode, alt screen) is always restored on exit
class TerminalGuard {
  /// Raw mode runner
  final TerminalRunner _runner;
  /// Alt screen manager
  final AltScreenManager _altScreen;
  /// Whether the terminal has already been restored
  bool _restored = false;

  TerminalGuard(this._runner, this._altScreen);

  /// Arms the guard: resets the restored flag so restore() will take effect
  void arm() {
    _restored = false;
  }

  /// Restores terminal state (exit alt screen, disable raw mode) if not already done
  void restore() {
    if (_restored) return;
    _restored = true;
    _altScreen.exit();
    _runner.exitRawMode();
  }

  /// Disarms the guard: marks restored so future restore() calls are no-ops
  void disarm() {
    _restored = true;
  }

  /// Runs body and guarantees terminal is restored afterwards
  void runGuarded<T>(T Function() body) {
    try {
      body();
    } finally {
      restore();
    }
  }

  /// Whether the terminal state has been fully restored
  bool get isRestored => _restored;
}
