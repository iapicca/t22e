import 'dart:async';
import 'dart:io';

import '../well_known.dart' show WellKnown;
import 'terminal_guard.dart' show TerminalGuard;

/// Installs POSIX signal handlers for SIGINT, SIGTERM, SIGTSTP, SIGCONT
class SignalHandler {
  /// Terminal guard for cleanup on signals
  final TerminalGuard _guard;
  /// Callback for SIGINT
  final void Function() onInterrupt;
  /// SIGINT subscription
  StreamSubscription<ProcessSignal>? _sigintSub;
  /// SIGTERM subscription
  StreamSubscription<ProcessSignal>? _sigtermSub;
  /// SIGTSTP subscription
  StreamSubscription<ProcessSignal>? _sigtstpSub;
  /// SIGCONT subscription
  StreamSubscription<ProcessSignal>? _sigcontSub;

  SignalHandler({required TerminalGuard guard, required this.onInterrupt})
      : _guard = guard;

  /// Installs all signal handlers
  void install() {
    _sigintSub = ProcessSignal.sigint.watch().listen((_) {
      onInterrupt();
    });

    _sigtermSub = ProcessSignal.sigterm.watch().listen((_) {
      _guard.restore();
      exit(WellKnown.exitCodeOk);
    });

    _sigtstpSub = ProcessSignal.sigtstp.watch().listen((_) {
      _guard.restore();
    });

    _sigcontSub = ProcessSignal.sigcont.watch().listen((_) {});
  }

  /// Cancels all signal subscriptions
  void dispose() {
    _sigintSub?.cancel();
    _sigtermSub?.cancel();
    _sigtstpSub?.cancel();
    _sigcontSub?.cancel();
  }
}
