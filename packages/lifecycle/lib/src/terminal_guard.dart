import 'package:notifier/notifier.dart'
    show InitMixin, ValueNotifier, VoidCallback;

/// Manages terminal lifecycle state — ensures cleanup runs exactly once.
///
/// When a TUI app runs in raw mode with alternate screen enabled, the terminal
/// is in a non-standard state. If the process exits without restoring the
/// terminal, the user's shell will be left in a broken state.
///
/// TerminalGuard ensures restoration runs exactly once, whether the app exits
/// normally, throws an exception, or is interrupted by a signal.
class TerminalGuard extends ValueNotifier<bool> with InitMixin {
  final VoidCallback onRestore;

  TerminalGuard({required this.onRestore}) : super(false);

  bool get isRestored => value;

  void arm() {
    checkInit();
    value = false;
  }

  void restore() {
    if (value) return;
    value = true;
    onRestore();
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
