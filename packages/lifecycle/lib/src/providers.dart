import 'package:notifier/notifier.dart' show VoidCallback;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'signal_handler.dart';
import 'signal_providers.dart';
import 'terminal_guard.dart';

part 'providers.g.dart';

@riverpod
TerminalGuard terminalGuard(Ref ref, {required VoidCallback onRestore}) {
  final guard = TerminalGuard(onRestore: onRestore);
  guard.init();
  ref.onDispose(guard.dispose);
  return guard;
}

@riverpod
SignalHandler signalHandler(
  Ref ref, {
  required VoidCallback onInterrupt,
  required VoidCallback onCleanup,
}) {
  final handler = SignalHandler(
    onInterrupt: onInterrupt,
    onCleanup: onCleanup,
    sigint: ref.watch(sigintStreamProvider),
    sigterm: ref.watch(sigtermStreamProvider),
  );
  ref.onDispose(handler.dispose);
  return handler;
}
