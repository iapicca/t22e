import 'package:terminal/terminal.dart' show TerminalRunner;
import 'alt_screen_manager.dart' show AltScreenManager;

/// Ensures the terminal is restored to its original state on exit or crash.
class TerminalGuard {
  final TerminalRunner _runner;
  final AltScreenManager _altScreen;
  bool _restored = false;

  TerminalGuard(this._runner, this._altScreen);

  /// Arms the guard so the next [restore] call will take effect.
  void arm() {
    _restored = false;
  }

  /// Restores the terminal (alt screen + raw mode exit) if armed.
  void restore() {
    if (_restored) return;
    _restored = true;
    _altScreen.exit();
    _runner.exitRawMode();
  }

  /// Disarms the guard so restore becomes a no-op.
  void disarm() {
    _restored = true;
  }

  /// Runs [body] with a guarantee that restore is called in the finally block.
  void runGuarded<T>(T Function() body) {
    try {
      body();
    } finally {
      restore();
    }
  }

  /// Whether the terminal has already been restored.
  bool get isRestored => _restored;
}
