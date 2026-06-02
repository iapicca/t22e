import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terminal/terminal.dart';

import 'alt_screen_manager.dart';
import 'signal_handler.dart';
import 'terminal_guard.dart';

part 'providers.g.dart';

/// Factory provider that creates an [AltScreenManager] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final altScreen = container.read(altScreenManagerProvider);
/// altScreen.enter();
/// container.dispose(); // automatically exits alt screen
/// ```
@riverpod
AltScreenManager altScreenManager(Ref ref) {
  final manager = AltScreenManager(const TerminalIo());
  ref.onDispose(() => manager.dispose(null));
  return manager;
}

/// Factory provider that creates a [TerminalGuard] managed by Riverpod.
///
/// The guard composes [TerminalRunner] and [AltScreenManager] to ensure
/// the terminal is restored on exit or crash.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final guard = container.read(terminalGuardProvider);
/// guard.arm();
/// guard.runGuarded(() {
///   // ... application code
/// });
/// container.dispose(); // automatically restores terminal
/// ```
@riverpod
TerminalGuard terminalGuard(Ref ref) {
  final guard = TerminalGuard(
    ref.watch(terminalRunnerProvider),
    ref.watch(altScreenManagerProvider),
  );
  ref.onDispose(() => guard.dispose(null));
  return guard;
}

/// Factory provider that creates a [SignalHandler] managed by Riverpod.
///
/// Requires an [onInterrupt] callback to be provided via the family parameter.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
///
/// Example:
/// ```dart
/// final container = ProviderContainer(
///   overrides: [
///     signalHandlerProvider(() {
///       print('Interrupted!');
///     }).overrideWith((ref) => SignalHandler(
///       guard: ref.watch(terminalGuardProvider),
///       onInterrupt: () => print('Custom interrupt handler'),
///     )),
///   ],
/// );
/// final handler = container.read(signalHandlerProvider(() {}));
/// handler.install();
/// container.dispose(); // automatically removes signal listeners
/// ```
@riverpod
SignalHandler signalHandler(Ref ref, {required void Function() onInterrupt}) {
  final handler = SignalHandler(
    guard: ref.watch(terminalGuardProvider),
    onInterrupt: onInterrupt,
  );
  ref.onDispose(() => handler.dispose(null));
  return handler;
}
