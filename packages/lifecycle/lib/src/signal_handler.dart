import 'dart:async';
import 'dart:io';

import 'package:protocol/protocol.dart' show Defaults;
import 'terminal_guard.dart' show TerminalGuard;

class SignalHandler {
  final TerminalGuard _guard;
  final void Function() onInterrupt;
  StreamSubscription<ProcessSignal>? _sigintSub;
  StreamSubscription<ProcessSignal>? _sigtermSub;
  StreamSubscription<ProcessSignal>? _sigtstpSub;
  StreamSubscription<ProcessSignal>? _sigcontSub;

  SignalHandler({required TerminalGuard guard, required this.onInterrupt})
    : _guard = guard;

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

  void dispose() {
    _sigintSub?.cancel();
    _sigtermSub?.cancel();
    _sigtstpSub?.cancel();
    _sigcontSub?.cancel();
  }
}
