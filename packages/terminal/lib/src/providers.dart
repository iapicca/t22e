import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ffi_raw_backend.dart';
import 'io_raw_backend.dart';
import 'runner.dart';
import 'terminal_io.dart';

part 'providers.g.dart';

/// Factory provider that creates a [TerminalIo] managed by Riverpod.
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final io = container.read(terminalIoProvider);
/// io.write('Hello');
/// container.dispose();
/// ```
@riverpod
TerminalIo terminalIo(Ref ref) {
  return const TerminalIo();
}

/// Factory provider that creates an [IoRawModeBackend] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final backend = container.read(ioRawBackendProvider);
/// backend.enable();
/// container.dispose(); // automatically disables and disposes
/// ```
@riverpod
IoRawModeBackend ioRawBackend(Ref ref) {
  final backend = IoRawModeBackend();
  ref.onDispose(() {
    try {
      backend.dispose(null);
    } catch (_) {
      // dispose() calls disable() which may fail in non-terminal environments
    }
  });
  return backend;
}

/// Factory provider that creates a [FfiRawModeBackend] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final backend = container.read(ffiRawBackendProvider);
/// backend.enable();
/// container.dispose(); // automatically disables and disposes
/// ```
@riverpod
FfiRawModeBackend ffiRawBackend(Ref ref) {
  final backend = FfiRawModeBackend();
  ref.onDispose(() => backend.dispose(null));
  return backend;
}

/// Factory provider that creates a [TerminalRunner] managed by Riverpod.
///
/// Riverpod handles disposal automatically via [ref.onDispose].
/// The runner is created with default backends (Ffi + Io).
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final runner = container.read(terminalRunnerProvider);
/// runner.runWithRawMode(() {
///   // ... application code
/// });
/// container.dispose(); // automatically exits raw mode and disposes
/// ```
@riverpod
TerminalRunner terminalRunner(Ref ref) {
  final runner = TerminalRunner();
  ref.onDispose(() => runner.dispose(null));
  return runner;
}
