import 'dart:async';
import 'dart:io' as io;

import 'package:notifier/notifier.dart' show Disposable, VoidCallback;

/// Handles POSIX signals (SIGINT, SIGTERM, SIGTSTP, SIGCONT) for graceful shutdown.
///
/// When a TUI app runs in raw mode with alternate screen enabled, the terminal
/// is in a non-standard state. If the process is killed (SIGTERM), suspended
/// (SIGTSTP), or interrupted (SIGINT) without restoring the terminal, the
/// user's shell will be left in a broken state.
///
/// SignalHandler ensures terminal restoration on any signal-triggered exit path.
class SignalHandler with Disposable {
  final VoidCallback onInterrupt;
  final VoidCallback onCleanup;
  final Stream<io.ProcessSignal> sigint;
  final Stream<io.ProcessSignal> sigterm;
  final Stream<io.ProcessSignal> sigtstp;
  final Stream<io.ProcessSignal> sigcont;

  StreamSubscription<io.ProcessSignal>? _sigintSub;
  StreamSubscription<io.ProcessSignal>? _sigtermSub;
  StreamSubscription<io.ProcessSignal>? _sigtstpSub;
  StreamSubscription<io.ProcessSignal>? _sigcontSub;

  SignalHandler({
    required this.onInterrupt,
    required this.onCleanup,
    required this.sigint,
    required this.sigterm,
    required this.sigtstp,
    required this.sigcont,
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

    _sigtstpSub = sigtstp.listen((_) {
      onCleanup();
    });

    _sigcontSub = sigcont.listen((_) {});
  }

  @override
  void dispose({String? message}) {
    super.dispose(message: message);
    _sigintSub?.cancel();
    _sigtermSub?.cancel();
    _sigtstpSub?.cancel();
    _sigcontSub?.cancel();
  }
}
