import 'package:terminal/terminal.dart' show TerminalRunner;
import 'alt_screen_manager.dart' show AltScreenManager;

class TerminalGuard {
  final TerminalRunner _runner;
  final AltScreenManager _altScreen;
  bool _restored = false;

  TerminalGuard(this._runner, this._altScreen);

  void arm() {
    _restored = false;
  }

  void restore() {
    if (_restored) return;
    _restored = true;
    _altScreen.exit();
    _runner.exitRawMode();
  }

  void disarm() {
    _restored = true;
  }

  void runGuarded<T>(T Function() body) {
    try {
      body();
    } finally {
      restore();
    }
  }

  bool get isRestored => _restored;
}
