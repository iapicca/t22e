import 'dart:async';
import 'dart:io' as io;

import 'package:notifier/notifier.dart' show Disposable, VoidCallback;
import 'terminal_guard.dart' show TerminalGuard;

/// Handles POSIX signals (SIGINT, SIGTERM, SIGTSTP, SIGCONT) for graceful shutdown.
class SignalHandler with Disposable {
  final TerminalGuard _guard;
  final VoidCallback onInterrupt;
  final VoidCallback onTerminate;
  final Stream<io.ProcessSignal> sigint;
  final Stream<io.ProcessSignal> sigterm;
  final Stream<io.ProcessSignal> sigtstp;
  final Stream<io.ProcessSignal> sigcont;

  StreamSubscription<io.ProcessSignal>? _sigintSub;
  StreamSubscription<io.ProcessSignal>? _sigtermSub;
  StreamSubscription<io.ProcessSignal>? _sigtstpSub;
  StreamSubscription<io.ProcessSignal>? _sigcontSub;

  SignalHandler({
    required this._guard,
    required this.onInterrupt,
    VoidCallback? onTerminate,
    required this.sigint,
    required this.sigterm,
    required this.sigtstp,
    required this.sigcont,
  }) : onTerminate = onTerminate ?? _defaultTerminate;

  static void _defaultTerminate() => io.exit(0);

  void install() {
    check();
    _sigintSub = sigint.listen((_) {
      onInterrupt();
    });

    _sigtermSub = sigterm.listen((_) {
      _guard.restore();
      onTerminate();
    });

    _sigtstpSub = sigtstp.listen((_) {
      _guard.restore();
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
