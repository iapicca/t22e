import 'dart:async';
import 'dart:io';

import 'package:protocol/protocol.dart' show Defaults;
import 'terminal_guard.dart' show TerminalGuard;

/// Handles POSIX signals (SIGINT, SIGTERM, SIGTSTP, SIGCONT) for graceful shutdown.
class SignalHandler {
  final TerminalGuard _guard;
  /// Callback invoked on SIGINT (Ctrl+C).
  final void Function() onInterrupt;
  StreamSubscription<ProcessSignal>? _sigintSub;
  StreamSubscription<ProcessSignal>? _sigtermSub;
  StreamSubscription<ProcessSignal>? _sigtstpSub;
  StreamSubscription<ProcessSignal>? _sigcontSub;

  SignalHandler({required TerminalGuard guard, required this.onInterrupt})
    : _guard = guard;

  /// Installs signal listeners for all handled signals.
  void install() {
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
  void dispose() {
    _sigintSub?.cancel();
    _sigtermSub?.cancel();
    _sigtstpSub?.cancel();
    _sigcontSub?.cancel();
  }
}
