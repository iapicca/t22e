import 'dart:async';
import 'dart:io' as io;

import 'package:notifier/notifier.dart' show Disposable, VoidCallback;

/// Handles POSIX signals (SIGINT, SIGTERM) for graceful shutdown.
///
/// When a TUI app runs in raw mode with alternate screen enabled, the terminal
/// is in a non-standard state. If the process is killed (SIGTERM) or
/// interrupted (SIGINT) without restoring the terminal, the user's shell
/// will be left in a broken state.
///
/// SignalHandler ensures terminal restoration on any signal-triggered exit path.
class SignalHandler with Disposable {
  final VoidCallback onInterrupt;
  final VoidCallback onCleanup;
  final Stream<io.ProcessSignal> sigint;
  final Stream<io.ProcessSignal> sigterm;

  StreamSubscription<io.ProcessSignal>? _sigintSub;
  StreamSubscription<io.ProcessSignal>? _sigtermSub;

  SignalHandler({
    required this.onInterrupt,
    required this.onCleanup,
    required this.sigint,
    required this.sigterm,
  });

  void install() {
    check();
    _sigintSub = sigint.listen((_) {
      onInterrupt();
    });

    _sigtermSub = sigterm.listen((_) {
      onCleanup();
      io.exit(0);
    });
  }

  @override
  void dispose({String? message}) {
    super.dispose(message: message);
    _sigintSub?.cancel();
    _sigtermSub?.cancel();
  }
}
