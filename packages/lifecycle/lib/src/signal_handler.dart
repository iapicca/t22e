import 'dart:async';
import 'dart:io';

import 'package:notifier/notifier.dart' show Disposable;
import 'package:protocol/protocol.dart' show Defaults;
import 'terminal_guard.dart' show TerminalGuard;

/// Handles POSIX signals (SIGINT, SIGTERM, SIGTSTP, SIGCONT) for graceful shutdown.

/// TODO rework with init(); dispose(); and riverpod
class SignalHandler with Disposable {
  final TerminalGuard _guard;

  /// Callback invoked on SIGINT (Ctrl+C).
  final void Function() onInterrupt;
  StreamSubscription<ProcessSignal>? _sigintSub;
  StreamSubscription<ProcessSignal>? _sigtermSub;
  StreamSubscription<ProcessSignal>? _sigtstpSub;
  StreamSubscription<ProcessSignal>? _sigcontSub;

  SignalHandler({required this._guard, required this.onInterrupt});

  /// Installs signal listeners for all handled signals.
  void install() {
    check();
    _sigintSub = ProcessSignal.sigint.watch().listen((_) {
      onInterrupt();
    });

    _sigtermSub = ProcessSignal.sigterm.watch().listen((_) {
      _guard.restore();
      exit(Defaults.exitCodeOk);
    });

    _sigtstpSub = ProcessSignal.sigtstp.watch().listen((_) {
      _guard.restore();
    });

    _sigcontSub = ProcessSignal.sigcont.watch().listen((_) {});
  }

  /// Removes all installed signal listeners.
  @override
  void dispose(String? message) {
    super.dispose(message);
    _sigintSub?.cancel();
    _sigtermSub?.cancel();
    _sigtstpSub?.cancel();
    _sigcontSub?.cancel();
  }
}
