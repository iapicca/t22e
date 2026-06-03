import 'package:notifier/notifier.dart' show InitMixin, ValueNotifier;
import 'package:terminal/terminal.dart' show TerminalRunner;
import 'alt_screen_manager.dart' show AltScreenManager;

class TerminalGuard extends ValueNotifier<bool> with InitMixin {
  final TerminalRunner _runner;
  final AltScreenManager _altScreen;

  TerminalGuard(this._runner, this._altScreen) : super(false);

  bool get isRestored => value;

  void arm() {
    checkInit();
    value = false;
  }

  void restore() {
    if (value) return;
    value = true;
    _altScreen.exit();
    _runner.exitRawMode();
  }

  void disarm() {
    value = true;
  }

  void runGuarded<T>(T Function() body) {
    checkInit();
    try {
      body();
    } finally {
      restore();
    }
  }

  @override
  void dispose({String? message}) {
    restore();
    super.dispose(message: message);
  }
}
